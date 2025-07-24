import 'package:flutter/foundation.dart';
import '../../config/environment.dart';

/// Cấu hình WebSocket cho chat và notification
/// Sử dụng STOMP protocol để giao tiếp với Spring Boot backend
class WebSocketConfig {
  static const String endpoint = '/ws'; // Main WebSocket endpoint

  /// URL chính để kết nối WebSocket
  static String get url => wsEndpoint;

  // WebSocket endpoints
  static String get wsEndpoint {
    // Tùy thuộc vào environment
    switch (EnvironmentConfig.current) {
      case Environment.dev:
        return 'ws://10.0.2.2:8080/api/ws';
      case Environment.staging:
        return 'ws://150.95.109.13:8080/api/ws';
      case Environment.prod:
        return 'wss://api.amoura.space/api/ws';
    }
  }

  // Thêm method để lấy base WebSocket URL cho production
  static String get productionWsUrl {
    return 'wss://api.amoura.space/api/ws';
  }

  // STOMP destinations for subscribing
  static const String topicChatPrefix =
      '/topic/chat/'; // /topic/chat/{chatRoomId}
  static const String topicUserStatus =
      '/topic/user-status/'; // /topic/user-status/{chatRoomId}
  static const String queueNotification =
      '/user/queue/notification'; // User-specific notifications
  static const String queueMatch = '/user/queue/match'; // Match notifications

  // STOMP destinations for sending
  static const String appChatMessage = '/app/chat.sendMessage'; // Send message
  static const String appChatTyping = '/app/chat.typing'; // Typing indicator
  static const String appUserStatus = '/app/user.status'; // User online/offline

  // Connection settings
  static const int heartbeatIncoming = 10000; // 10 seconds
  static const int heartbeatOutgoing = 10000; // 10 seconds
  static const int reconnectDelay = 5000; // 5 seconds
  static const int maxReconnectAttempts = 10;

  /// URL WebSocket chính để kết nối
  static String get wsUrl {
    final baseUrl = EnvironmentConfig.baseUrl.replaceFirst('/api', '');
    return '$baseUrl$endpoint';
  }

  /// URL WebSocket thay thế
  static String get wsUrlAlternative {
    final baseUrl = EnvironmentConfig.baseUrl.replaceFirst('/api', '');
    return '$baseUrl$endpoint';
  }

  // WebSocket topics và queues
  static const String topicPrefix = '/topic';
  static const String queuePrefix = '/queue';
  static const String userQueuePrefix = '/user/queue';
  static const String appPrefix = '/app';

  /// Topic chat cho phòng chat cụ thể
  static String chatTopic(String chatRoomId) => '$topicPrefix/chat/$chatRoomId';

  /// Topic trạng thái online/offline của user trong phòng chat
  static String userStatusInChatTopic(String chatRoomId) =>
      '$topicPrefix/chat/$chatRoomId/user-status';

  /// Queue thông báo cá nhân cho user
  static String userNotificationQueue() => '$userQueuePrefix/notification';

  /// Personal notification topic
  static String get personalNotificationTopic =>
      '$userQueuePrefix/notification';

  /// General user status topic (không sử dụng nữa, thay bằng chat-specific topics)
  static String get userStatusTopic => '$topicPrefix/user-status';

  /// Typing indicator topic
  static String typingIndicatorTopic(String chatRoomId) =>
      '$topicPrefix/chat/$chatRoomId/typing';

  /// Read receipt destination
  static String get readReceiptDestination => '$appPrefix/chat.read';

  // WebSocket message destinations
  static const String sendMessageDestination = '/app/chat.sendMessage';
  static const String typingDestination = '/app/chat.typing';
  static const String recallMessageDestination = '/app/chat.recallMessage';

  /// Destination để gửi tin nhắn qua WebSocket
  static String get sendMessageWsDestination => sendMessageDestination;

  /// Destination để gửi typing indicator
  static String get typingWsDestination => typingDestination;

  /// Destination để thu hồi tin nhắn
  static String get recallMessageWsDestination => recallMessageDestination;

  // WebSocket message types
  static const String messageTypeMessage = 'MESSAGE';
  static const String messageTypeTyping = 'TYPING';
  static const String messageTypeReadReceipt = 'READ_RECEIPT';
  static const String messageTypeMessageRecalled = 'MESSAGE_RECALLED';
  static const String messageTypeMatch = 'MATCH';

  /// Headers cho kết nối WebSocket
  static Map<String, String> getConnectionHeaders(String jwtToken) {
    return {
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'application/json',
    };
  }

  /// Cấu hình STOMP client
  static Map<String, dynamic> getStompConfig(String jwtToken) {
    return {
      'brokerURL': wsEndpoint,
      'connectHeaders': getConnectionHeaders(jwtToken),
      'reconnectDelay': reconnectDelay,
      'heartbeatIncoming': heartbeatIncoming,
      'heartbeatOutgoing': heartbeatOutgoing,
      'debug': (str) => debugPrint('STOMP: $str'),
    };
  }

  /// Cấu hình STOMP client với SockJS (cho web)
  static Map<String, dynamic> getStompConfigWithSockJS(String jwtToken) {
    return {
      'webSocketFactory': () => null, // Sẽ được set bởi SockJS
      'connectHeaders': getConnectionHeaders(jwtToken),
      'reconnectDelay': reconnectDelay,
      'heartbeatIncoming': heartbeatIncoming,
      'heartbeatOutgoing': heartbeatOutgoing,
      'debug': (str) => debugPrint('STOMP: $str'),
    };
  }
}

/// Cấu hình API endpoints cho chat
class ChatApiConfig {
  // Base API endpoints
  static const String chatBase = '/chat';
  static const String roomsEndpoint = '$chatBase/rooms';
  static const String messagesEndpoint = '$chatBase/messages';
  static const String uploadImageEndpoint = '$chatBase/upload-image';
  static const String deleteImageEndpoint = '$chatBase/delete-image';

  /// URL đầy đủ cho các API endpoints
  static String get roomsUrl => '${EnvironmentConfig.baseUrl}$roomsEndpoint';
  static String get messagesUrl =>
      '${EnvironmentConfig.baseUrl}$messagesEndpoint';
  static String get uploadImageUrl =>
      '${EnvironmentConfig.baseUrl}$uploadImageEndpoint';
  static String get deleteImageUrl =>
      '${EnvironmentConfig.baseUrl}$deleteImageEndpoint';

  /// URL cho chat room cụ thể
  static String chatRoomUrl(String chatRoomId) =>
      '${EnvironmentConfig.baseUrl}$roomsEndpoint/$chatRoomId';

  /// URL cho tin nhắn trong chat room
  static String chatMessagesUrl(String chatRoomId) =>
      '${EnvironmentConfig.baseUrl}$roomsEndpoint/$chatRoomId/messages';

  /// URL để đánh dấu tin nhắn đã đọc
  static String markMessagesReadUrl(String chatRoomId) =>
      '${EnvironmentConfig.baseUrl}$roomsEndpoint/$chatRoomId/messages/read';

  /// URL để lấy số tin nhắn chưa đọc
  static String unreadCountUrl(String chatRoomId) =>
      '${EnvironmentConfig.baseUrl}$roomsEndpoint/$chatRoomId/messages/unread-count';

  /// URL để xóa tin nhắn cho riêng user
  static String deleteMessageForMeUrl(String messageId) =>
      '${EnvironmentConfig.baseUrl}$messagesEndpoint/$messageId/delete-for-me';

  /// URL để thu hồi tin nhắn
  static String recallMessageUrl(String messageId) =>
      '${EnvironmentConfig.baseUrl}$messagesEndpoint/$messageId/recall';

  // Headers cho API calls
  static Map<String, String> getApiHeaders(String jwtToken) {
    return {
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'application/json',
    };
  }

  /// Headers cho upload file
  static Map<String, String> getUploadHeaders(String jwtToken) {
    return {
      'Authorization': 'Bearer $jwtToken',
      // Content-Type sẽ được set tự động cho multipart/form-data
    };
  }
}

/// Cấu hình thông báo
class NotificationApiConfig {
  static const String notificationBase = '/notifications';

  /// URL đầy đủ cho các API thông báo
  static String get notificationsUrl =>
      '${EnvironmentConfig.baseUrl}$notificationBase';
  static String get unreadNotificationsUrl =>
      '${EnvironmentConfig.baseUrl}$notificationBase/unread';
  static String get unreadCountUrl =>
      '${EnvironmentConfig.baseUrl}$notificationBase/unread/count';
  static String get readAllUrl =>
      '${EnvironmentConfig.baseUrl}$notificationBase/read-all';

  /// URL để đánh dấu thông báo đã đọc
  static String markAsReadUrl(String notificationId) =>
      '${EnvironmentConfig.baseUrl}$notificationBase/$notificationId/read';
}

/// Cấu hình user status
class UserStatusApiConfig {
  /// URL để kiểm tra trạng thái online của user
  static String userOnlineStatusUrl(String userId) =>
      '${EnvironmentConfig.baseUrl}/users/$userId/online';
}
