import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/notification_service.dart';
import '../../infrastructure/services/likes_service.dart';
import '../../data/models/notification/notification_model.dart' as api;
import '../../core/services/profile_service.dart';
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
  final ProfileService _profileService = getIt<ProfileService>();
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
  
  // Getters for liked users
  List<dynamic> get likedUsers {
    try {
      return _likesService.likedUsers;
    } catch (e) {
      debugPrint('NotificationViewModel: Error getting likedUsers: $e');
      return [];
    }
  }
  
  int get likedUsersCount {
    try {
      return _likesService.likedUsers.length;
    } catch (e) {
      debugPrint('NotificationViewModel: Error getting likedUsersCount: $e');
      return 0;
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
      
      // Refresh likes khi chuyển sang tab Likes (index 0)
      if (index == 0) {
        debugPrint('NotificationViewModel: Switched to Likes tab, refreshing likes...');
        refreshLikes();
      }
      
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
    // Clear old notifications when loading
    _notifications = [];
    // Clear likes service data
    _likesService.clearData();
    notifyListeners();

    try {
      debugPrint('NotificationViewModel: Loading notifications from API...');
      
      // Lấy user ID từ profile service
      String? userId;
      try {
        debugPrint('NotificationViewModel: Getting profile data...');
        final profileData = await _profileService.getProfile();
        debugPrint('NotificationViewModel: Profile data keys: ${profileData.keys.toList()}');
        debugPrint('NotificationViewModel: Profile data userId: ${profileData['userId']}');
        debugPrint('NotificationViewModel: Profile data userId type: ${profileData['userId'].runtimeType}');
        
        final userIdInt = profileData['userId'] as int?;
        userId = userIdInt?.toString();
        debugPrint('NotificationViewModel: Got user ID from profile: $userId');
        debugPrint('NotificationViewModel: User ID type: ${userId.runtimeType}');
        debugPrint('NotificationViewModel: User ID is empty: ${userId?.isEmpty}');
        debugPrint('NotificationViewModel: User ID equals current_user_id: ${userId == "current_user_id"}');
      } catch (e) {
        debugPrint('NotificationViewModel: Error getting user ID from profile: $e');
        userId = null;
      }
      
      if (userId != null && userId.isNotEmpty) {
        debugPrint('NotificationViewModel: Calling notification service initialize with userId: $userId');
        debugPrint('NotificationViewModel: User ID is not null: ${userId != null}');
        debugPrint('NotificationViewModel: User ID is not empty: ${userId.isNotEmpty}');
        await _service.initialize(userId);
        debugPrint('NotificationViewModel: Notification service initialized successfully');
      } else {
        debugPrint('NotificationViewModel: Invalid user ID, skipping notification service initialization');
        debugPrint('NotificationViewModel: User ID is null: ${userId == null}');
        debugPrint('NotificationViewModel: User ID is empty: ${userId?.isEmpty}');
      }
      
      // Load notifications từ API thật (sẽ trả về empty nếu chưa initialize)
      await _service.refreshNotifications();
      
      // Load liked users từ API thật
      try {
        debugPrint('NotificationViewModel: About to call _likesService.fetchLikedUsers()...');
        await _likesService.fetchLikedUsers();
        debugPrint('NotificationViewModel: Successfully called _likesService.fetchLikedUsers()');
        // Tạo notifications từ liked users
        _createNotificationsFromLikedUsers();
        debugPrint('NotificationViewModel: Created notifications from liked users');
      } catch (e) {
        debugPrint('NotificationViewModel: ERROR loading liked users: $e');
        debugPrint('NotificationViewModel: Error type: ${e.runtimeType}');
        debugPrint('NotificationViewModel: Error details: ${e.toString()}');
        // Set error if likes service fails
        _error = 'Failed to load likes: ${e.toString()}';
        // Continue without liked users
      }
      
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
      debugPrint('NotificationViewModel: ==> refreshLikes called');
      await _likesService.fetchLikedUsers();
      debugPrint('NotificationViewModel: refreshLikes - fetchLikedUsers completed');
      _createNotificationsFromLikedUsers();
      debugPrint('NotificationViewModel: refreshLikes - createNotificationsFromLikedUsers completed');
      notifyListeners();
      debugPrint('NotificationViewModel: refreshLikes - notifyListeners completed');
    } catch (e) {
      debugPrint('NotificationViewModel: ERROR in refreshLikes: $e');
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
      
      debugPrint('NotificationViewModel: Creating notifications from ${likedUsers.length} liked users');
      
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
          title: 'New Like',
          body: '${likedUser.fullName} liked your profile',
          time: notificationTime,
          type: NotificationType.like,
          isRead: false,
          userId: likedUser.id,
          avatar: likedUser.avatarUrl,
        );
        
        _notifications.add(notification);
        debugPrint('NotificationViewModel: Added notification for user: ${likedUser.fullName}');
      }
      
      // Sort by time (newest first)
      _notifications.sort((a, b) => b.time.compareTo(a.time));
      
      debugPrint('NotificationViewModel: Created ${_notifications.where((n) => n.type == NotificationType.like).length} like notifications');
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationViewModel: Error creating notifications from liked users: $e');
    }
  }
  void markAsRead(String notificationId) {
    try {
      // Bỏ qua các thông báo local (id giả) như like_*
      if (notificationId.startsWith('like_')) {
        final idx = _notifications.indexWhere((n) => n.id == notificationId);
        if (idx != -1) {
          _notifications[idx] = _notifications[idx].copyWith(isRead: true);
          notifyListeners();
        }
        return;
      }
      _service.markAsRead(notificationId);
      // UI sẽ tự động cập nhật qua stream
    } catch (e) {
      debugPrint('NotificationViewModel: Error marking notification as read: $e');
    }
  }

  void markAllAsRead() {
    try {
      // Đánh dấu tất cả local và server
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
      notifyListeners();
      _service.markAllAsRead();
      // Cập nhật badge tổng từ server
      _service.refreshUnreadCount();
    } catch (e) {
      debugPrint('NotificationViewModel: Error marking all notifications as read: $e');
    }
  }

  void markAllAsReadByType(NotificationType type) {
    try {
      // Lọc các id chưa đọc theo type rồi gọi markAsRead cho từng cái
      final target = _notifications.where((n) => n.type == type && !n.isRead);
      for (final n in target) {
        // Bỏ qua markAsRead API cho thông báo local (like_*) để tránh 400
        if (n.id.startsWith('like_')) {
          final idx = _notifications.indexWhere((x) => x.id == n.id);
          if (idx != -1) {
            _notifications[idx] = _notifications[idx].copyWith(isRead: true);
          }
        } else {
          _service.markAsRead(n.id);
        }
      }
      notifyListeners();
      // Đồng bộ badge tổng từ server
      _service.refreshUnreadCount();
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
      for (final n in groupNotifications) {
        if (!n.isRead) {
          final idx = _notifications.indexWhere((x) => x.id == n.id);
          if (idx != -1) {
            _notifications[idx] = _notifications[idx].copyWith(isRead: true);
          }
          if (!n.id.startsWith('like_')) {
            _service.markAsRead(n.id);
          }
        }
      }
      notifyListeners();
      _service.refreshUnreadCount();
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
