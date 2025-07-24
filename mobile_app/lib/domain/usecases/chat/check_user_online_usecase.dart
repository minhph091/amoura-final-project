import '../../../core/services/chat_service.dart';
import '../../../app/di/injection.dart';

class CheckUserOnlineUseCase {
  final ChatService _chatService = getIt<ChatService>();

  CheckUserOnlineUseCase();

  /// Kiểm tra trạng thái online của user
  /// Gọi qua ChatService -> ChatApi -> REST API endpoint: GET /api/users/{userId}/online
  Future<bool> execute(String userId) async {
    return await _chatService.checkUserOnlineStatus(userId);
  }
} 
