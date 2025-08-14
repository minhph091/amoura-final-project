import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../core/services/typing_test_service.dart';
import 'typing_indicator.dart';

/// Test screen để test typing indicator với mock data và real WebSocket
class TypingTestScreen extends StatefulWidget {
  const TypingTestScreen({super.key});

  @override
  State<TypingTestScreen> createState() => _TypingTestScreenState();
}

class _TypingTestScreenState extends State<TypingTestScreen> {
  final TypingTestService _testService = TypingTestService();
  final TextEditingController _chatIdController = TextEditingController(text: '1');
  final TextEditingController _senderIdController = TextEditingController(text: '2');
  final TextEditingController _senderNameController = TextEditingController(text: 'Đan Thuỷ Mai');
  
  bool _isTyping = false;
  String _typingUserName = '';
  StreamSubscription? _mockTypingSubscription;

  @override
  void initState() {
    super.initState();
    _setupMockTypingListener();
  }

  void _setupMockTypingListener() {
    _mockTypingSubscription = _testService.mockTypingStream.listen((typingData) {
      debugPrint('TypingTestScreen: Received mock typing data: $typingData');
      
      final chatRoomId = typingData['chatRoomId']?.toString();
      final isTyping = typingData['typing'] == true;
      final senderId = typingData['senderId']?.toString();
      final senderName = typingData['senderName']?.toString();
      final messageType = typingData['type']?.toString();
      
      debugPrint('TypingTestScreen: Processing typing - ChatRoomId: $chatRoomId, IsTyping: $isTyping, SenderId: $senderId, SenderName: $senderName, Type: $messageType');
      
      if (chatRoomId == _chatIdController.text && 
          senderId != null && 
          senderId != '1' && // Not current user
          messageType == 'TYPING') {
        
        setState(() {
          _isTyping = isTyping;
          _typingUserName = isTyping ? (senderName ?? 'Unknown User') : '';
        });
        
        debugPrint('TypingTestScreen: Updated typing state - IsTyping: $isTyping, UserName: $_typingUserName');
      }
    });
  }

  @override
  void dispose() {
    _mockTypingSubscription?.cancel();
    _testService.dispose();
    _chatIdController.dispose();
    _senderIdController.dispose();
    _senderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Test Screen'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[900], // Dark theme
        child: Column(
          children: [
            // Connection status
            Container(
              padding: const EdgeInsets.all(16),
              color: _testService.isConnected ? Colors.green[100] : Colors.red[100],
              child: Row(
                children: [
                  Icon(
                    _testService.isConnected ? Icons.wifi : Icons.wifi_off,
                    color: _testService.isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WebSocket: ${_testService.isConnected ? "Connected" : "Disconnected"}',
                    style: TextStyle(
                      color: _testService.isConnected ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'User ID: ${_testService.currentUserId ?? "Unknown"}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            // Mock chat area
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mock message bubble
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.pink, Colors.purple],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test message from Đan Thuỷ Mai',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '12:30',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Typing indicator
                    TypingIndicator(
                      isTyping: _isTyping,
                      userName: _isTyping ? _typingUserName : null,
                      isDarkMode: true,
                    ),
                    
                    // Purple line separator
                    Container(
                      height: 1,
                      color: Colors.purple,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ],
                ),
              ),
            ),
            
            // Controls
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[800],
              child: Column(
                children: [
                  // Input fields
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatIdController,
                          decoration: const InputDecoration(
                            labelText: 'Chat Room ID',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _senderIdController,
                          decoration: const InputDecoration(
                            labelText: 'Sender ID',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _senderNameController,
                    decoration: const InputDecoration(
                      labelText: 'Sender Name',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Test buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _testService.simulateTypingIndicator(
                              chatRoomId: _chatIdController.text,
                              senderId: _senderIdController.text,
                              senderName: _senderNameController.text,
                              isTyping: true,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Simulate Start Typing'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _testService.simulateTypingIndicator(
                              chatRoomId: _chatIdController.text,
                              senderId: _senderIdController.text,
                              senderName: _senderNameController.text,
                              isTyping: false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Simulate Stop Typing'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Real WebSocket buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _testService.sendRealTypingIndicator(
                              _chatIdController.text,
                              true,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Send Real Start Typing'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _testService.sendRealTypingIndicator(
                              _chatIdController.text,
                              false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Send Real Stop Typing'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status display
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Is Typing: $_isTyping',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'User Name: $_typingUserName',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Chat ID: ${_chatIdController.text}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 