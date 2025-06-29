import '../../../core/services/chat_service.dart';
import '../../../app/di/injection.dart';

class DeleteMessageUseCase {
  final ChatService _chatService = getIt<ChatService>();

  DeleteMessageUseCase();

  /// Xóa tin nhắn cho riêng user hiện tại
  Future<void> execute(String messageId) async {
    return await _chatService.deleteMessage(messageId);
  }
} 