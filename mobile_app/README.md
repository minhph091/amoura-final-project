# Amoura Mobile App — Tài liệu dự án

Ứng dụng Amoura là một ứng dụng hẹn hò đa nền tảng (Android/iOS) xây dựng bằng Flutter, áp dụng Clean Architecture, DI với get_it, quản lý trạng thái qua Provider, giao tiếp REST qua Dio, realtime qua WebSocket sử dụng STOMP, hỗ trợ đa ngôn ngữ và theme.

### Mục lục

- [Tổng quan](#tổng-quan)
- [Kiến trúc & cấu trúc thư mục](#kiến-trúc--cấu-trúc-thư-mục)
- [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
- [Cài đặt & chạy ứng dụng](#cài-đặt--chạy-ứng-dụng)
- [Cấu hình môi trường (dev/staging/prod)](#cấu-hình-môi-trường-devstagingprod)
- [HTTP Client & xử lý Token](#http-client--xử-lý-token)
- [Xác thực & đăng ký](#xác-thực--đăng-ký)
- [Điều hướng & bootstrap ứng dụng](#điều-hướng--bootstrap-ứng-dụng)
- [Đa ngôn ngữ & Theme](#đa-ngôn-ngữ--theme)
- [Realtime/WebSocket](#realtimewebsocket)
- [Chat](#chat)
- [Thông báo (Notifications)](#thông-báo-notifications)
- [Trạng thái người dùng (Online/Offline)](#trạng-thái-người-dùng-onlineoffline)
- [Khám phá/Matching & Hiệu năng](#khám-phámatching--hiệu-năng)
- [Quy trình build & phát hành](#quy-trình-build--phát-hành)
- [Quy ước mã nguồn & lint](#quy-ước-mã-nguồn--lint)
- [Troubleshooting](#troubleshooting)

## Tổng quan

- Ứng dụng cung cấp các tính năng: đăng nhập/đăng ký (OTP/email), thiết lập hồ sơ, màn hình khám phá và match, chat realtime (nhắn tin, gửi ảnh, typing indicator, read receipt, recall), thông báo realtime (match, tin nhắn, like), gói VIP, like/rewind, cài đặt, v.v.
- Tầng dữ liệu giao tiếp REST với backend, còn phần realtime sử dụng STOMP qua WebSocket với xác thực JWT.

## Kiến trúc & cấu trúc thư mục

Thư mục chính trong `lib/`:

- `app/`
  - `app.dart`: Khởi tạo `MaterialApp`, đa ngôn ngữ, theme, định tuyến.
  - `core/navigation.dart`: `navigatorKey` toàn cục.
  - `di/injection.dart`: Cấu hình DI (get_it) cho ApiClient, Services, Repositories, UseCases, SocketClient.
  - `routes/app_pages.dart`, `routes/app_routes.dart`: Bản đồ điều hướng.
- `config/`
  - `environment.dart`: Chọn môi trường và `baseUrl` theo môi trường.
  - `api_config.dart`, `app_config.dart`: Các hằng số cấu hình API/ứng dụng (nếu có).
  - `language/`: I18n (tiếng Việt/Anh) và `LanguageController`.
  - `theme/`: `AppTheme` (light/dark) và cấu hình liên quan.
- `core/`
  - `api/`: `ApiClient` (Dio), xử lý headers/refresh token, upload multipart.
  - `constants/`: `api_endpoints.dart`, `websocket_config.dart`, hằng số chung.
  - `services/`: Dịch vụ cốt lõi như `AuthService`, `ChatService`, `NotificationService`, `UserStatusService`, ...
  - `utils/`, `base/`, `di/`: Tiện ích và nền tảng dùng chung.
- `data/`
  - `remote/`: Lớp gọi API (AuthApi, ChatApi, NotificationApi, ProfileApi, ...).
  - `repositories/`: Triển khai repository (ChatRepositoryImpl, MessageRepositoryImpl, ...).
  - `models/`: Model dữ liệu cho domain/UI (Message, Chat, Profile, ...).
- `domain/`
  - `entities/`, `models/`, `repositories/`, `usecases/`: Lớp domain độc lập UI.
- `infrastructure/`
  - `socket/`: `SocketClient` (STOMP client) quản lý kết nối WebSocket, subscribe/publish, streams.
  - `services/`: Dịch vụ hạ tầng (khởi tạo app, precache ảnh, discovery buffers, ...).
  - `storage/`, `platform/`: Lưu trữ/cầu nối nền tảng.
- `presentation/`
  - Tổ chức theo tính năng: `auth`, `discovery`, `chat`, `main_navigator`, `profile`, `settings`, `notification`, `subscription`, ...
  - UI View + ViewModel/Controller + Widgets.

Entry points môi trường:

- `main_dev.dart`, `main_staging.dart`, `main_prod.dart` đặt `EnvironmentConfig.current` trước khi gọi `runMain()` trong `main.dart`.

## Yêu cầu hệ thống

- Flutter SDK ổn định (khuyến nghị Flutter 3.22+). Dart SDK trong `pubspec.yaml`: `^3.7.2`.
- Android Studio / Xcode (để build Android/iOS).
- Thiết bị thử nghiệm: Android Emulator hoặc máy thật; iOS Simulator/máy thật.

Dependencies nổi bật (xem `pubspec.yaml`):

- Âm thanh trong app:

  - Đã khai báo thư mục `assets/sounds/` trong `pubspec.yaml`.
  - Thêm 3 file MP3 ngắn, dễ chịu:
    - `assets/sounds/swipe_like.mp3`
    - `assets/sounds/swipe_pass.mp3`
    - `assets/sounds/match_success.mp3`
  - Nếu muốn thay âm riêng, chỉ cần đặt file mới cùng tên hoặc đổi đường dẫn trong `SoundService`.

- Dio (HTTP), Provider, get_it (DI), stomp_dart_client (STOMP/WebSocket), shared_preferences, geolocator/geocoding, image_picker/image_cropper, cached_network_image, flutter_image_compress, permission_handler, audioplayers, ...

## Cài đặt & chạy ứng dụng

1. Cài dependencies

```bash
flutter pub get
```

2. Chạy theo môi trường (chọn thiết bị trước bằng `flutter devices`):

- Dev (Android Emulator kết nối backend local qua `10.0.2.2:8080`):

```bash
flutter run -t lib/main_dev.dart
```

- Staging:

```bash
flutter run -t lib/main_staging.dart
```

- Prod:

```bash
flutter run -t lib/main_prod.dart
```

3. Build phát hành:

- Android APK (prod):

```bash
flutter build apk --release -t lib/main_prod.dart
```

- iOS (prod):

```bash
flutter build ios --release -t lib/main_prod.dart
```

Ghi chú:

- Ứng dụng không sử dụng `.env`; chọn môi trường bằng file entry-point.
- Dev Android Emulator map `localhost` thành `10.0.2.2`.

## Cấu hình môi trường (dev/staging/prod)

File: `lib/config/environment.dart`

- `Environment.dev`: `http://10.0.2.2:8080/api` (Android Emulator). WebSocket: `ws://10.0.2.2:8080/ws`.
- `Environment.staging`: `http://150.95.109.13:8080/api`. WebSocket: `ws://150.95.109.13:8080/api/ws`.
- `Environment.prod`: `https://api.amoura.space/api`. WebSocket: `wss://api.amoura.space/api/ws`.

Chọn môi trường ở các file entry `main_*.dart`.

## HTTP Client & xử lý Token

File: `lib/core/api/api_client.dart`

- Sử dụng `Dio` với `baseUrl` từ `EnvironmentConfig.baseUrl` (đảm bảo có trailing slash).
- Tự động đính kèm `Authorization: Bearer <accessToken>` nếu có.
- Xử lý `401 Unauthorized`:
  - Nếu lỗi xác thực đăng nhập (`INVALID_CREDENTIALS`) thì trả lỗi ngay.
  - Ngược lại thử refresh token (qua `RefreshTokenUseCase`); nếu thất bại thì xóa token và điều hướng về `welcome`.
- Hỗ trợ `uploadMultipart(...)` cho upload ảnh chat, avatar/cover/highlight.

API endpoints: xem `lib/core/constants/api_endpoints.dart` và các `*Api` trong `lib/data/remote/`.

## Xác thực & đăng ký

Files chính: `lib/data/remote/auth_api.dart`, `lib/core/services/auth_service.dart`

- Luồng đăng ký gồm: initiate -> verify OTP -> complete.
- Đăng nhập hỗ trợ OTP email hoặc mật khẩu (tùy `loginType`).
- `AuthService` lưu `accessToken`/`refreshToken` bằng `shared_preferences`.

## Điều hướng & bootstrap ứng dụng

- `lib/app/app.dart`: Khởi tạo `MaterialApp`, `onGenerateRoute`, `initialRoute`, theme và localization.
- `lib/app/routes/app_pages.dart`: Map route -> View (`splash`, `welcome`, `auth`, `setup_profile`, `main_navigator`, `discovery`, `chat_conversation`, ...).
- `lib/main.dart` (`runMain()`):
  - Khởi tạo DI (`configureDependencies(navigatorKey)`).
  - Cung cấp `MultiProvider`: `ThemeModeController`, `LanguageController`, `ProfileViewModel` (preload), `SubscriptionService`, `RewindService`, `LikesService`.
  - Ẩn `debugPrint` ở prod-release.

## Đa ngôn ngữ & Theme

- I18n: `lib/config/language/` với `en.dart`, `vi.dart`, `AppLocalizations`, `LanguageController`.
- Theme: `lib/config/theme/` với `AppTheme.lightTheme`, `AppTheme.darkTheme`, `ThemeModeController`.

## Realtime/WebSocket

Files:

- Config: `lib/core/constants/websocket_config.dart`
- Client: `lib/infrastructure/socket/socket_client.dart`
- Sử dụng `stomp_dart_client`. Kết nối đến `WebSocketConfig.wsEndpoint` theo môi trường, xác thực bằng JWT trong `stompConnectHeaders`.

Chủ đề/đích STOMP:

- Subscribe:
  - Chat room: `/topic/chat/{chatRoomId}`
  - Typing: `/topic/chat/{chatRoomId}/typing`
  - Trạng thái người dùng theo phòng: `/topic/chat/{chatRoomId}/user-status`
  - Thông báo cá nhân: `/user/queue/notification`
- Send:
  - Gửi tin nhắn: `/app/chat.sendMessage`
  - Typing: `/app/chat.typing`
  - Read receipt: `/app/chat.read`
  - Recall: `/app/chat.recallMessage`

Luồng kết nối:

1. Ứng dụng khởi tạo (sau đăng nhập) -> `AppStartupService` -> `AppInitializationService.initializeAppData()`.
2. Tải profile hiện tại để lấy `userId` -> gọi `SocketClient.connect(userId)`.
3. `SocketClient` phát streams: `messageStream`, `typingStream`, `notificationStream`, `userStatusStream`, `connectionStream`.
4. `ChatService`/`NotificationService` subscribe các stream này để cập nhật UI.

Lưu ý:

- Prod dùng `wss://` (TLS). Dev/Staging dùng `ws://`.
- Khi đổi user hoặc logout, client sẽ `disconnect()` và làm sạch subscriptions.

## Chat

Files chính:

- Dịch vụ: `lib/core/services/chat_service.dart`
- API: `lib/data/remote/chat_api.dart`
- Repository: `lib/data/repositories/chat_repository_impl.dart`, `lib/data/repositories/message_repository_impl.dart`
- Model: `lib/domain/models/message.dart`, `lib/domain/models/chat.dart`

Tính năng & luồng:

- Lấy danh sách phòng chat: `getChatRooms()` (cache kết quả, emit stream).
- Lấy tin nhắn theo phòng với cursor-based pagination: `getMessages(chatRoomId, {cursor, limit, direction})`.
  - Merge dữ liệu API với cache local, sắp xếp theo thời gian (mới nhất trước), lưu `SharedPreferences` (giới hạn ~100 tin gần nhất/room), lọc message hệ thống/không hợp lệ.
- Gửi tin nhắn: `sendMessage(...)` gọi REST API. WebSocket sẽ broadcast lại; dịch vụ có cơ chế tránh duplicate (message của chính mình chỉ thêm 1 lần).
- Upload ảnh: `uploadChatImage(File, chatRoomId)` -> backend trả về URL plain text.
- Đánh dấu đã đọc: `markMessagesAsRead(chatRoomId)` -> backend gửi READ_RECEIPT qua WebSocket.
- WebSocket subscribe theo phòng: `subscribeToChat(chatRoomId)` và typing/user-status per room.
- Xử lý realtime:
  - MESSAGE/TYPING/READ_RECEIPT/MESSAGE_RECALLED; có logic lọc/anti-duplicate/cập nhật unread count.

Gợi ý tích hợp UI:

- Khi vào màn chat: gọi `ChatService.subscribeToChat(chatId)` và lắng nghe `messagesStream`/`newMessageStream`/`typingStream`.
- Khi rời màn: `unsubscribeFromChat(chatId)`.

## Thông báo (Notifications)

Files: `lib/core/services/notification_service.dart`, `lib/data/remote/notification_api.dart`

- Realtime: lắng nghe `/user/queue/notification` từ `SocketClient.notificationStream`.
- REST: lấy danh sách, số chưa đọc, mark as read, mark all as read.
- Cache local bằng `SharedPreferences` (lưu tối đa ~100 bản ghi gần nhất).
- Streams: `notificationsStream`, `newNotificationStream`, `unreadCountStream`.

## Trạng thái người dùng (Online/Offline)

File: `lib/core/services/user_status_service.dart`

- Lắng nghe `SocketClient.userStatusStream` để cập nhật cache map `{userId: isOnline}` và emit stream.
- Có API kiểm tra trạng thái online một người dùng (`/users/{id}/online`) để lấy trạng thái khi chưa có trong cache.

## Khám phá/Matching & Hiệu năng

Files tiêu biểu: `lib/infrastructure/services/app_initialization_service.dart`, `profile_buffer_service.dart`, `image_precache_service.dart`, cùng nhóm `presentation/discovery/*`.

- Startup: tải trước hồ sơ người dùng hiện tại, khởi tạo WebSocket, khởi tạo buffer hồ sơ gợi ý và precache ảnh (cover + highlights) cho vài hồ sơ đầu để cuộn/trượt mượt hơn.
- Matching endpoints: xem `ApiEndpoints` (`/matching/recommendations`, `/matching/swipe`, `/matching/matches`).

## Quy trình build & phát hành

- Android:
  - Dev: `flutter run -t lib/main_dev.dart`
  - Release APK: `flutter build apk --release -t lib/main_prod.dart`
  - Cấu hình `android/app/build.gradle.kts` và signing (nếu cần phát hành).
- iOS:
  - Mở bằng Xcode để cấu hình signing, capabilities.
  - Build: `flutter build ios --release -t lib/main_prod.dart`

Quyền truy cập (permissions):

- Địa điểm (geolocator), Ảnh/Camera (image_picker), Lưu trữ (cached images), v.v. Cần đảm bảo thêm mô tả quyền trong `AndroidManifest.xml`/`Info.plist` tương ứng theo yêu cầu thư viện.

## Quy ước mã nguồn & lint

- Theo `flutter_lints: ^5.0.0` và convention Clean Architecture.
- Code style: đặt tên mô tả, tránh viết tắt, tránh lồng sâu, ưu tiên early-return, xử lý lỗi có chủ đích.
- State/UI: dùng Provider/ChangeNotifier cho UI layer; service/domain độc lập UI, inject bằng get_it.

## Troubleshooting

- Không kết nối được WebSocket:
  - Kiểm tra `EnvironmentConfig.current` và URL WebSocket tương ứng (`wsEndpoint`).
  - Dev (Android Emulator) phải dùng `10.0.2.2` thay vì `localhost`.
  - Prod cần chứng chỉ TLS hợp lệ để dùng `wss://`.
  - Đảm bảo JWT hợp lệ; đăng nhập lại nếu `401`.
- Upload ảnh chat trả về lỗi/format lạ:
  - Backend trả URL dạng plain text; `ApiClient.uploadMultipart` đã set `responseType.plain` với endpoint upload chat.
- Gửi tin nhắn bị duplicate:
  - Logic đã tránh nhân đôi giữa REST và WebSocket; nếu backend thay đổi, cần đồng bộ lại quy ước `id`/thời điểm để so khớp.
- Không thấy dữ liệu Discovery ngay:
  - Chờ `AppInitializationService` hoàn tất preload/buffer; kiểm tra logs và quyền mạng/ảnh.

---

Nếu bạn cần mở rộng tài liệu cho từng module UI cụ thể (`presentation/*`) hoặc hướng dẫn tích hợp thiết kế/animation, hãy bổ sung vào các mục tương ứng ở README này.
