import '../../core/api/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/websocket_config.dart';
import '../../domain/models/chat.dart';
import '../../domain/models/message.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ChatApi {
  final ApiClient _apiClient;
  
  ChatApi(this._apiClient);

  /// Lấy danh sách chat rooms của user với cursor-based pagination
  /// Sử dụng REST API endpoint: GET /api/chat/rooms
  Future<List<Chat>> getChatRooms({
    int? cursor,
    int limit = 20,
    String direction = 'NEXT',
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.chatRooms,
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
        'direction': direction,
      },
    );
    
    final List<dynamic> chatRoomsJson = response.data;
    return chatRoomsJson.map((json) => Chat.fromJson(json)).toList();
  }

  /// Lấy thông tin chat room theo ID
  /// Sử dụng REST API endpoint: GET /api/chat/rooms/{chatRoomId}
  Future<Chat> getChatRoomById(String chatRoomId) async {
    try {
      final endpoint = ApiEndpoints.chatRoomById(chatRoomId);
      debugPrint('ChatApi: Calling GET $endpoint for chatRoomId: $chatRoomId');
      
      final response = await _apiClient.get(endpoint);
      
      debugPrint('ChatApi: Response status: ${response.statusCode}');
      debugPrint('ChatApi: Response data type: ${response.data.runtimeType}');
      
      final chatRoom = Chat.fromJson(response.data);
      debugPrint('ChatApi: Chat room parsed successfully - ID: ${chatRoom.id}');
      
      return chatRoom;
    } catch (e) {
      debugPrint('ChatApi: Error getting chat room by ID $chatRoomId: $e');
      debugPrint('ChatApi: Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Deactivate chat room (ẩn khỏi danh sách chat)
  /// Sử dụng REST API endpoint: DELETE /api/chat/rooms/{chatRoomId}
  Future<void> deactivateChatRoom(String chatRoomId) async {
    await _apiClient.delete(ApiEndpoints.chatRoomById(chatRoomId));
  }

  /// Gửi tin nhắn mới qua REST API
  /// Sử dụng REST API endpoint: POST /api/chat/messages
  /// Lưu ý: Tin nhắn sẽ được broadcast qua WebSocket sau khi lưu thành công
  Future<Message> sendMessage({
    required String chatRoomId,
    required String content,
    required MessageType type,
    String? imageUrl,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.chatMessages,
      data: {
        'chatRoomId': int.parse(chatRoomId),
        'content': content,
        'messageType': type.name.toUpperCase(),
        if (imageUrl != null) 'imageUrl': imageUrl,
      },
    );
    
    return Message.fromJson(response.data);
  }

  /// Lấy danh sách tin nhắn theo chatRoomId với cursor-based pagination
  /// Sử dụng REST API endpoint: GET /api/chat/rooms/{chatRoomId}/messages
  /// Backend trả về CursorPaginationResponse với format: { data: [...], hasNext: bool, ... }
  Future<Map<String, dynamic>> getMessagesByChatId(
    String chatRoomId, {
    int? cursor,
    int limit = 20,
    String direction = 'NEXT',
  }) async {
    try {
      debugPrint('ChatApi: Getting messages for chat room $chatRoomId with cursor: $cursor');
      
      final response = await _apiClient.get(
        ApiEndpoints.chatMessagesByRoom(chatRoomId),
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
          'direction': direction,
        },
      );
      
      debugPrint('ChatApi: Messages response status: ${response.statusCode}');
      debugPrint('ChatApi: Messages response data type: ${response.data.runtimeType}');
      debugPrint('ChatApi: Messages response keys: ${response.data?.keys?.toList()}');
      
      final data = response.data;
      // Backend trả về CursorPaginationResponse với field 'data' chứa danh sách messages
      final List<dynamic> messagesJson = data['data'] ?? [];
      debugPrint('ChatApi: Found ${messagesJson.length} messages in response');
      
      // Debug từng message để xem structure
      if (messagesJson.isNotEmpty) {
        debugPrint('ChatApi: Sample message structure: ${messagesJson.first}');
      }
      
      final messages = messagesJson.map((json) => Message.fromJson(json)).toList();
      debugPrint('ChatApi: Parsed ${messages.length} message objects successfully');
      
      return {
        'messages': messages,
        'hasNext': data['hasNext'] ?? false,
        'hasPrevious': data['hasPrevious'] ?? false,
        'nextCursor': data['nextCursor'],
        'previousCursor': data['previousCursor'],
        'totalCount': data['totalCount'] ?? messages.length,
      };
    } catch (e) {
      debugPrint('ChatApi: Error getting messages for chat room $chatRoomId: $e');
      rethrow;
    }
  }

  /// Đánh dấu tin nhắn đã đọc
  /// Sử dụng REST API endpoint: PUT /api/chat/rooms/{chatRoomId}/messages/read
  /// Sau khi gọi API này, backend sẽ gửi WebSocket message type "READ_RECEIPT" cho các client khác
  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      await _apiClient.put(
        ApiEndpoints.markMessagesAsRead(chatRoomId),
      );
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
      // Don't rethrow as this is not critical
    }
  }

  /// Lấy số tin nhắn chưa đọc
  /// Sử dụng REST API endpoint: GET /api/chat/rooms/{chatRoomId}/messages/unread-count
  Future<int> getUnreadMessageCount(String chatRoomId) async {
    final response = await _apiClient.get(
      ApiEndpoints.unreadMessageCount(chatRoomId),
    );
    
    return response.data;
  }

  /// Xóa tin nhắn cho riêng user hiện tại
  /// Sử dụng REST API endpoint: POST /api/chat/messages/{messageId}/delete-for-me
  /// Tin nhắn sẽ bị ẩn khỏi danh sách tin nhắn của user này nhưng vẫn hiển thị cho user khác
  Future<void> deleteMessageForMe(String messageId) async {
    await _apiClient.post(ApiEndpoints.deleteMessageForMe(messageId));
  }

  /// Thu hồi tin nhắn (trong vòng 30 phút sau khi gửi)
  /// Sử dụng REST API endpoint: POST /api/chat/messages/{messageId}/recall
  /// Chỉ người gửi tin nhắn mới có thể thu hồi tin nhắn của mình
  /// Tất cả client trong phòng chat sẽ nhận được thông báo thu hồi ngay lập tức qua WebSocket
  Future<void> recallMessage(String messageId) async {
    await _apiClient.post(ApiEndpoints.recallMessage(messageId));
  }

  /// Upload ảnh cho chat
  /// Sử dụng REST API endpoint: POST /api/chat/upload-image
  /// Trả về URL của ảnh đã upload để sử dụng trong tin nhắn
  Future<String> uploadChatImage(File file, String chatRoomId) async {
    final response = await _apiClient.uploadMultipart(
      ApiEndpoints.chatUploadImage,
      fileField: 'file',
      filePath: file.path,
      additionalData: {
        'chatRoomId': chatRoomId,
      },
    );
    
    return response.data;
  }

  /// Xóa ảnh chat (chỉ người upload mới xóa được)
  /// Sử dụng REST API endpoint: DELETE /api/chat/delete-image
  Future<void> deleteChatImage(String imageUrl) async {
    await _apiClient.delete(
      ApiEndpoints.chatDeleteImage,
      queryParameters: {'imageUrl': imageUrl},
    );
  }

  /// Gửi typing indicator qua WebSocket
  /// Sử dụng WebSocket destination: /app/chat.typing
  /// Backend sẽ broadcast typing indicator tới tất cả thành viên trong phòng chat
  Future<void> sendTypingIndicator(String chatRoomId, bool isTyping) async {
    // TODO: Implement WebSocket typing indicator
    // Đây sẽ được implement khi có WebSocket client
    print('Sending typing indicator: $isTyping for chat room: $chatRoomId');
  }

  /// Subscribe vào topic chat để nhận tin nhắn realtime
  /// Sử dụng WebSocket topic: /topic/chat/{chatRoomId}
  Future<void> subscribeToChatRoom(String chatRoomId, Function(Map<String, dynamic>) onMessageReceived) async {
    // TODO: Implement WebSocket subscription
    // Đây sẽ được implement khi có WebSocket client
    print('Subscribing to chat room: $chatRoomId');
  }

  /// Subscribe vào topic user status để nhận thông báo online/offline
  /// Sử dụng WebSocket topic: /topic/chat/{chatRoomId}/user-status
  Future<void> subscribeToUserStatus(String chatRoomId, Function(Map<String, dynamic>) onStatusChanged) async {
    // TODO: Implement WebSocket user status subscription
    // Đây sẽ được implement khi có WebSocket client
    print('Subscribing to user status for chat room: $chatRoomId');
  }

  /// Subscribe vào queue thông báo cá nhân để nhận thông báo match
  /// Sử dụng WebSocket queue: /user/queue/notification
  Future<void> subscribeToNotifications(Function(Map<String, dynamic>) onNotificationReceived) async {
    // TODO: Implement WebSocket notification subscription
    // Đây sẽ được implement khi có WebSocket client
    print('Subscribing to notifications');
  }
}
