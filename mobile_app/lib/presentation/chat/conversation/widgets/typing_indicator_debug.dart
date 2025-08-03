import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'typing_indicator.dart';

/// Debug widget để test typing indicator với mock data
class TypingIndicatorDebug extends StatefulWidget {
  const TypingIndicatorDebug({super.key});

  @override
  State<TypingIndicatorDebug> createState() => _TypingIndicatorDebugState();
}

class _TypingIndicatorDebugState extends State<TypingIndicatorDebug> {
  bool _isTyping = false;
  String _userName = 'Ly Đinh';
  Timer? _mockTypingTimer;

  @override
  void initState() {
    super.initState();
    _startMockTyping();
  }

  void _startMockTyping() {
    _mockTypingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _isTyping = !_isTyping;
      });
      
      debugPrint('TypingIndicatorDebug: Mock typing state changed to: $_isTyping');
    });
  }

  @override
  void dispose() {
    _mockTypingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Indicator Debug'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[900], // Dark theme like the image
        child: Column(
          children: [
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
                            'không thấy trạng thái nhập tin nhắn',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '31.16',
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
                      userName: _isTyping ? _userName : null,
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
            
            // Mock input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                border: Border(
                  top: BorderSide(color: Colors.grey[700]!),
                ),
              ),
              child: Row(
                children: [
                  // Attachment icon
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () {},
                  ),
                  
                  // Input field
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Nhập tin nhắn...',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          
                          // Emoji button
                          IconButton(
                            icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                            onPressed: () {},
                          ),
                          
                          // Send button
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
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