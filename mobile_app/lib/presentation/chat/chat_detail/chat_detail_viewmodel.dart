import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/models/message.dart';
import '../../../domain/usecases/chat/get_messages_usecase.dart';
import '../../../domain/usecases/chat/send_message_usecase.dart';
import '../../../domain/usecases/chat/delete_message_usecase.dart';
import '../../../domain/usecases/chat/recall_message_usecase.dart';
import '../../../domain/usecases/chat/upload_chat_image_usecase.dart';
import '../../../domain/usecases/chat/ai_edit_message_usecase.dart';
import '../../../app/di/injection.dart';
import '../../../core/utils/file_utils.dart';
import '../../../data/remote/profile_api.dart';
import '../../../core/services/chat_service.dart';
import '../../../domain/usecases/chat/get_chat_room_usecase.dart';
import '../../../core/services/user_status_service.dart';

class ChatDetailViewModel extends ChangeNotifier {
  final GetMessagesUseCase _getMessagesUseCase = getIt<GetMessagesUseCase>();
  final SendMessageUseCase _sendMessageUseCase = getIt<SendMessageUseCase>();
  final DeleteMessageUseCase _deleteMessageUseCase =
      getIt<DeleteMessageUseCase>();
  final RecallMessageUseCase _recallMessageUseCase =
      getIt<RecallMessageUseCase>();
  final UploadChatImageUseCase _uploadChatImageUseCase =
      getIt<UploadChatImageUseCase>();
  final ProfileApi _profileApi = getIt<ProfileApi>();
  final ChatService _chatService = getIt<ChatService>();
  final GetChatRoomUseCase _getChatRoomUseCase = getIt<GetChatRoomUseCase>();
  final UserStatusService _userStatusService = getIt<UserStatusService>();
  final AiEditMessageUseCase _aiEditMessageUseCase = getIt<AiEditMessageUseCase>();

  final ImagePicker _imagePicker = ImagePicker();

  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isLoadingMore = false; // Loading pagination
  bool _hasMoreMessages = false; // Có tin nhắn cũ hơn không
  String? _nextCursor; // Cursor cho pagination
  bool _isTyping = false;
  bool _showDateIndicator = false;
  DateTime? _currentDateIndicator;
  String? _lastActiveTime;
  String _currentUserId = '';
  String _currentUserName = '';
  String _currentChatId = '';
  Timer? _typingTimer;
  Timer? _markAsReadTimer; // Timer để debounce mark as read
  Timer? _refreshTimer; // Timer để refresh messages khi không có WebSocket

  // Pinned messages
  List<Message> _pinnedMessages = [];
  int _currentPinnedMessageIndex = 0;

  // Stream subscriptions
  StreamSubscription<Map<String, List<Message>>>? _messagesSubscription;
  StreamSubscription<Message>? _newMessageSubscription;
  StreamSubscription<Map<String, bool>>? _userStatusSubscription;

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore; // Getter cho pagination loading
  bool get hasMoreMessages => _hasMoreMessages; // Getter cho pagination status
  bool get isTyping => _isTyping;
  bool get showDateIndicator => _showDateIndicator;
  DateTime? get currentDateIndicator => _currentDateIndicator;
  String? get lastActiveTime => _lastActiveTime;
  String get currentUserId => _currentUserId;
  List<Message> get pinnedMessages => _pinnedMessages;
  int get currentPinnedMessageIndex => _currentPinnedMessageIndex;
  Message? get currentPinnedMessage =>
      _pinnedMessages.isNotEmpty
          ? _pinnedMessages[_currentPinnedMessageIndex]
          : null;

  XFile? _pendingMedia;
  String? _pendingMediaType; // 'image' | 'video'

  XFile? get pendingMedia => _pendingMedia;
  String? get pendingMediaType => _pendingMediaType;

  String? _recipientId;
  String? _recipientName; // Thêm recipient name
  bool _isRecipientOnline = false;
  DateTime? _recipientLastSeen;

  String? get recipientId => _recipientId;
  String? get recipientName => _recipientName; // Getter cho recipient name
  bool get isRecipientOnline => _isRecipientOnline;
  DateTime? get recipientLastSeen => _recipientLastSeen;

  void setPendingMedia(XFile file, String type) {
    _pendingMedia = file;
    _pendingMediaType = type;
    notifyListeners();
  }

  void clearPendingMedia() {
    _pendingMedia = null;
    _pendingMediaType = null;
    notifyListeners();
  }

  bool get hasPendingMedia => _pendingMedia != null;

  // --- TYPING INDICATOR STATE ---
  bool _isOtherUserTyping = false;
  String? _typingUserName; // Thêm tên người đang typing
  Timer? _otherUserTypingTimer;
  bool get isOtherUserTyping => _isOtherUserTyping;
  String? get typingUserName => _typingUserName; // Getter cho tên người typing

  ChatDetailViewModel() {
    _initViewModel();
  }

  Future<void> _initViewModel() async {
    // Initialize with current user information
    await _getCurrentUserInfo();

    // Setup typing indicator listener
    _setupTypingListener();

    // Subscribe to ChatService streams để nhận tin nhắn realtime
    _subscribeToStreams();
  }

  /// Subscribe vào streams từ ChatService để nhận messages realtime
  void _subscribeToStreams() {
    // Lắng nghe tin nhắn mới từ tất cả chat rooms
    _newMessageSubscription = _chatService.newMessageStream.listen((
      newMessage,
    ) {
      if (newMessage.chatId == _currentChatId) {
        // Enhanced filter for new messages
        final contentLower = newMessage.content.trim().toLowerCase();
        final senderNameLower = newMessage.senderName.trim().toLowerCase();

        if (newMessage.type == MessageType.system ||
            newMessage.senderName.trim().isEmpty ||
            senderNameLower.contains('unknown') ||
            senderNameLower == 'null' ||
            senderNameLower == 'system' ||
            newMessage.content.trim().isEmpty ||
            contentLower == 'read' ||
            contentLower == 'false' ||
            contentLower == 'true' ||
            contentLower == 'messages marked as read' ||
            contentLower.startsWith('read_receipt')) {
          debugPrint(
            'ChatDetailViewModel: Filtered out invalid new message - Sender: "${newMessage.senderName}", Content: "${newMessage.content}"',
          );
          return;
        }

        // Kiểm tra xem tin nhắn đã có trong danh sách chưa
        final existingIndex = _messages.indexWhere(
          (msg) => msg.id == newMessage.id,
        );
        if (existingIndex == -1) {
          // Thêm tin nhắn mới vào đầu danh sách
          _messages.insert(0, newMessage);
          _updateDateIndicator();
          notifyListeners();

          debugPrint(
            'ChatDetailViewModel: Added new valid message in chat ${newMessage.chatId}: ${newMessage.content}',
          );
        }
      }
    });

    // Lắng nghe cập nhật messages từ cache
    _messagesSubscription = _chatService.messagesStream.listen((messagesMap) {
      if (_currentChatId.isNotEmpty &&
          messagesMap.containsKey(_currentChatId)) {
        // Enhanced filter: loại bỏ system messages và invalid messages
        _messages =
            messagesMap[_currentChatId]!.where((msg) {
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

        debugPrint(
          'ChatDetailViewModel: Filtered ${messagesMap[_currentChatId]!.length} messages to ${_messages.length} valid messages',
        );
        _updateDateIndicator();
        notifyListeners();
      }
    });
  }

  /// Lấy thông tin current user từ backend API
  /// API endpoint: GET /user
  Future<void> _getCurrentUserInfo() async {
    try {
      final userInfo = await _profileApi.getUserInfo();

      // Lấy user ID và tên từ response
      _currentUserId = userInfo['id']?.toString() ?? '';
      _currentUserName =
          '${userInfo['firstName'] ?? ''} ${userInfo['lastName'] ?? ''}'.trim();

      if (_currentUserName.isEmpty) {
        _currentUserName = userInfo['username'] ?? 'Unknown User';
      }

      debugPrint(
        'Current user info loaded: ID=$_currentUserId, Name=$_currentUserName',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting current user info: $e');
      // Fallback values nếu không lấy được thông tin
      _currentUserId = 'unknown';
      _currentUserName = 'Current User';
    }
  }

  // Record and send audio message
  Future<void> recordAndSendAudio(String chatId) async {
    try {
      debugPrint(
        'ChatDetailViewModel: Recording audio message for chat $chatId',
      );

      // TODO: Implement actual audio recording
      // For now, simulate audio recording and send a mock audio message
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Simulate recording time

      // Create mock audio file info
      final mockAudioUrl =
          'audio_message_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Send audio message
      final sentMessage = await _sendMessageUseCase.execute(
        chatRoomId: chatId,
        content: 'Voice message', // Fallback text
        type: MessageType.audio,
        imageUrl: mockAudioUrl, // Using imageUrl field for audio URL
      );

      debugPrint(
        'ChatDetailViewModel: Audio message sent successfully: ${sentMessage.id}',
      );
    } catch (e) {
      debugPrint('ChatDetailViewModel: Error recording/sending audio: $e');
    }
  }

  // Record and send video message
  Future<void> recordAndSendVideo(String chatId) async {
    try {
      debugPrint(
        'ChatDetailViewModel: Recording video message for chat $chatId',
      );

      // TODO: Implement actual video recording
      // For now, simulate video recording and send a mock video message
      await Future.delayed(
        const Duration(seconds: 3),
      ); // Simulate recording time

      // Create mock video file info
      final mockVideoUrl =
          'video_message_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Send video message
      final sentMessage = await _sendMessageUseCase.execute(
        chatRoomId: chatId,
        content: 'Video message', // Fallback text
        type: MessageType.video,
        imageUrl: mockVideoUrl, // Using imageUrl field for video URL
      );

      debugPrint(
        'ChatDetailViewModel: Video message sent successfully: ${sentMessage.id}',
      );
    } catch (e) {
      debugPrint('ChatDetailViewModel: Error recording/sending video: $e');
    }
  }

  /// Cập nhật avatar cho các sender trong messages
  /// Backend đã trả về senderAvatar, chỉ cần verify và log
  Future<void> _updateChatParticipantAvatars(String chatRoomId) async {
    try {
      if (_messages.isEmpty) {
        debugPrint('No messages to update avatars for');
        return;
      }

      // Kiểm tra xem backend đã trả về avatar chưa
      int messagesWithAvatar = 0;
      int messagesWithoutAvatar = 0;

      for (final message in _messages) {
        if (message.senderId != _currentUserId) {
          if (message.senderAvatar != null &&
              message.senderAvatar!.isNotEmpty) {
            messagesWithAvatar++;
            debugPrint(
              'Message ${message.id} from ${message.senderName} has avatar: ${message.senderAvatar}',
            );
          } else {
            messagesWithoutAvatar++;
            debugPrint(
              'Message ${message.id} from ${message.senderName} missing avatar',
            );
          }
        }
      }

      debugPrint(
        'Avatar status: $messagesWithAvatar messages have avatar, $messagesWithoutAvatar missing avatar',
      );

      // Backend đã cung cấp avatar trong response, không cần fetch thêm
      // Avatar sẽ được sử dụng trực tiếp từ message.senderAvatar
    } catch (e) {
      debugPrint('Error checking chat participant avatars: $e');
    }
  }

  /// Setup listeners cho typing indicators từ WebSocket
  void _setupTypingListener() {
    // Subscribe vào typing stream từ ChatService
    _chatService.typingStream.listen((typingData) {
      debugPrint('ChatDetailViewModel: Received typing data: $typingData');
      
      final chatRoomId = typingData['chatRoomId']?.toString();
      final senderId = typingData['senderId']?.toString();
      final messageType = typingData['type']?.toString();
      
      // Chuẩn hóa logic nhận typing từ backend
      bool isTyping = false;
      if (typingData.containsKey('typing')) {
        isTyping = typingData['typing'] == true;
      } else if (typingData.containsKey('content')) {
        // Nếu backend gửi content: "true"/"false"
        isTyping = typingData['content'] == 'true';
      }
      
      debugPrint('ChatDetailViewModel: Processing typing - ChatRoomId: $chatRoomId, SenderId: $senderId, IsTyping: $isTyping, Type: $messageType');
      
      // Chỉ cập nhật typing status nếu là từ user khác và trong current chat
      if (chatRoomId == _currentChatId &&
          senderId != null &&
          senderId != _currentUserId &&
          messageType == 'TYPING') {
        updateRecipientTypingStatus(isTyping);
        debugPrint(
          'ChatDetailViewModel: User $senderId is ${isTyping ? "typing" : "not typing"} in chat $chatRoomId',
        );
      } else {
        debugPrint('ChatDetailViewModel: Skipping typing update - ChatRoomId: $chatRoomId vs $_currentChatId, SenderId: $senderId vs $_currentUserId, Type: $messageType');
      }
    });
  }

  // Load chat messages from usecase
  Future<void> loadMessages(String chatId) async {
    try {
      _isLoading = true;
      _currentChatId = chatId;
      notifyListeners();

      // Clear any cached invalid messages for this chat
      await _clearInvalidMessagesFromCache(chatId);

      // Đảm bảo có current user info trước khi setup WebSocket
      if (_currentUserId.isEmpty) {
        await _getCurrentUserInfo();
      }

      // Lấy chat room để xác định recipientId và recipientName
      final chatRoom = await _getChatRoomUseCase.execute(chatId);
      if (chatRoom.user1Id == _currentUserId) {
        _recipientId = chatRoom.user2Id;
        _recipientName = chatRoom.user2Name;
      } else {
        _recipientId = chatRoom.user1Id;
        _recipientName = chatRoom.user1Name;
      }
      debugPrint('ChatDetailViewModel: Recipient info - ID: $_recipientId, Name: $_recipientName');
      // Lấy trạng thái online ban đầu
      if (_recipientId != null && _recipientId!.isNotEmpty) {
        _isRecipientOnline = await _userStatusService.getUserOnlineStatus(
          _recipientId!,
        );
        notifyListeners();
        // Lắng nghe realtime
        _userStatusSubscription?.cancel();
        _userStatusSubscription = _userStatusService.statusStream.listen((
          statusMap,
        ) {
          if (statusMap.containsKey(_recipientId)) {
            _isRecipientOnline = statusMap[_recipientId!] ?? false;
            notifyListeners();
          }
        });
      }

      // Initialize WebSocket connection với current user ID
      if (_currentUserId.isNotEmpty) {
        debugPrint(
          'ChatDetailViewModel: Setting up WebSocket for user $_currentUserId in chat $chatId',
        );
        try {
          await _chatService.initializeWebSocket(_currentUserId);
          await _chatService.subscribeToChat(chatId);
          debugPrint(
            'ChatDetailViewModel: WebSocket setup completed successfully',
          );
          // Stop periodic refresh nếu WebSocket thành công
          _stopPeriodicRefresh();
        } catch (e) {
          debugPrint('ChatDetailViewModel: WebSocket setup failed: $e');
          // Fallback: Start periodic refresh khi WebSocket không available
          _startPeriodicRefresh(chatId);
        }
      } else {
        debugPrint(
          'ChatDetailViewModel: Warning - No current user ID available for WebSocket',
        );
      }

      // Get messages from usecase với pagination info
      final result = await _getMessagesUseCase.execute(chatId, limit: 20);
      final messages = result['messages'] as List<Message>;
      final hasNext = result['hasNext'] as bool? ?? false;
      final nextCursor = result['nextCursor'] as int?;

      // Process messages
      _messages = messages;
      _hasMoreMessages = hasNext;
      _nextCursor = nextCursor?.toString();

      // Update date indicator
      _updateDateIndicator();

      _isLoading = false;
      notifyListeners();

      // Check avatar status trong messages (async để không block UI)
      _updateChatParticipantAvatars(chatId)
          .then((_) {
            debugPrint('Avatar check completed for chat $chatId');
          })
          .catchError((e) {
            debugPrint('Avatar check failed for chat $chatId: $e');
          });

      debugPrint('Loaded ${messages.length} messages for chat $chatId');
    } catch (e) {
      _isLoading = false;
      debugPrint('Error loading messages: $e');
      notifyListeners();
    }
  }

  /// Refresh messages từ server
  Future<void> refreshMessages() async {
    if (_currentChatId.isNotEmpty) {
      await loadMessages(_currentChatId);
    }
  }

  /// Load thêm tin nhắn cũ hơn (pagination) khi user scroll lên đầu
  /// Preserve scroll position để tin nhắn không bị nhảy vị trí
  Future<void> loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages || _nextCursor == null) {
      return; // Đã đang load hoặc không còn tin nhắn cũ hơn
    }

    try {
      _isLoadingMore = true;

      // Store current message count để preserve scroll position
      final previousMessageCount = _messages.length;
      notifyListeners();

      debugPrint(
        'ChatDetailViewModel: Loading more messages with cursor: $_nextCursor (current count: $previousMessageCount)',
      );

      // Load tin nhắn cũ hơn từ API với cursor pagination
      final result = await _getMessagesUseCase.execute(
        _currentChatId,
        cursor: int.tryParse(_nextCursor!),
        limit: 20,
        direction: 'NEXT', // Load tin nhắn cũ hơn
      );

      final oldMessages = result['messages'] as List<Message>;
      final hasNext = result['hasNext'] as bool? ?? false;
      final nextCursor = result['nextCursor'] as int?;

      if (oldMessages.isNotEmpty) {
        // Filter old messages để loại bỏ system/invalid messages
        final validOldMessages =
            oldMessages.where((msg) {
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

        debugPrint(
          'ChatDetailViewModel: Filtered ${oldMessages.length} old messages to ${validOldMessages.length} valid messages',
        );

        // IMPORTANT: Append to end of list để preserve scroll position
        // Với reverse=true ListView, index 0 là newest, index cuối là oldest
        final allMessages = [..._messages, ...validOldMessages];

        // Remove duplicates dựa trên ID
        final uniqueMessages = <Message>[];
        final seenIds = <String>{};

        for (final message in allMessages) {
          if (!seenIds.contains(message.id)) {
            uniqueMessages.add(message);
            seenIds.add(message.id);
          }
        }

        _messages = uniqueMessages;
        _hasMoreMessages = hasNext;
        _nextCursor = nextCursor?.toString();

        final newMessageCount = _messages.length;
        final addedCount = newMessageCount - previousMessageCount;

        debugPrint(
          'ChatDetailViewModel: Added $addedCount valid messages. Total: $newMessageCount (preserved position for existing messages)',
        );
      }

      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      debugPrint('ChatDetailViewModel: Error loading more messages: $e');
      notifyListeners();
    }
  }

  /// Đánh dấu tin nhắn đã đọc trong chat detail
  /// Chỉ gọi API để đánh dấu đã đọc, không thay đổi UI messages
  Future<void> markMessagesAsRead(String chatId) async {
    // Cancel timer cũ nếu có
    _markAsReadTimer?.cancel();

    // Debounce: chỉ gọi API sau 1 giây không có request mới
    _markAsReadTimer = Timer(const Duration(seconds: 1), () async {
      try {
        debugPrint(
          'ChatDetailViewModel: Marking messages as read for chat: $chatId',
        );

        // Chỉ gọi API để mark messages as read - không thay đổi UI messages
        await _chatService.markMessagesAsRead(chatId);

        // Notify chat list để reset unread count và bold text
        _chatService.notifyReadReceipt(chatId, _currentUserId);

        debugPrint(
          'ChatDetailViewModel: Successfully marked messages as read for chat: $chatId',
        );
      } catch (e) {
        debugPrint(
          'ChatDetailViewModel: ERROR marking messages as read for chat $chatId: $e',
        );
        debugPrint(
          'ChatDetailViewModel: This may affect unread message display in chat list',
        );
      }
    });
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Offline';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastSeenDate = DateTime(lastSeen.year, lastSeen.month, lastSeen.day);

    if (now.difference(lastSeen).inMinutes < 1) {
      return 'Online';
    } else if (now.difference(lastSeen).inMinutes < 60) {
      return 'Active ${now.difference(lastSeen).inMinutes} min ago';
    } else if (lastSeenDate == today) {
      return 'Active today at ${DateFormat('h:mm a').format(lastSeen)}';
    } else if (lastSeenDate == yesterday) {
      return 'Active yesterday at ${DateFormat('h:mm a').format(lastSeen)}';
    } else {
      return 'Active on ${DateFormat('MMM d').format(lastSeen)}';
    }
  }

  // Public method để UI có thể gọi
  String formatLastSeen(DateTime? lastSeen) {
    return _formatLastSeen(lastSeen);
  }

  void _updateDateIndicator() {
    if (_messages.isNotEmpty) {
      _showDateIndicator = true;
      _currentDateIndicator = _messages.first.timestamp;
      notifyListeners();
    } else {
      _showDateIndicator = false;
      notifyListeners();
    }
  }

  // Send a new text message
  Future<void> sendMessage({
    required String chatId,
    required String message,
    String? replyToMessageId,
    String? replyToSender,
  }) async {
    try {
      debugPrint(
        'ChatDetailViewModel: Sending message - ChatId: $chatId, Content: "$message", ReplyTo: $replyToMessageId, ReplyToSender: $replyToSender',
      );

      final sentMessage = await _sendMessageUseCase.execute(
        chatRoomId: chatId,
        content: message,
        type: MessageType.text,
        replyToMessageId: replyToMessageId,
      );

      debugPrint(
        'ChatDetailViewModel: Message sent successfully: ${sentMessage.id} with reply: $replyToMessageId',
      );
    } catch (e) {
      debugPrint('ChatDetailViewModel: Error sending message: $e');
      // Error handling sẽ được xử lý trong UI
    }
  }

  // Cache for AI edit results to improve performance (avoid duplicate calls)
  final Map<String, String> _aiEditCache = {};
  
  // Request AI to edit a message with timeout, cache and graceful fallback
  Future<String> requestAiEdit(
    String original,
    String prompt, {
    int variant = 0, // >0 when user clicks "Sửa lại"
    bool bypassCache = false,
  }) async {
    if (original.trim().isEmpty) return original;
    if (prompt.trim().isEmpty) return original;
    if (_recipientId == null || _recipientId!.isEmpty) return original;

    // Create cache key (include variant to produce different suggestions)
    final cacheKey = '${original.hashCode}_${prompt.hashCode}_v$variant';
    
    // Check cache first
    if (!bypassCache && _aiEditCache.containsKey(cacheKey)) {
      debugPrint('AI Edit: Using cached result');
      return _aiEditCache[cacheKey]!;
    }

    try {
      // Add timeout to prevent long waiting
      final result = await _aiEditMessageUseCase.execute(
        originalMessage: original,
        editPrompt: prompt,
        receiverId: _recipientId!,
      ).timeout(
        const Duration(seconds: 3), // tighter timeout for snappier UX
        onTimeout: () {
          debugPrint('AI Edit: Request timeout');
          throw TimeoutException('AI edit request timed out', const Duration(seconds: 3));
        },
      );
      
      // Cache the result
      _aiEditCache[cacheKey] = result.editedMessage;
      
      // Limit cache size to prevent memory issues
      if (_aiEditCache.length > 50) {
        final oldestKey = _aiEditCache.keys.first;
        _aiEditCache.remove(oldestKey);
      }
      
      // If result equals original in a retry case, provide a quick local variant to avoid feeling stuck
      if (variant > 0 && _normalize(result.editedMessage) == _normalize(original)) {
        return _localRefine(original, prompt, variant);
      }
      return result.editedMessage;
    } catch (e) {
      debugPrint('AI Edit: Error - $e');
      // Fast local fallback (<=100ms) to keep UX responsive without backend changes
      final fallback = _localRefine(original, prompt, variant);
      return fallback.isNotEmpty ? fallback : original;
    }
  }

  // Simple client-side refinement to keep UX responsive when AI times out
  String _localRefine(String original, String prompt, int variant) {
    final text = original.trim();
    if (text.isEmpty) return text;

    final lowerPrompt = prompt.toLowerCase();

    // Small transformations to make output feel improved and different
    String result = text;
    result = _capitalizeSentence(result);
    result = _removeExcessDots(result);

    // Apply style based on prompt
    if (lowerPrompt.contains('lịch sự') || lowerPrompt.contains('ấm áp') || lowerPrompt.contains('polite')) {
      result = _addPoliteTone(result, variant);
    } else if (lowerPrompt.contains('trang trọng') || lowerPrompt.contains('formal')) {
      result = _addFormalTone(result, variant);
    } else if (lowerPrompt.contains('ngắn gọn') || lowerPrompt.contains('súc tích') || lowerPrompt.contains('concise')) {
      result = _makeConcise(result);
    } else if (lowerPrompt.contains('hài hước') || lowerPrompt.contains('humor')) {
      result = _addLightHumor(result, variant);
    } else if (lowerPrompt.contains('tự tin') || lowerPrompt.contains('confident')) {
      result = _makeConfident(result, variant);
    } else if (lowerPrompt.contains('thả thính') || lowerPrompt.contains('flirty')) {
      result = _makeFlirty(result, variant);
    }

    // Ensure difference from original for retry
    if (_normalize(result) == _normalize(original)) {
      result = '$result${variant % 2 == 0 ? " 🙂" : " 😉"}';
    }
    return result;
  }

  String _capitalizeSentence(String s) {
    if (s.isEmpty) return s;
    final trimmed = s.trim();
    final first = trimmed[0].toUpperCase();
    final rest = trimmed.substring(1);
    return '$first$rest';
  }

  String _removeExcessDots(String s) {
    return s.replaceAll(RegExp(r"\.{3,}"), '…');
  }

  String _addPoliteTone(String s, int variant) {
    final prefixes = [
      'Mình nghĩ là',
      'Theo mình thì',
      'Nếu được',
      'Mình rất muốn',
    ];
    final suffixes = [
      ' nhé.',
      ' bạn nhé.',
      ' nha.',
      ' ạ.',
    ];
    final p = prefixes[variant % prefixes.length];
    final sf = suffixes[(variant + 1) % suffixes.length];
    return '$p ${_lowerFirst(s)}$sf';
  }

  String _addFormalTone(String s, int variant) {
    final prefixes = ['Xin phép', 'Theo tôi', 'Thành thật mà nói'];
    final p = prefixes[variant % prefixes.length];
    return '$p, ${_lowerFirst(s)}.';
  }

  String _makeConcise(String s) {
    // Remove filler phrases and keep sentence short
    var r = s
        .replaceAll(RegExp(r"\bkiểu như là\b", caseSensitive: false), '')
        .replaceAll(RegExp(r"\bcó lẽ\b", caseSensitive: false), '')
        .replaceAll(RegExp(r"\bthật ra\b", caseSensitive: false), '')
        .trim();
    if (!r.endsWith('.') && !r.endsWith('!') && !r.endsWith('?')) r = '$r.';
    return r;
  }

  String _addLightHumor(String s, int variant) {
    final tails = [' 😄', ' 😅', ' 😁'];
    return '$s${tails[variant % tails.length]}';
  }

  String _makeConfident(String s, int variant) {
    final openers = ['Mình chủ động nhé:', 'Mình đề xuất thế này:', 'Mình có ý này:'];
    return '${openers[variant % openers.length]} ${_lowerFirst(s)}';
  }

  String _makeFlirty(String s, int variant) {
    final tails = [' 😉', ' ✨', ' 😊'];
    return '$s${tails[variant % tails.length]}';
  }

  String _lowerFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toLowerCase() + s.substring(1);
  }

  String _normalize(String s) => s.trim().toLowerCase();

  // Edit an existing message
  Future<void> editMessage(String messageId, String newContent) async {
    try {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        // Optimistic update
        final updatedMessage = _messages[index].copyWith(
          content: newContent,
          isEdited: true,
          editedAt: DateTime.now(),
        );

        _messages[index] = updatedMessage;
        notifyListeners();

        // TODO: Implement edit message functionality
        // await _messageRepository.updateMessage(updatedMessage);
      }
    } catch (e) {
      debugPrint('Error editing message: $e');
      // Revert changes if failed
      await refreshMessages();
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _deleteMessageUseCase.execute(messageId);
      debugPrint('Message deleted successfully: $messageId');
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }

  // Recall a message (within 30 minutes)
  Future<void> recallMessage(String messageId) async {
    try {
      await _recallMessageUseCase.execute(messageId);
      debugPrint('Message recalled successfully: $messageId');
    } catch (e) {
      debugPrint('Error recalling message: $e');
    }
  }

  // Add reaction to message
  Future<void> addReaction(String messageId, String reaction) async {
    try {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        // Add reaction locally
        final updatedMessage = _messages[index].copyWith(
          reactions: {..._messages[index].reactions, _currentUserId: reaction},
        );

        _messages[index] = updatedMessage;
        notifyListeners();

        // TODO: Implement reaction functionality
        // await _messageRepository.updateMessage(updatedMessage);
      }
    } catch (e) {
      debugPrint('Error adding reaction: $e');
    }
  }

  // Scroll to specific message (used for reply)
  void scrollToMessage(String messageId) {
    // Implementation would depend on your UI setup
    // This is a placeholder that would be connected to the UI
    debugPrint('Scrolling to message: $messageId');
  }

  // ATTACHMENT HANDLING

  // Select image from gallery
  Future<void> selectImageFromGallery(String chatId) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        setPendingMedia(image, 'image');
      }
    } catch (e) {
      debugPrint('Error selecting image: $e');
    }
  }

  // Take picture from camera
  Future<void> takePicture(String chatId) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (image != null) {
        setPendingMedia(image, 'image');
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  // Select video from gallery
  Future<void> selectVideoFromGallery(String chatId) async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null) {
        setPendingMedia(video, 'video');
      }
    } catch (e) {
      debugPrint('Error selecting video: $e');
    }
  }

  // Record video from camera
  Future<void> recordVideoFromCamera(String chatId) async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null) {
        setPendingMedia(video, 'video');
      }
    } catch (e) {
      debugPrint('Error recording video: $e');
    }
  }

  // Select document
  Future<void> selectDocument(String chatId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? result = await picker.pickMedia();

      if (result != null) {
        final file = File(result.path);
        final fileName = result.name;
        final fileSize = await FileUtils.getFileSizeString(file: file);

        await _sendMediaMessage(
          chatId: chatId,
          file: file,
          type: MessageType.file,
          caption: fileName,
          fileInfo: '$fileName • $fileSize',
        );
      }
    } catch (e) {
      debugPrint('Error selecting document: $e');
    }
  }

  // Share current location
  Future<void> shareCurrentLocation(String chatId) async {
    try {
      final permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final locationMessage =
          'Location: ${position.latitude}, ${position.longitude}';

      await sendMessage(chatId: chatId, message: locationMessage);

      // In a real app, you might want to send a specialized location message type
      // with a map preview image, etc.
    } catch (e) {
      debugPrint('Error sharing location: $e');
    }
  }

  // Helper method to send media messages
  Future<void> _sendMediaMessage({
    required String chatId,
    required File file,
    required MessageType type,
    required String caption,
    String? fileInfo,
  }) async {
    try {
      // Upload file and get remote URL
      final mediaUrl = await _uploadChatImageUseCase.execute(file, chatId);

      // Send message with media
      final sentMessage = await _sendMessageUseCase.execute(
        chatRoomId: chatId,
        content: caption,
        type: type,
        imageUrl: mediaUrl,
      );

      debugPrint('Media message sent successfully: ${sentMessage.id}');
    } catch (e) {
      debugPrint('Error sending media message: $e');
    }
  }

  // Gửi media message (sau khi user nhấn gửi)
  Future<void> sendPendingMedia(String chatId) async {
    if (_pendingMedia == null || _pendingMediaType == null) {
      debugPrint('ChatDetailViewModel: ERROR - No pending media to send');
      return;
    }

    try {
      debugPrint(
        'ChatDetailViewModel: Sending pending media - Type: $_pendingMediaType, File: ${_pendingMedia!.path}',
      );
      final file = File(_pendingMedia!.path);
      final type =
          _pendingMediaType == 'image' ? MessageType.image : MessageType.video;

      // Upload media first
      debugPrint('ChatDetailViewModel: Uploading media file...');
      final mediaUrl = await _uploadChatImageUseCase.execute(file, chatId);
      debugPrint(
        'ChatDetailViewModel: Media uploaded successfully - URL: $mediaUrl',
      );

      // Send message with media URL
      debugPrint('ChatDetailViewModel: Sending message with media URL...');
      await _sendMessageUseCase.execute(
        chatRoomId: chatId,
        content: '', // Empty content for media messages
        type: type,
        imageUrl: mediaUrl,
      );

      debugPrint('ChatDetailViewModel: Media message sent successfully');
      clearPendingMedia();
    } catch (e) {
      debugPrint('ChatDetailViewModel: ERROR sending pending media: $e');
      debugPrint(
        'ChatDetailViewModel: ERROR details - ChatId: $chatId, MediaType: $_pendingMediaType',
      );

      // Don't clear pending media on error so user can retry
      // clearPendingMedia();
    }
  }

  // CALL FUNCTIONALITY

  Future<void> initiateVoiceCall(String chatId) async {
    // Implementation would connect to your calling service
    debugPrint('Initiating voice call for chat: $chatId');
  }

  Future<void> initiateVideoCall(String chatId) async {
    // Implementation would connect to your calling service
    debugPrint('Initiating video call for chat: $chatId');
  }

  // Typing indicator functions - Gửi typing status qua WebSocket
  void setUserTyping(bool isTyping) {
    // Cancel any existing timer
    _typingTimer?.cancel();

    if (isTyping && _currentChatId.isNotEmpty) {
      // Gửi typing indicator qua ChatService/WebSocket
      _chatService.sendTypingIndicator(_currentChatId, true);
      debugPrint(
        'ChatDetailViewModel: Sent typing=true for chat $_currentChatId',
      );

      // Auto-cancel after 3 seconds of inactivity
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _chatService.sendTypingIndicator(_currentChatId, false);
        debugPrint(
          'ChatDetailViewModel: Auto-sent typing=false for chat $_currentChatId',
        );
      });
    } else if (_currentChatId.isNotEmpty) {
      // Gửi stopped typing qua ChatService/WebSocket
      _chatService.sendTypingIndicator(_currentChatId, false);
      debugPrint(
        'ChatDetailViewModel: Sent typing=false for chat $_currentChatId',
      );
    }
  }

  /// Cập nhật trạng thái typing của đối phương (và timeout tự động ẩn)
  void updateRecipientTypingStatus(bool isTyping) {
    if (isTyping) {
      _isOtherUserTyping = true;
      _typingUserName = _recipientName; // Sử dụng recipient name
      debugPrint('ChatDetailViewModel: User $_typingUserName is typing');
      // Reset timer mỗi lần nhận được typing=true
      _otherUserTypingTimer?.cancel();
      _otherUserTypingTimer = Timer(const Duration(seconds: 2), () {
        _isOtherUserTyping = false;
        _typingUserName = null;
        notifyListeners();
      });
    } else {
      _isOtherUserTyping = false;
      _typingUserName = null;
      _otherUserTypingTimer?.cancel();
    }
    notifyListeners();
  }

  // Pin a message
  Future<void> pinMessage(String messageId) async {
    try {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final messageToPin = _messages[index];

        // Check if already pinned
        if (_pinnedMessages.any((m) => m.id == messageId)) return;

        // Add to pinned messages
        _pinnedMessages.add(messageToPin);
        _currentPinnedMessageIndex = _pinnedMessages.length - 1;

        notifyListeners();

        // TODO: Update in repository
        // await _messageRepository.pinMessage(messageId);
      }
    } catch (e) {
      debugPrint('Error pinning message: $e');
    }
  }

  // Unpin a message
  Future<void> unpinMessage(String messageId) async {
    try {
      final index = _pinnedMessages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        // Remove from pinned messages
        _pinnedMessages.removeAt(index);

        // Reset current pinned message index if needed
        if (_currentPinnedMessageIndex >= _pinnedMessages.length) {
          _currentPinnedMessageIndex = _pinnedMessages.length - 1;
        }

        notifyListeners();

        // TODO: Update in repository
        // await _messageRepository.unpinMessage(messageId);
      }
    } catch (e) {
      debugPrint('Error unpinning message: $e');
    }
  }

  // Unpin all messages
  Future<void> unpinAllMessages() async {
    try {
      if (_pinnedMessages.isNotEmpty && _messages.isNotEmpty) {
        // Clear pinned messages locally
        _pinnedMessages = [];
        _currentPinnedMessageIndex = -1;

        notifyListeners();

        // TODO: Update in repository
        // await _messageRepository.unpinAllMessages(chatId);
      }
    } catch (e) {
      debugPrint('Error unpinning all messages: $e');
    }
  }

  // Navigate to next pinned message
  void showNextPinnedMessage() {
    navigateToNextPinnedMessage();
  }

  // Navigate to next pinned message
  void navigateToNextPinnedMessage() {
    if (_pinnedMessages.isNotEmpty) {
      _currentPinnedMessageIndex =
          (_currentPinnedMessageIndex + 1) % _pinnedMessages.length;
      notifyListeners();
    }
  }

  // Navigate to previous pinned message
  void navigateToPreviousPinnedMessage() {
    if (_pinnedMessages.isNotEmpty) {
      _currentPinnedMessageIndex =
          (_currentPinnedMessageIndex - 1 + _pinnedMessages.length) %
          _pinnedMessages.length;
      notifyListeners();
    }
  }

  /// Bắt đầu refresh messages định kỳ khi WebSocket không available
  void _startPeriodicRefresh(String chatId) {
    debugPrint(
      'ChatDetailViewModel: Starting periodic message refresh for chat $chatId',
    );
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        debugPrint('ChatDetailViewModel: Refreshing messages for chat $chatId');
        final result = await _getMessagesUseCase.execute(chatId);
        final newMessages = result['messages'] as List<Message>;

        // Check for new messages
        final currentMessageIds = _messages.map((m) => m.id).toSet();
        final newMessagesList =
            newMessages
                .where((m) => !currentMessageIds.contains(m.id))
                .toList();

        if (newMessagesList.isNotEmpty) {
          debugPrint(
            'ChatDetailViewModel: Found ${newMessagesList.length} new messages',
          );
          _messages = newMessages;
          _updateDateIndicator();
          notifyListeners();
        }
      } catch (e) {
        debugPrint('ChatDetailViewModel: Error refreshing messages: $e');
      }
    });
  }

  /// Dừng periodic refresh
  void _stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    debugPrint('ChatDetailViewModel: Stopped periodic message refresh');
  }

  /// Clear invalid messages từ cache để tránh hiển thị system messages
  Future<void> _clearInvalidMessagesFromCache(String chatId) async {
    try {
      // Check if ChatService has cached messages for this chat
      // và clear any invalid messages
      debugPrint(
        'ChatDetailViewModel: Clearing invalid messages from cache for chat $chatId',
      );

      // Force refresh cache bằng cách clear local storage invalid messages
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('messages_$chatId');

      if (messagesJson != null) {
        final List<dynamic> messagesList = jsonDecode(messagesJson);
        final allMessages =
            messagesList.map((json) => Message.fromJson(json)).toList();

        // Filter out system/invalid messages
        final validMessages =
            allMessages.where((msg) {
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

        if (validMessages.length != allMessages.length) {
          // Save back only valid messages
          final validMessagesJson = jsonEncode(
            validMessages.map((msg) => msg.toJson()).toList(),
          );
          await prefs.setString('messages_$chatId', validMessagesJson);
          debugPrint(
            'ChatDetailViewModel: Cleaned cache - ${allMessages.length} -> ${validMessages.length} messages',
          );
        }
      }
    } catch (e) {
      debugPrint('ChatDetailViewModel: Error clearing invalid messages: $e');
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _markAsReadTimer?.cancel(); // Cancel mark as read timer
    _refreshTimer?.cancel(); // Cancel refresh timer
    _otherUserTypingTimer?.cancel(); // Cancel other user typing timer
    _messagesSubscription?.cancel();
    _newMessageSubscription?.cancel();
    _userStatusSubscription?.cancel();
    super.dispose();
  }
}
