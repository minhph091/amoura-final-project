# Amoura Mobile App

## Mô tả
Ứng dụng di động Amoura được phát triển bằng Flutter - ứng dụng hẹn hò với tính năng matching thông minh.

## Yêu cầu hệ thống
- Flutter SDK 3.7.2+
- Dart SDK 3.7.2+
- Android Studio / VS Code
- Android SDK (cho Android development)
- Xcode (cho iOS development - chỉ trên macOS)

## Cài đặt và Chạy

### 1. Cài đặt Flutter
Tham khảo hướng dẫn chính thức: [Flutter Installation](https://docs.flutter.dev/get-started/install)

### 2. Kiểm tra cài đặt
```bash
flutter doctor
```

### 3. Cài đặt dependencies
```bash
flutter pub get
```

### 4. Chạy ứng dụng

#### Chạy trên Android Emulator/Device
```bash
flutter run
```

#### Chạy trên iOS Simulator (chỉ macOS)
```bash
flutter run -d ios
```

#### Chạy trên Chrome (web debug)
```bash
flutter run -d chrome
```

### 5. Build production

#### Build APK (Android)
```bash
flutter build apk --release
```

#### Build App Bundle (Android - khuyến nghị cho Play Store)
```bash
flutter build appbundle --release
```

#### Build iOS (chỉ macOS)
```bash
flutter build ios --release
```

## Scripts và Commands hữu ích
```bash
# Làm sạch cache
flutter clean

# Cập nhật dependencies
flutter pub upgrade

# Analyze code
flutter analyze

# Run tests
flutter test

# Generate icons
flutter pub run flutter_launcher_icons
```

## Tech Stack
- **Framework**: Flutter 3.7.2
- **Language**: Dart
- **State Management**: Provider
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences
- **Dependency Injection**: GetIt
- **Location Services**: Geolocator, Geocoding
- **Image Handling**: Image Picker, Image Cropper
- **UI Components**: Material Design, Cupertino
- **Animations**: Flutter Animate
- **Icons**: Font Awesome, Phosphor, Material Symbols
- **Real-time**: STOMP WebSocket

## Tính năng chính
- Đăng ký/Đăng nhập
- Profile management
- Matching algorithm
- Chat real-time
- Location-based matching
- Photo upload/cropping
- Push notifications
- Đa ngôn ngữ
- Audio messages

## Cấu trúc thư mục
```
mobile_app/
├── android/            # Android platform code
├── ios/               # iOS platform code  
├── lib/               # Dart source code
├── assets/            # Images, icons, sounds
├── test/              # Unit tests
└── web/               # Web platform support
```

## Debugging
- Sử dụng Flutter Inspector trong IDE
- `flutter logs` để xem logs realtime
- `flutter run --verbose` để debug chi tiết
