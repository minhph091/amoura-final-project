import 'package:flutter/foundation.dart';

enum NotificationType {
  match,
  message,
  like,
  system,
}

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
}

class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;
  int _currentTabIndex = 0;

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
    return _notifications.where((n) => n.type == NotificationType.like).toList();
  }

  List<NotificationModel> getMessageNotifications() {
    return _notifications.where((n) => n.type == NotificationType.message).toList();
  }

  List<NotificationModel> getSystemNotifications() {
    return _notifications.where((n) => n.type == NotificationType.system).toList();
  }

  int getUnreadCountByType(NotificationType type) {
    return _notifications.where((n) => n.type == type && !n.isRead).length;
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // This would be an API call in a real app
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration
      _notifications = [
        NotificationModel(
          id: '1',
          title: 'Emma liked your profile',
          body: 'You got a new like from Emma!',
          time: DateTime.now().subtract(const Duration(minutes: 15)),
          type: NotificationType.like,
          userId: '101',
          avatar: 'https://randomuser.me/api/portraits/women/32.jpg',
        ),
        NotificationModel(
          id: '2',
          title: 'New message from Alex',
          body: 'Hey! How are you doing today?',
          time: DateTime.now().subtract(const Duration(hours: 2)),
          type: NotificationType.message,
          isRead: true,
          userId: '102',
          avatar: 'https://randomuser.me/api/portraits/men/54.jpg',
        ),
        NotificationModel(
          id: '3',
          title: 'Match with Sophia!',
          body: 'You and Sophia liked each other!',
          time: DateTime.now().subtract(const Duration(days: 1)),
          type: NotificationType.match,
          userId: '103',
          avatar: 'https://randomuser.me/api/portraits/women/45.jpg',
        ),
        NotificationModel(
          id: '4',
          title: 'Profile verification completed',
          body: 'Your profile has been successfully verified!',
          time: DateTime.now().subtract(const Duration(days: 3)),
          type: NotificationType.system,
        ),
        NotificationModel(
          id: '5',
          title: 'James liked your profile',
          body: 'You got a new like from James!',
          time: DateTime.now().subtract(const Duration(hours: 5)),
          type: NotificationType.like,
          userId: '104',
          avatar: 'https://randomuser.me/api/portraits/men/22.jpg',
        ),
        NotificationModel(
          id: '6',
          title: 'New message from Sophia',
          body: 'Looking forward to our date tomorrow!',
          time: DateTime.now().subtract(const Duration(hours: 3)),
          type: NotificationType.message,
          userId: '103',
          avatar: 'https://randomuser.me/api/portraits/women/45.jpg',
        ),
        NotificationModel(
          id: '7',
          title: 'Your subscription is expiring soon',
          body: 'Your premium features will expire in 3 days.',
          time: DateTime.now().subtract(const Duration(days: 2)),
          type: NotificationType.system,
        ),
        NotificationModel(
          id: '8',
          title: 'Oliver liked your profile',
          body: 'You got a new like from Oliver!',
          time: DateTime.now().subtract(const Duration(hours: 8)),
          type: NotificationType.like,
          userId: '105',
          avatar: 'https://randomuser.me/api/portraits/men/33.jpg',
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _notifications[index];
      if (!notification.isRead) {
        _notifications[index] = NotificationModel(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          time: notification.time,
          type: notification.type,
          isRead: true,
          userId: notification.userId,
          avatar: notification.avatar,
          url: notification.url,
        );
        notifyListeners();
      }
    }
  }

  void markAllAsRead() {
    bool changed = false;
    final updatedList = _notifications.map((n) {
      if (!n.isRead) {
        changed = true;
        return NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          time: n.time,
          type: n.type,
          isRead: true,
          userId: n.userId,
          avatar: n.avatar,
          url: n.url,
        );
      }
      return n;
    }).toList();

    if (changed) {
      _notifications = updatedList;
      notifyListeners();
    }
  }

  void markAllAsReadByType(NotificationType type) {
    bool changed = false;
    final updatedList = _notifications.map((n) {
      if (n.type == type && !n.isRead) {
        changed = true;
        return NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          time: n.time,
          type: n.type,
          isRead: true,
          userId: n.userId,
          avatar: n.avatar,
          url: n.url,
        );
      }
      return n;
    }).toList();

    if (changed) {
      _notifications = updatedList;
      notifyListeners();
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
}
