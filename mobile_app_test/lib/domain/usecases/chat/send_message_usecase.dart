import '../../../core/services/chat_service.dart';
import '../../../domain/models/message.dart';
import '../../../app/di/injection.dart';

class SendMessageUseCase {
  final ChatService _chatService = getIt<ChatService>();

  SendMessageUseCase();

  /// Gửi tin nhắn mới trong cuộc trò chuyện
  Future<Message> execute({
    required String chatRoomId,
    required String content,
    required MessageType type,
    String? imageUrl,
    String? replyToMessageId,
  }) async {
    return await _chatService.sendMessage(
      chatRoomId: chatRoomId,
      content: content,
      type: type,
      imageUrl: imageUrl,
      replyToMessageId: replyToMessageId,
    );
  }
}
