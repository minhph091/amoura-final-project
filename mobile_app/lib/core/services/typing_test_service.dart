import 'dart:async';
import 'package:flutter/foundation.dart';
import '../infrastructure/socket/socket_client.dart';
import '../app/di/injection.dart';

/// Service để test typing indicator với mock data
class TypingTestService {
  static final TypingTestService _instance = TypingTestService._internal();
  factory TypingTestService() => _instance;
  TypingTestService._internal();

  final SocketClient _socketClient = getIt<SocketClient>();
  final StreamController<Map<String, dynamic>> _mockTypingController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get mockTypingStream => _mockTypingController.stream;

  /// Simulate typing indicator from WebSocket
  void simulateTypingIndicator({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required bool isTyping,
  }) {
    debugPrint('TypingTestService: Simulating typing indicator - ChatId: $chatRoomId, SenderId: $senderId, SenderName: $senderName, IsTyping: $isTyping');
    
    final mockTypingData = {
      'chatRoomId': chatRoomId,
      'typing': isTyping,
      'senderId': senderId,
      'senderName': senderName,
      'content': isTyping.toString(),
      'type': 'TYPING',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    debugPrint('TypingTestService: Emitting mock typing data: $mockTypingData');
    _mockTypingController.add(mockTypingData);
  }

  /// Send real typing indicator via WebSocket
  void sendRealTypingIndicator(String chatRoomId, bool isTyping) {
    debugPrint('TypingTestService: Sending real typing indicator - ChatId: $chatRoomId, IsTyping: $isTyping');
    _socketClient.sendTypingIndicator(chatRoomId, isTyping);
  }

  /// Get current connection status
  bool get isConnected => _socketClient.isConnected;

  /// Get current user ID
  String? get currentUserId => _socketClient.currentUserId;

  /// Dispose resources
  void dispose() {
    _mockTypingController.close();
  }
} 