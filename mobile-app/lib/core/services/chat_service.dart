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
  
  // WebSocket connection status
  bool get isConnected => _socketClient.isConnected;
  
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
      
      // Lấy messages mới từ backend API
      final apiResponse = await _messageRepository.getMessagesByChatId(chatRoomId);
      debugPrint('ChatService: Backend returned ${apiResponse.length} messages');
      
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
      
      // Return format compatible with pagination
      return {
        'messages': allMessages,
        'hasNext': false, // For now, we load all messages
        'hasPrevious': false,
        'nextCursor': null,
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
  
  /// Load messages từ local storage
  Future<void> _loadMessagesFromStorage(String chatRoomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('messages_$chatRoomId');
      
      if (messagesJson != null) {
        final List<dynamic> messagesList = jsonDecode(messagesJson);
        final messages = messagesList.map((json) => Message.fromJson(json)).toList();
        _cachedMessages[chatRoomId] = messages;
        debugPrint('Loaded ${messages.length} messages from storage for chat $chatRoomId');
      }
    } catch (e) {
      debugPrint('Error loading messages from storage: $e');
    }
  }
  
  /// Save messages vào local storage
  Future<void> _saveMessagesToStorage(String chatRoomId, List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Only keep last 100 messages to avoid storage bloat
      final messagesToSave = messages.take(100).toList();
      final messagesJson = jsonEncode(messagesToSave.map((msg) => msg.toJson()).toList());
      
      await prefs.setString('messages_$chatRoomId', messagesJson);
      debugPrint('Saved ${messagesToSave.length} messages to storage for chat $chatRoomId');
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
      debugPrint('Sending message to chat room: $chatRoomId');
      
      // Tạo message object để gửi
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
        mediaUrl: imageUrl,
      );
      
      // Gửi qua repository (REST API)
      final sentMessage = await _messageRepository.sendMessage(message);
      
      // Thêm vào cache local ngay lập tức
      if (!_cachedMessages.containsKey(chatRoomId)) {
        _cachedMessages[chatRoomId] = [];
      }
      _cachedMessages[chatRoomId]!.insert(0, sentMessage);
      
      // Notify listeners
      _messagesController.add(_cachedMessages);
      _newMessageController.add(sentMessage);
      
      // Cập nhật last message trong chat list
      await _updateChatLastMessage(chatRoomId, sentMessage);
      
      debugPrint('Message sent successfully: ${sentMessage.id}');
      return sentMessage;
    } catch (e) {
      debugPrint('Error sending message: $e');
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
      return await _messageRepository.uploadMedia(file, MessageType.image);
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
      
      // Kết nối WebSocket
      await _socketClient.connect(userId);
      
      // Subscribe vào các streams từ SocketClient
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
      
      // Xử lý các loại message khác nhau
      switch (messageData['type']) {
        case 'MESSAGE':
          // Tin nhắn thường
          final message = Message.fromJson(messageData);
          _addMessageToCache(message);
          break;
        case 'TYPING':
          // Typing indicator - không cần lưu vào cache
          debugPrint('ChatService: Received typing indicator');
          break;
        case 'READ_RECEIPT':
          // Read receipt - cập nhật trạng thái read cho messages
          _handleReadReceipt(messageData);
          break;
        case 'MESSAGE_RECALLED':
          // Message recalled - cập nhật message bị thu hồi
          _handleMessageRecalled(messageData);
          break;
        default:
          // Các loại message khác
          debugPrint('ChatService: Unknown message type: ${messageData['type']}');
      }
    } catch (e) {
      debugPrint('ChatService: Error handling WebSocket message: $e');
    }
  }
  
  /// Thêm tin nhắn mới vào cache và notify listeners
  void _addMessageToCache(Message message) {
    // Thêm vào cache local
    if (!_cachedMessages.containsKey(message.chatId)) {
      _cachedMessages[message.chatId] = [];
    }
    
    // Kiểm tra xem message đã có trong cache chưa (tránh duplicate)
    final existingIndex = _cachedMessages[message.chatId]!
        .indexWhere((m) => m.id == message.id);
    
    if (existingIndex == -1) {
      _cachedMessages[message.chatId]!.insert(0, message);
      
      // Notify listeners
      _messagesController.add(_cachedMessages);
      _newMessageController.add(message);
      
      // Cập nhật last message trong chat list
      _updateChatLastMessage(message.chatId, message);
      
      debugPrint('ChatService: Added new message to cache: ${message.id}');
    } else {
      debugPrint('ChatService: Message already exists in cache: ${message.id}');
    }
  }
  
  /// Xử lý read receipt
  void _handleReadReceipt(Map<String, dynamic> receiptData) {
    final chatRoomId = receiptData['chatRoomId']?.toString();
    if (chatRoomId != null && _cachedMessages.containsKey(chatRoomId)) {
      // Cập nhật trạng thái read cho messages
      // TODO: Implement read receipt logic
      debugPrint('ChatService: Handling read receipt for chat: $chatRoomId');
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
        debugPrint('ChatService: Message recalled: $messageId');
      }
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
      final subscriptionId = _socketClient.subscribeToChat(chatRoomId, (messageData) {
        // Message sẽ được xử lý trong _messageSubscription stream
        debugPrint('Received message in chat $chatRoomId');
      });
      
      _chatSubscriptions[chatRoomId] = subscriptionId;
      debugPrint('Subscribed to chat room: $chatRoomId');
    } catch (e) {
      debugPrint('Error subscribing to chat $chatRoomId: $e');
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
    disconnectWebSocket();
    _socketClient.dispose();
  }
} 