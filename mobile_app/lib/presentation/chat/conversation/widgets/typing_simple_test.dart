import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'typing_indicator.dart';

/// Simple test để verify typing indicator hoạt động
class TypingSimpleTest extends StatefulWidget {
  const TypingSimpleTest({super.key});

  @override
  State<TypingSimpleTest> createState() => _TypingSimpleTestState();
}

class _TypingSimpleTestState extends State<TypingSimpleTest> {
  bool _isTyping = false;
  String _typingUserName = 'Đan Thủy Mai';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Simple Test'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[900],
        child: Column(
          children: [
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
                            debugPrint('TypingSimpleTest: Set typing to true');
                            
                            // Auto stop after 3 seconds
                            Future.delayed(const Duration(seconds: 3), () {
                              if (mounted) {
                                setState(() {
                                  _isTyping = false;
                                });
                                debugPrint('TypingSimpleTest: Auto stopped typing');
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Show Typing (3s)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isTyping = false;
                            });
                            debugPrint('TypingSimpleTest: Set typing to false');
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
} 