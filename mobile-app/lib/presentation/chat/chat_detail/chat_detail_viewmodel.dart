import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/message.dart';
import '../../../domain/usecases/chat/get_messages_usecase.dart';
import '../../../domain/usecases/chat/send_message_usecase.dart';
import '../../../domain/usecases/chat/delete_message_usecase.dart';
import '../../../domain/usecases/chat/recall_message_usecase.dart';
import '../../../domain/usecases/chat/mark_messages_read_usecase.dart';
import '../../../domain/usecases/chat/upload_chat_image_usecase.dart';
import '../../../app/di/injection.dart';
import '../../../core/utils/file_utils.dart';
import '../../../data/remote/profile_api.dart';
import '../../../core/services/chat_service.dart';
import '../../../domain/usecases/chat/get_chat_room_usecase.dart';

class ChatDetailViewModel extends ChangeNotifier {
  final GetMessagesUseCase _getMessagesUseCase = getIt<GetMessagesUseCase>();
  final SendMessageUseCase _sendMessageUseCase = getIt<SendMessageUseCase>();
  final DeleteMessageUseCase _deleteMessageUseCase = getIt<DeleteMessageUseCase>();
  final RecallMessageUseCase _recallMessageUseCase = getIt<RecallMessageUseCase>();
  final MarkMessagesReadUseCase _markMessagesReadUseCase = getIt<MarkMessagesReadUseCase>();
  final UploadChatImageUseCase _uploadChatImageUseCase = getIt<UploadChatImageUseCase>();
  final ProfileApi _profileApi = getIt<ProfileApi>();
  final ChatService _chatService = getIt<ChatService>();
  final GetChatRoomUseCase _getChatRoomUseCase = getIt<GetChatRoomUseCase>();
  
  final ImagePicker _imagePicker = ImagePicker();

  List<Message> _messages = [];
  bool _isLoading = true;
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

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  bool get showDateIndicator => _showDateIndicator;
  DateTime? get currentDateIndicator => _currentDateIndicator;
  String? get lastActiveTime => _lastActiveTime;
  String get currentUserId => _currentUserId;
  List<Message> get pinnedMessages => _pinnedMessages;
  int get currentPinnedMessageIndex => _currentPinnedMessageIndex;
  Message? get currentPinnedMessage =>
      _pinnedMessages.isNotEmpty ? _pinnedMessages[_currentPinnedMessageIndex] : null;

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
    _newMessageSubscription = _chatService.newMessageStream.listen((newMessage) {
      if (newMessage.chatId == _currentChatId) {
        // Kiểm tra xem tin nhắn đã có trong danh sách chưa
        final existingIndex = _messages.indexWhere((msg) => msg.id == newMessage.id);
        if (existingIndex == -1) {
          // Thêm tin nhắn mới vào đầu danh sách
          _messages.insert(0, newMessage);
          _updateDateIndicator();
          notifyListeners();
          
          debugPrint('Received new message in chat ${newMessage.chatId}: ${newMessage.content}');
        }
      }
    });
    
    // Lắng nghe cập nhật messages từ cache
    _messagesSubscription = _chatService.messagesStream.listen((messagesMap) {
      if (_currentChatId.isNotEmpty && messagesMap.containsKey(_currentChatId)) {
        _messages = messagesMap[_currentChatId]!;
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
      _currentUserName = '${userInfo['firstName'] ?? ''} ${userInfo['lastName'] ?? ''}'.trim();
      
      if (_currentUserName.isEmpty) {
        _currentUserName = userInfo['username'] ?? 'Unknown User';
      }
      
      debugPrint('Current user info loaded: ID=$_currentUserId, Name=$_currentUserName');
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting current user info: $e');
      // Fallback values nếu không lấy được thông tin
      _currentUserId = 'unknown';
      _currentUserName = 'Current User';
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
          if (message.senderAvatar != null && message.senderAvatar!.isNotEmpty) {
            messagesWithAvatar++;
            debugPrint('Message ${message.id} from ${message.senderName} has avatar: ${message.senderAvatar}');
          } else {
            messagesWithoutAvatar++;
            debugPrint('Message ${message.id} from ${message.senderName} missing avatar');
          }
        }
      }
      
      debugPrint('Avatar status: $messagesWithAvatar messages have avatar, $messagesWithoutAvatar missing avatar');
      
      // Backend đã cung cấp avatar trong response, không cần fetch thêm
      // Avatar sẽ được sử dụng trực tiếp từ message.senderAvatar
      
    } catch (e) {
      debugPrint('Error checking chat participant avatars: $e');
    }
  }

  void _setupTypingListener() {
    // Setup firebase or socket listeners for typing indicators
  }

  // Load chat messages from usecase
  Future<void> loadMessages(String chatId) async {
    try {
      _isLoading = true;
      _currentChatId = chatId;
      notifyListeners();

      // Đảm bảo có current user info trước khi setup WebSocket
      if (_currentUserId.isEmpty) {
        await _getCurrentUserInfo();
      }

      // Initialize WebSocket connection với current user ID
      if (_currentUserId.isNotEmpty) {
        debugPrint('ChatDetailViewModel: Setting up WebSocket for user $_currentUserId in chat $chatId');
        try {
          await _chatService.initializeWebSocket(_currentUserId);
          await _chatService.subscribeToChat(chatId);
          debugPrint('ChatDetailViewModel: WebSocket setup completed successfully');
          // Stop periodic refresh nếu WebSocket thành công
          _stopPeriodicRefresh();
        } catch (e) {
          debugPrint('ChatDetailViewModel: WebSocket setup failed: $e');
          // Fallback: Start periodic refresh khi WebSocket không available
          _startPeriodicRefresh(chatId);
        }
      } else {
        debugPrint('ChatDetailViewModel: Warning - No current user ID available for WebSocket');
      }

      // Get messages from usecase
      final result = await _getMessagesUseCase.execute(chatId);
      final messages = result['messages'] as List<Message>;

      // Process messages
      _messages = messages;

      // Update date indicator
      _updateDateIndicator();

      _isLoading = false;
      notifyListeners();
      
      // Check avatar status trong messages (async để không block UI)
      _updateChatParticipantAvatars(chatId).then((_) {
        debugPrint('Avatar check completed for chat $chatId');
      }).catchError((e) {
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

  /// Đánh dấu tin nhắn đã đọc
  /// Gọi API để mark messages as read và cập nhật local state với debounce
  Future<void> markMessagesAsRead(String chatId) async {
    // Cancel timer cũ nếu có
    _markAsReadTimer?.cancel();
    
    // Debounce: chỉ gọi API sau 2 giây không có request mới
    _markAsReadTimer = Timer(const Duration(seconds: 2), () async {
      try {
        debugPrint('ChatDetailViewModel: Actually marking messages as read for chat: $chatId');
        
        // Gọi ChatService để mark messages as read thông qua API
        await _chatService.markMessagesAsRead(chatId);
        
        // Cập nhật local state - đánh dấu tất cả messages của người khác là đã đọc
        bool hasUpdates = false;
        for (int i = 0; i < _messages.length; i++) {
          final message = _messages[i];
          // Chỉ cập nhật messages của người khác (không phải current user)
          if (message.senderId != _currentUserId && !message.isRead) {
            _messages[i] = message.copyWith(
              isRead: true,
              readAt: DateTime.now(),
              status: MessageStatus.read,
            );
            hasUpdates = true;
          }
        }
        
        if (hasUpdates) {
          notifyListeners();
          debugPrint('ChatDetailViewModel: Updated local messages read status');
        }
        
        debugPrint('ChatDetailViewModel: Successfully marked messages as read for chat: $chatId');
      } catch (e) {
        debugPrint('ChatDetailViewModel: Error marking messages as read: $e');
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
  }) async {
    try {
      final sentMessage = await _sendMessageUseCase.execute(
        chatRoomId: chatId,
        content: message,
        type: MessageType.text,
        replyToMessageId: replyToMessageId,
      );

      debugPrint('Message sent successfully: ${sentMessage.id}');
    } catch (e) {
      debugPrint('Error sending message: $e');
      // Error handling sẽ được xử lý trong UI
    }
  }

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
        await _sendMediaMessage(
          chatId: chatId,
          file: File(image.path),
          type: MessageType.image,
          caption: '',
        );
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
        await _sendMediaMessage(
          chatId: chatId,
          file: File(image.path),
          type: MessageType.image,
          caption: '',
        );
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
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
      final locationMessage = 'Location: ${position.latitude}, ${position.longitude}';

      await sendMessage(
        chatId: chatId,
        message: locationMessage,
      );

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

  // CALL FUNCTIONALITY

  Future<void> initiateVoiceCall(String chatId) async {
    // Implementation would connect to your calling service
    debugPrint('Initiating voice call for chat: $chatId');
  }

  Future<void> initiateVideoCall(String chatId) async {
    // Implementation would connect to your calling service
    debugPrint('Initiating video call for chat: $chatId');
  }

  // Typing indicator functions
  void setUserTyping(bool isTyping) {
    // Cancel any existing timer
    _typingTimer?.cancel();

    if (isTyping) {
      // TODO: Send typing indicator to backend
      // _messageRepository.sendTypingIndicator(_currentUserId, true);

      // Auto-cancel after some time of inactivity
      _typingTimer = Timer(const Duration(seconds: 5), () {
        // _messageRepository.sendTypingIndicator(_currentUserId, false);
      });
    } else {
      // TODO: Send stopped typing to backend
      // _messageRepository.sendTypingIndicator(_currentUserId, false);
    }
  }

  void updateRecipientTypingStatus(bool isTyping) {
    _isTyping = isTyping;
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
        // Get chat ID from the first message
        final chatId = _messages.first.chatId;

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
    debugPrint('ChatDetailViewModel: Starting periodic message refresh for chat $chatId');
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        debugPrint('ChatDetailViewModel: Refreshing messages for chat $chatId');
        final result = await _getMessagesUseCase.execute(chatId);
        final newMessages = result['messages'] as List<Message>;
        
        // Check for new messages
        final currentMessageIds = _messages.map((m) => m.id).toSet();
        final newMessagesList = newMessages.where((m) => !currentMessageIds.contains(m.id)).toList();
        
        if (newMessagesList.isNotEmpty) {
          debugPrint('ChatDetailViewModel: Found ${newMessagesList.length} new messages');
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

  @override
  void dispose() {
    _typingTimer?.cancel();
    _markAsReadTimer?.cancel(); // Cancel mark as read timer
    _refreshTimer?.cancel(); // Cancel refresh timer
    _messagesSubscription?.cancel();
    _newMessageSubscription?.cancel();
    super.dispose();
  }
}
