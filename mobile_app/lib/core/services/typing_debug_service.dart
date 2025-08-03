import 'dart:async';
import 'package:flutter/foundation.dart';
import '../infrastructure/socket/socket_client.dart';
import '../app/di/injection.dart';

/// Service để debug typing indicator
class TypingDebugService {
  static final TypingDebugService _instance = TypingDebugService._internal();
  factory TypingDebugService() => _instance;
  TypingDebugService._internal();

  final SocketClient _socketClient = getIt<SocketClient>();
  final StreamController<Map<String, dynamic>> _debugController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _connectionSubscription;

  Stream<Map<String, dynamic>> get debugStream => _debugController.stream;

  /// Initialize debug service
  void initialize() {
    debugPrint('TypingDebugService: Initializing...');
    
    // Listen to all WebSocket messages
    _messageSubscription = _socketClient.messageStream.listen((messageData) {
      debugPrint('TypingDebugService: Received message: $messageData');
      _debugController.add({
        'type': 'MESSAGE',
        'data': messageData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });

    // Listen to typing events
    _typingSubscription = _socketClient.typingStream.listen((typingData) {
      debugPrint('TypingDebugService: Received typing: $typingData');
      _debugController.add({
        'type': 'TYPING',
        'data': typingData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });

    // Listen to connection status
    _connectionSubscription = _socketClient.connectionStream.listen((connected) {
      debugPrint('TypingDebugService: Connection status: $connected');
      _debugController.add({
        'type': 'CONNECTION',
        'data': {'connected': connected},
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  /// Send test typing indicator
  void sendTestTypingIndicator(String chatRoomId, bool isTyping) {
    debugPrint('TypingDebugService: Sending test typing indicator - ChatId: $chatRoomId, IsTyping: $isTyping');
    
    try {
      _socketClient.sendTypingIndicator(chatRoomId, isTyping);
      _debugController.add({
        'type': 'SENT_TYPING',
        'data': {
          'chatRoomId': chatRoomId,
          'isTyping': isTyping,
          'success': true,
        },
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('TypingDebugService: Error sending typing indicator: $e');
      _debugController.add({
        'type': 'SENT_TYPING_ERROR',
        'data': {
          'chatRoomId': chatRoomId,
          'isTyping': isTyping,
          'error': e.toString(),
          'success': false,
        },
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Get current connection status
  bool get isConnected => _socketClient.isConnected;

  /// Get current user ID
  String? get currentUserId => _socketClient.currentUserId;

  /// Dispose resources
  void dispose() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _connectionSubscription?.cancel();
    _debugController.close();
  }
} 