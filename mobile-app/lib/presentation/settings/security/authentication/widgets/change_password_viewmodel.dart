import 'package:flutter/material.dart';
import 'package:amoura/data/repositories/user_repository.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  ChangePasswordViewModel({required this.userRepository}) {
    newPasswordController.addListener(_validateNewPasswordRealtime);
    confirmPasswordController.addListener(_validateConfirmPasswordRealtime);
  }

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? currentPasswordError;
  String? newPasswordError;
  String? confirmPasswordError;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Validate new password: min 8, upper, number, special char
  bool _isValidPassword(String value) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*(),.?":{}|<>]).{8,}');
    return regex.hasMatch(value);
  }

  void _validateNewPasswordRealtime() {
    final value = newPasswordController.text;
    if (value.isEmpty) {
      newPasswordError = 'New password is required';
    } else if (!_isValidPassword(value)) {
      newPasswordError = 'Password must be at least 8 characters, include an uppercase letter, a number, and a special character.';
    } else {
      newPasswordError = null;
    }
    // Confirm password cũng cần check lại nếu user sửa new password
    _validateConfirmPasswordRealtime();
    notifyListeners();
  }

  void _validateConfirmPasswordRealtime() {
    final value = confirmPasswordController.text;
    if (value.isEmpty) {
      confirmPasswordError = 'Please confirm your new password';
    } else if (value != newPasswordController.text) {
      confirmPasswordError = 'Passwords do not match';
    } else {
      confirmPasswordError = null;
    }
    notifyListeners();
  }

  void validateInputs() {
    currentPasswordError = currentPasswordController.text.isEmpty ? 'Current password is required' : null;
    _validateNewPasswordRealtime();
    _validateConfirmPasswordRealtime();
  }

  void clearFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    currentPasswordError = null;
    newPasswordError = null;
    confirmPasswordError = null;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    validateInputs();
    if (currentPasswordError == null && newPasswordError == null && confirmPasswordError == null) {
      setLoading(true);
      try {
        await userRepository.changePassword(
          currentPassword: currentPasswordController.text,
          newPassword: newPasswordController.text,
        );
        setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } catch (e) {
        setLoading(false);
        // Nếu lỗi là sai mật khẩu hiện tại, hiển thị lỗi ngay dưới trường nhập
        final msg = e.toString().toLowerCase();
        if (msg.contains('incorrect') || msg.contains('current password')) {
          currentPasswordError = 'Current password is incorrect. Please try again.';
          notifyListeners();
        } else {
          print('[ChangePassword] Change password failed: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}