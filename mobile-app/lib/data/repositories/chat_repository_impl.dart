import '../../domain/models/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../remote/chat_api.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatApi _chatApi;

  ChatRepositoryImpl(this._chatApi);

  @override
  Future<List<Chat>> getAllChats() async {
    return await _chatApi.getChatRooms();
  }

  @override
  Future<Chat> getChatById(String chatId) async {
    return await _chatApi.getChatRoomById(chatId);
  }

  @override
  Future<void> createChat(Chat chat) async {
    // Chat rooms are created automatically when users match
    // This method might not be needed or could be used for system chats
    throw UnimplementedError('Chat rooms are created automatically when users match');
  }

  @override
  Future<void> updateChat(Chat chat) async {
    // Chat updates are handled through message operations
    // This method might not be needed for the current implementation
    throw UnimplementedError('Chat updates are handled through message operations');
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await _chatApi.deactivateChatRoom(chatId);
  }

  @override
  Future<void> updateChatLastMessage(String chatId, String lastMessage, DateTime timestamp) async {
    // This is handled automatically by the backend when messages are sent
    // No need to implement this method as it's managed server-side
  }

  @override
  Future<void> markMessagesAsRead(String chatId) async {
    await _chatApi.markMessagesAsRead(chatId);
  }
}
