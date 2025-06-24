import 'package:flutter/foundation.dart';

class ChatModel {
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
  List<ChatModel> _chatList = [];
  List<ChatModel> _filteredChatList = [];
  List<UserModel> _activeUsers = [];
  List<UserModel> _recentUsers = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<ChatModel> get chatList => _searchQuery.isEmpty ? _chatList : _filteredChatList;
  List<UserModel> get activeUsers => _activeUsers;
  List<UserModel> get recentUsers => _recentUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
      // This would be an API call in a real application
      await Future.delayed(const Duration(seconds: 1));

      _chatList = _generateMockChatList();
      _activeUsers = _generateMockActiveUsers();
      _recentUsers = _generateMockRecentUsers();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load chat list: ${e.toString()}';
      notifyListeners();
    }
  }

  void toggleReadStatus(String userId) {
    final index = _chatList.indexWhere((chat) => chat.userId == userId);
    if (index != -1) {
      final chat = _chatList[index];
      _chatList[index] = ChatModel(
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

  void deleteChat(String userId) {
    _chatList.removeWhere((chat) => chat.userId == userId);
    notifyListeners();
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

  // Mock data generation
  List<ChatModel> _generateMockChatList() {
    return [
      ChatModel(
        userId: "1",
        name: "Emma Watson",
        avatar: "https://randomuser.me/api/portraits/women/1.jpg",
        lastMessage: "See you tomorrow!",
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        isPinned: true,
        isOnline: true,
      ),
      ChatModel(
        userId: "2",
        name: "Chris Evans",
        avatar: "https://randomuser.me/api/portraits/men/1.jpg",
        lastMessage: "That sounds great! Looking forward to it.",
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        isOnline: false,
      ),
      ChatModel(
        userId: "3",
        name: "Sofia Martinez",
        avatar: "https://randomuser.me/api/portraits/women/2.jpg",
        lastMessage: "I just sent you the photos from our trip.",
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
        unreadCount: 1,
        isOnline: true,
      ),
      ChatModel(
        userId: "4",
        name: "Keanu Reeves",
        avatar: "https://randomuser.me/api/portraits/men/2.jpg",
        lastMessage: "Let me know when you're free.",
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        isOnline: false,
      ),
      ChatModel(
        userId: "5",
        name: "Jennifer Lawrence",
        avatar: "https://randomuser.me/api/portraits/women/3.jpg",
        lastMessage: "Thanks for the recommendation!",
        lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
        isOnline: true,
      ),
      ChatModel(
        userId: "6",
        name: "Tom Holland",
        avatar: "https://randomuser.me/api/portraits/men/3.jpg",
        lastMessage: "Did you watch the new movie?",
        lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
        isPinned: true,
        isOnline: false,
      ),
    ];
  }

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
}
