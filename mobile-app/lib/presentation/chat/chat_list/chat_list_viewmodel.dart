import 'package:flutter/foundation.dart';
import '../../../domain/models/chat.dart';
import '../../../domain/models/message.dart';
import '../../../domain/usecases/chat/get_conversations_usecase.dart';
import '../../../app/di/injection.dart';
import '../../../data/remote/profile_api.dart';
import '../../../core/services/chat_service.dart';
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

  bool get isUnread => unreadCount > 0;

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

    return ChatModel(
      chatRoomId: chat.id,
      userId: participantId,
      name: participantName,
      avatar: displayAvatar,
      lastMessage: chat.lastMessage?.content ?? '',
      lastMessageTime: chat.lastMessage?.timestamp ?? chat.updatedAt ?? DateTime.now(),
      unreadCount: chat.unreadCount ?? 0,
      isOnline: false, // This would need to be fetched separately
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
  final GetConversationsUseCase _getConversationsUseCase = getIt<GetConversationsUseCase>();
  final ProfileApi _profileApi = getIt<ProfileApi>();
  final ChatService _chatService = getIt<ChatService>();
  
  List<ChatModel> _chatList = [];
  List<ChatModel> _filteredChatList = [];
  List<UserModel> _activeUsers = [];
  List<UserModel> _recentUsers = [];
  List<UserModel> _matches = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _currentUserId = '';
  
  // Stream subscriptions để lắng nghe ChatService
  StreamSubscription<List<Chat>>? _chatsSubscription;
  StreamSubscription<Message>? _newMessageSubscription;

  // Getters
  List<ChatModel> get chatList => _searchQuery.isEmpty ? _chatList : _filteredChatList;
  List<UserModel> get activeUsers => _activeUsers;
  List<UserModel> get recentUsers => _recentUsers;
  List<UserModel> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatListViewModel() {
    _subscribeToStreams();
  }

  /// Subscribe vào streams từ ChatService để auto-refresh khi có thay đổi
  void _subscribeToStreams() {
    // Lắng nghe cập nhật chat list từ ChatService
    _chatsSubscription = _chatService.chatsStream.listen((chats) async {
      if (_currentUserId.isNotEmpty) {
        await _processChatList(chats);
      }
    });
    
    // Lắng nghe tin nhắn mới để cập nhật last message
    _newMessageSubscription = _chatService.newMessageStream.listen((newMessage) {
      _updateChatWithNewMessage(newMessage);
    });
  }

  /// Xử lý danh sách chat từ domain models thành UI models
  Future<void> _processChatList(List<Chat> chats) async {
    try {
      // Convert to ChatModel với current user ID
      _chatList = await Future.wait(chats.map((chat) => ChatModel.fromChat(chat, _currentUserId)));
      
      // Tạo danh sách matches từ chat rooms
      _matches = _chatList.map((chat) => UserModel(
        userId: chat.userId,
        name: chat.name,
        avatar: chat.avatar,
        isOnline: chat.isOnline,
      )).toList();
      
      // Sort by last message time
      _sortChatList();
      
      // Generate mock active and recent users for now
      _activeUsers = _generateMockActiveUsers();
      _recentUsers = _generateMockRecentUsers();

      notifyListeners();
    } catch (e) {
      debugPrint('Error processing chat list: $e');
    }
  }

  /// Cập nhật chat khi có tin nhắn mới
  void _updateChatWithNewMessage(Message newMessage) {
    final chatIndex = _chatList.indexWhere((chat) => chat.chatRoomId == newMessage.chatId);
    if (chatIndex != -1) {
      final updatedChat = ChatModel(
        chatRoomId: _chatList[chatIndex].chatRoomId,
        userId: _chatList[chatIndex].userId,
        name: _chatList[chatIndex].name,
        avatar: _chatList[chatIndex].avatar,
        lastMessage: newMessage.content,
        lastMessageTime: newMessage.timestamp,
        unreadCount: _chatList[chatIndex].unreadCount + 1, // Tăng unread count
        isPinned: _chatList[chatIndex].isPinned,
        isMuted: _chatList[chatIndex].isMuted,
        isHidden: _chatList[chatIndex].isHidden,
        isOnline: _chatList[chatIndex].isOnline,
      );
      
      _chatList[chatIndex] = updatedChat;
      _sortChatList();
      notifyListeners();
      
      debugPrint('Updated chat ${newMessage.chatId} with new message: ${newMessage.content}');
    }
  }

  // Search functionality
  void searchChats(String query) {
    _searchQuery = query.toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredChatList = [];
    } else {
      _filteredChatList = _chatList.where((chat) {
        return chat.name.toLowerCase().contains(_searchQuery) ||
               chat.lastMessage.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    notifyListeners();
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

  /// Lấy current user ID từ backend API và initialize WebSocket
  /// API endpoint: GET /user  
  Future<void> _getCurrentUserId() async {
    try {
      final userInfo = await _profileApi.getUserInfo();
      _currentUserId = userInfo['id']?.toString() ?? '';
      debugPrint('Current user ID loaded for chat list: $_currentUserId');
      
      // Initialize WebSocket connection for realtime updates
      if (_currentUserId.isNotEmpty && _currentUserId != 'unknown') {
        await _chatService.initializeWebSocket(_currentUserId);
      }
    } catch (e) {
      debugPrint('Error getting current user ID in chat list: $e');
      _currentUserId = 'unknown';
    }
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

  // Mock data generation for active and recent users
  List<UserModel> _generateMockActiveUsers() {
    return [
      UserModel(
        userId: "1",
        name: "Emma",
        avatar: "https://randomuser.me/api/portraits/women/1.jpg",
        isOnline: true,
      ),
      UserModel(
        userId: "3",
        name: "Sofia",
        avatar: "https://randomuser.me/api/portraits/women/2.jpg",
        isOnline: true,
      ),
      UserModel(
        userId: "5",
        name: "Jennifer",
        avatar: "https://randomuser.me/api/portraits/women/3.jpg",
        isOnline: true,
      ),
      UserModel(
        userId: "7",
        name: "Alex",
        avatar: "https://randomuser.me/api/portraits/men/4.jpg",
        isOnline: true,
      ),
      UserModel(
        userId: "8",
        name: "Olivia",
        avatar: "https://randomuser.me/api/portraits/women/4.jpg",
        isOnline: true,
      ),
      UserModel(
        userId: "9",
        name: "Daniel",
        avatar: "https://randomuser.me/api/portraits/men/5.jpg",
        isOnline: true,
      ),
    ];
  }

  List<UserModel> _generateMockRecentUsers() {
    return [
      UserModel(
        userId: "1",
        name: "Emma",
        avatar: "https://randomuser.me/api/portraits/women/1.jpg",
      ),
      UserModel(
        userId: "2",
        name: "Chris",
        avatar: "https://randomuser.me/api/portraits/men/1.jpg",
      ),
      UserModel(
        userId: "3",
        name: "Sofia",
        avatar: "https://randomuser.me/api/portraits/women/2.jpg",
      ),
      UserModel(
        userId: "4",
        name: "Keanu",
        avatar: "https://randomuser.me/api/portraits/men/2.jpg",
      ),
    ];
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    _newMessageSubscription?.cancel();
    super.dispose();
  }
}
