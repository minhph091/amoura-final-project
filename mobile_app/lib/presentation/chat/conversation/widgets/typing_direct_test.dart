import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/chat_service.dart';
import '../../../app/di/injection.dart';
import 'typing_indicator.dart';

/// Direct test để emit typing data trực tiếp vào ChatService
class TypingDirectTest extends StatefulWidget {
  const TypingDirectTest({super.key});

  @override
  State<TypingDirectTest> createState() => _TypingDirectTestState();
}

class _TypingDirectTestState extends State<TypingDirectTest> {
  final ChatService _chatService = getIt<ChatService>();
  bool _isTyping = false;
  String _typingUserName = 'Đan Thủy Mai';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Direct Test'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[900],
        child: Column(
          children: [
            // Connection status
            Container(
              padding: const EdgeInsets.all(16),
              color: _chatService.isConnected ? Colors.green[100] : Colors.red[100],
              child: Row(
                children: [
                  Icon(
                    _chatService.isConnected ? Icons.wifi : Icons.wifi_off,
                    color: _chatService.isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WebSocket: ${_chatService.isConnected ? "Connected" : "Disconnected"}',
                    style: TextStyle(
                      color: _chatService.isConnected ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
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
                    // Mock message
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
                            'Test message from $_typingUserName',
                            style: const TextStyle(
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isTyping = true;
                            });
                            debugPrint('TypingDirectTest: Set typing to true');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Show Typing'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isTyping = false;
                            });
                            debugPrint('TypingDirectTest: Set typing to false');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Hide Typing'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Direct emit to ChatService
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _directEmitToChatService(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Direct Emit Start'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _directEmitToChatService(false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Direct Emit Stop'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status
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
                          'Status:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Is Typing: $_isTyping',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'User Name: $_typingUserName',
                          style: const TextStyle(color: Colors.white),
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

  void _directEmitToChatService(bool isTyping) {
    debugPrint('TypingDirectTest: Direct emitting to ChatService - IsTyping: $isTyping');
    
    // Direct emit typing data to ChatService typing stream
    final typingData = {
      'chatRoomId': '9310',
      'typing': isTyping,
      'senderId': '1912',
      'senderName': 'Đan Thủy Mai',
      'content': isTyping.toString(),
      'type': 'TYPING',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    debugPrint('TypingDirectTest: Emitting typing data to ChatService: $typingData');
    
    // This should trigger the typing indicator in chat conversation
    // We need to find a way to emit this data to the current chat conversation
    setState(() {
      _isTyping = isTyping;
    });
  }
} 