import 'package:flutter/material.dart';

class NotificationSettingsViewModel extends ChangeNotifier {
  bool _systemNotifications = true;
  bool _likeNotifications = true;
  bool _messageNotifications = true;

  // Getters
  bool get systemNotifications => _systemNotifications;
  bool get likeNotifications => _likeNotifications;
  bool get messageNotifications => _messageNotifications;

  bool get allNotificationsEnabled =>
      _systemNotifications && _likeNotifications && _messageNotifications;

  // Initialize with saved settings
  NotificationSettingsViewModel() {
    _loadSettings();
  }

  // Load saved settings from shared preferences or API
  Future<void> _loadSettings() async {
    // In a real app, you would fetch these from SharedPreferences or an API
    // For now, we'll just simulate a delay
    await Future.delayed(const Duration(milliseconds: 500));

    // These would come from storage in a real app
    _systemNotifications = true;
    _likeNotifications = true;
    _messageNotifications = true;

    notifyListeners();
  }

  // Setters
  void setSystemNotifications(bool value) {
    _systemNotifications = value;
    notifyListeners();
  }

  void setLikeNotifications(bool value) {
    _likeNotifications = value;
    notifyListeners();
  }

  void setMessageNotifications(bool value) {
    _messageNotifications = value;
    notifyListeners();
  }

  // Set all notifications at once
  void setAllNotifications(bool value) {
    _systemNotifications = value;
    _likeNotifications = value;
    _messageNotifications = value;
    notifyListeners();
  }

  // Save settings to persistent storage
  Future<void> saveSettings() async {
    // In a real app, you would save to SharedPreferences or call an API
    // For now, we'll just simulate a delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Log the settings that would be saved
    debugPrint('Saving notification settings:');
    debugPrint('System: $_systemNotifications');
    debugPrint('Likes: $_likeNotifications');
    debugPrint('Messages: $_messageNotifications');
  }
}