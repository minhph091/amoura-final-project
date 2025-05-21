// lib/core/utils/validation_util.dart

import '../constants/app_constants.dart';

class ValidationUtil {
  static bool isEmail(String input) =>
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(input);

  static bool isPhoneNumber(String input) =>
      RegExp(r"^(\+?[0-9]{10,15})$").hasMatch(input);

  static bool isPasswordValid(String input) =>
      input.length >= AppConstants.passwordMinLength &&
          RegExp(r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=!*()_])(?=\S+$).{8,}$").hasMatch(input);

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required!';
    if (!isEmail(value)) return 'Invalid email format!';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required!';
    if (!isPhoneNumber(value)) return 'Invalid phone number!';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required!';
    if (!isPasswordValid(value)) {
      return 'Password must be at least 8 characters, including uppercase, lowercase, number & special character!';
    }
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirm) {
    if (confirm == null || confirm.trim().isEmpty) return 'Please confirm your password!';
    if (password != confirm) return 'Passwords do not match!';
    return null;
  }
}