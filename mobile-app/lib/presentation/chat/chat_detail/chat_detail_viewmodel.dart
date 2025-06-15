import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/message.dart';
import '../../../domain/repositories/message_repository.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/file_utils.dart';

class ChatDetailViewModel extends ChangeNotifier {
  final MessageRepository _messageRepository = serviceLocator<MessageRepository>();
  final ChatRepository _chatRepository = serviceLocator<ChatRepository>();
  final ImagePicker _imagePicker = ImagePicker();

  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  bool _showDateIndicator = false;
  DateTime? _currentDateIndicator;
  String? _lastActiveTime;
  String _currentUserId = ''; // This would be fetched from auth service
  Timer? _typingTimer;

  // Pinned messages
  List<Message> _pinnedMessages = [];
  int _currentPinnedMessageIndex = 0;

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
  }

  Future<void> _getCurrentUserInfo() async {
    try {
      // Get current user ID from auth service
      // This would be implemented based on your authentication setup
      _currentUserId = 'current_user_id'; // Placeholder

      notifyListeners();
    } catch (e) {
      debugPrint('Error getting current user info: $e');
    }
  }

  void _setupTypingListener() {
    // Setup firebase or socket listeners for typing indicators
  }

  // Load chat messages from repository
  Future<void> loadMessages(String chatId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get last active time for recipient
      final chat = await _chatRepository.getChatById(chatId);
      _lastActiveTime = _formatLastSeen(chat.lastSeenAt);

      // Get messages
      final messages = await _messageRepository.getMessagesByChatId(chatId);

      // Process messages
      _messages = messages;

      // Update date indicator
      _updateDateIndicator();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error loading messages: $e');
      notifyListeners();
    }
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
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatId,
        senderId: _currentUserId,
        senderName: 'Current User', // This would come from user profile
        content: message,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        type: MessageType.text,
        replyToMessageId: replyToMessageId,
      );

      // Optimistic update - add to local list immediately
      _messages.insert(0, newMessage);
      notifyListeners();

      // Send to repository/backend
      final sentMessage = await _messageRepository.sendMessage(newMessage);

      // Update local message with server response
      final index = _messages.indexWhere((m) => m.id == newMessage.id);
      if (index != -1) {
        _messages[index] = sentMessage;
        notifyListeners();
      }

      // Update chat last message
      await _updateChatLastMessage(chatId, message);

    } catch (e) {
      debugPrint('Error sending message: $e');

      // Update status to failed
      final index = _messages.indexWhere((m) => m.id == DateTime.now().millisecondsSinceEpoch.toString());
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(status: MessageStatus.failed);
        notifyListeners();
      }
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

        // Update in repository
        await _messageRepository.updateMessage(updatedMessage);
      }
    } catch (e) {
      debugPrint('Error editing message: $e');
      // Revert changes if failed
      await loadMessages(_messages.first.chatId);
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        // Remove locally
        final deletedMessage = _messages[index];
        _messages.removeAt(index);
        notifyListeners();

        // Delete from repository
        await _messageRepository.deleteMessage(messageId);

        // Update chat last message if this was the last message
        if (index == 0 && _messages.isNotEmpty) {
          await _updateChatLastMessage(
            deletedMessage.chatId,
            _messages.first.content,
          );
        }
      }
    } catch (e) {
      debugPrint('Error deleting message: $e');
      // Refresh messages if failed
      await loadMessages(_messages.first.chatId);
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

        // Update in repository
        await _messageRepository.updateMessage(updatedMessage);
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

  // Update chat with last message info
  Future<void> _updateChatLastMessage(String chatId, String lastMessage) async {
    try {
      await _chatRepository.updateChatLastMessage(
        chatId,
        lastMessage,
        DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error updating chat last message: $e');
    }
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
      // Create optimistic message
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatId,
        senderId: _currentUserId,
        senderName: 'Current User', // Would come from user profile
        content: caption,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        type: type,
        mediaUrl: file.path, // Local file path initially
        fileInfo: fileInfo,
      );

      // Add to local list immediately
      _messages.insert(0, newMessage);
      notifyListeners();

      // Upload file and get remote URL
      final mediaUrl = await _messageRepository.uploadMedia(file, type);

      // Update message with remote URL
      final updatedMessage = newMessage.copyWith(
        mediaUrl: mediaUrl,
        status: MessageStatus.sent,
      );

      // Update in repository
      final sentMessage = await _messageRepository.sendMessage(updatedMessage);

      // Update local message
      final index = _messages.indexWhere((m) => m.id == newMessage.id);
      if (index != -1) {
        _messages[index] = sentMessage;
        notifyListeners();
      }

      // Update chat last message
      String lastMessageText = type == MessageType.image
          ? 'Photo'
          : type == MessageType.video
              ? 'Video'
              : type == MessageType.audio
                  ? 'Audio'
                  : 'File';

      if (caption.isNotEmpty) {
        lastMessageText += ': $caption';
      }

      await _updateChatLastMessage(chatId, lastMessageText);

    } catch (e) {
      debugPrint('Error sending media message: $e');

      // Update status to failed
      final index = _messages.indexWhere((m) => m.id == DateTime.now().millisecondsSinceEpoch.toString());
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(status: MessageStatus.failed);
        notifyListeners();
      }
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
      // Send typing indicator to backend
      _messageRepository.sendTypingIndicator(_currentUserId, true);

      // Auto-cancel after some time of inactivity
      _typingTimer = Timer(const Duration(seconds: 5), () {
        _messageRepository.sendTypingIndicator(_currentUserId, false);
      });
    } else {
      // Send stopped typing to backend
      _messageRepository.sendTypingIndicator(_currentUserId, false);
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

        // Optionally, remove from regular messages
        // _messages.removeAt(index);

        notifyListeners();

        // Update in repository
        await _messageRepository.pinMessage(messageId);
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

        // Update in repository
        await _messageRepository.unpinMessage(messageId);
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

        // Update in repository
        await _messageRepository.unpinAllMessages(chatId);
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

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}
