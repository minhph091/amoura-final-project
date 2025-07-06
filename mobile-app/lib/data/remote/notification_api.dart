import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/notification/notification_model.dart';

class NotificationApi {
  final ApiClient _apiClient;
  NotificationApi(this._apiClient);

  // Lấy danh sách thông báo với cursor-based pagination
  Future<Map<String, dynamic>> getNotifications({int? cursor, int limit = 20, String direction = 'NEXT'}) async {
    final response = await _apiClient.get(
      '/notifications',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
        'direction': direction,
      },
    );
    final data = response.data;
    final notifications = (data['data'] as List?)?.map((e) => NotificationModel.fromJson(e)).toList() ?? [];
    return {
      'notifications': notifications,
      'nextCursor': data['nextCursor'],
      'hasMore': data['hasMore'],
    };
  }

  // Lấy thông báo chưa đọc
  Future<List<NotificationModel>> getUnreadNotifications() async {
    final response = await _apiClient.get('/notifications/unread');
    final data = response.data as List;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  // Lấy số lượng thông báo chưa đọc
  Future<int> getUnreadNotificationCount() async {
    final response = await _apiClient.get('/notifications/unread/count');
    return response.data as int;
  }

  // Đánh dấu thông báo đã đọc
  Future<void> markNotificationAsRead(String notificationId) async {
    await _apiClient.put('/notifications/$notificationId/read');
  }

  // Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllNotificationsAsRead() async {
    await _apiClient.put('/notifications/read-all');
  }
}