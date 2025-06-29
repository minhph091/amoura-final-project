import 'dart:async';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../constants/websocket_config.dart';
import '../../infrastructure/socket/socket_client.dart';
import '../../app/di/injection.dart';

/// Service để track online/offline status của users
/// Kết nối với WebSocket để nhận real-time status updates
class UserStatusService {
  final ApiClient _apiClient = getIt<ApiClient>();
  final SocketClient _socketClient = getIt<SocketClient>();
  
  // Map lưu trữ status của users: {userId: isOnline}
  final Map<String, bool> _userStatusMap = {};
  
  // Stream controller để broadcast status changes
  final StreamController<Map<String, bool>> _statusController = 
      StreamController<Map<String, bool>>.broadcast();
  
  // Stream để listen status changes
  Stream<Map<String, bool>> get statusStream => _statusController.stream;
  
  // Subscription để listen WebSocket status updates
  StreamSubscription? _statusSubscription;
  
  /// Initialize service và setup WebSocket listeners
  Future<void> initialize() async {
    try {
      debugPrint('UserStatusService: Initializing...');
      
      // Subscribe vào user status updates từ WebSocket
      _statusSubscription = _socketClient.userStatusStream.listen((statusData) {
        _handleStatusUpdate(statusData);
      });
      
      debugPrint('UserStatusService: Initialized successfully');
    } catch (e) {
      debugPrint('UserStatusService: Error initializing: $e');
    }
  }
  
  /// Xử lý status updates từ WebSocket
  void _handleStatusUpdate(Map<String, dynamic> statusData) {
    try {
      final userId = statusData['userId']?.toString();
      final status = statusData['status']?.toString();
      
      if (userId != null && status != null) {
        final isOnline = status.toUpperCase() == 'ONLINE';
        
        // Cập nhật local cache
        _userStatusMap[userId] = isOnline;
        
        // Broadcast update
        _statusController.add({userId: isOnline});
        
        debugPrint('UserStatusService: User $userId is now ${isOnline ? "online" : "offline"}');
      }
    } catch (e) {
      debugPrint('UserStatusService: Error handling status update: $e');
    }
  }
  
  /// Lấy online status của một user cụ thể
  /// Trả về cached status hoặc fetch từ API nếu chưa có
  Future<bool> getUserOnlineStatus(String userId) async {
    try {
      // Return cached status nếu có
      if (_userStatusMap.containsKey(userId)) {
        return _userStatusMap[userId]!;
      }
      
      // Fetch từ API nếu chưa có trong cache
      final response = await _apiClient.get(
        UserStatusApiConfig.userOnlineStatusUrl(userId),
      );
      
      // Backend trả về Boolean trực tiếp, không phải object
      final isOnline = response.data == true;
      _userStatusMap[userId] = isOnline;
      
      debugPrint('UserStatusService: Fetched status for user $userId: ${isOnline ? "online" : "offline"}');
      return isOnline;
    } catch (e) {
      debugPrint('UserStatusService: Error getting user status for $userId: $e');
      // Return false (offline) as fallback
      return false;
    }
  }
  
  /// Lấy online status của nhiều users cùng lúc
  Future<Map<String, bool>> getMultipleUserStatus(List<String> userIds) async {
    final statusMap = <String, bool>{};
    
    try {
      // Lấy cached statuses trước
      final uncachedUserIds = <String>[];
      
      for (final userId in userIds) {
        if (_userStatusMap.containsKey(userId)) {
          statusMap[userId] = _userStatusMap[userId]!;
        } else {
          uncachedUserIds.add(userId);
        }
      }
      
      // Fetch uncached users từ API (nếu có endpoint batch)
      if (uncachedUserIds.isNotEmpty) {
        // TODO: Implement batch API nếu backend support
        // For now, fetch individually
        for (final userId in uncachedUserIds) {
          statusMap[userId] = await getUserOnlineStatus(userId);
        }
      }
      
      debugPrint('UserStatusService: Got status for ${statusMap.length} users');
      return statusMap;
    } catch (e) {
      debugPrint('UserStatusService: Error getting multiple user status: $e');
      return statusMap;
    }
  }
  
  /// Update current user's status (online/offline)
  Future<void> updateMyStatus(bool isOnline) async {
    try {
      // TODO: Call API để update status nếu backend có endpoint
      debugPrint('UserStatusService: Updating my status to ${isOnline ? "online" : "offline"}');
      
      // For now, just send via WebSocket if connected
      if (_socketClient.isConnected) {
        // WebSocket message để update status
        // Backend sẽ broadcast change này cho other users
      }
    } catch (e) {
      debugPrint('UserStatusService: Error updating my status: $e');
    }
  }
  
  /// Get cached status của một user (không call API)
  bool? getCachedUserStatus(String userId) {
    return _userStatusMap[userId];
  }
  
  /// Clear tất cả cached status
  void clearCache() {
    _userStatusMap.clear();
    debugPrint('UserStatusService: Cleared status cache');
  }
  
  /// Dispose service
  void dispose() {
    _statusSubscription?.cancel();
    _statusController.close();
    _userStatusMap.clear();
    debugPrint('UserStatusService: Disposed');
  }
}

class UserStatusApiConfig {
  static const String usersBase = '/users';
  
  /// API endpoint để check user online status
  /// GET /api/users/{userId}/online - trả về Boolean
  static String userOnlineStatusUrl(String userId) => '$usersBase/$userId/online';
} 