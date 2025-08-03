import 'package:flutter/material.dart';
import 'typing_indicator.dart';

/// Test widget để kiểm tra typing indicator
class TypingIndicatorTest extends StatefulWidget {
  const TypingIndicatorTest({super.key});

  @override
  State<TypingIndicatorTest> createState() => _TypingIndicatorTestState();
}

class _TypingIndicatorTestState extends State<TypingIndicatorTest> {
  bool _isTyping = false;
  String _userName = 'John Doe';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Indicator Test'),
      ),
      body: Column(
        children: [
          // Typing indicator
          TypingIndicator(
            isTyping: _isTyping,
            userName: _isTyping ? _userName : null,
          ),
          
          const SizedBox(height: 20),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isTyping = true;
                  });
                },
                child: const Text('Start Typing'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isTyping = false;
                  });
                },
                child: const Text('Stop Typing'),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // User name input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'User Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _userName = value;
                });
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Status
          Text(
            'Status: ${_isTyping ? "Typing" : "Not typing"}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
} 