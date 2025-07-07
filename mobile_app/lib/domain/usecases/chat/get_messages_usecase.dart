import 'package:flutter/foundation.dart';
import '../../../core/services/chat_service.dart';
import '../../../app/di/injection.dart';

/// Use case để lấy tin nhắn từ một chat room
/// Gọi qua ChatService -> MessageRepository -> ChatApi -> REST API
class GetMessagesUseCase {
  final ChatService _chatService = getIt<ChatService>();

  /// Execute method để lấy tin nhắn với pagination
  /// Trả về Map chứa messages và pagination info
  /// cursor: ID của message cuối cùng để load tiếp
  /// limit: số lượng messages mỗi page (default 20)
  /// direction: 'NEXT' để load tin nhắn cũ hơn, 'PREV' để load tin nhắn mới hơn
  Future<Map<String, dynamic>> execute(String chatRoomId, {
    int? cursor,
    int limit = 20,
    String direction = 'NEXT',
  }) async {
    debugPrint('GetMessagesUseCase: Getting messages for chat $chatRoomId with cursor=$cursor, limit=$limit');
    
    return await _chatService.getMessages(
      chatRoomId,
      cursor: cursor,
      limit: limit,
      direction: direction,
    );
  }
}