# Typing Indicator Implementation

## Tổng quan

Tính năng typing indicator đã được implement trong mobile app để hiển thị trạng thái đang nhập tin nhắn của đối phương, tương tự như trong web chat.

## Các thành phần chính

### 1. TypingIndicator Widget
- **File**: `lib/presentation/chat/conversation/widgets/typing_indicator.dart`
- **Chức năng**: Hiển thị animation dots và text "đang nhập tin nhắn"
- **Features**:
  - Animation dots với delay khác nhau
  - Slide và fade animation khi xuất hiện
  - Hỗ trợ dark mode
  - Customizable user name

### 2. MessageInput Widget (Updated)
- **File**: `lib/presentation/chat/conversation/widgets/message_input.dart`
- **Chức năng**: Gửi typing indicator khi user nhập tin nhắn
- **Features**:
  - Debounce timer (2 giây)
  - Tự động gửi typing indicator khi bắt đầu nhập
  - Tự động dừng typing indicator khi dừng nhập hoặc gửi tin nhắn
  - Callback để thông báo thay đổi trạng thái typing

### 3. ChatService (Updated)
- **File**: `lib/core/services/chat_service.dart`
- **Chức năng**: Xử lý typing indicator qua WebSocket
- **Features**:
  - Gửi typing indicator qua WebSocket
  - Nhận và xử lý typing indicator từ server
  - Stream để broadcast typing events
  - Tích hợp với SocketClient

### 4. SocketClient (Existing)
- **File**: `lib/infrastructure/socket/socket_client.dart`
- **Chức năng**: Gửi typing indicator qua STOMP protocol
- **Features**:
  - Destination: `/app/chat.typing`
  - Format: `{chatRoomId, typing, timestamp}`
  - Tích hợp với WebSocketConfig

## Cách sử dụng

### 1. Trong ChatConversationView

```dart
class _ChatConversationViewState extends State<ChatConversationView> {
  final ChatService _chatService = getIt<ChatService>();
  bool _isTyping = false;
  String? _typingUserName;
  StreamSubscription? _typingSubscription;

  @override
  void initState() {
    super.initState();
    _setupTypingListener();
  }

  void _setupTypingListener() {
    _typingSubscription = _chatService.typingStream.listen((typingData) {
      final chatRoomId = typingData['chatRoomId']?.toString();
      final isTyping = typingData['typing'] == true;
      final senderId = typingData['senderId']?.toString();
      
      if (chatRoomId == widget.conversationId.toString() && 
          senderId != null && 
          senderId != currentUserId) {
        setState(() {
          _isTyping = isTyping;
          _typingUserName = isTyping ? widget.recipientName : null;
        });
      }
    });
  }

  void _handleTypingChange(bool isTyping) {
    _chatService.sendTypingIndicator(
      widget.conversationId.toString(), 
      isTyping
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Messages list
        Expanded(
          child: ListView.builder(
            // ... message list
          ),
        ),
        
        // Typing indicator
        TypingIndicator(
          isTyping: _isTyping,
          userName: _typingUserName,
        ),
        
        // Message input
        MessageInput(
          onSendMessage: _handleSendMessage,
          onTypingChange: _handleTypingChange,
          chatId: widget.conversationId.toString(),
          // ... other props
        ),
      ],
    );
  }

  @override
  void dispose() {
    _typingSubscription?.cancel();
    super.dispose();
  }
}
```

### 2. WebSocket Message Format

#### Gửi typing indicator:
```json
{
  "chatRoomId": 123,
  "typing": true,
  "timestamp": "2024-01-01T12:00:00Z"
}
```

#### Nhận typing indicator:
```json
{
  "type": "TYPING",
  "chatRoomId": "123",
  "content": "true",
  "senderId": "456",
  "senderName": "John Doe",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

## Testing

### 1. TypingIndicatorTest Widget
- **File**: `lib/presentation/chat/conversation/widgets/typing_indicator_test.dart`
- **Chức năng**: Test UI của typing indicator
- **Cách sử dụng**: Navigate đến TypingIndicatorTest để test animation

### 2. WebSocket Testing
- Sử dụng web chat để test typing indicator realtime
- Mở web chat và mobile app cùng lúc
- Nhập tin nhắn trong web chat để xem typing indicator trong mobile app

## Cấu hình

### WebSocket Config
- **Typing Destination**: `/app/chat.typing`
- **Typing Topic**: `/topic/chat/{chatRoomId}/typing`
- **Debounce Time**: 2 giây

### Environment
- **Dev**: `ws://10.0.2.2:8080/ws`
- **Staging**: `ws://150.95.109.13:8080/api/ws`
- **Prod**: `wss://api.amoura.space/api/ws`

## Troubleshooting

### 1. Typing indicator không hiển thị
- Kiểm tra WebSocket connection
- Kiểm tra chatRoomId có đúng không
- Kiểm tra senderId có khác currentUserId không

### 2. Typing indicator không dừng
- Kiểm tra debounce timer trong MessageInput
- Kiểm tra dispose method có cancel subscription không

### 3. WebSocket connection issues
- Kiểm tra environment config
- Kiểm tra JWT token
- Kiểm tra network connectivity

## Future Improvements

1. **Typing sound**: Thêm âm thanh khi có typing indicator
2. **Multiple users**: Hỗ trợ hiển thị nhiều user đang typing
3. **Typing history**: Lưu lịch sử typing để analytics
4. **Custom animations**: Cho phép customize animation style
5. **Typing speed**: Hiển thị tốc độ typing của user 