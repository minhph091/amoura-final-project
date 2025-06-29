import 'dart:io';
import '../models/message.dart';

abstract class MessageRepository {
  Future<List<Message>> getMessagesByChatId(String chatId);
  Future<Message> sendMessage(Message message);
  Future<void> updateMessage(Message message);
  Future<void> deleteMessage(String messageId);
  Future<String> uploadMedia(File file, MessageType type);
  Future<void> sendTypingIndicator(String userId, bool isTyping);
  Future<void> pinMessage(String messageId);
  Future<void> unpinMessage(String messageId);
  Future<void> unpinAllMessages(String chatId);
  Future<void> recallMessage(String messageId);
}
