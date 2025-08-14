import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/models/chat.dart';
import '../../domain/models/message.dart';
import '../../infrastructure/socket/socket_client.dart';
import '../../app/di/injection.dart';


/// Service chính để xử lý chat và tin nhắn
/// Tích hợp WebSocket để nhận/gửi tin nhắn realtime
class ChatService {
  final ChatRepository _chatRepository = getIt<ChatRepository>();
  final MessageRepository _messageRepository = getIt<MessageRepository>();
  final SocketClient _socketClient = getIt<SocketClient>();
  
  // Stream controllers để broadcast dữ liệu
  final StreamController<List<Chat>> _chatsController = StreamController<List<Chat>>.broadcast();
  final StreamController<Map<String, List<Message>>> _messagesController = 
      StreamController<Map<String, List<Message>>>.broadcast();
  final StreamController<Message> _newMessageController = StreamController<Message>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, bool>> _onlineStatusController = 
      StreamController<Map<String, bool>>.broadcast();
  // Tổng số tin nhắn chưa đọc theo từng chat để hiển thị badge tổng
  final Map<String, int> _chatUnreadCounts = <String, int>{};
  final StreamController<int> _totalUnreadCountController =
      StreamController<int>.broadcast();
  
  // Cache để lưu trữ local
  List<Chat> _cachedChats = [];
  final Map<String, List<Message>> _cachedMessages = {};
  final Map<String, String?> _chatSubscriptions = {}; // Track WebSocket subscriptions per chat
  String? _currentUserId;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _userStatusSubscription;
  
  // Getters for streams
  Stream<List<Chat>> get chatsStream => _chatsController.stream;
  Stream<Map<String, List<Message>>> get messagesStream => _messagesController.stream;
  Stream<Message> get newMessageStream => _newMessageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, bool>> get onlineStatusStream => _onlineStatusController.stream;
  Stream<int> get totalUnreadCountStream => _totalUnreadCountController.stream;

  /// Emit một sự kiện seed chat để ChatList hiển thị placeholder ngay sau khi match
  void seedChatFromMatch(
    String chatRoomId,
    String otherUserId,
    String otherUserName, {
    String? otherUserAvatar,
  }) {
    try {
      final message = Message(
        id: 'seed_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatRoomId,
        senderId: otherUserId, // giả lập tin của đối phương để tạo cuộc trò chuyện
        senderName: otherUserName,
        content: 'seed',
        timestamp: DateTime.now(),
        status: MessageStatus.read,
        type: MessageType.text,
        senderAvatar: otherUserAvatar,
      );
      _newMessageController.add(message);
      // Đặt unread = 0 để không hiện badge sau khi vừa mở
      _emitUnreadCountUpdate(chatRoomId, 0);
    } catch (e) {
      debugPrint('ChatService: Error seeding chat from match: $e');
    }
  }
  
  // WebSocket connection status
  bool get isConnected => _socketClient.isConnected;

  // Thêm getter public cho connectionStream
  Stream<bool> get connectionStream => _socketClient.connectionStream;
  
  /// Lấy danh sách conversations từ backend
  /// Sử dụng cache để cải thiện performance
  Future<List<Chat>> getChatRooms() async {
    try {
      debugPrint('Loading chat rooms from backend...');
      final chats = await _chatRepository.getAllChats();
      
      // Cache the results
      _cachedChats = chats;
      _chatsController.add(chats);
      
      debugPrint('Loaded ${chats.length} chat rooms successfully');
      return chats;
    } catch (e) {
      debugPrint('Error loading chat rooms: $e');
      // Return cached data if available
      if (_cachedChats.isNotEmpty) {
        return _cachedChats;
      }
      rethrow;
    }
  }
  
  /// Lấy chat room theo ID  
  Future<Chat> getChatRoom(String chatRoomId) async {
    try {
      debugPrint('ChatService: Getting chat room with ID: $chatRoomId');
      final chatRoom = await _chatRepository.getChatById(chatRoomId);
      debugPrint('ChatService: Chat room retrieved successfully - ID: ${chatRoom.id}');
      return chatRoom;
    } catch (e) {
      debugPrint('ChatService: Error getting chat room $chatRoomId: $e');
      debugPrint('ChatService: Error type: ${e.runtimeType}');
      rethrow;
    }
  }
  
  /// Lấy tin nhắn của một chat room với pagination
  /// Kết hợp cache local và dữ liệu từ backend API
  Future<Map<String, dynamic>> getMessages(String chatRoomId, {
    int? cursor,
    int limit = 20,
    String direction = 'NEXT',
  }) async {
    try {
      debugPrint('ChatService: Loading messages for chat room: $chatRoomId');
      
      // Load từ local storage trước để hiển thị ngay
      await _loadMessagesFromStorage(chatRoomId);
      final cachedMessages = _cachedMessages[chatRoomId] ?? [];
      debugPrint('ChatService: Found ${cachedMessages.length} cached messages');
      
      // Lấy messages mới từ backend API với pagination parameters
      final apiResult = await _messageRepository.getMessagesByChatId(
        chatRoomId, 
        cursor: cursor, 
        limit: limit, 
        direction: direction
      );
      
      // Extract messages và pagination info từ response
      final apiResponse = apiResult is List<Message> 
          ? apiResult  // Backward compatibility
          : (apiResult as Map<String, dynamic>)['messages'] as List<Message>? ?? [];
      
      final hasNext = apiResult is Map<String, dynamic> 
          ? apiResult['hasNext'] as bool? ?? false
          : false;
      final nextCursor = apiResult is Map<String, dynamic>
          ? apiResult['nextCursor'] as int?
          : null;
      
      debugPrint('ChatService: Backend returned ${apiResponse.length} messages with hasNext=$hasNext, nextCursor=$nextCursor');
      
      // Merge với cache cũ và remove duplicates
      final allMessages = <Message>[];
      final existingIds = <String>{};
      
      // Add API messages first (they are more up-to-date)
      for (final apiMsg in apiResponse) {
        allMessages.add(apiMsg);
        existingIds.add(apiMsg.id);
      }
      
      // Add cached messages that are not in API response
      for (final cachedMsg in cachedMessages) {
        if (!existingIds.contains(cachedMsg.id)) {
          allMessages.add(cachedMsg);
        }
      }
      
      // Sort by timestamp (newest first - reversed chronological order)
      allMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Cache merged messages
      _cachedMessages[chatRoomId] = allMessages;
      _messagesController.add(_cachedMessages);
      
      // Save to storage for persistence
      await _saveMessagesToStorage(chatRoomId, allMessages);
      
      debugPrint('ChatService: Final result - ${allMessages.length} total messages for chat $chatRoomId');
      
      // Return format với pagination info từ backend
      return {
        'messages': allMessages,
        'hasNext': hasNext,
        'hasPrevious': false, // Backend chưa support previous
        'nextCursor': nextCursor,
        'previousCursor': null,
        'totalCount': allMessages.length,
      };
    } catch (e) {
      debugPrint('ChatService: Error loading messages for chat $chatRoomId: $e');
      
      // Return cached data from storage if API fails
      await _loadMessagesFromStorage(chatRoomId);
      final fallbackMessages = _cachedMessages[chatRoomId] ?? [];
      debugPrint('ChatService: Using ${fallbackMessages.length} fallback messages from cache');
      
      if (fallbackMessages.isNotEmpty) {
        return {
          'messages': fallbackMessages,
          'hasNext': false,
          'hasPrevious': false,
          'nextCursor': null,
          'previousCursor': null,
          'totalCount': fallbackMessages.length,
        };
      }
      rethrow;
    }
  }
  
  /// Load messages từ local storage với filter
  Future<void> _loadMessagesFromStorage(String chatRoomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('messages_$chatRoomId');
      
      if (messagesJson != null) {
        final List<dynamic> messagesList = jsonDecode(messagesJson);
        final allMessages = messagesList.map((json) => Message.fromJson(json)).toList();
        
        // Filter out system/invalid messages from storage
        final validMessages = allMessages.where((msg) {
          final contentLower = msg.content.trim().toLowerCase();
          final senderNameLower = msg.senderName.trim().toLowerCase();
          
          return msg.type != MessageType.system && 
                 msg.senderName.trim().isNotEmpty &&
                 !senderNameLower.contains('unknown') &&
                 senderNameLower != 'null' &&
                 senderNameLower != 'system' &&
                 msg.content.trim().isNotEmpty &&
                 contentLower != 'read' &&
                 contentLower != 'false' &&
                 contentLower != 'true' &&
                 contentLower != 'messages marked as read' &&
                 !contentLower.startsWith('read_receipt');
        }).toList();
        
        _cachedMessages[chatRoomId] = validMessages;
        debugPrint('Loaded ${allMessages.length} messages from storage, filtered to ${validMessages.length} valid messages for chat $chatRoomId');
      }
    } catch (e) {
      debugPrint('Error loading messages from storage: $e');
    }
  }
  
  /// Save messages vào local storage với filter
  Future<void> _saveMessagesToStorage(String chatRoomId, List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Filter out system/invalid messages before saving
      final validMessages = messages.where((msg) {
        final contentLower = msg.content.trim().toLowerCase();
        final senderNameLower = msg.senderName.trim().toLowerCase();
        
        return msg.type != MessageType.system && 
               msg.senderName.trim().isNotEmpty &&
               !senderNameLower.contains('unknown') &&
               senderNameLower != 'null' &&
               senderNameLower != 'system' &&
               msg.content.trim().isNotEmpty &&
               contentLower != 'read' &&
               contentLower != 'false' &&
               contentLower != 'true' &&
               contentLower != 'messages marked as read' &&
               !contentLower.startsWith('read_receipt');
      }).take(100).toList(); // Only keep last 100 valid messages
      
      final messagesJson = jsonEncode(validMessages.map((msg) => msg.toJson()).toList());
      
      await prefs.setString('messages_$chatRoomId', messagesJson);
      debugPrint('Saved ${validMessages.length} valid messages to storage for chat $chatRoomId (filtered from ${messages.length})');
    } catch (e) {
      debugPrint('Error saving messages to storage: $e');
    }
  }
  
  /// Gửi tin nhắn mới
  /// Gửi qua REST API và sau đó WebSocket sẽ broadcast
  Future<Message> sendMessage({
    required String chatRoomId,
    required String content,
    required MessageType type,
    String? replyToMessageId,
    String? imageUrl,
  }) async {
    try {
      debugPrint('ChatService: Sending message to chat room: $chatRoomId - Content: $content, ReplyTo: $replyToMessageId');
      
      // Find original message details for reply functionality
      String? replyToMessage;
      String? replyToSenderName;
      
      if (replyToMessageId != null && replyToMessageId.isNotEmpty) {
        // Search for the original message in cached messages
        final cachedMessages = _cachedMessages[chatRoomId] ?? [];
        final originalMessage = cachedMessages.firstWhere(
          (msg) => msg.id == replyToMessageId,
          orElse: () => Message(
            id: '',
            chatId: chatRoomId,
            senderId: '',
            senderName: '',
            content: '',
            timestamp: DateTime.now(),
          ),
        );
        
        if (originalMessage.id.isNotEmpty) {
          replyToMessage = originalMessage.content;
          replyToSenderName = originalMessage.senderName;
          debugPrint('ChatService: Found original message for reply - Content: "$replyToMessage", Sender: "$replyToSenderName"');
        } else {
          debugPrint('ChatService: WARNING - Could not find original message with ID: $replyToMessageId');
        }
      }
      
      // Tạo message object để gửi với đầy đủ thông tin reply
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatRoomId,
        senderId: 'temp', // Sẽ được set đúng trong repository
        senderName: 'temp',
        content: content,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        type: type,
        replyToMessageId: replyToMessageId,
        replyToMessage: replyToMessage, // Include original message content
        replyToSenderName: replyToSenderName, // Include original sender name
        mediaUrl: imageUrl,
      );
      
      // Gửi qua repository (REST API) trước với đầy đủ reply information
      final sentMessage = await _messageRepository.sendMessage(message);
      debugPrint('ChatService: API response - Message ID: ${sentMessage.id}, Content: ${sentMessage.content}, Type: ${sentMessage.type.name}');
      debugPrint('ChatService: Reply info preserved - ReplyTo: ${sentMessage.replyToMessageId}, OriginalMsg: "${sentMessage.replyToMessage}", OriginalSender: "${sentMessage.replyToSenderName}"');
      
      // Thêm tin nhắn của chính user vào cache để hiển thị ngay lập tức
      if (!_cachedMessages.containsKey(chatRoomId)) {
        _cachedMessages[chatRoomId] = [];
      }
      
      // Check duplicate trước khi thêm
      final existingIndex = _cachedMessages[chatRoomId]!
          .indexWhere((m) => m.id == sentMessage.id);
          
      if (existingIndex == -1) {
        _cachedMessages[chatRoomId]!.insert(0, sentMessage);
        _messagesController.add(_cachedMessages);
        _newMessageController.add(sentMessage);
        debugPrint('ChatService: Added sent message to cache with reply info - Type: ${sentMessage.type.name}, HasReply: ${sentMessage.replyToMessageId != null}');
      } else {
        debugPrint('ChatService: WARNING - Sent message already exists in cache: ${sentMessage.id}');
      }
      
      // NOTE: Tạm tắt WebSocket gửi message để tránh duplicate messages
      // WebSocket sẽ tự động nhận message từ backend sau khi REST API thành công
      // Chỉ gửi qua WebSocket khi thực sự cần thiết (ví dụ: typing indicators)
      debugPrint('ChatService: Skipping WebSocket send to avoid duplicates - message will be broadcasted by backend');
      
      // Cập nhật last message trong chat list
      await _updateChatLastMessage(chatRoomId, sentMessage);
      
      debugPrint('ChatService: Message sent successfully: ${sentMessage.id}');
      return sentMessage;
    } catch (e) {
      debugPrint('ChatService: Error sending message: $e');
      rethrow;
    }
  }
  
  /// Cập nhật last message trong chat list
  Future<void> _updateChatLastMessage(String chatRoomId, Message message) async {
    try {
      final chatIndex = _cachedChats.indexWhere((chat) => chat.id == chatRoomId);
      if (chatIndex != -1) {
        final updatedChat = _cachedChats[chatIndex].copyWith(
          lastMessage: message,
          updatedAt: message.timestamp,
        );
        _cachedChats[chatIndex] = updatedChat;
        
        // Sort chats by last message time
        _cachedChats.sort((a, b) {
          final aTime = a.lastMessage?.timestamp ?? a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.lastMessage?.timestamp ?? b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
        
        _chatsController.add(_cachedChats);
      }
    } catch (e) {
      debugPrint('Error updating chat last message: $e');
    }
  }
  
  /// Xóa tin nhắn
  Future<void> deleteMessage(String messageId) async {
    try {
      await _messageRepository.deleteMessage(messageId);
      
      // Remove from local cache
      _cachedMessages.forEach((chatId, messages) {
        messages.removeWhere((msg) => msg.id == messageId);
      });
      
      _messagesController.add(_cachedMessages);
    } catch (e) {
      debugPrint('Error deleting message: $e');
      rethrow;
    }
  }
  
  /// Thu hồi tin nhắn
  Future<void> recallMessage(String messageId) async {
    try {
      await _messageRepository.recallMessage(messageId);
      
      // Update in local cache
      _cachedMessages.forEach((chatId, messages) {
        final index = messages.indexWhere((msg) => msg.id == messageId);
        if (index != -1) {
          messages[index] = messages[index].copyWith(
            recalled: true,
            recalledAt: DateTime.now(),
          );
        }
      });
      
      _messagesController.add(_cachedMessages);
    } catch (e) {
      debugPrint('Error recalling message: $e');
      rethrow;
    }
  }
  
  /// Đánh dấu tin nhắn đã đọc
  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      // Gọi backend API để đánh dấu đã đọc
      await _chatRepository.markMessagesAsRead(chatRoomId);
      
      // Update local cache
      if (_cachedMessages.containsKey(chatRoomId)) {
        for (var message in _cachedMessages[chatRoomId]!) {
          if (message.status != MessageStatus.read) {
            final index = _cachedMessages[chatRoomId]!.indexOf(message);
            _cachedMessages[chatRoomId]![index] = message.copyWith(status: MessageStatus.read);
          }
        }
        _messagesController.add(_cachedMessages);
      }
      
      debugPrint('ChatService: Marked messages as read for chat $chatRoomId');
    } catch (e) {
      debugPrint('ChatService: Error marking messages as read: $e');
    }
  }
  
  /// Upload file/image cho chat
  Future<String> uploadChatImage(File file, String chatRoomId) async {
    try {
      return await _messageRepository.uploadMedia(file, MessageType.image, chatRoomId);
    } catch (e) {
      debugPrint('Error uploading chat image: $e');
      rethrow;
    }
  }
  
  /// Gửi typing indicator qua WebSocket
  Future<void> sendTypingIndicator(String chatRoomId, bool isTyping) async {
    try {
      if (_socketClient.isConnected) {
        _socketClient.sendTypingIndicator(chatRoomId, isTyping);
      } else {
        debugPrint('Cannot send typing indicator - WebSocket not connected');
      }
    } catch (e) {
      debugPrint('Error sending typing indicator: $e');
    }
  }
  
  /// Kiểm tra user có online không
  Future<bool> checkUserOnlineStatus(String userId) async {
    try {
      // TODO: Implement online status check
      return false;
    } catch (e) {
      debugPrint('Error checking user online status: $e');
      return false;
    }
  }
  
  /// Initialize WebSocket connection với user ID
  Future<void> initializeWebSocket(String userId) async {
    try {
      debugPrint('Initializing WebSocket connection for user: $userId');
      _currentUserId = userId;
      
      // Subscribe vào các streams từ SocketClient (không cần connect lại)
      _setupWebSocketListeners();
      
      debugPrint('WebSocket initialized successfully');
    } catch (e) {
      debugPrint('Error initializing WebSocket: $e');
      rethrow;
    }
  }
  
  /// Setup các listeners cho WebSocket streams
  void _setupWebSocketListeners() {
    // Lắng nghe connection status
    _connectionSubscription = _socketClient.connectionStream.listen((connected) {
      debugPrint('WebSocket connection status: $connected');
      if (!connected) {
        // Clear subscriptions khi mất kết nối
        _chatSubscriptions.clear();
      }
    });
    
    // Lắng nghe tin nhắn mới từ tất cả chat rooms
    _messageSubscription = _socketClient.messageStream.listen((messageData) {
      _handleNewMessage(messageData);
    });
    
    // Lắng nghe typing indicators
    _typingSubscription = _socketClient.typingStream.listen((typingData) {
      _typingController.add(typingData);
    });
    
    // Lắng nghe user status updates (online/offline)
    _userStatusSubscription = _socketClient.userStatusStream.listen((statusData) {
      final userId = statusData['userId'] as String?;
      final isOnline = statusData['status'] == 'ONLINE';
      
      if (userId != null) {
        _onlineStatusController.add({userId: isOnline});
      }
    });
  }
  
  /// Xử lý tin nhắn mới từ WebSocket
  void _handleNewMessage(Map<String, dynamic> messageData) {
    try {
      debugPrint('ChatService: Processing WebSocket message - Type: ${messageData['type']}');
      debugPrint('ChatService: Full message data: $messageData');
      
      // Enhanced filtering for WebSocket message types
      final messageType = messageData['type']?.toString().toUpperCase() ?? '';
      final content = messageData['content']?.toString() ?? '';
      final senderName = messageData['senderName']?.toString() ?? '';
      final senderId = messageData['senderId']?.toString() ?? '';
      
      // Xử lý các loại message khác nhau
      switch (messageType) {
        case 'MESSAGE':
          // Tin nhắn thường - less restrictive validation
          if (senderId.trim().isEmpty) {
            debugPrint('ChatService: Skipping MESSAGE with empty senderId');
            return;
          }
          final message = Message.fromJson(messageData);
          if (message.type != MessageType.system) {
            _addMessageToCache(message);
            debugPrint('ChatService: Added MESSAGE to cache - ID: ${message.id}, Sender: $senderName');
          } else {
            debugPrint('ChatService: Filtered out system message from MESSAGE type');
          }
          break;
        case 'TYPING':
          // Typing indicator - không cần lưu vào cache, chỉ emit cho UI
          debugPrint('ChatService: Received typing indicator - Content: $content, SenderId: $senderId');
          break;
        case 'READ_RECEIPT':
          // Read receipt - chỉ xử lý internal logic, không emit vào UI
          debugPrint('ChatService: Processing READ_RECEIPT - not adding to message stream');
          _handleReadReceipt(messageData);
          return; // Early return để không xử lý thêm
        case 'MESSAGE_RECALLED':
        case 'RECALL':
          // Message recalled - cập nhật message bị thu hồi
          debugPrint('ChatService: Processing message recall for messageId: ${messageData['messageId']}');
          _handleMessageRecalled(messageData);
          return; // Early return vì không phải tin nhắn mới
        default:
          // Enhanced fallback processing with less strict validation
          debugPrint('ChatService: Processing unknown/default message type: $messageType');
          
          // Less restrictive validation for unknown message types
          if (messageType == 'READ_RECEIPT' || 
              content.toLowerCase() == 'read' ||
              content.toLowerCase() == 'true' ||
              content.toLowerCase() == 'false') {
            debugPrint('ChatService: Skipping system message - Type: $messageType, Content: "$content"');
            return;
          }
          
          // Try to process as regular message
          try {
            final message = Message.fromJson(messageData);
            if (message.type == MessageType.system) {
              debugPrint('ChatService: Filtered out system message from unknown type');
              return;
            }
            
            if (message.recalled) {
              debugPrint('ChatService: Received recalled message update for messageId: ${message.id}');
              _addMessageToCache(message); // This will update the existing message with recalled flag
            } else {
              _addMessageToCache(message);
              debugPrint('ChatService: Added unknown type message to cache - ID: ${message.id}, Type: $messageType');
            }
          } catch (parseError) {
            debugPrint('ChatService: Failed to parse message as Message object: $parseError');
            debugPrint('ChatService: Raw message data: $messageData');
          }
      }
    } catch (e) {
      debugPrint('ChatService: Error handling WebSocket message: $e');
      debugPrint('ChatService: Failed message data: $messageData');
    }
  }
  
  /// Thêm tin nhắn mới vào cache và notify listeners
  void _addMessageToCache(Message message) {
    // Thêm vào cache local
    if (!_cachedMessages.containsKey(message.chatId)) {
      _cachedMessages[message.chatId] = [];
    }
    
    // Enhanced duplicate check: kiểm tra bằng ID, hoặc content+sender+type+time trong vòng 60 giây
    final existingIndex = _cachedMessages[message.chatId]!
        .indexWhere((m) => 
            m.id == message.id || 
            (m.senderId == message.senderId && 
             m.content.trim() == message.content.trim() &&
             m.type == message.type &&
             m.timestamp.difference(message.timestamp).abs().inSeconds < 60));
             
    debugPrint('ChatService: Duplicate check for message ${message.id} - SenderId: ${message.senderId}, Content: "${message.content}", Type: ${message.type.name}');
    if (existingIndex != -1) {
      final existingMsg = _cachedMessages[message.chatId]![existingIndex];
      debugPrint('ChatService: Found potential duplicate - Existing ID: ${existingMsg.id}, New ID: ${message.id}');
    }
    
    if (existingIndex == -1) {
      // Chỉ thêm nếu không phải tin nhắn của chính user (đã được thêm trong sendMessage)
      // Hoặc nếu là tin nhắn từ WebSocket của user khác
      if (message.senderId != _currentUserId) {
        _cachedMessages[message.chatId]!.insert(0, message);
        
        // Notify listeners
        _messagesController.add(_cachedMessages);
        _newMessageController.add(message);
        
        // Cập nhật last message trong chat list
        _updateChatLastMessage(message.chatId, message);
        
        // Cập nhật unread count realtime khi nhận tin nhắn mới
        _updateUnreadCountForChat(message.chatId);
        
        debugPrint('ChatService: Added new message from other user to cache: ${message.id} - Content: ${message.content}');
      } else {
        debugPrint('ChatService: Skipped own message from WebSocket (already added via API): ${message.id}');
      }
    } else {
      // Message already exists, check if it's an update (like recall status)
      final existingMessage = _cachedMessages[message.chatId]![existingIndex];
      if (existingMessage.recalled != message.recalled ||
          existingMessage.content != message.content ||
          existingMessage.isRead != message.isRead) {
        
        // Update existing message with new data
        _cachedMessages[message.chatId]![existingIndex] = message;
        
        // Notify listeners about the update
        _messagesController.add(_cachedMessages);
        _newMessageController.add(message);
        
        debugPrint('ChatService: Updated existing message: ${message.id} - Recalled: ${message.recalled}, Content: ${message.content}');
      } else {
        debugPrint('ChatService: Duplicate message detected and skipped: ${message.id} - Content: ${message.content}');
      }
    }
  }
  
  /// Cập nhật unread count cho chat room khi nhận tin nhắn mới
  Future<void> _updateUnreadCountForChat(String chatRoomId) async {
    try {
      // Gọi API để lấy unread count mới nhất
      final unreadCount = await _chatRepository.getUnreadMessageCount(chatRoomId);
      
      // Emit unread count update để chat list có thể cập nhật UI
      _emitUnreadCountUpdate(chatRoomId, unreadCount);
      
      debugPrint('ChatService: Updated unread count for chat $chatRoomId: $unreadCount');
    } catch (e) {
      debugPrint('ChatService: Error updating unread count for chat $chatRoomId: $e');
      // Fallback: tăng unread count local nếu API fail
      _emitUnreadCountUpdate(chatRoomId, 1); // Tăng 1
    }
  }
  
  /// Emit unread count update để chat list cập nhật UI
  void _emitUnreadCountUpdate(String chatRoomId, int unreadCount) {
    // Tạo một message đặc biệt để notify unread count change
    final unreadUpdateMessage = Message(
      id: 'unread_update_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatRoomId,
      senderId: 'system',
      senderName: 'System',
      content: 'unread_count:$unreadCount', // Special format để identify
      timestamp: DateTime.now(),
      status: MessageStatus.read,
      type: MessageType.system,
    );
    
    // Emit vào newMessageStream để chat list nhận được
    _newMessageController.add(unreadUpdateMessage);

    // Cập nhật tổng unread để hiển thị badge ở bottom bar
    _chatUnreadCounts[chatRoomId] = unreadCount;
    final total = _chatUnreadCounts.values.fold<int>(0, (sum, v) => sum + (v > 0 ? v : 0));
    _totalUnreadCountController.add(total);
  }
  
  /// Xử lý read receipt
  void _handleReadReceipt(Map<String, dynamic> receiptData) {
    final chatRoomId = receiptData['chatRoomId']?.toString();
    if (chatRoomId != null && _cachedMessages.containsKey(chatRoomId)) {
      // Cập nhật trạng thái read cho messages
      // TODO: Implement read receipt logic
      debugPrint('ChatService: Handling read receipt for chat: $chatRoomId');
      // Reset unread của chat này về 0 và phát tổng unread mới
      _chatUnreadCounts[chatRoomId] = 0;
      final total = _chatUnreadCounts.values.fold<int>(0, (sum, v) => sum + (v > 0 ? v : 0));
      _totalUnreadCountController.add(total);
    }
  }
  
  /// Xử lý message recalled
  void _handleMessageRecalled(Map<String, dynamic> recallData) {
    final messageId = recallData['messageId']?.toString();
    final chatRoomId = recallData['chatRoomId']?.toString();
    
    if (messageId != null && chatRoomId != null && _cachedMessages.containsKey(chatRoomId)) {
      final messages = _cachedMessages[chatRoomId]!;
      final index = messages.indexWhere((msg) => msg.id == messageId);
      
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          recalled: true,
          recalledAt: DateTime.now(),
        );
        
        _messagesController.add(_cachedMessages);
        debugPrint('ChatService: Message recalled successfully: $messageId in chat $chatRoomId');
        
        // Emit as new message to update UI immediately
        _newMessageController.add(messages[index]);
      } else {
        debugPrint('ChatService: Could not find message to recall: $messageId in chat $chatRoomId');
      }
    } else {
      debugPrint('ChatService: Invalid recall data - MessageId: $messageId, ChatRoomId: $chatRoomId');
    }
  }
  
  /// Subscribe vào một chat room để nhận tin nhắn realtime
  Future<void> subscribeToChat(String chatRoomId) async {
    if (!_socketClient.isConnected) {
      debugPrint('Cannot subscribe to chat - WebSocket not connected');
      return;
    }
    
    // Nếu đã subscribe rồi thì skip
    if (_chatSubscriptions.containsKey(chatRoomId)) {
      debugPrint('Already subscribed to chat room: $chatRoomId');
      return;
    }
    
    try {
      // Chỉ subscribe, không xử lý message ở đây vì đã có _messageSubscription
      final subscriptionId = _socketClient.subscribeToChat(chatRoomId, (messageData) {
        // Không xử lý gì ở đây, message đã được xử lý trong _messageSubscription
      });
      
      _chatSubscriptions[chatRoomId] = subscriptionId;
      debugPrint('Subscribed to chat room: $chatRoomId');
      
      // Subscribe vào user status cho chat room này
      _subscribeToUserStatusForChat(chatRoomId);
    } catch (e) {
      debugPrint('Error subscribing to chat $chatRoomId: $e');
    }
  }
  
  /// Subscribe vào user status updates cho một chat room cụ thể
  /// Topic: /topic/chat/{chatRoomId}/user-status
  void _subscribeToUserStatusForChat(String chatRoomId) {
    if (!_socketClient.isConnected) return;
    
    try {
      _socketClient.subscribeToUserStatusInChat(chatRoomId, (statusData) {
        final userId = statusData['userId']?.toString();
        final status = statusData['status']?.toString();
        
        if (userId != null && status != null) {
          final isOnline = status.toUpperCase() == 'ONLINE';
          _onlineStatusController.add({userId: isOnline});
          debugPrint('ChatService: User $userId is now ${isOnline ? "online" : "offline"} in chat $chatRoomId');
        }
      });
    } catch (e) {
      debugPrint('Error subscribing to user status for chat $chatRoomId: $e');
    }
  }
  
  /// Unsubscribe khỏi một chat room
  void unsubscribeFromChat(String chatRoomId) {
    final subscriptionId = _chatSubscriptions[chatRoomId];
    if (subscriptionId != null) {
      _socketClient.unsubscribe(subscriptionId);
      _chatSubscriptions.remove(chatRoomId);
      debugPrint('Unsubscribed from chat room: $chatRoomId');
    }
  }
  
  /// Disconnect WebSocket
  void disconnectWebSocket() {
    try {
      debugPrint('Disconnecting WebSocket...');
      
      // Cancel subscriptions
      _connectionSubscription?.cancel();
      _messageSubscription?.cancel();
      _typingSubscription?.cancel();
      _userStatusSubscription?.cancel();
      
      // Clear chat subscriptions
      _chatSubscriptions.clear();
      
      // Disconnect socket
      _socketClient.disconnect();
      
      _currentUserId = null;
      _chatUnreadCounts.clear();
      _totalUnreadCountController.add(0);
    } catch (e) {
      debugPrint('Error disconnecting WebSocket: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _chatsController.close();
    _messagesController.close();
    _newMessageController.close();
    _typingController.close();
    _onlineStatusController.close();
    _totalUnreadCountController.close();
    disconnectWebSocket();
    _socketClient.dispose();
  }
  
  /// Notify chat list rằng messages đã được đọc để reset unread count
  void notifyReadReceipt(String chatRoomId, String userId) {
    try {
      // Tạo system message để notify chat list
      final readReceiptMessage = Message(
        id: 'read_receipt_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatRoomId,
        senderId: userId,
        senderName: 'System',
        content: 'Messages marked as read',
        timestamp: DateTime.now(),
        status: MessageStatus.read,
        type: MessageType.system, // System message
      );
      
      // Emit vào stream để chat list có thể nhận được
      _newMessageController.add(readReceiptMessage);

      // Đồng bộ tổng unread badge: set chat này = 0 và phát tổng mới
      _chatUnreadCounts[chatRoomId] = 0;
      final total = _chatUnreadCounts.values.fold<int>(0, (sum, v) => sum + (v > 0 ? v : 0));
      _totalUnreadCountController.add(total);
      
      debugPrint('ChatService: Notified read receipt for chat $chatRoomId');
    } catch (e) {
      debugPrint('ChatService: Error notifying read receipt: $e');
    }
  }
} 

