// lib/presentation/profile/edit/edit_profile_viewmodel.dart

import 'package:flutter/material.dart';

class EditProfileViewModel extends ChangeNotifier {
  dynamic profile;

  bool isLoading = false;
  bool isSaving = false;
  String? error;
  String? successMessage;

  EditProfileViewModel({this.profile});

  Future<void> loadProfile({String? userId}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // TODO: Gọi API lấy profile
      // profile = await ProfileApi.getProfile(userId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Hàm lưu profile
  Future<void> saveProfile(dynamic updateData) async {
    isSaving = true;
    error = null;
    successMessage = null;
    notifyListeners();

    try {
      // TODO: Gọi API cập nhật profile
      // await ProfileApi.updateProfile(updateData);
      // profile = await ProfileApi.getProfile(); // reload lại nếu muốn
      successMessage = "Profile updated successfully";
    } catch (e) {
      error = e.toString();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}