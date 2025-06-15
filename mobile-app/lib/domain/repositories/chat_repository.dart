import '../models/chat.dart';

abstract class ChatRepository {
  Future<List<Chat>> getAllChats();
  Future<Chat> getChatById(String chatId);
  Future<void> createChat(Chat chat);
  Future<void> updateChat(Chat chat);
  Future<void> deleteChat(String chatId);
  Future<void> updateChatLastMessage(String chatId, String lastMessage, DateTime timestamp);
}
