import 'package:flutter/material.dart';

class MainNavigatorViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  int? _chatBadgeCount;
  int? _notificationBadgeCount;

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