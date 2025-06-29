import '../../../core/services/chat_service.dart';
import '../../../app/di/injection.dart';

class RecallMessageUseCase {
  final ChatService _chatService = getIt<ChatService>();

  RecallMessageUseCase();

  /// Thu hồi tin nhắn (trong vòng 30 phút sau khi gửi)
  Future<void> execute(String messageId) async {
    return await _chatService.recallMessage(messageId);
  }
} 