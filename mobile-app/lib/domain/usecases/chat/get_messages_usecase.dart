import '../../../core/services/chat_service.dart';
import '../../../app/di/injection.dart';

/// Use case để lấy tin nhắn từ một chat room
/// Gọi qua ChatService -> MessageRepository -> ChatApi -> REST API
class GetMessagesUseCase {
  final ChatService _chatService = getIt<ChatService>();

  /// Execute method để lấy tin nhắn với pagination
  /// Trả về Map chứa messages và pagination info
  Future<Map<String, dynamic>> execute(String chatRoomId, {
    int? cursor,
    int limit = 20,
    String direction = 'NEXT',
  }) async {
    return await _chatService.getMessages(
      chatRoomId,
      cursor: cursor,
      limit: limit,
      direction: direction,
    );
  }
}