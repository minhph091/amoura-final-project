import 'dart:io';
import '../../domain/models/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../remote/chat_api.dart';
import 'package:flutter/foundation.dart';

class MessageRepositoryImpl implements MessageRepository {
  final ChatApi _chatApi;

  MessageRepositoryImpl(this._chatApi);

  @override
  Future<List<Message>> getMessagesByChatId(String chatId) async {
    try {
      debugPrint('MessageRepository: Getting messages for chat $chatId');
      final result = await _chatApi.getMessagesByChatId(chatId);
      final messages = result['messages'] as List<Message>;
      debugPrint('MessageRepository: Retrieved ${messages.length} messages from API');
      return messages;
    } catch (e) {
      debugPrint('MessageRepository: Error getting messages for chat $chatId: $e');
      rethrow;
    }
  }

  @override
  Future<Message> sendMessage(Message message) async {
    return await _chatApi.sendMessage(
      chatRoomId: message.chatId,
      content: message.content,
      type: message.type,
      imageUrl: message.mediaUrl,
    );
  }

  @override
  Future<void> updateMessage(Message message) async {
    // For now, we'll use recall message functionality
    // In the future, we might need to add edit message endpoint
    if (message.isEdited) {
      // If message was edited, we might need to implement edit functionality
      // For now, we'll just return as the backend handles this
      return;
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _chatApi.deleteMessageForMe(messageId);
  }

  @override
  Future<String> uploadMedia(File file, MessageType type) async {
    // For now, we'll use a placeholder chatRoomId
    // In a real implementation, you'd need to pass the actual chatRoomId
    return await _chatApi.uploadChatImage(file, '1');
  }

  @override
  Future<void> sendTypingIndicator(String userId, bool isTyping) async {
    // This would be implemented with WebSocket in a real app
    // For now, we'll just log it
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

  @override
  Future<void> recallMessage(String messageId) async {
    await _chatApi.recallMessage(messageId);
  }
}
