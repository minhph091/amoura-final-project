import 'package:flutter/material.dart';
import '../../../domain/models/settings/blocked_message.dart';
import '../../../domain/models/settings/blocked_user.dart';
import '../../../infrastructure/services/blocking_service.dart';

class BlockListViewModel extends ChangeNotifier {
  final BlockingService _blockingService;

  // Tab controller
  late TabController tabController;

  // Constructor
  BlockListViewModel(this._blockingService, TickerProvider vsync) {
    tabController = TabController(length: 2, vsync: vsync);

    // Listen to changes in the blocking service
    _blockingService.addListener(_onBlockingServiceChanged);
  }

  @override
  void dispose() {
    tabController.dispose();
    _blockingService.removeListener(_onBlockingServiceChanged);
    super.dispose();
  }

  // Initialize data
  void init() {
    fetchBlockedUsers();
    fetchBlockedMessages();
  }

  // Getters
  List<BlockedUser> get blockedUsers => _blockingService.blockedUsers;
  List<BlockedMessage> get blockedMessages => _blockingService.blockedMessages;
  bool get isLoadingUsers => _blockingService.isLoadingUsers;
  bool get isLoadingMessages => _blockingService.isLoadingMessages;
  bool get hasBlockedUsers => blockedUsers.isNotEmpty;
  bool get hasBlockedMessages => blockedMessages.isNotEmpty;

  // Blocking service methods
  Future<void> fetchBlockedUsers() => _blockingService.fetchBlockedUsers();
  Future<void> fetchBlockedMessages() => _blockingService.fetchBlockedMessages();
  Future<void> unblockUser(String userId) => _blockingService.unblockUser(userId);
  Future<void> unblockUsers(Set<String> userIds) => _blockingService.unblockUsers(userIds);
  Future<void> unblockMessage(String messageId) => _blockingService.unblockMessage(messageId);

  // Unblock all users
  Future<void> unblockAllUsers() async {
    final userIds = blockedUsers.map((user) => user.id).toSet();
    if (userIds.isNotEmpty) {
      await _blockingService.unblockUsers(userIds);
    }
  }

  // Callback when blocking service changes
  void _onBlockingServiceChanged() {
    notifyListeners();
  }
}
