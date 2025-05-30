// lib/presentation/profile/view/profile_viewmodel.dart

import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  // Profile data
  dynamic profile;

  // Loading state
  bool isLoading = false;
  String? error;

  // Constructor: có thể truyền sẵn profile (nếu có) hoặc tự fetch (tùy use-case)
  ProfileViewModel({this.profile});

  // Hàm load profile (giả định có userId, hoặc lấy từ local/session)
  Future<void> loadProfile({String? userId}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // TODO: Gọi API lấy thông tin profile ở đây
      // profile = await ProfileApi.getProfile(userId);
      // Giả sử fetch xong thì:
      // profile = resultProfile;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}