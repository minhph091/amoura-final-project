import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/notification_service.dart';
import '../../infrastructure/services/likes_service.dart';
import '../../data/models/notification/notification_model.dart' as api;
import '../../app/di/injection.dart';
import 'dart:async';

// UI NotificationModel để tránh conflict với API NotificationModel
class UINotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;
  final String? userId;
  final NotificationType type;
  final String? avatar;
  final String? url;

  UINotificationModel({
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

  UINotificationModel copyWith({bool? isRead}) {
    try {
      return UINotificationModel(
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
    } catch (e) {
      debugPrint('UINotificationModel: Error in copyWith: $e');
      rethrow;
    }
  }
}

// UI NotificationType enum
enum NotificationType { match, message, like, system }

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _service = getIt<NotificationService>();
  final LikesService _likesService = getIt<LikesService>();
  List<UINotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;
  int _currentTabIndex = 0;
  late final StreamSubscription _notificationStream;
  late final StreamSubscription _newNotificationStream;
  bool _initialized = false;

  NotificationViewModel() {
    try {
      // Constructor logic if needed
    } catch (e) {
      debugPrint('NotificationViewModel: Error in constructor: $e');
    }
  }

  List<UINotificationModel> get notifications {
    try {
      return _notifications;
    } catch (e) {
      debugPrint('NotificationViewModel: Error getting notifications: $e');
      return [];
    }
  }
  
  bool get isLoading {
    try {
      return _isLoading;
    } catch (e) {
      debugPrint('NotificationViewModel: Error getting isLoading: $e');
      return true;
    }
  }
  
  String? get error {
    try {
      return _error;
    } catch (e) {
      debugPrint('NotificationViewModel: Error getting error: $e');
      return 'Unknown error';
    }
  }
  
  int get unreadCount {
    try {
      return _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint('NotificationViewModel: Error getting unread count: $e');
      return 0;
    }
  }
  
  int get currentTabIndex {
    try {
      return _currentTabIndex;
    } catch (e) {
      debugPrint('NotificationViewModel: Error getting current tab index: $e');
      return 0;
    }
  }

  void setCurrentTabIndex(int index) {
    try {
      _currentTabIndex = index;
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationViewModel: Error setting current tab index: $e');
    }
  }

  List<UINotificationModel> getLikeNotifications() {
    try {
      // Trả về cả like và match
      return _notifications
          .where(
            (n) =>
                n.type == NotificationType.like ||
                n.type == NotificationType.match,
          )
          .toList();
    } catch (e) {
      debugPrint('NotificationViewModel: Error getting like notifications: $e');
      return [];
    }
  }

  List<UINotificationModel> getMessageNotifications() {
    try {
      return _notifications
          .where((n) => n.type == NotificationType.message)
          .toList();
    } catch (e) {
      debugPrint('NotificationViewModel: Error getting message notifications: $e');
      return [];
    }
  }

  List<UINotificationModel> getSystemNotifications() {
    try {
      return _notifications
          .where((n) => n.type == NotificationType.system)
          .toList();
    } catch (e) {
      debugPrint('NotificationViewModel: Error getting system notifications: $e');
      return [];
    }
  }

  int getUnreadCountByType(NotificationType type) {
    try {
      return _notifications.where((n) => n.type == type && !n.isRead).length;
    } catch (e) {
      debugPrint('NotificationViewModel: Error getting unread count by type: $e');
      return 0;
    }
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('NotificationViewModel: Loading notifications from API...');
      
      // Initialize notification service với user ID (cần lấy từ auth service)
      // TODO: Lấy user ID từ auth service hoặc từ JWT token
      // Có thể decode JWT token để lấy user ID hoặc thêm method getUserId() vào AuthService
      final userId = "current_user_id"; // Tạm thời hardcode
      await _service.initialize(userId);
      
      // Load notifications từ API thật (sẽ trả về empty nếu chưa initialize)
      await _service.refreshNotifications();
      
      // Load liked users từ API thật
      await _likesService.fetchLikedUsers();
      
      // Tạo notifications từ liked users
      _createNotificationsFromLikedUsers();
      
      // Setup streams nếu chưa setup
      if (!_initialized) {
        _setupStreams();
        _initialized = true;
      }
      
      debugPrint('NotificationViewModel: Successfully loaded notifications');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationViewModel: Error loading notifications: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshLikes() async {
    try {
      await _likesService.fetchLikedUsers();
      _createNotificationsFromLikedUsers();
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationViewModel: Error refreshing likes: $e');
    }
  }

  void _setupStreams() {
    try {
      _notificationStream = _service.notificationsStream.listen((notifications) {
        // Convert API notifications to UI notifications
        _notifications = notifications.map((apiNotification) {
          return UINotificationModel(
            id: apiNotification.id,
            title: apiNotification.title ?? '',
            body: apiNotification.content ?? '',
            time: apiNotification.timestamp ?? apiNotification.createdAt ?? DateTime.now(),
            type: _mapNotificationType(apiNotification.type),
            isRead: apiNotification.isRead,
            userId: apiNotification.relatedEntityId?.toString(),
            avatar: apiNotification.avatar,
            url: apiNotification.url,
          );
        }).toList();
        
        // Add liked users notifications
        _createNotificationsFromLikedUsers();
        
        notifyListeners();
      });

      _newNotificationStream = _service.newNotificationStream.listen((apiNotification) {
        final notification = UINotificationModel(
          id: apiNotification.id,
          title: apiNotification.title ?? '',
          body: apiNotification.content ?? '',
          time: apiNotification.timestamp ?? apiNotification.createdAt ?? DateTime.now(),
          type: _mapNotificationType(apiNotification.type),
          isRead: apiNotification.isRead,
          userId: apiNotification.relatedEntityId?.toString(),
          avatar: apiNotification.avatar,
          url: apiNotification.url,
        );
        
        _notifications.insert(0, notification);
        notifyListeners();
      });
    } catch (e) {
      debugPrint('NotificationViewModel: Error setting up streams: $e');
    }
  }

  NotificationType _mapNotificationType(api.NotificationType apiType) {
    try {
      switch (apiType) {
        case api.NotificationType.match:
          return NotificationType.match;
        case api.NotificationType.message:
          return NotificationType.message;
        case api.NotificationType.like:
          return NotificationType.like;
        case api.NotificationType.system:
        case api.NotificationType.marketing:
        default:
          return NotificationType.system;
      }
    } catch (e) {
      debugPrint('NotificationViewModel: Error mapping notification type: $e');
      return NotificationType.system; // Default fallback
    }
  }

  void _createNotificationsFromLikedUsers() {
    try {
      // Tạo notifications từ liked users
      final likedUsers = _likesService.likedUsers;
      final now = DateTime.now();
      
      // Xóa các like notifications cũ (để tránh duplicate)
      _notifications.removeWhere((n) => n.type == NotificationType.like);
      
      // Thêm notifications mới từ liked users
      for (final likedUser in likedUsers) {
        final likedAt = likedUser.profileDetails?['likedAt'];
        final notificationTime = likedAt != null 
            ? DateTime.tryParse(likedAt) ?? now
            : now;
        
        final notification = UINotificationModel(
          id: 'like_${likedUser.id}',
          title: 'new_like',
          body: '${likedUser.fullName} liked your profile',
          time: notificationTime,
          type: NotificationType.like,
          isRead: false,
          userId: likedUser.id,
          avatar: likedUser.avatarUrl,
        );
        
        _notifications.add(notification);
      }
      
      // Sort by time (newest first)
      _notifications.sort((a, b) => b.time.compareTo(a.time));
    } catch (e) {
      debugPrint('NotificationViewModel: Error creating notifications from liked users: $e');
    }
  }

  void markAsRead(String notificationId) {
    try {
      _service.markAsRead(notificationId);
      // UI sẽ tự động cập nhật qua stream
    } catch (e) {
      debugPrint('NotificationViewModel: Error marking notification as read: $e');
    }
  }

  void markAllAsRead() {
    try {
      _service.markAllAsRead();
      // UI sẽ tự động cập nhật qua stream
    } catch (e) {
      debugPrint('NotificationViewModel: Error marking all notifications as read: $e');
    }
  }

  void markAllAsReadByType(NotificationType type) {
    try {
      // Lọc các id chưa đọc theo type rồi gọi markAsRead cho từng cái
      final ids =
          _notifications
              .where((n) => n.type == type && !n.isRead)
              .map((n) => n.id)
              .toList();
      for (final id in ids) {
        _service.markAsRead(id);
      }
    } catch (e) {
      debugPrint('NotificationViewModel: Error marking all notifications as read by type: $e');
    }
  }

  void dismissNotification(String notificationId) {
    try {
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationViewModel: Error dismissing notification: $e');
    }
  }

  void clearAllByType(NotificationType type) {
    try {
      _notifications.removeWhere((n) => n.type == type);
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationViewModel: Error clearing notifications by type: $e');
    }
  }

  void markAllAsReadInGroup(List<UINotificationModel> groupNotifications) {
    try {
      for (final notification in groupNotifications) {
        if (!notification.isRead) {
          final index = _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = notification.copyWith(isRead: true);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationViewModel: Error marking all as read in group: $e');
    }
  }

  void deleteAllInGroup(List<UINotificationModel> groupNotifications) {
    try {
      for (final notification in groupNotifications) {
        _notifications.removeWhere((n) => n.id == notification.id);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationViewModel: Error deleting all in group: $e');
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _notificationStream.cancel();
      _newNotificationStream.cancel();
    }
    // Dispose notification service
    _service.dispose();
    super.dispose();
  }
}
