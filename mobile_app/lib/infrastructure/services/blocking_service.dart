// filepath: c:\amoura-final-project\mobile-app\lib\infrastructure\services\blocking_service.dart
import 'package:flutter/foundation.dart';
import '../../domain/models/settings/blocked_message.dart';
import '../../domain/models/settings/blocked_user.dart';

class BlockingService extends ChangeNotifier {
  // Messages-related properties and methods
  bool _isLoadingMessages = false;
  bool get isLoadingMessages => _isLoadingMessages;

  final List<BlockedMessage> _blockedMessages = [];
  List<BlockedMessage> get blockedMessages => List.unmodifiable(_blockedMessages);

  // Users-related properties and methods
  bool _isLoadingUsers = false;
  bool get isLoadingUsers => _isLoadingUsers;

  final List<BlockedUser> _blockedUsers = [];
  List<BlockedUser> get blockedUsers => List.unmodifiable(_blockedUsers);

  // Constructor
  BlockingService() {
    // Initialize with some data for demo purposes
    _initMockData();
  }

  void _initMockData() {
    _blockedMessages.addAll(_mockBlockedMessages);
    _blockedUsers.addAll(_mockBlockedUsers);
  }

  // MESSAGES RELATED METHODS

  // Fetch blocked messages from backend/storage
  Future<void> fetchBlockedMessages() async {
    _setLoadingMessages(true);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data already loaded in constructor
    } catch (e) {
      debugPrint('Error fetching blocked messages: $e');
    } finally {
      _setLoadingMessages(false);
    }
  }

  // Unblock a message by ID
  Future<void> unblockMessage(String messageId) async {
    _setLoadingMessages(true);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      _blockedMessages.removeWhere((message) => message.id == messageId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error unblocking message: $e');
    } finally {
      _setLoadingMessages(false);
    }
  }

  void _setLoadingMessages(bool isLoading) {
    _isLoadingMessages = isLoading;
    notifyListeners();
  }

  // USERS RELATED METHODS

  // Fetch blocked users from backend/storage
  Future<void> fetchBlockedUsers() async {
    _setLoadingUsers(true);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data already loaded in constructor
    } catch (e) {
      debugPrint('Error fetching blocked users: $e');
    } finally {
      _setLoadingUsers(false);
    }
  }

  // Unblock a user by ID
  Future<void> unblockUser(String userId) async {
    _setLoadingUsers(true);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      _blockedUsers.removeWhere((user) => user.id == userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error unblocking user: $e');
    } finally {
      _setLoadingUsers(false);
    }
  }

  // Unblock multiple users by ID
  Future<void> unblockUsers(Set<String> userIds) async {
    if (userIds.isEmpty) return;

    _setLoadingUsers(true);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));

      _blockedUsers.removeWhere((user) => userIds.contains(user.id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error unblocking multiple users: $e');
    } finally {
      _setLoadingUsers(false);
    }
  }

  void _setLoadingUsers(bool isLoading) {
    _isLoadingUsers = isLoading;
    notifyListeners();
  }

  // MOCK DATA

  // Mock data for messages
  final List<BlockedMessage> _mockBlockedMessages = [
    BlockedMessage(
      id: '1',
      userName: 'Alex Johnson',
      age: 28,
      location: 'New York',
      userPhotoUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      messageContent: 'Hey, how are you doing? Would you like to meet for coffee sometime?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      userId: 'user123',
    ),
    BlockedMessage(
      id: '2',
      userName: 'Emily Chen',
      age: 25,
      location: 'San Francisco',
      userPhotoUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
      messageContent: 'I saw your profile and thought we might have a lot in common.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      userId: 'user456',
    ),
    BlockedMessage(
      id: '3',
      userName: 'Michael Smith',
      age: 31,
      location: 'Chicago',
      userPhotoUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
      messageContent: 'Hi there! Your profile caught my attention. Would love to chat more.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      userId: 'user789',
    ),
  ];

  // Mock data for users
  final List<BlockedUser> _mockBlockedUsers = [
    BlockedUser(
      id: 'user1',
      name: 'Sophia Williams',
      age: 24,
      location: 'Los Angeles',
      photoUrl: 'https://randomuser.me/api/portraits/women/11.jpg',
      blockedAt: DateTime.now().subtract(const Duration(days: 5)),
      distance: 8.5,
    ),
    BlockedUser(
      id: 'user2',
      name: 'Daniel Brown',
      age: 29,
      location: 'Miami',
      photoUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
      blockedAt: DateTime.now().subtract(const Duration(days: 12)),
      blockReason: 'Inappropriate behavior',
      distance: 15.2,
    ),
    BlockedUser(
      id: 'user3',
      name: 'Olivia Garcia',
      age: 26,
      location: 'Seattle',
      photoUrl: 'https://randomuser.me/api/portraits/women/33.jpg',
      blockedAt: DateTime.now().subtract(const Duration(days: 3)),
      distance: 5.4,
    ),
    BlockedUser(
      id: 'user4',
      name: 'Noah Martinez',
      age: 32,
      location: 'Austin',
      photoUrl: 'https://randomuser.me/api/portraits/men/44.jpg',
      blockedAt: DateTime.now().subtract(const Duration(hours: 8)),
      blockReason: 'Spam messages',
      distance: 12.8,
    ),
  ];
}
