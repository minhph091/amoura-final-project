import 'dart:io';
import '../../../core/services/chat_service.dart';
import '../../../app/di/injection.dart';

class UploadChatImageUseCase {
  final ChatService _chatService = getIt<ChatService>();

  UploadChatImageUseCase();

  /// Upload ảnh cho chat và trả về URL
  Future<String> execute(File file, String chatRoomId) async {
    return await _chatService.uploadChatImage(file, chatRoomId);
  }
} 
