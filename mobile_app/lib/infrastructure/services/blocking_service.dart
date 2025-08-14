// filepath: c:\amoura-final-project\mobile-app\lib\infrastructure\services\blocking_service.dart
import 'package:flutter/foundation.dart';
import '../../domain/models/settings/blocked_message.dart';
import '../../domain/models/settings/blocked_user.dart';

class BlockingService extends ChangeNotifier {
  // Messages-related properties and methods
  bool _isLoadingMessages = false;
  bool get isLoadingMessages => _isLoadingMessages;

  final List<BlockedMessage> _blockedMessages = [];
  List<BlockedMessage> get blockedMessages =>
      List.unmodifiable(_blockedMessages);

  // Users-related properties and methods
  bool _isLoadingUsers = false;
  bool get isLoadingUsers => _isLoadingUsers;

  final List<BlockedUser> _blockedUsers = [];
  List<BlockedUser> get blockedUsers => List.unmodifiable(_blockedUsers);

  // Constructor
  BlockingService();

  // MESSAGES RELATED METHODS

  // Fetch blocked messages from backend/storage
  Future<void> fetchBlockedMessages() async {
    _setLoadingMessages(true);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
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
}
