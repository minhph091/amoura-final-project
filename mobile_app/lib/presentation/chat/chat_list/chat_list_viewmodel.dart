import 'package:flutter/foundation.dart';
import '../../../domain/models/chat.dart';
import '../../../domain/models/message.dart';
import '../../../domain/usecases/chat/get_conversations_usecase.dart';
import '../../../app/di/injection.dart';
import '../../../data/remote/profile_api.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/user_status_service.dart';
import 'dart:async';

class ChatModel {
  final String chatRoomId;
  final String userId;
  final String name;
  final String avatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;
  final bool isHidden;
  final bool isOnline;
  final bool isUnread;

  ChatModel({
    required this.chatRoomId,
    required this.userId,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    this.isHidden = false,
    this.isOnline = false,
    this.isUnread = false,
  });

  /// Convert from domain Chat model với logic xác định participant khác current user
  /// Lấy thông tin về participant (người chat với current user) chứ không phải current user
  static Future<ChatModel> fromChat(Chat chat, String currentUserId) async {
    // Xác định participant (người chat với current user)
    String participantId;
    String participantName;
    String? participantAvatar;

    if (chat.user1Id == currentUserId) {
      // Current user là user1, lấy thông tin user2
      participantId = chat.user2Id ?? '';
      participantName = chat.user2Name ?? 'Unknown User';
      participantAvatar = chat.user2Avatar;
    } else {
      // Current user là user2 hoặc không xác định, lấy thông tin user1
      participantId = chat.user1Id ?? '';
      participantName = chat.user1Name ?? 'Unknown User';
      participantAvatar = chat.user1Avatar;
    }

    // Transform URL nếu có avatar
    String displayAvatar = '';
    if (participantAvatar != null && participantAvatar.isNotEmpty) {
      displayAvatar = participantAvatar;
      // Log để debug avatar URL
      debugPrint('ChatModel: Original avatar URL = $participantAvatar');
      debugPrint('ChatModel: Display avatar URL = $displayAvatar');
    }

    // Enhanced unread status logic: kiểm tra cả unreadCount và last message status
    final unreadCount = chat.unreadCount ?? 0;
    final hasUnreadMessages = unreadCount > 0;

    // Chỉ hiển thị unread nếu last message không phải từ current user và chưa được đọc
    final lastMessageFromOtherUser =
        chat.lastMessage != null && chat.lastMessage!.senderId != currentUserId;
    final lastMessageUnread =
        chat.lastMessage != null && !chat.lastMessage!.isRead;

    // isUnread = true khi có tin nhắn chưa đọc HOẶC last message từ người khác và chưa đọc
    final shouldShowUnread =
        hasUnreadMessages || (lastMessageFromOtherUser && lastMessageUnread);

    debugPrint(
      'ChatModel: Chat ${chat.id} - UnreadCount: $unreadCount, LastMsgFromOther: $lastMessageFromOtherUser, LastMsgUnread: $lastMessageUnread, ShouldShowUnread: $shouldShowUnread',
    );

    return ChatModel(
      chatRoomId: chat.id,
      userId: participantId,
      name: participantName,
      avatar: displayAvatar,
      lastMessage: chat.lastMessage?.content ?? '',
      lastMessageTime:
          chat.lastMessage?.timestamp ?? chat.updatedAt ?? DateTime.now(),
      unreadCount: unreadCount,
      isPinned: false,
      isMuted: false,
      isHidden: false,
      isOnline: false,
      isUnread:
          shouldShowUnread, // Chỉ unread khi có tin nhắn chưa đọc từ người khác
    );
  }
}

class UserModel {
  final String userId;
  final String name;
  final String avatar;
  final bool isOnline;

  UserModel({
    required this.userId,
    required this.name,
    required this.avatar,
    this.isOnline = false,
  });
}

class ChatListViewModel extends ChangeNotifier {
  final GetConversationsUseCase _getConversationsUseCase =
      getIt<GetConversationsUseCase>();
  final ProfileApi _profileApi = getIt<ProfileApi>();
  final ChatService _chatService = getIt<ChatService>();
  final UserStatusService _userStatusService = getIt<UserStatusService>();

  List<ChatModel> _chatList = [];
  List<ChatModel> _filteredChatList = [];
  List<UserModel> _activeUsers = [];
  List<UserModel> _recentUsers = [];
  List<UserModel> _matches = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _currentUserId = '';

  // Stream subscriptions để lắng nghe ChatService và UserStatusService
  StreamSubscription<List<Chat>>? _chatsSubscription;
  StreamSubscription<Message>? _newMessageSubscription;
  StreamSubscription<Map<String, bool>>? _userStatusSubscription;

  // Getters
  List<ChatModel> get chatList =>
      _searchQuery.isEmpty ? _chatList : _filteredChatList;
  List<UserModel> get activeUsers => _activeUsers;
  List<UserModel> get recentUsers => _recentUsers;
  List<UserModel> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatListViewModel() {
    _subscribeToStreams();
  }

  /// Subscribe vào streams từ ChatService và UserStatusService để auto-refresh khi có thay đổi
  void _subscribeToStreams() {
    // Lắng nghe cập nhật chat list từ ChatService
    _chatsSubscription = _chatService.chatsStream.listen((chats) async {
      if (_currentUserId.isNotEmpty) {
        await _processChatList(chats);
      }
    });

    // Lắng nghe tin nhắn mới để cập nhật last message
    _newMessageSubscription = _chatService.newMessageStream.listen((
      newMessage,
    ) {
      _updateChatWithNewMessage(newMessage);
    });

    // Lắng nghe user status changes để cập nhật online indicators
    _userStatusSubscription = _userStatusService.statusStream.listen((
      statusUpdate,
    ) {
      _updateUserOnlineStatus(statusUpdate);
      // Cập nhật danh sách matches khi trạng thái thay đổi để UI hiển thị đúng chấm xanh/xám
      for (int i = 0; i < _matches.length; i++) {
        final uid = _matches[i].userId;
        if (statusUpdate.containsKey(uid)) {
          _matches[i] = UserModel(
            userId: _matches[i].userId,
            name: _matches[i].name,
            avatar: _matches[i].avatar,
            isOnline: statusUpdate[uid]!,
          );
        }
      }
      notifyListeners();
    });
  }

  /// Xử lý danh sách chat từ domain models thành UI models
  Future<void> _processChatList(List<Chat> chats) async {
    try {
      // Convert to ChatModel với current user ID
      _chatList = await Future.wait(
        chats.map((chat) => ChatModel.fromChat(chat, _currentUserId)),
      );

      // Lấy trạng thái online cho tất cả users trong chat list
      final userIds = _chatList.map((chat) => chat.userId).toList();
      final onlineStatusMap = await _userStatusService.getMultipleUserStatus(
        userIds,
      );

      // Cập nhật trạng thái online cho chat list
      for (int i = 0; i < _chatList.length; i++) {
        final chat = _chatList[i];
        final isOnline = onlineStatusMap[chat.userId] ?? false;
        _chatList[i] = ChatModel(
          chatRoomId: chat.chatRoomId,
          userId: chat.userId,
          name: chat.name,
          avatar: chat.avatar,
          lastMessage: chat.lastMessage,
          lastMessageTime: chat.lastMessageTime,
          unreadCount: chat.unreadCount,
          isPinned: false,
          isMuted: false,
          isHidden: false,
          isOnline: isOnline,
          isUnread: (chat.unreadCount) > 0,
        );
      }

      // Tạo danh sách matches từ chat rooms (dedupe theo userId)
      final seen = <String>{};
      _matches = [];
      for (final chat in _chatList) {
        if (seen.add(chat.userId)) {
          _matches.add(
            UserModel(
              userId: chat.userId,
              name: chat.name,
              avatar: chat.avatar,
              isOnline: chat.isOnline,
            ),
          );
        }
      }

      // Sort by last message time
      _sortChatList();

      // Remove mock active and recent users; only use real matched users
      _activeUsers = [];
      _recentUsers = [];

      // Subscribe vào tất cả chat rooms sau khi đã có danh sách
      if (_chatList.isNotEmpty) {
        // Sửa: chỉ subscribe khi WebSocket đã kết nối
        if (_chatService.isConnected) {
          _subscribeToAllChatRoomsUserStatus();
        } else {
          debugPrint('ChatListViewModel: WebSocket chưa kết nối, sẽ lắng nghe trạng thái kết nối để subscribe sau.');
          // Lắng nghe trạng thái kết nối WebSocket
          _chatService.connectionStream.listen((connected) {
            if (connected) {
              debugPrint('ChatListViewModel: WebSocket đã kết nối, tiến hành subscribe chat rooms!');
              _subscribeToAllChatRoomsUserStatus();
            }
          });
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error processing chat list: $e');
    }
  }

  /// Cập nhật chat với tin nhắn mới từ WebSocket
  void _updateChatWithNewMessage(Message newMessage) {
    try {
      // Kiểm tra nếu là unread count update từ ChatService
      if (newMessage.content.startsWith('unread_count:')) {
        final unreadCountStr = newMessage.content.split(':')[1];
        final unreadCount = int.tryParse(unreadCountStr) ?? 0;

        // Cập nhật unread count cho chat tương ứng
        final chatIndex = _chatList.indexWhere(
          (chat) => chat.chatRoomId == newMessage.chatId,
        );
        if (chatIndex != -1) {
          final updatedChat = ChatModel(
            chatRoomId: _chatList[chatIndex].chatRoomId,
            userId: _chatList[chatIndex].userId,
            name: _chatList[chatIndex].name,
            avatar: _chatList[chatIndex].avatar,
            lastMessage: _chatList[chatIndex].lastMessage,
            lastMessageTime: _chatList[chatIndex].lastMessageTime,
            unreadCount: unreadCount,
            isPinned: _chatList[chatIndex].isPinned,
            isMuted: _chatList[chatIndex].isMuted,
            isHidden: _chatList[chatIndex].isHidden,
            isOnline: _chatList[chatIndex].isOnline,
            isUnread: unreadCount > 0, // Cập nhật isUnread dựa trên unreadCount
          );

          _chatList[chatIndex] = updatedChat;
          notifyListeners();

          debugPrint(
            'ChatListViewModel: Updated unread count for chat ${newMessage.chatId}: $unreadCount',
          );
        }
        return; // Early return vì đây là unread count update, không phải tin nhắn mới
      }

      // Nếu là system message (type system hoặc content là 'Messages marked as read'), chỉ reset unread, không cập nhật last message
      final isSystem =
          newMessage.type.toString().toLowerCase() == 'system' ||
          newMessage.content.trim().toLowerCase() ==
              'messages marked as read' ||
          newMessage.content.trim().toLowerCase() == 'read';
      final chatIndex = _chatList.indexWhere(
        (chat) => chat.chatRoomId == newMessage.chatId,
      );
      if (chatIndex != -1) {
        final currentChat = _chatList[chatIndex];
        if (isSystem) {
          // Chỉ reset unread count và isUnread
          final updatedChat = ChatModel(
            chatRoomId: currentChat.chatRoomId,
            userId: currentChat.userId,
            name: currentChat.name,
            avatar: currentChat.avatar,
            lastMessage: currentChat.lastMessage, // Giữ nguyên
            lastMessageTime: currentChat.lastMessageTime, // Giữ nguyên
            unreadCount: 0,
            isPinned: currentChat.isPinned,
            isMuted: currentChat.isMuted,
            isHidden: currentChat.isHidden,
            isOnline: currentChat.isOnline,
            isUnread: false,
          );
          _chatList[chatIndex] = updatedChat;
          notifyListeners();
          debugPrint(
            'ChatListViewModel: System message - reset unread for chat ${newMessage.chatId}',
          );
          return;
        }
        // Nếu là message thực tế, cập nhật last message, tăng unread, tô đậm
        final updatedChat = ChatModel(
          chatRoomId: currentChat.chatRoomId,
          userId: currentChat.userId,
          name: currentChat.name,
          avatar: currentChat.avatar,
          lastMessage: newMessage.content,
          lastMessageTime: newMessage.timestamp,
          unreadCount: currentChat.unreadCount + 1, // Tăng unread count
          isPinned: currentChat.isPinned,
          isMuted: currentChat.isMuted,
          isHidden: currentChat.isHidden,
          isOnline: currentChat.isOnline,
          isUnread: true, // Đánh dấu là unread
        );
        // Di chuyển chat lên đầu danh sách
        _chatList.removeAt(chatIndex);
        _chatList.insert(0, updatedChat);
        if (_searchQuery.isNotEmpty) {
          _updateFilteredList();
        }
        notifyListeners();
        debugPrint(
          'ChatListViewModel: Updated chat with new message - Chat: ${newMessage.chatId}, UnreadCount: ${updatedChat.unreadCount}',
        );
      }
    } catch (e) {
      debugPrint('ChatListViewModel: Error updating chat with new message: $e');
    }
  }

  /// Cập nhật online status của users trong chat list
  void _updateUserOnlineStatus(Map<String, bool> statusUpdate) {
    bool hasUpdates = false;

    // Cập nhật chat list
    for (final entry in statusUpdate.entries) {
      final userId = entry.key;
      final isOnline = entry.value;

      final chatIndex = _chatList.indexWhere((chat) => chat.userId == userId);
      if (chatIndex != -1 && _chatList[chatIndex].isOnline != isOnline) {
        final chat = _chatList[chatIndex];
        _chatList[chatIndex] = ChatModel(
          chatRoomId: chat.chatRoomId,
          userId: chat.userId,
          name: chat.name,
          avatar: chat.avatar,
          lastMessage: chat.lastMessage,
          lastMessageTime: chat.lastMessageTime,
          unreadCount: chat.unreadCount,
          isPinned: chat.isPinned,
          isMuted: chat.isMuted,
          isHidden: chat.isHidden,
          isOnline: isOnline, // Update online status
          isUnread: chat.unreadCount > 0,
        );
        hasUpdates = true;
        debugPrint(
          'ChatListViewModel: Updated online status for user $userId: ${isOnline ? "online" : "offline"}',
        );
      }
    }

    // Cập nhật active users list
    for (int i = 0; i < _activeUsers.length; i++) {
      final userId = _activeUsers[i].userId;
      if (statusUpdate.containsKey(userId)) {
        final isOnline = statusUpdate[userId]!;
        if (_activeUsers[i].isOnline != isOnline) {
          _activeUsers[i] = UserModel(
            userId: _activeUsers[i].userId,
            name: _activeUsers[i].name,
            avatar: _activeUsers[i].avatar,
            isOnline: isOnline,
          );
          hasUpdates = true;
        }
      }
    }

    // Cập nhật matches list
    for (int i = 0; i < _matches.length; i++) {
      final userId = _matches[i].userId;
      if (statusUpdate.containsKey(userId)) {
        final isOnline = statusUpdate[userId]!;
        if (_matches[i].isOnline != isOnline) {
          _matches[i] = UserModel(
            userId: _matches[i].userId,
            name: _matches[i].name,
            avatar: _matches[i].avatar,
            isOnline: isOnline,
          );
          hasUpdates = true;
        }
      }
    }

    if (hasUpdates) {
      notifyListeners();
    }
  }

  // Search functionality
  void searchChats(String query) {
    _searchQuery = query.toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredChatList = [];
    } else {
      _filteredChatList =
          _chatList.where((chat) {
            return chat.name.toLowerCase().contains(_searchQuery) ||
                chat.lastMessage.toLowerCase().contains(_searchQuery);
          }).toList();
    }
    notifyListeners();
  }

  /// Cập nhật filtered list khi có thay đổi trong chat list
  void _updateFilteredList() {
    if (_searchQuery.isNotEmpty) {
      _filteredChatList =
          _chatList.where((chat) {
            return chat.name.toLowerCase().contains(_searchQuery) ||
                chat.lastMessage.toLowerCase().contains(_searchQuery);
          }).toList();
    }
  }

  Future<void> loadChatList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Lấy current user ID trước khi load chat list
      if (_currentUserId.isEmpty) {
        await _getCurrentUserId();
      }

      // Lấy danh sách chat rooms từ usecase thông qua ChatService
      final chats = await _getConversationsUseCase.execute();
      await _processChatList(chats);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load chat list: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Refresh chat list từ server
  Future<void> refreshChatList() async {
    try {
      debugPrint('Refreshing chat list...');
      await loadChatList();
    } catch (e) {
      debugPrint('Error refreshing chat list: $e');
    }
  }

  /// Lấy current user ID từ backend API và initialize WebSocket + UserStatusService
  /// API endpoint: GET /user
  Future<void> _getCurrentUserId() async {
    try {
      final userInfo = await _profileApi.getUserInfo();
      _currentUserId = userInfo['id']?.toString() ?? '';
      debugPrint('Current user ID loaded for chat list: $_currentUserId');

      // Initialize WebSocket connection for realtime updates
      if (_currentUserId.isNotEmpty && _currentUserId != 'unknown') {
        await _chatService.initializeWebSocket(_currentUserId);
        // Initialize UserStatusService để track online/offline status
        await _userStatusService.initialize();
        debugPrint('ChatListViewModel: Initialized UserStatusService');
        // Subscribe vào user status cho tất cả chat rooms
        _subscribeToAllChatRoomsUserStatus();
      }
    } catch (e) {
      debugPrint('Error getting current user ID in chat list: $e');
      _currentUserId = 'unknown';
    }
  }

  /// Subscribe vào user status cho tất cả chat rooms
  void _subscribeToAllChatRoomsUserStatus() {
    for (final chat in _chatList) {
      // Subscribe vào cả user status và messages cho mỗi chat room
      _chatService.subscribeToChat(chat.chatRoomId);
    }
    debugPrint(
      'ChatListViewModel: Subscribed to ${_chatList.length} chat rooms for messages and user status updates',
    );
  }

  void toggleReadStatus(String userId) {
    final index = _chatList.indexWhere((chat) => chat.userId == userId);
    if (index != -1) {
      final chat = _chatList[index];
      _chatList[index] = ChatModel(
        chatRoomId: chat.chatRoomId,
        userId: chat.userId,
        name: chat.name,
        avatar: chat.avatar,
        lastMessage: chat.lastMessage,
        lastMessageTime: chat.lastMessageTime,
        unreadCount: chat.isUnread ? 0 : 1,
        isPinned: chat.isPinned,
        isMuted: chat.isMuted,
        isHidden: chat.isHidden,
        isOnline: chat.isOnline,
        isUnread: chat.isUnread,
      );
      notifyListeners();
    }
  }

  void togglePinned(String userId) {
    final index = _chatList.indexWhere((chat) => chat.userId == userId);
    if (index != -1) {
      final chat = _chatList[index];
      _chatList[index] = ChatModel(
        chatRoomId: chat.chatRoomId,
        userId: chat.userId,
        name: chat.name,
        avatar: chat.avatar,
        lastMessage: chat.lastMessage,
        lastMessageTime: chat.lastMessageTime,
        unreadCount: chat.unreadCount,
        isPinned: !chat.isPinned,
        isMuted: chat.isMuted,
        isHidden: chat.isHidden,
        isOnline: chat.isOnline,
        isUnread: chat.isUnread,
      );

      // Sort to move pinned chats to the top
      _sortChatList();
      notifyListeners();
    }
  }

  void hideChat(String userId) {
    final index = _chatList.indexWhere((chat) => chat.userId == userId);
    if (index != -1) {
      final chat = _chatList[index];
      _chatList[index] = ChatModel(
        chatRoomId: chat.chatRoomId,
        userId: chat.userId,
        name: chat.name,
        avatar: chat.avatar,
        lastMessage: chat.lastMessage,
        lastMessageTime: chat.lastMessageTime,
        unreadCount: chat.unreadCount,
        isPinned: chat.isPinned,
        isMuted: chat.isMuted,
        isHidden: true,
        isOnline: chat.isOnline,
        isUnread: chat.isUnread,
      );
      notifyListeners();
    }
  }

  Future<void> deleteChat(String userId) async {
    try {
      // TODO: Implement delete chat usecase
      _chatList.removeWhere((chat) => chat.userId == userId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete chat: ${e.toString()}';
      notifyListeners();
    }
  }

  void _sortChatList() {
    _chatList.sort((a, b) {
      // First sort by pinned status
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;

      // Then sort by last message time
      return b.lastMessageTime.compareTo(a.lastMessageTime);
    });
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    _newMessageSubscription?.cancel();
    _userStatusSubscription?.cancel();
    super.dispose();
  }
}
