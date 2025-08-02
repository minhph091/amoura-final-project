import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../../core/constants/websocket_config.dart';
import '../../core/services/auth_service.dart';
import '../../app/di/injection.dart';
import '../../config/environment.dart';

/// WebSocket STOMP client để kết nối với Spring Boot backend
/// Xử lý việc nhận tin nhắn realtime, typing indicators, và notifications
class SocketClient {
  static final SocketClient _instance = SocketClient._internal();
  factory SocketClient() => _instance;
  SocketClient._internal();

  StompClient? _stompClient;
  bool _isConnected = false;
  String? _currentUserId;
  final AuthService _authService = getIt<AuthService>();

  // Stream controllers cho các loại events khác nhau
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _typingController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _userStatusController =
      StreamController.broadcast();
  final StreamController<bool> _connectionController =
      StreamController.broadcast();

  // Public streams để các service khác có thể subscribe
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;
  Stream<Map<String, dynamic>> get userStatusStream =>
      _userStatusController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;

  /// Kết nối tới WebSocket server với JWT authentication
  /// Sử dụng STOMP protocol trên WebSocket transport
  Future<void> connect(String userId) async {
    // Connection guard - prevent multiple simultaneous connections
    if (_isConnected && _currentUserId == userId) {
      debugPrint('WebSocket: Already connected for user $userId');
      return;
    }

    // If connecting to different user, disconnect first
    if (_isConnected && _currentUserId != userId) {
      debugPrint('WebSocket: Switching user from $_currentUserId to $userId');
      disconnect();
    }

    // Disconnect existing connection first
    if (_stompClient != null) {
      debugPrint('WebSocket: Disconnecting existing connection...');
      _stompClient!.deactivate();
      _stompClient = null;
      _isConnected = false;
    }

    try {
      _currentUserId = userId;

      // Lấy access token để authentication
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token available for WebSocket connection');
      }

      // Debug connection trước khi kết nối STOMP
      await testWebSocketConnection();

      // Sử dụng WebSocketConfig để lấy URL chuẩn
      String wsUrl = WebSocketConfig.wsEndpoint;
      
      debugPrint('WebSocket: wsUrl truyền vào StompClient = $wsUrl');
      debugPrint('WebSocket: Final URL before connect: $wsUrl');
      debugPrint('WebSocket: URL protocol check - starts with wss://: ${wsUrl.startsWith('wss://')}');
      debugPrint('WebSocket: URL protocol check - starts with ws://: ${wsUrl.startsWith('ws://')}');
      debugPrint('WebSocket: URL validation - contains /api/ws: ${wsUrl.contains('/api/ws')}');
      debugPrint('WebSocket: URL validation - ends with /: ${wsUrl.endsWith('/')}');
      debugPrint('WebSocket: Environment: ${EnvironmentConfig.current}');
      
      // Validate URL format before passing to StompClient
      if (!wsUrl.startsWith('ws://') && !wsUrl.startsWith('wss://')) {
        throw Exception('Invalid WebSocket URL format: $wsUrl');
      }

      // Đảm bảo URL không có trailing slash cho StompClient
      if (wsUrl.endsWith('/')) {
        wsUrl = wsUrl.substring(0, wsUrl.length - 1);
        debugPrint('WebSocket: Removed trailing slash, new URL: $wsUrl');
      }

      debugPrint('WebSocket: Final URL for StompClient: $wsUrl');
      debugPrint('WebSocket: URL length: ${wsUrl.length}');
      debugPrint('WebSocket: URL contains port 0: ${wsUrl.contains(':0')}');
      debugPrint('WebSocket: URL contains fragment #: ${wsUrl.contains('#')}');

      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrl,
          useSockJS: false, // Raw WebSocket cho mobile 
          onConnect: _onConnect,
          onDisconnect: _onDisconnect,    
          beforeConnect: () async {
            debugPrint('WebSocket: Preparing to connect...');
            debugPrint('WebSocket: About to connect to: $wsUrl');
          },
          onWebSocketError: (dynamic error) {
            debugPrint('WebSocket Error: $error');
            debugPrint('WebSocket Error Details: $error');
            debugPrint('WebSocket: Error occurred while connecting to: $wsUrl');
            debugPrint('WebSocket: Original URL was: $wsUrl');
            debugPrint('WebSocket: Error type: ${error.runtimeType}');
            _connectionController.add(false);
            _isConnected = false;
          },
          onStompError: (StompFrame frame) {
            debugPrint('STOMP Error: ${frame.body}');
            debugPrint('STOMP Error Headers: ${frame.headers}');
            debugPrint('STOMP Error Command: ${frame.command}');
            _connectionController.add(false);
            _isConnected = false;
          },
          onDebugMessage: (String message) {
            if (kDebugMode) {
              debugPrint('WebSocket Debug: $message');
            }
          },
          stompConnectHeaders: {
            'Authorization': 'Bearer $accessToken',
          },
          heartbeatIncoming: const Duration(seconds: 10),
          heartbeatOutgoing: const Duration(seconds: 10),
          reconnectDelay: const Duration(seconds: 5),
        ),
      );

      _stompClient!.activate();
    } catch (e) {
      debugPrint('WebSocket: Failed to connect - $e');
      _connectionController.add(false);
      _isConnected = false;
      rethrow;
    }
  }

  /// Callback khi kết nối WebSocket thành công
  /// Subscribe vào các topics cần thiết để nhận messages và notifications
  void _onConnect(StompFrame frame) {
    debugPrint('WebSocket: Connected successfully');
    _isConnected = true;
    _connectionController.add(true);

    // Subscribe to personal notification queue
    _stompClient!.subscribe(
      destination: '/user/queue/notification',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final data = json.decode(frame.body!);
            _notificationController.add(data);
            debugPrint('WebSocket: Received notification: ${frame.body}');
          } catch (e) {
            debugPrint('WebSocket: Failed to parse notification: $e');
          }
        }
      },
    );

    // Subscribe to user status updates
    _stompClient!.subscribe(
      destination: '/topic/user-status',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final data = json.decode(frame.body!);
            _userStatusController.add(data);
            debugPrint('WebSocket: User status update: ${frame.body}');
          } catch (e) {
            debugPrint('WebSocket: Failed to parse user status: $e');
          }
        }
      },
    );
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
  /// Note: User status updates sẽ được subscribe per chat room, không subscribe global
  void _subscribeToUserStatusUpdates() {
    if (_stompClient == null || !_isConnected) return;

    // Không subscribe global user status nữa
    // User status sẽ được subscribe per chat room khi cần
    debugPrint('WebSocket: User status updates will be subscribed per chat room');
  }

  /// Subscribe vào một chat room cụ thể để nhận tin nhắn realtime
  /// Topic: /topic/chat/{chatRoomId}
  String? subscribeToChat(
    String chatRoomId,
    Function(Map<String, dynamic>) onMessage,
  ) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('WebSocket: Cannot subscribe to chat - not connected');
      return null;
    }

    final destination = WebSocketConfig.chatTopic(chatRoomId);

    _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        try {
          if (frame.body != null) {
            final message = jsonDecode(frame.body!);
            debugPrint(
              'WebSocket: Received message in chat $chatRoomId - Type: ${message['type']}, Content: ${message['content']}',
            );
            debugPrint('WebSocket: Full message data: $message');

            // Xử lý các loại message khác nhau
            switch (message['type']) {
              case 'MESSAGE':
                // Tin nhắn thường - chỉ gửi vào stream chung
                _messageController.add(message);
                debugPrint('WebSocket: Added MESSAGE to stream - Sender: ${message['senderName']}');
                break;
              case 'TYPING':
                // Typing indicator
                _typingController.add(message);
                debugPrint('WebSocket: Added TYPING to stream');
                break;
              case 'READ_RECEIPT':
                // Read receipt
                _messageController.add(message);
                debugPrint('WebSocket: Added READ_RECEIPT to stream');
                break;
              case 'MESSAGE_RECALLED':
                // Message recalled
                _messageController.add(message);
                debugPrint('WebSocket: Added MESSAGE_RECALLED to stream');
                break;
              default:
                // Các loại message khác - chỉ gửi vào stream, không gọi onMessage để tránh duplicate
                _messageController.add(message);
                debugPrint(
                  'WebSocket: Unknown message type: ${message['type']}, added to stream',
                );
            }
          } else {
            debugPrint('WebSocket: Received empty message body in chat $chatRoomId');
          }
        } catch (e) {
          debugPrint('WebSocket: Error parsing chat message - $e');
          debugPrint('WebSocket: Raw frame body: ${frame.body}');
        }
      },
    );

    debugPrint('WebSocket: Subscribed to chat room $chatRoomId');
    // Return destination as subscription ID since stomp_dart_client doesn't provide subscription ID
    return destination;
  }

  /// Subscribe vào typing indicators của một chat room
  /// Topic: /topic/chat/{chatRoomId}/typing
  String? subscribeToTypingIndicators(
    String chatRoomId,
    Function(Map<String, dynamic>) onTyping,
  ) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('WebSocket: Cannot subscribe to typing - not connected');
      return null;
    }

    final destination = WebSocketConfig.typingIndicatorTopic(chatRoomId);

    _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        try {
          if (frame.body != null) {
            final typingData = jsonDecode(frame.body!);
            debugPrint(
              'WebSocket: Typing indicator in chat $chatRoomId - ${typingData['userId']} is ${typingData['isTyping'] ? "typing" : "not typing"}',
            );

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

    debugPrint(
      'WebSocket: Subscribed to typing indicators for chat $chatRoomId',
    );
    // Return destination as subscription ID
    return destination;
  }

  /// Subscribe vào user status updates cho một chat room cụ thể
  /// Topic: /topic/chat/{chatRoomId}/user-status
  String? subscribeToUserStatusInChat(
    String chatRoomId,
    Function(Map<String, dynamic>) onStatusUpdate,
  ) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('WebSocket: Cannot subscribe to user status - not connected');
      return null;
    }

    final destination = WebSocketConfig.userStatusInChatTopic(chatRoomId);

    _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        try {
          if (frame.body != null) {
            final statusData = jsonDecode(frame.body!);
            debugPrint(
              'WebSocket: User status update in chat $chatRoomId - User ${statusData['userId']} is ${statusData['status']}',
            );
            onStatusUpdate(statusData);
          }
        } catch (e) {
          debugPrint('WebSocket: Error parsing user status update - $e');
        }
      },
    );

    debugPrint(
      'WebSocket: Subscribed to user status updates for chat room $chatRoomId',
    );
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
      'typing': isTyping,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _stompClient!.send(
      destination: WebSocketConfig.typingDestination,
      body: jsonEncode(typingData),
    );

    debugPrint(
      'WebSocket: Sent typing indicator for chat $chatRoomId - $isTyping',
    );
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

  /// Test connection để debug URL và kết nối
  Future<void> testWebSocketConnection() async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        debugPrint('WebSocket Test: No access token available');
        return;
      }

      String testUrl = WebSocketConfig.wsEndpoint;
      // Không modify URL gốc
      String simpleTestUrl = testUrl;
      
      debugPrint('=== WebSocket Connection Test ===');
      debugPrint('Test URL: $testUrl');
      debugPrint('Environment: ${EnvironmentConfig.current}');
      debugPrint('Access Token available: ${accessToken.isNotEmpty}');
      debugPrint('================================');

      // Simple WebSocket test without STOMP cho production
      if (EnvironmentConfig.current == Environment.prod) {
        // Không thêm port 443 vì có thể gây xung đột
        debugPrint('Testing simple WebSocket connection to: $simpleTestUrl');
        
        try {
          final testWs = await WebSocket.connect(simpleTestUrl, headers: {
            'Authorization': 'Bearer $accessToken',
          });
          debugPrint('Simple WebSocket connection successful!');
          await testWs.close();
        } catch (e) {
          debugPrint('Simple WebSocket connection failed: $e');
        }
      }
    } catch (e) {
      debugPrint('WebSocket Test Error: $e');
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

  /// Gửi tin nhắn qua WebSocket
  /// Destination: /app/chat.sendMessage
  void sendMessage(
    String chatRoomId,
    String content,
    String messageType, {
    String? imageUrl,
  }) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('WebSocket: Cannot send message - not connected');
      return;
    }

    final messageData = {
      'chatRoomId': int.parse(chatRoomId),
      'content': content,
      'messageType': messageType.toUpperCase(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };

    _stompClient!.send(
      destination: WebSocketConfig.sendMessageWsDestination,
      body: jsonEncode(messageData),
    );

    debugPrint(
      'WebSocket: Sent message to chat $chatRoomId - Type: $messageType',
    );
  }
}
