import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/notification/notification_model.dart';
import '../../data/remote/notification_api.dart';
import '../../infrastructure/socket/socket_client.dart';
import '../../app/di/injection.dart';

/// Service chính để xử lý thông báo
/// Tích hợp WebSocket để nhận thông báo realtime và REST API để quản lý thông báo
/// WebSocket topic: /user/queue/notification (user-specific notifications)
class NotificationService {
  final NotificationApi _notificationApi = getIt<NotificationApi>();
  final SocketClient _socketClient = getIt<SocketClient>();
  
  // Stream controllers để broadcast dữ liệu thông báo
  final StreamController<List<NotificationModel>> _notificationsController = 
      StreamController<List<NotificationModel>>.broadcast();
  final StreamController<NotificationModel> _newNotificationController = 
      StreamController<NotificationModel>.broadcast();
  final StreamController<int> _unreadCountController = 
      StreamController<int>.broadcast();
  
  // Cache để lưu trữ local
  List<NotificationModel> _cachedNotifications = [];
  int _cachedUnreadCount = 0;
  String? _currentUserId;
  StreamSubscription? _notificationSubscription;
  Timer? _refreshTimer;
  
  // Getters for streams
  Stream<List<NotificationModel>> get notificationsStream => _notificationsController.stream;
  Stream<NotificationModel> get newNotificationStream => _newNotificationController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;
  
  // Getters for cached data
  List<NotificationModel> get notifications => _cachedNotifications;
  int get unreadCount => _cachedUnreadCount;
  
  /// Initialize notification service với user ID
  /// Setup WebSocket subscription cho /user/queue/notification
  Future<void> initialize(String userId) async {
    try {
      debugPrint('NotificationService: Initializing for user: $userId');
      debugPrint('NotificationService: User ID type: ${userId.runtimeType}');
      debugPrint('NotificationService: User ID is empty: ${userId.isEmpty}');
      debugPrint('NotificationService: User ID equals current_user_id: ${userId == "current_user_id"}');
      debugPrint('NotificationService: User ID length: ${userId.length}');
      
      // Validate user ID
      if (userId.isEmpty || userId == "current_user_id") {
        debugPrint('NotificationService: Invalid user ID, skipping initialization');
        return;
      }
      
      _currentUserId = userId;
      
      // Clear old cache when initializing
      _cachedNotifications = [];
      _cachedUnreadCount = 0;
      
      // Subscribe vào notification stream từ shared SocketClient
      await _setupWebSocketNotifications();
      
      // Load notifications từ API để sync với server
      await refreshNotifications();
      
      // Start periodic refresh nếu WebSocket không stable
      _startPeriodicRefresh();
      
      debugPrint('NotificationService: Initialized successfully');
    } catch (e) {
      debugPrint('NotificationService: Error initializing: $e');
      rethrow;
    }
  }
  
  /// Setup WebSocket để nhận thông báo realtime
  /// Subscribe vào topic: /user/queue/notification
  Future<void> _setupWebSocketNotifications() async {
    // Kiểm tra xem đã initialize chưa
    if (_currentUserId == null) {
      debugPrint('NotificationService: Not initialized, skipping WebSocket setup');
      return;
    }
    
    if (!_socketClient.isConnected) {
      debugPrint('NotificationService: WebSocket not connected, skipping notification subscription');
      return;
    }
    
    try {
      // Subscribe vào user-specific notification queue
      // Theo hướng dẫn: /user/queue/notification cho thông báo cá nhân
      _notificationSubscription = _socketClient.notificationStream.listen((notificationData) {
        _handleNewNotification(notificationData);
      });
      
      debugPrint('NotificationService: Subscribed to WebSocket notification stream');
    } catch (e) {
      debugPrint('NotificationService: Error setting up WebSocket notifications: $e');
    }
  }
  
  /// Xử lý thông báo mới từ WebSocket
  /// Format: { id, type, title, content, relatedEntityId, relatedEntityType, timestamp, action }
  void _handleNewNotification(Map<String, dynamic> notificationData) {
    try {
      // Kiểm tra xem đã initialize chưa
      if (_currentUserId == null) {
        debugPrint('NotificationService: Not initialized, skipping WebSocket notification');
        return;
      }
      
      debugPrint('NotificationService: Processing WebSocket notification - Type: ${notificationData['type']}');
      
      final notification = NotificationModel.fromJson(notificationData);
      
      // Kiểm tra duplicate (có thể nhận duplicate từ WebSocket và API)
      final existingIndex = _cachedNotifications.indexWhere((n) => n.id == notification.id);
      
      if (existingIndex == -1) {
        // Thêm thông báo mới vào đầu danh sách
        _cachedNotifications.insert(0, notification);
        
        // Cập nhật unread count nếu thông báo chưa đọc
        if (!notification.isRead) {
          _cachedUnreadCount++;
          _unreadCountController.add(_cachedUnreadCount);
        }
        
        // Emit streams
        _notificationsController.add(_cachedNotifications);
        _newNotificationController.add(notification);
        
        // Save to local storage
        _saveNotificationsToStorage();
        
        // Xử lý các loại thông báo đặc biệt
        _handleSpecialNotificationTypes(notification);
        
        debugPrint('NotificationService: Added new notification: ${notification.title}');
      } else {
        debugPrint('NotificationService: Duplicate notification detected, skipping: ${notification.id}');
      }
    } catch (e) {
      debugPrint('NotificationService: Error handling WebSocket notification: $e');
      debugPrint('NotificationService: Failed notification data: $notificationData');
    }
  }
  
  /// Xử lý các loại thông báo đặc biệt (MATCH, MESSAGE, LIKE)
  void _handleSpecialNotificationTypes(NotificationModel notification) {
    // Kiểm tra xem đã initialize chưa
    if (_currentUserId == null) {
      debugPrint('NotificationService: Not initialized, skipping special notification handling');
      return;
    }
    
    switch (notification.type) {
      case NotificationType.match:
        debugPrint('NotificationService: Match notification received - ${notification.content}');
        break;
      case NotificationType.message:
        debugPrint('NotificationService: Message notification received - ${notification.content}');
        break;
      case NotificationType.like:
        debugPrint('NotificationService: Like notification received - ${notification.content}');
        break;
      default:
        debugPrint('NotificationService: System notification received - ${notification.type}');
    }
  }
  
  /// Lấy danh sách thông báo từ API với pagination
  Future<Map<String, dynamic>> getNotifications({
    int? cursor,
    int limit = 20,
    String direction = 'NEXT',
  }) async {
    try {
      // Kiểm tra xem đã initialize chưa
      if (_currentUserId == null) {
        debugPrint('NotificationService: Not initialized, returning empty result');
        return {
          'notifications': <NotificationModel>[],
          'nextCursor': null,
          'hasMore': false,
        };
      }
      
      debugPrint('NotificationService: Loading notifications from API...');
      
      final result = await _notificationApi.getNotifications(
        cursor: cursor,
        limit: limit,
        direction: direction,
      );
      
      final notifications = result['notifications'] as List<NotificationModel>;
      
      if (cursor == null) {
        // First load - replace cache
        _cachedNotifications = notifications;
      } else {
        // Pagination - append to cache
        _cachedNotifications.addAll(notifications);
        
        // Remove duplicates
        final uniqueNotifications = <NotificationModel>[];
        final seenIds = <String>{};
        
        for (final notification in _cachedNotifications) {
          if (!seenIds.contains(notification.id)) {
            uniqueNotifications.add(notification);
            seenIds.add(notification.id);
          }
        }
        
        _cachedNotifications = uniqueNotifications;
      }
      
      // Sort by timestamp (newest first)
      _cachedNotifications.sort((a, b) {
        final at = a.timestamp ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bt = b.timestamp ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bt.compareTo(at);
      });
      
      _notificationsController.add(_cachedNotifications);
      await _saveNotificationsToStorage();
      
      debugPrint('NotificationService: Loaded ${notifications.length} notifications');
      
      return result;
    } catch (e) {
      debugPrint('NotificationService: Error loading notifications: $e');
      rethrow;
    }
  }
  
  /// Refresh notifications từ server
  Future<void> refreshNotifications() async {
    try {
      // Kiểm tra xem đã initialize chưa
      if (_currentUserId == null) {
        debugPrint('NotificationService: Not initialized, skipping refresh');
        return;
      }
      
      await getNotifications(); // Load first page
      await refreshUnreadCount();
    } catch (e) {
      debugPrint('NotificationService: Error refreshing notifications: $e');
    }
  }
  
  /// Lấy số lượng thông báo chưa đọc
  Future<void> refreshUnreadCount() async {
    try {
      // Kiểm tra xem đã initialize chưa
      if (_currentUserId == null) {
        debugPrint('NotificationService: Not initialized, skipping unread count refresh');
        return;
      }
      
      final count = await _notificationApi.getUnreadNotificationCount();
      _cachedUnreadCount = count;
      _unreadCountController.add(_cachedUnreadCount);
      
      debugPrint('NotificationService: Unread count updated: $count');
    } catch (e) {
      debugPrint('NotificationService: Error getting unread count: $e');
    }
  }
  
  /// Đánh dấu thông báo đã đọc
  Future<void> markAsRead(String notificationId) async {
    try {
      // Kiểm tra xem đã initialize chưa
      if (_currentUserId == null) {
        debugPrint('NotificationService: Not initialized, skipping mark as read');
        return;
      }
      
      debugPrint('NotificationService: Marking notification as read: $notificationId');
      
      // Gọi API để mark as read
      await _notificationApi.markNotificationAsRead(notificationId);
      
      // Cập nhật local cache
      final index = _cachedNotifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_cachedNotifications[index].isRead) {
        _cachedNotifications[index] = _cachedNotifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        
        // Giảm unread count
        _cachedUnreadCount = (_cachedUnreadCount - 1).clamp(0, double.infinity).toInt();
        
        // Emit updates
        _notificationsController.add(_cachedNotifications);
        _unreadCountController.add(_cachedUnreadCount);
        
        await _saveNotificationsToStorage();
        
        debugPrint('NotificationService: Notification marked as read successfully');
      }
    } catch (e) {
      debugPrint('NotificationService: Error marking notification as read: $e');
      rethrow;
    }
  }
  
  /// Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead() async {
    try {
      // Kiểm tra xem đã initialize chưa
      if (_currentUserId == null) {
        debugPrint('NotificationService: Not initialized, skipping mark all as read');
        return;
      }
      
      debugPrint('NotificationService: Marking all notifications as read');
      
      // Gọi API
      await _notificationApi.markAllNotificationsAsRead();
      
      // Cập nhật local cache
      _cachedNotifications = _cachedNotifications.map((notification) {
        if (!notification.isRead) {
          return notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
        return notification;
      }).toList();
      
      // Reset unread count
      _cachedUnreadCount = 0;
      
      // Emit updates
      _notificationsController.add(_cachedNotifications);
      _unreadCountController.add(_cachedUnreadCount);
      
      await _saveNotificationsToStorage();
      
      debugPrint('NotificationService: All notifications marked as read');
    } catch (e) {
      debugPrint('NotificationService: Error marking all notifications as read: $e');
      rethrow;
    }
  }
  
  /// Lấy chỉ thông báo chưa đọc
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      // Kiểm tra xem đã initialize chưa
      if (_currentUserId == null) {
        debugPrint('NotificationService: Not initialized, returning cached unread notifications');
        return _cachedNotifications.where((n) => !n.isRead).toList();
      }
      
      return await _notificationApi.getUnreadNotifications();
    } catch (e) {
      debugPrint('NotificationService: Error getting unread notifications: $e');
      // Return cached unread notifications as fallback
      return _cachedNotifications.where((n) => !n.isRead).toList();
    }
  }
  
  /// Load notifications từ local storage
  Future<void> _loadNotificationsFromStorage() async {
    try {
      // Kiểm tra xem đã có user ID chưa
      if (_currentUserId == null) {
        debugPrint('NotificationService: No user ID, skipping load from storage');
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications_$_currentUserId');
      final unreadCountStr = prefs.getString('unread_count_$_currentUserId');
      
      if (notificationsJson != null) {
        final List<dynamic> notificationsList = jsonDecode(notificationsJson);
        _cachedNotifications = notificationsList
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        
        debugPrint('NotificationService: Loaded ${_cachedNotifications.length} notifications from storage');
      }
      
      if (unreadCountStr != null) {
        _cachedUnreadCount = int.tryParse(unreadCountStr) ?? 0;
        _unreadCountController.add(_cachedUnreadCount);
      }
    } catch (e) {
      debugPrint('NotificationService: Error loading notifications from storage: $e');
    }
  }
  
  /// Save notifications vào local storage
  Future<void> _saveNotificationsToStorage() async {
    try {
      // Kiểm tra xem đã có user ID chưa
      if (_currentUserId == null) {
        debugPrint('NotificationService: No user ID, skipping save to storage');
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      
      // Only keep last 100 notifications
      final notificationsToSave = _cachedNotifications.take(100).toList();
      final notificationsJson = jsonEncode(notificationsToSave.map((n) => n.toJson()).toList());
      
      await prefs.setString('notifications_$_currentUserId', notificationsJson);
      await prefs.setString('unread_count_$_currentUserId', _cachedUnreadCount.toString());
      
      debugPrint('NotificationService: Saved ${notificationsToSave.length} notifications to storage');
    } catch (e) {
      debugPrint('NotificationService: Error saving notifications to storage: $e');
    }
  }
  
  /// Start periodic refresh khi WebSocket không stable
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      // Kiểm tra xem đã initialize chưa
      if (_currentUserId == null) {
        debugPrint('NotificationService: Not initialized, skipping periodic refresh');
        return;
      }
      
      if (!_socketClient.isConnected) {
        debugPrint('NotificationService: WebSocket disconnected, refreshing notifications...');
        await refreshNotifications();
      }
    });
  }
  
  /// Disconnect và cleanup
  void dispose() {
    _notificationSubscription?.cancel();
    _refreshTimer?.cancel();
    _notificationsController.close();
    _newNotificationController.close();
    _unreadCountController.close();
    _currentUserId = null; // Reset user ID
    debugPrint('NotificationService: Disposed');
  }
} 