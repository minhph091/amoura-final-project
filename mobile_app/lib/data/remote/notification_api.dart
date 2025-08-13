import '../../core/api/api_client.dart';
import '../models/notification/notification_model.dart';
import 'package:flutter/foundation.dart';

class NotificationApi {
  final ApiClient _apiClient;
  
  NotificationApi(this._apiClient) {
    try {
      // Constructor logic if needed
    } catch (e) {
      debugPrint('NotificationApi: Error in constructor: $e');
    }
  }

  // Lấy danh sách thông báo với cursor-based pagination
  Future<Map<String, dynamic>> getNotifications({
    int? cursor,
    int limit = 20,
    String direction = 'NEXT',
  }) async {
    try {
      final response = await _apiClient.get(
        '/notifications',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
          'direction': direction,
        },
      );
      final data = response.data;
      final notifications =
          (data['data'] as List?)
              ?.map((e) => NotificationModel.fromJson(e))
              .toList() ??
          [];
      return {
        'notifications': notifications,
        'nextCursor': data['nextCursor'],
        'hasMore': data['hasMore'],
      };
    } catch (e) {
      debugPrint('NotificationApi: Error getting notifications: $e');
      rethrow;
    }
  }

  // Lấy thông báo chưa đọc
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final response = await _apiClient.get('/notifications/unread');
      final data = response.data as List;
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('NotificationApi: Error getting unread notifications: $e');
      rethrow;
    }
  }

  // Lấy số lượng thông báo chưa đọc
  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await _apiClient.get('/notifications/unread/count');
      return response.data as int;
    } catch (e) {
      debugPrint('NotificationApi: Error getting unread notification count: $e');
      rethrow;
    }
  }

  // Đánh dấu thông báo đã đọc
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _apiClient.put('/notifications/$notificationId/read');
    } catch (e) {
      debugPrint('NotificationApi: Error marking notification as read: $e');
      rethrow;
    }
  }

  // Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _apiClient.put('/notifications/read-all');
    } catch (e) {
      debugPrint('NotificationApi: Error marking all notifications as read: $e');
      rethrow;
    }
  }
}
