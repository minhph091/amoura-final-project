# CHAT INTEGRATION GUIDE

## Tổng quan

Hệ thống chat đã được tích hợp đầy đủ với backend API theo pattern Clean Architecture của dự án. Tất cả các API endpoints đều được cấu hình trong một file duy nhất và có comment tiếng Việt chi tiết.

## Cấu trúc tích hợp

### 1. Service Layer

- **ChatService** (`lib/core/services/chat_service.dart`): Service chính xử lý tất cả logic chat
- **MessageRepository** và **ChatRepository**: Interface định nghĩa các method cần thiết

### 2. Use Case Layer

- **GetConversationsUseCase**: Lấy danh sách chat rooms
- **GetMessagesUseCase**: Lấy tin nhắn trong chat room
- **SendMessageUseCase**: Gửi tin nhắn mới
- **DeleteMessageUseCase**: Xóa tin nhắn cho riêng user
- **RecallMessageUseCase**: Thu hồi tin nhắn (trong 30 phút)
- **MarkMessagesReadUseCase**: Đánh dấu tin nhắn đã đọc
- **UploadChatImageUseCase**: Upload ảnh cho chat
- **CheckUserOnlineUseCase**: Kiểm tra trạng thái online của user

### 3. Repository Layer

- **ChatRepositoryImpl**: Implement ChatRepository interface
- **MessageRepositoryImpl**: Implement MessageRepository interface
- **ChatApi**: Gọi các REST API endpoints

### 4. Configuration

- **WebSocketConfig** (`lib/core/constants/websocket_config.dart`): Cấu hình tất cả WebSocket endpoints và topics
- **ChatApiConfig**: Cấu hình tất cả REST API endpoints cho chat
- **ApiEndpoints** (`lib/core/constants/api_endpoints.dart`): Định nghĩa các endpoint constants

## API Endpoints được tích hợp

### Chat Rooms

- `GET /api/chat/rooms` - Lấy danh sách chat rooms với pagination
- `GET /api/chat/rooms/{chatRoomId}` - Lấy thông tin chat room
- `DELETE /api/chat/rooms/{chatRoomId}` - Deactivate chat room

### Messages

- `POST /api/chat/messages` - Gửi tin nhắn mới
- `GET /api/chat/rooms/{chatRoomId}/messages` - Lấy tin nhắn với pagination
- `PATCH /api/chat/rooms/{chatRoomId}/messages/read` - Đánh dấu đã đọc
- `GET /api/chat/rooms/{chatRoomId}/messages/unread-count` - Số tin nhắn chưa đọc
- `POST /api/chat/messages/{messageId}/recall` - Thu hồi tin nhắn
- `POST /api/chat/messages/{messageId}/delete-for-me` - Xóa tin nhắn cho riêng mình

### File Upload

- `POST /api/chat/upload-image` - Upload hình ảnh cho chat
- `DELETE /api/chat/delete-image` - Xóa hình ảnh

## WebSocket Topics được cấu hình

### Chat Topics

- `/topic/chat/{chatRoomId}` - Nhận tin nhắn realtime trong phòng chat
- `/topic/chat/{chatRoomId}/user-status` - Nhận thông báo online/offline của user

### User Notifications

- `/user/queue/notification` - Nhận thông báo cá nhân (match, etc.)

### Message Destinations

- `/app/chat.sendMessage` - Gửi tin nhắn qua WebSocket
- `/app/chat.typing` - Gửi typing indicator
- `/app/chat.recallMessage` - Thu hồi tin nhắn qua WebSocket

## Cách sử dụng trong ViewModel

### ChatListViewModel

```dart
class ChatListViewModel extends ChangeNotifier {
  final GetConversationsUseCase _getConversationsUseCase = serviceLocator<GetConversationsUseCase>();

  Future<void> loadChatList() async {
    try {
      // Lấy danh sách chat rooms từ usecase
      final chats = await _getConversationsUseCase.execute();
      // Xử lý dữ liệu...
    } catch (e) {
      // Xử lý lỗi...
    }
  }
}
```

### ChatDetailViewModel

```dart
class ChatDetailViewModel extends ChangeNotifier {
  final GetMessagesUseCase _getMessagesUseCase = serviceLocator<GetMessagesUseCase>();
  final SendMessageUseCase _sendMessageUseCase = serviceLocator<SendMessageUseCase>();
  final RecallMessageUseCase _recallMessageUseCase = serviceLocator<RecallMessageUseCase>();

  Future<void> loadMessages(String chatId) async {
    final result = await _getMessagesUseCase.execute(chatId);
    final messages = result['messages'] as List<Message>;
    // Xử lý dữ liệu...
  }

  Future<void> sendMessage(String chatId, String message) async {
    await _sendMessageUseCase.execute(
      chatRoomId: chatId,
      content: message,
      type: MessageType.text,
    );
  }

  Future<void> recallMessage(String messageId) async {
    await _recallMessageUseCase.execute(messageId);
  }
}
```

## Tính năng đã được tích hợp

### ✅ Đã hoàn thành

1. **REST API Integration**: Tất cả endpoints đã được tích hợp
2. **Clean Architecture**: Tuân thủ pattern của dự án
3. **Dependency Injection**: Tất cả services và usecases đã được đăng ký
4. **Error Handling**: Xử lý lỗi đầy đủ với try-catch
5. **Comments**: Comment tiếng Việt chi tiết cho tất cả logic quan trọng
6. **Configuration**: Tất cả URLs được quản lý tập trung

### 🔄 Cần implement tiếp

1. **WebSocket Client**: Cần thêm thư viện WebSocket để implement realtime features
2. **Authentication**: Cần lấy current user ID từ AuthService
3. **User Profile**: Cần lấy thông tin user từ ProfileService
4. **Pagination**: Implement cursor-based pagination cho messages
5. **Typing Indicators**: Implement WebSocket typing indicators
6. **Online Status**: Implement WebSocket user status tracking
7. **Push Notifications**: Implement thông báo match qua WebSocket

## Lưu ý quan trọng

1. **Không sửa UI**: Tất cả logic UI đã được giữ nguyên, chỉ thay đổi data source
2. **Backend Integration**: Tất cả API calls đều gọi đến backend thực tế, không còn mock data
3. **Error Handling**: Có xử lý lỗi đầy đủ với fallback mechanisms
4. **Performance**: Sử dụng lazy loading và pagination để tối ưu performance
5. **Security**: Tất cả API calls đều có JWT authentication

## Next Steps

1. Thêm thư viện WebSocket (stomp-js hoặc tương tự)
2. Implement WebSocket client trong ChatService
3. Thêm realtime features (typing indicators, online status)
4. Implement push notifications cho match
5. Test tất cả features với backend thực tế
