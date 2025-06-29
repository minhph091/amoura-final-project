import 'dart:io';
import '../models/message.dart';

abstract class MessageRepository {
  /// Lấy messages với pagination support
  /// Trả về Map hoặc List để tương thích với backend mới/cũ  
  Future<dynamic> getMessagesByChatId(String chatId, {
    int? cursor,
    int limit = 20,
    String direction = 'NEXT',
  });
  
  Future<Message> sendMessage(Message message);
  Future<void> updateMessage(Message message);
  Future<void> deleteMessage(String messageId);
  Future<String> uploadMedia(File file, MessageType type, String chatRoomId);
  Future<void> sendTypingIndicator(String userId, bool isTyping);
  Future<void> pinMessage(String messageId);
  Future<void> unpinMessage(String messageId);
  Future<void> unpinAllMessages(String chatId);
  Future<void> recallMessage(String messageId);
}
