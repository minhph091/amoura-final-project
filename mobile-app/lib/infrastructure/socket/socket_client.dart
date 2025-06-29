import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../../core/constants/websocket_config.dart';
import '../../core/services/auth_service.dart';
import '../../app/di/injection.dart';

/// WebSocket STOMP client để kết nối với Spring Boot backend
/// Xử lý việc nhận tin nhắn realtime, typing indicators, và notifications
class SocketClient {
  StompClient? _stompClient;
  bool _isConnected = false;
  String? _currentUserId;
  final AuthService _authService = getIt<AuthService>();
  
  // Stream controllers cho các loại events khác nhau
  final StreamController<Map<String, dynamic>> _messageController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _typingController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _notificationController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _userStatusController = StreamController.broadcast();
  final StreamController<bool> _connectionController = StreamController.broadcast();

  // Public streams để các service khác có thể subscribe
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  Stream<Map<String, dynamic>> get userStatusStream => _userStatusController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;

  /// Kết nối tới WebSocket server với JWT authentication
  /// Sử dụng STOMP protocol trên WebSocket transport
  Future<void> connect(String userId) async {
    if (_isConnected && _currentUserId == userId) {
      debugPrint('WebSocket: Already connected for user $userId');
      return;
    }

    try {
      _currentUserId = userId;
      
      // Lấy access token để authentication
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token available for WebSocket connection');
      }

      debugPrint('WebSocket: Connecting to ${WebSocketConfig.url} for user $userId');

      _stompClient = StompClient(
        config: StompConfig(
          url: WebSocketConfig.url,
          onConnect: _onConnect,
          onDisconnect: _onDisconnect,
          beforeConnect: () async {
            debugPrint('WebSocket: Preparing to connect...');
          },
          onWebSocketError: (dynamic error) {
            debugPrint('WebSocket Error: $error');
            _connectionController.add(false);
          },
          onStompError: (StompFrame frame) {
            debugPrint('STOMP Error: ${frame.body}');
            _connectionController.add(false);
          },
          onDebugMessage: (String message) {
            if (kDebugMode) {
              debugPrint('WebSocket Debug: $message');
            }
          },
          // Thêm JWT token vào headers cho authentication
          stompConnectHeaders: {
            'Authorization': 'Bearer $accessToken',
            'login': userId,
            'passcode': '',
          },
          // Cấu hình heartbeat để maintain connection
          heartbeatIncoming: const Duration(seconds: 20),
          heartbeatOutgoing: const Duration(seconds: 20),
        ),
      );

      _stompClient!.activate();
      
    } catch (e) {
      debugPrint('WebSocket: Failed to connect - $e');
      _connectionController.add(false);
      rethrow;
    }
  }

  /// Callback khi kết nối WebSocket thành công
  /// Subscribe vào các topics cần thiết để nhận messages và notifications
  void _onConnect(StompFrame frame) {
    debugPrint('WebSocket: Connected successfully');
    _isConnected = true;
    _connectionController.add(true);

    // Subscribe vào personal notification queue
    // Nhận thông báo match, system messages, etc.
    _subscribeToPersonalNotifications();

    // Subscribe vào user status updates để biết ai online/offline
    _subscribeToUserStatusUpdates();

    debugPrint('WebSocket: All subscriptions initialized');
  }

  /// Callback khi mất kết nối WebSocket
  void _onDisconnect(StompFrame frame) {
    debugPrint('WebSocket: Disconnected');
    _isConnected = false;
    _connectionController.add(false);
  }

  /// Subscribe vào queue thông báo cá nhân
  /// Topic: /user/queue/notification
  void _subscribeToPersonalNotifications() {
    if (_stompClient == null || !_isConnected) return;

    _stompClient!.subscribe(
      destination: WebSocketConfig.personalNotificationTopic,
      callback: (StompFrame frame) {
        try {
          if (frame.body != null) {
            final notification = jsonDecode(frame.body!);
            debugPrint('WebSocket: Received notification - ${notification['type']}');
            _notificationController.add(notification);
          }
        } catch (e) {
          debugPrint('WebSocket: Error parsing notification - $e');
        }
      },
    );

    debugPrint('WebSocket: Subscribed to personal notifications');
  }

  /// Subscribe vào user status updates
  /// Topic: /topic/user-status
  void _subscribeToUserStatusUpdates() {
    if (_stompClient == null || !_isConnected) return;

    _stompClient!.subscribe(
      destination: WebSocketConfig.userStatusTopic,
      callback: (StompFrame frame) {
        try {
          if (frame.body != null) {
            final statusUpdate = jsonDecode(frame.body!);
            debugPrint('WebSocket: User status update - ${statusUpdate['userId']} is ${statusUpdate['status']}');
            _userStatusController.add(statusUpdate);
          }
        } catch (e) {
          debugPrint('WebSocket: Error parsing user status - $e');
        }
      },
    );

    debugPrint('WebSocket: Subscribed to user status updates');
  }

  /// Subscribe vào một chat room cụ thể để nhận tin nhắn realtime
  /// Topic: /topic/chat/{chatRoomId}
  String? subscribeToChat(String chatRoomId, Function(Map<String, dynamic>) onMessage) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('WebSocket: Cannot subscribe to chat - not connected');
      return null;
    }

    final destination = WebSocketConfig.chatTopic(chatRoomId);
    
    final subscription = _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        try {
          if (frame.body != null) {
            final message = jsonDecode(frame.body!);
            debugPrint('WebSocket: Received message in chat $chatRoomId - Type: ${message['type']}, Content: ${message['content']}');
            
            // Xử lý các loại message khác nhau
            switch (message['type']) {
              case 'MESSAGE':
                // Tin nhắn thường
                onMessage(message);
                _messageController.add(message);
                break;
              case 'TYPING':
                // Typing indicator
                _typingController.add(message);
                break;
              case 'READ_RECEIPT':
                // Read receipt
                _messageController.add(message);
                break;
              case 'MESSAGE_RECALLED':
                // Message recalled
                _messageController.add(message);
                break;
              default:
                // Các loại message khác
                onMessage(message);
                _messageController.add(message);
            }
          }
        } catch (e) {
          debugPrint('WebSocket: Error parsing chat message - $e');
        }
      },
    );

    debugPrint('WebSocket: Subscribed to chat room $chatRoomId');
    // Return destination as subscription ID since stomp_dart_client doesn't provide subscription ID
    return destination;
  }

  /// Subscribe vào typing indicators của một chat room
  /// Topic: /topic/chat/{chatRoomId}/typing
  String? subscribeToTypingIndicators(String chatRoomId, Function(Map<String, dynamic>) onTyping) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('WebSocket: Cannot subscribe to typing - not connected');
      return null;
    }

    final destination = WebSocketConfig.typingIndicatorTopic(chatRoomId);
    
    final subscription = _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        try {
          if (frame.body != null) {
            final typingData = jsonDecode(frame.body!);
            debugPrint('WebSocket: Typing indicator in chat $chatRoomId - ${typingData['userId']} is ${typingData['isTyping'] ? "typing" : "not typing"}');
            
            // Gọi callback để xử lý typing indicator
            onTyping(typingData);
            
            // Cũng emit vào stream chung
            _typingController.add(typingData);
          }
        } catch (e) {
          debugPrint('WebSocket: Error parsing typing indicator - $e');
        }
      },
    );

    debugPrint('WebSocket: Subscribed to typing indicators for chat $chatRoomId');
    // Return destination as subscription ID
    return destination;
  }

  /// Unsubscribe khỏi một subscription bằng destination
  void unsubscribe(String destination) {
    if (_stompClient != null && _isConnected) {
      // stomp_dart_client doesn't have direct unsubscribe by ID
      // We'll need to handle this differently or track subscriptions manually
      debugPrint('WebSocket: Attempted to unsubscribe from $destination');
    }
  }

  /// Gửi typing indicator tới chat room
  /// Destination: /app/chat.typing
  void sendTypingIndicator(String chatRoomId, bool isTyping) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('WebSocket: Cannot send typing indicator - not connected');
      return;
    }

    final typingData = {
      'chatRoomId': int.parse(chatRoomId),
      'userId': _currentUserId,
      'isTyping': isTyping,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _stompClient!.send(
      destination: WebSocketConfig.typingDestination,
      body: jsonEncode(typingData),
    );

    debugPrint('WebSocket: Sent typing indicator for chat $chatRoomId - $isTyping');
  }

  /// Gửi message read receipt
  /// Destination: /app/chat.read
  void sendReadReceipt(String chatRoomId, String messageId) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('WebSocket: Cannot send read receipt - not connected');
      return;
    }

    final readData = {
      'chatRoomId': int.parse(chatRoomId),
      'messageId': messageId,
      'userId': _currentUserId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _stompClient!.send(
      destination: WebSocketConfig.readReceiptDestination,
      body: jsonEncode(readData),
    );

    debugPrint('WebSocket: Sent read receipt for message $messageId');
  }

  /// Ngắt kết nối WebSocket
  void disconnect() {
    if (_stompClient != null) {
      debugPrint('WebSocket: Disconnecting...');
      _stompClient!.deactivate();
      _stompClient = null;
      _isConnected = false;
      _currentUserId = null;
      _connectionController.add(false);
    }
  }

  /// Cleanup tất cả resources
  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _notificationController.close();
    _userStatusController.close();
    _connectionController.close();
  }
}