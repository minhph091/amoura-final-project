// lib/presentation/main_navigator/main_navigator_viewmodel.dart

import 'package:flutter/material.dart';

class MainNavigatorViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  int? _chatBadgeCount;
  int? _notificationBadgeCount;
  String? _vipBadge;

  int get currentIndex => _currentIndex;
  int? get chatBadgeCount => _chatBadgeCount;
  int? get notificationBadgeCount => _notificationBadgeCount;
  String? get vipBadge => _vipBadge;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setChatBadgeCount(int? count) {
    _chatBadgeCount = count;
    notifyListeners();
  }

  void setNotificationBadgeCount(int? count) {
    _notificationBadgeCount = count;
    notifyListeners();
  }

  void setVipBadge(String? badge) {
    _vipBadge = badge;
    notifyListeners();
  }
}