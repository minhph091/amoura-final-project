import '../../domain/models/chat.dart';
import '../../domain/repositories/chat_repository.dart';

// This is a mock implementation for demonstration purposes
class ChatRepositoryImpl implements ChatRepository {
  final List<Chat> _mockChats = [];

  @override
  Future<List<Chat>> getAllChats() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockChats;
  }

  @override
  Future<Chat> getChatById(String chatId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final chat = _mockChats.firstWhere(
      (c) => c.id == chatId,
      orElse: () => Chat(
        id: chatId,
        participantIds: ['current_user_id', 'recipient_id'],
        lastSeenAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    );

    return chat;
  }

  @override
  Future<void> createChat(Chat chat) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    _mockChats.add(chat);
  }

  @override
  Future<void> updateChat(Chat chat) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockChats.indexWhere((c) => c.id == chat.id);
    if (index != -1) {
      _mockChats[index] = chat;
    } else {
      _mockChats.add(chat);
    }
  }

  @override
  Future<void> deleteChat(String chatId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    _mockChats.removeWhere((c) => c.id == chatId);
  }

  @override
  Future<void> updateChatLastMessage(String chatId, String lastMessage, DateTime timestamp) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockChats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _mockChats[index] = _mockChats[index].copyWith(
        lastMessage: lastMessage,
        lastMessageTime: timestamp,
      );
    }
  }
}
