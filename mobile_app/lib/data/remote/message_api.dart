import '../../core/api/api_client.dart';
import '../../domain/models/message.dart';
import 'dart:io';

class MessageApi {
  final ApiClient _apiClient;
  MessageApi(this._apiClient);

  /// Lấy danh sách tin nhắn theo chatRoomId từ backend mới
  Future<List<Message>> getMessagesByChatId(String chatRoomId, {int page = 0, int size = 50}) async {
    final response = await _apiClient.get('/api/chat/rooms/$chatRoomId/messages', queryParameters: {
      'page': page,
      'size': size,
    });
    // Giả sử backend trả về dạng { content: [...], ... } hoặc List
    final data = response.data;
    List<dynamic> messagesJson;
    if (data is Map && data['content'] is List) {
      messagesJson = data['content'];
    } else if (data is List) {
      messagesJson = data;
    } else {
      messagesJson = [];
    }
    return messagesJson.map((json) => Message.fromJson(json)).toList();
  }

  /// Gửi tin nhắn mới
  Future<Message> sendMessage(Message message) async {
    // TODO: Thay endpoint '/api/messages' bằng endpoint thực tế từ backend
    final response = await _apiClient.post('/api/messages', data: {
      'chatId': message.chatId,
      'content': message.content,
      'type': message.type.index,
      'replyToMessageId': message.replyToMessageId,
    });
    if (response.data != null) {
      return Message.fromJson(response.data);
    }
    throw Exception('Failed to send message');
  }

  /// Cập nhật tin nhắn
  Future<void> updateMessage(Message message) async {
    // TODO: Thay endpoint '/api/messages/{messageId}' bằng endpoint thực tế từ backend
    await _apiClient.patch('/api/messages/${message.id}', data: {
      'content': message.content,
      'isEdited': message.isEdited,
    });
  }

  /// Xóa tin nhắn
  Future<void> deleteMessage(String messageId) async {
    // TODO: Thay endpoint '/api/messages/{messageId}' bằng endpoint thực tế từ backend
    await _apiClient.delete('/api/messages/$messageId');
  }

  /// Upload media file
  Future<String> uploadMedia(File file, MessageType type) async {
    // TODO: Thay endpoint '/api/messages/upload' bằng endpoint thực tế từ backend
    final response = await _apiClient.uploadMultipart(
      '/api/messages/upload',
      fileField: 'file',
      filePath: file.path,
    );
    if (response.data != null && response.data['url'] != null) {
      return response.data['url'];
    }
    throw Exception('Failed to upload media');
  }

  /// Pin tin nhắn
  Future<void> pinMessage(String messageId) async {
    // TODO: Thay endpoint '/api/messages/{messageId}/pin' bằng endpoint thực tế từ backend
    await _apiClient.post('/api/messages/$messageId/pin');
  }

  /// Unpin tin nhắn
  Future<void> unpinMessage(String messageId) async {
    // TODO: Thay endpoint '/api/messages/{messageId}/unpin' bằng endpoint thực tế từ backend
    await _apiClient.delete('/api/messages/$messageId/pin');
  }

  /// Unpin tất cả tin nhắn trong chat
  Future<void> unpinAllMessages(String chatId) async {
    // TODO: Thay endpoint '/api/chats/{chatId}/messages/unpin-all' bằng endpoint thực tế từ backend
    await _apiClient.delete('/api/chats/$chatId/messages/unpin-all');
  }
} 
