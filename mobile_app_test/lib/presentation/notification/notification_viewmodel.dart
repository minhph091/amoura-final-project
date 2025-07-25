import 'package:flutter/foundation.dart';
import '../../core/services/notification_service.dart';
import '../../app/di/injection.dart';
import 'dart:async';

enum NotificationType { match, message, like, system }

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;
  final String? userId;
  final NotificationType type;
  final String? avatar;
  final String? url;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
    this.userId,
    this.avatar,
    this.url,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      time: time,
      type: type,
      isRead: isRead ?? this.isRead,
      userId: userId,
      avatar: avatar,
      url: url,
    );
  }
}

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _service = getIt<NotificationService>();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;
  int _currentTabIndex = 0;
  late final StreamSubscription _notificationStream;
  late final StreamSubscription _newNotificationStream;
  final bool _initialized = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  int get currentTabIndex => _currentTabIndex;

  void setCurrentTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  List<NotificationModel> getLikeNotifications() {
    // Trả về cả like và match
    return _notifications
        .where(
          (n) =>
              n.type == NotificationType.like ||
              n.type == NotificationType.match,
        )
        .toList();
  }

  List<NotificationModel> getMessageNotifications() {
    return _notifications
        .where((n) => n.type == NotificationType.message)
        .toList();
  }

  List<NotificationModel> getSystemNotifications() {
    return _notifications
        .where((n) => n.type == NotificationType.system)
        .toList();
  }

  int getUnreadCountByType(NotificationType type) {
    return _notifications.where((n) => n.type == type && !n.isRead).length;
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Add mock data for demo purposes
    _addMockNotifications();
    _isLoading = false;
    notifyListeners();
  }

  void _addMockNotifications() {
    final now = DateTime.now();
    _notifications = [
      // Likes & Matches
      NotificationModel(
        id: 'mock_like_1',
        title: 'new_like',
        body: 'like_body',
        time: now.subtract(const Duration(hours: 2)),
        type: NotificationType.like,
        isRead: false,
        avatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=634&q=80',
      ),
      NotificationModel(
        id: 'mock_match_1',
        title: 'new_match',
        body: 'match_body_sarah',
        time: now.subtract(const Duration(hours: 5)),
        type: NotificationType.match,
        isRead: false,
        avatar:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&auto=format&fit=crop&w=634&q=80',
      ),
      NotificationModel(
        id: 'mock_like_2',
        title: 'new_like',
        body: 'like_body',
        time: now.subtract(const Duration(days: 1, hours: 3)),
        type: NotificationType.like,
        isRead: true,
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=634&q=80',
      ),
      NotificationModel(
        id: 'mock_match_2',
        title: 'new_match',
        body: 'match_body_emma',
        time: now.subtract(const Duration(days: 2)),
        type: NotificationType.match,
        isRead: true,
        avatar:
            'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?ixlib=rb-4.0.3&auto=format&fit=crop&w=634&q=80',
      ),
      // Messages
      NotificationModel(
        id: 'mock_message_1',
        title: 'new_message',
        body: 'message_body_sarah',
        time: now.subtract(const Duration(minutes: 30)),
        type: NotificationType.message,
        isRead: false,
        avatar:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&auto=format&fit=crop&w=634&q=80',
      ),
      NotificationModel(
        id: 'mock_message_2',
        title: 'new_message',
        body: 'message_body_emma',
        time: now.subtract(const Duration(hours: 6)),
        type: NotificationType.message,
        isRead: false,
        avatar:
            'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?ixlib=rb-4.0.3&auto=format&fit=crop&w=634&q=80',
      ),
      NotificationModel(
        id: 'mock_message_3',
        title: 'new_message',
        body: 'message_body_michael',
        time: now.subtract(const Duration(days: 1, hours: 2)),
        type: NotificationType.message,
        isRead: true,
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=634&q=80',
      ),
      // System notifications
      NotificationModel(
        id: 'mock_system_1',
        title: 'welcome',
        body: 'welcome_body',
        time: now.subtract(const Duration(hours: 4)),
        type: NotificationType.system,
        isRead: false,
      ),
      NotificationModel(
        id: 'mock_system_2',
        title: 'app_update_available',
        body: 'app_update_body',
        time: now.subtract(const Duration(days: 1)),
        type: NotificationType.system,
        isRead: false,
      ),
      NotificationModel(
        id: 'mock_system_3',
        title: 'safety_reminder',
        body: 'safety_reminder_body',
        time: now.subtract(const Duration(days: 3)),
        type: NotificationType.system,
        isRead: true,
      ),
      NotificationModel(
        id: 'mock_system_4',
        title: 'profile_views_boost',
        body: 'profile_views_boost_body',
        time: now.subtract(const Duration(days: 5)),
        type: NotificationType.system,
        isRead: true,
      ),
    ];
  }

  void markAsRead(String notificationId) {
    _service.markAsRead(notificationId);
    // UI sẽ tự động cập nhật qua stream
  }

  void markAllAsRead() {
    _service.markAllAsRead();
    // UI sẽ tự động cập nhật qua stream
  }

  void markAllAsReadByType(NotificationType type) {
    // Lọc các id chưa đọc theo type rồi gọi markAsRead cho từng cái
    final ids =
        _notifications
            .where((n) => n.type == type && !n.isRead)
            .map((n) => n.id)
            .toList();
    for (final id in ids) {
      _service.markAsRead(id);
    }
  }

  void dismissNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  void clearAllByType(NotificationType type) {
    _notifications.removeWhere((n) => n.type == type);
    notifyListeners();
  }

  void markAllAsReadInGroup(List<NotificationModel> groupNotifications) {
    for (final notification in groupNotifications) {
      if (!notification.isRead) {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyWith(isRead: true);
        }
      }
    }
    notifyListeners();
  }

  void deleteAllInGroup(List<NotificationModel> groupNotifications) {
    for (final notification in groupNotifications) {
      _notifications.removeWhere((n) => n.id == notification.id);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    if (_initialized) {
      _notificationStream.cancel();
      _newNotificationStream.cancel();
    }
    super.dispose();
  }
}
