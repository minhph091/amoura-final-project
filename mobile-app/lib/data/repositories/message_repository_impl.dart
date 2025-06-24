import 'dart:io';
import '../../domain/models/message.dart';
import '../../domain/repositories/message_repository.dart';

// This is a mock implementation for demonstration purposes
class MessageRepositoryImpl implements MessageRepository {
  final List<Message> _mockMessages = [];

  @override
  Future<List<Message>> getMessagesByChatId(String chatId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockMessages.where((m) => m.chatId == chatId).toList();
  }

  @override
  Future<Message> sendMessage(Message message) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final sentMessage = message.copyWith(
      status: MessageStatus.sent,
    );

    _mockMessages.add(sentMessage);
    return sentMessage;
  }

  @override
  Future<void> updateMessage(Message message) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockMessages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _mockMessages[index] = message;
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    _mockMessages.removeWhere((m) => m.id == messageId);
  }

  @override
  Future<String> uploadMedia(File file, MessageType type) async {
    // Simulate file upload
    await Future.delayed(const Duration(seconds: 1));

    // Return a mock URL
    return 'https://example.com/media/${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  @override
  Future<void> sendTypingIndicator(String userId, bool isTyping) async {
    // In a real app, this would send the typing status to a real-time service
    print('User $userId is ${isTyping ? "typing" : "not typing"}');
  }

  @override
  Future<void> pinMessage(String messageId) {
    // TODO: implement pinMessage
    throw UnimplementedError();
  }

  @override
  Future<void> unpinAllMessages(String chatId) {
    // TODO: implement unpinAllMessages
    throw UnimplementedError();
  }

  @override
  Future<void> unpinMessage(String messageId) {
    // TODO: implement unpinMessage
    throw UnimplementedError();
  }
}
