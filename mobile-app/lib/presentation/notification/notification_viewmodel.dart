import 'package:flutter/foundation.dart';
import '../../core/services/notification_service.dart';
import '../../app/di/injection.dart';
import '../../core/services/profile_service.dart';
import 'dart:async';

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

  NotificationModel copyWith({
    bool? isRead,
  }) {
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
  bool _initialized = false;

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
      if (!_initialized) {
        // Lấy userId thực tế từ profile
        final profileService = getIt<ProfileService>();
        final profile = await profileService.getProfile();
        final userId = profile['userId']?.toString() ?? '';
        await _service.initialize(userId);
        _notificationStream = _service.notificationsStream.listen((data) {
          _notifications = _mapServiceModelsToUI(data);
          _isLoading = false;
          notifyListeners();
        });
        _newNotificationStream = _service.newNotificationStream.listen((notification) {
          notifyListeners();
        });
        _initialized = true;
      }
      await _service.refreshNotifications();
      _notifications = _mapServiceModelsToUI(_service.notifications);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
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
    final ids = _notifications.where((n) => n.type == type && !n.isRead).map((n) => n.id).toList();
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

  List<NotificationModel> _mapServiceModelsToUI(List serviceList) {
    // Mapping từ NotificationService sang NotificationModel UI
    return serviceList.map<NotificationModel>((n) {
      // Tùy chỉnh mapping cho đúng với NotificationModel UI
      return NotificationModel(
        id: n.id.toString(),
        title: n.title ?? '',
        body: n.content ?? '',
        time: n.timestamp ?? DateTime.now(),
        type: _mapType(n.type),
        isRead: n.isRead ?? false,
        userId: n.userId?.toString(),
        avatar: n.avatar,
        url: n.url,
      );
    }).toList();
  }

  NotificationType _mapType(dynamic type) {
    final t = type.toString().toLowerCase();
    if (t.contains('like')) return NotificationType.like;
    if (t.contains('match')) return NotificationType.match;
    if (t.contains('message')) return NotificationType.message;
    if (t.contains('system')) return NotificationType.system;
    return NotificationType.system;
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
