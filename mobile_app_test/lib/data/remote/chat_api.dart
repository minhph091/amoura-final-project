import '../../core/api/api_client.dart';
import '../../core/constants/api_endpoints.dart';
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
    String? replyToMessageId,
  }) async {
    // Backend validation: IMAGE message cần imageUrl, content có thể empty
    final requestData = <String, dynamic>{
      'chatRoomId': int.parse(chatRoomId),
      'messageType': type.name.toUpperCase(),
    };

    // Add reply information if provided
    if (replyToMessageId != null && replyToMessageId.isNotEmpty) {
      requestData['replyToMessageId'] = int.parse(replyToMessageId);
      debugPrint('ChatApi: Adding reply to message ID: $replyToMessageId');

      // Store reply info locally for fallback if backend doesn't return it
      // Note: This would require access to messages to find the original message
      // For now, we'll rely on the backend to return this information
    }

    if (type == MessageType.image) {
      // Cho IMAGE message: Backend yêu cầu content không được rỗng (@NotBlank validation)
      // Nếu user không nhập caption thì dùng fallback text
      final imageContent = content.trim().isEmpty ? 'Photo' : content.trim();
      requestData['content'] = imageContent;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        requestData['imageUrl'] = imageUrl;
        debugPrint(
          'ChatApi: IMAGE message - Content: "$imageContent", ImageUrl: $imageUrl, ReplyTo: $replyToMessageId',
        );
      } else {
        debugPrint(
          'ChatApi: ERROR - ImageUrl is required for IMAGE message type',
        );
        throw Exception('ImageUrl is required for IMAGE message type');
      }
    } else {
      // Cho TEXT message: content bắt buộc, không được rỗng
      final textContent = content.trim();
      if (textContent.isEmpty) {
        debugPrint(
          'ChatApi: ERROR - Content is required for TEXT message type',
        );
        throw Exception('Content is required for TEXT message type');
      }
      requestData['content'] = textContent;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        requestData['imageUrl'] = imageUrl;
      }
      debugPrint(
        'ChatApi: TEXT message - Content: "$textContent", ReplyTo: $replyToMessageId',
      );
    }

    try {
      debugPrint('ChatApi: Sending message with data: $requestData');

      final response = await _apiClient.post(
        ApiEndpoints.chatMessages,
        data: requestData,
      );

      debugPrint(
        'ChatApi: Message sent successfully - Status: ${response.statusCode}',
      );
      debugPrint('ChatApi: Response data: ${response.data}');

      final sentMessage = Message.fromJson(response.data);

      // If backend doesn't return reply information but we sent it, we need to preserve it
      // This is a fallback in case backend API doesn't include reply fields in response
      if (replyToMessageId != null &&
          replyToMessageId.isNotEmpty &&
          (sentMessage.replyToMessageId == null ||
              sentMessage.replyToMessageId!.isEmpty)) {
        debugPrint(
          'ChatApi: Backend response missing reply info, preserving locally sent replyToMessageId: $replyToMessageId',
        );

        // Return message with reply info preserved
        // Note: We may need the original message content and sender name
        // This would typically be passed from the calling service/repository
        return sentMessage.copyWith(
          replyToMessageId: replyToMessageId,
          // These would need to be passed from the calling method:
          // replyToMessage: localReplyToMessage,
          // replyToSenderName: localReplyToSenderName,
        );
      }

      return sentMessage;
    } catch (e) {
      debugPrint('ChatApi: ERROR sending message - Request data: $requestData');
      debugPrint('ChatApi: ERROR details: $e');
      if (e.toString().contains('400')) {
        debugPrint(
          'ChatApi: 400 Bad Request - Check request format and required fields',
        );
      }
      rethrow;
    }
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
      debugPrint(
        'ChatApi: Getting messages for chat room $chatRoomId with cursor: $cursor',
      );

      final response = await _apiClient.get(
        ApiEndpoints.chatMessagesByRoom(chatRoomId),
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
          'direction': direction,
        },
      );

      debugPrint('ChatApi: Messages response status: ${response.statusCode}');
      debugPrint(
        'ChatApi: Messages response data type: ${response.data.runtimeType}',
      );
      debugPrint(
        'ChatApi: Messages response keys: ${response.data?.keys?.toList()}',
      );

      final data = response.data;
      // Backend trả về CursorPaginationResponse với field 'data' chứa danh sách messages
      final List<dynamic> messagesJson = data['data'] ?? [];
      debugPrint('ChatApi: Found ${messagesJson.length} messages in response');

      // Debug từng message để xem structure
      if (messagesJson.isNotEmpty) {
        debugPrint('ChatApi: Sample message structure: ${messagesJson.first}');
      }

      final messages =
          messagesJson.map((json) => Message.fromJson(json)).toList();
      debugPrint(
        'ChatApi: Parsed ${messages.length} message objects successfully',
      );

      return {
        'messages': messages,
        'hasNext': data['hasNext'] ?? false,
        'hasPrevious': data['hasPrevious'] ?? false,
        'nextCursor': data['nextCursor'],
        'previousCursor': data['previousCursor'],
        'totalCount': data['totalCount'] ?? messages.length,
      };
    } catch (e) {
      debugPrint(
        'ChatApi: Error getting messages for chat room $chatRoomId: $e',
      );
      rethrow;
    }
  }

  /// Đánh dấu tin nhắn đã đọc
  /// Sử dụng REST API endpoint: PUT /api/chat/rooms/{chatRoomId}/messages/read
  /// Sau khi gọi API này, backend sẽ gửi WebSocket message type "READ_RECEIPT" cho các client khác
  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      await _apiClient.put(ApiEndpoints.markMessagesAsRead(chatRoomId));
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
    try {
      debugPrint('ChatApi: Uploading image for chat $chatRoomId');
      debugPrint('ChatApi: File path: ${file.path}');
      debugPrint('ChatApi: File size: ${await file.length()} bytes');

      final response = await _apiClient.uploadMultipart(
        ApiEndpoints.chatUploadImage,
        fileField: 'file',
        filePath: file.path,
        additionalData: {'chatRoomId': int.parse(chatRoomId)},
      );

      debugPrint('ChatApi: Upload response status: ${response.statusCode}');
      debugPrint(
        'ChatApi: Upload response data type: ${response.data.runtimeType}',
      );
      debugPrint('ChatApi: Upload response raw data: ${response.data}');

      // Backend trả về plain text URL (String) - không phải JSON
      if (response.data == null) {
        throw Exception('Upload response is null');
      }

      String imageUrl;

      // Backend trả về plain text URL theo backend controller design
      if (response.data is String) {
        imageUrl = response.data as String;
        debugPrint('ChatApi: Got plain text URL: $imageUrl');
      } else {
        // Fallback: convert any response to string
        imageUrl = response.data.toString();
        debugPrint('ChatApi: Converted response to string: $imageUrl');
      }

      // Validate URL
      if (imageUrl.isEmpty) {
        debugPrint('ChatApi: ERROR - Empty URL returned from upload');
        throw Exception('Empty URL returned from upload');
      }

      if (!imageUrl.contains('http')) {
        debugPrint('ChatApi: ERROR - Invalid URL format: $imageUrl');
        throw Exception('Invalid URL format returned from upload: $imageUrl');
      }

      debugPrint('ChatApi: Upload successful - URL: $imageUrl');
      return imageUrl;
    } catch (e) {
      debugPrint('ChatApi: Error uploading image: $e');
      debugPrint('ChatApi: Error type: ${e.runtimeType}');

      // Provide more specific error messages
      if (e.toString().contains('FormatException')) {
        debugPrint(
          'ChatApi: Format exception - backend returned non-JSON response',
        );
        throw Exception('Backend returned invalid response format');
      } else if (e.toString().contains('DioException')) {
        debugPrint('ChatApi: Network error during upload');
        throw Exception('Network error during image upload');
      }

      rethrow;
    }
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
    debugPrint(
      'Sending typing indicator: $isTyping for chat room: $chatRoomId',
    );
  }

  /// Subscribe vào topic chat để nhận tin nhắn realtime
  /// Sử dụng WebSocket topic: /topic/chat/{chatRoomId}
  Future<void> subscribeToChatRoom(
    String chatRoomId,
    Function(Map<String, dynamic>) onMessageReceived,
  ) async {
    // TODO: Implement WebSocket subscription
    // Đây sẽ được implement khi có WebSocket client
    debugPrint('Subscribing to chat room: $chatRoomId');
  }

  /// Subscribe vào topic user status để nhận thông báo online/offline
  /// Sử dụng WebSocket topic: /topic/chat/{chatRoomId}/user-status
  Future<void> subscribeToUserStatus(
    String chatRoomId,
    Function(Map<String, dynamic>) onStatusChanged,
  ) async {
    // TODO: Implement WebSocket user status subscription
    // Đây sẽ được implement khi có WebSocket client
    debugPrint('Subscribing to user status for chat room: $chatRoomId');
  }

  /// Subscribe vào queue thông báo cá nhân để nhận thông báo match
  /// Sử dụng WebSocket queue: /user/queue/notification
  Future<void> subscribeToNotifications(
    Function(Map<String, dynamic>) onNotificationReceived,
  ) async {
    // TODO: Implement WebSocket notification subscription
    // Đây sẽ được implement khi có WebSocket client
    debugPrint('Subscribing to notifications');
  }
}
