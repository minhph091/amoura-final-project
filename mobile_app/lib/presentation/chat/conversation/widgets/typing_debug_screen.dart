import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../core/services/typing_debug_service.dart';
import 'typing_indicator.dart';

/// Debug screen để test typing indicator với real WebSocket
class TypingDebugScreen extends StatefulWidget {
  const TypingDebugScreen({super.key});

  @override
  State<TypingDebugScreen> createState() => _TypingDebugScreenState();
}

class _TypingDebugScreenState extends State<TypingDebugScreen> {
  final TypingDebugService _debugService = TypingDebugService();
  final List<Map<String, dynamic>> _debugLogs = [];
  final TextEditingController _chatIdController = TextEditingController(text: '1');
  bool _isTyping = false;
  String _userName = 'Ly Đinh';
  StreamSubscription? _debugSubscription;

  @override
  void initState() {
    super.initState();
    _debugService.initialize();
    _setupDebugListener();
  }

  void _setupDebugListener() {
    _debugSubscription = _debugService.debugStream.listen((debugData) {
      setState(() {
        _debugLogs.insert(0, debugData);
        if (_debugLogs.length > 50) {
          _debugLogs.removeLast();
        }
      });
    });
  }

  @override
  void dispose() {
    _debugSubscription?.cancel();
    _debugService.dispose();
    _chatIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Debug Screen'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Connection status
          Container(
            padding: const EdgeInsets.all(16),
            color: _debugService.isConnected ? Colors.green[100] : Colors.red[100],
            child: Row(
              children: [
                Icon(
                  _debugService.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _debugService.isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'WebSocket: ${_debugService.isConnected ? "Connected" : "Disconnected"}',
                  style: TextStyle(
                    color: _debugService.isConnected ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'User ID: ${_debugService.currentUserId ?? "Unknown"}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          // Typing indicator preview
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Typing Indicator Preview:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TypingIndicator(
                  isTyping: _isTyping,
                  userName: _isTyping ? _userName : null,
                  isDarkMode: true,
                ),
              ],
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatIdController,
                        decoration: const InputDecoration(
                          labelText: 'Chat Room ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        initialValue: _userName,
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
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _debugService.sendTestTypingIndicator(
                            _chatIdController.text,
                            true,
                          );
                          setState(() {
                            _isTyping = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Start Typing'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _debugService.sendTestTypingIndicator(
                            _chatIdController.text,
                            false,
                          );
                          setState(() {
                            _isTyping = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Stop Typing'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Debug logs
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Debug Logs (${_debugLogs.length}):',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _debugLogs.clear();
                          });
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: _debugLogs.length,
                        itemBuilder: (context, index) {
                          final log = _debugLogs[index];
                          final type = log['type'] as String;
                          final data = log['data'] as Map<String, dynamic>;
                          final timestamp = log['timestamp'] as String;

                          Color logColor;
                          switch (type) {
                            case 'TYPING':
                              logColor = Colors.blue;
                              break;
                            case 'MESSAGE':
                              logColor = Colors.green;
                              break;
                            case 'CONNECTION':
                              logColor = Colors.orange;
                              break;
                            case 'SENT_TYPING':
                              logColor = Colors.purple;
                              break;
                            case 'SENT_TYPING_ERROR':
                              logColor = Colors.red;
                              break;
                            default:
                              logColor = Colors.grey;
                          }

                          return Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: logColor.withValues(alpha: 0.1),
                              border: Border(
                                left: BorderSide(color: logColor, width: 3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: logColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        type,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      timestamp.substring(11, 19), // HH:mm:ss
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data.toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 