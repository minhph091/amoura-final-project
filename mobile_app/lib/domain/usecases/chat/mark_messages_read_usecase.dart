import '../../../core/services/chat_service.dart';
import '../../../app/di/injection.dart';

class MarkMessagesReadUseCase {
  final ChatService _chatService = getIt<ChatService>();

  MarkMessagesReadUseCase();

  /// Đánh dấu tin nhắn đã đọc trong chat room
  Future<void> execute(String chatRoomId) async {
    return await _chatService.markMessagesAsRead(chatRoomId);
  }
} 
