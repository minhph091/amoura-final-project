// lib/presentation/main_navigator/main_navigator_viewmodel.dart
import 'package:flutter/material.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/notification_service.dart';
import '../../app/di/injection.dart';

class MainNavigatorViewModel extends ChangeNotifier {
  int _currentIndex = 0; // Mặc định bắt đầu với Discovery (index 0)
  int? _chatBadgeCount;
  int? _notificationBadgeCount;
  late final ChatService _chatService;
  late final NotificationService _notificationService;
  
  MainNavigatorViewModel() {
    // Lắng nghe tổng số tin nhắn chưa đọc để hiện badge ở tab Chat
    _chatService = getIt<ChatService>();
    _chatService.totalUnreadCountStream.listen((total) {
      setChatBadgeCount(total > 0 ? total : null);
    });
    // Lắng nghe số thông báo chưa đọc để hiện badge ở tab Notifications
    _notificationService = getIt<NotificationService>();
    _notificationService.unreadCountStream.listen((count) {
      setNotificationBadgeCount(count > 0 ? count : null);
    });
  }

  int get currentIndex => _currentIndex;
  int? get chatBadgeCount => _chatBadgeCount;
  int? get notificationBadgeCount => _notificationBadgeCount;

  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void setChatBadgeCount(int? value) {
    _chatBadgeCount = value;
    notifyListeners();
  }

  void setNotificationBadgeCount(int? value) {
    _notificationBadgeCount = value;
    notifyListeners();
  }
}
