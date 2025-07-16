import '../../../core/services/chat_service.dart';
import '../../../domain/models/chat.dart';
import '../../../app/di/injection.dart';

/// Use case để lấy danh sách conversations/chat rooms
/// Gọi qua ChatService -> ChatRepository -> ChatApi -> REST API
class GetConversationsUseCase {
  final ChatService _chatService = getIt<ChatService>();

  /// Execute method để lấy danh sách chat rooms
  Future<List<Chat>> execute() async {
    return await _chatService.getChatRooms();
  }
}
