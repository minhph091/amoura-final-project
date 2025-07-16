import '../../../core/services/chat_service.dart';
import '../../../domain/models/chat.dart';
import '../../../app/di/injection.dart';

/// Use case để lấy thông tin một chat room cụ thể
/// Gọi qua ChatService -> ChatRepository -> ChatApi -> REST API
class GetChatRoomUseCase {
  final ChatService _chatService = getIt<ChatService>();

  GetChatRoomUseCase();

  /// Execute method để lấy thông tin chat room theo ID
  /// Trả về Chat object từ backend
  Future<Chat> execute(String chatRoomId) async {
    return await _chatService.getChatRoom(chatRoomId);
  }
} 
