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
    // TODO: Replace with real API call to fetch notifications
    _isLoading = false;
    notifyListeners();
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
