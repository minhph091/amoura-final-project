// lib/core/utils/validation_util.dart

import '../constants/app_constants.dart';

class ValidationUtil {
  //=============================
  // Regex-based Validation
  //=============================

  static bool isEmail(String input) =>
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(input);

  static bool isPhoneNumber(String input) =>
      RegExp(r"^(\+?[0-9]{10,15})$").hasMatch(input);

  static bool isPasswordValid(String input) =>
      input.length >= AppConstants.passwordMinLength &&
          RegExp(r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=!*()_])(?=\S+$).{8,}$").hasMatch(input);

  //=============================
  // Common Input Validators
  //=============================


  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) return 'OTP is required!';
    if (value.length != AppConstants.otpLength) return 'Invalid OTP length!';
    return null;
  }

  //=============================
  // Personal Info Validators
  //=============================

  String? validateUsernameLength(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your username.';
    if (value.length < 3) return 'Username must be at least 3 characters.';
    if (value.length > 50) return 'Username must be at most 50 characters.';
    if (!RegExp(r"^[a-zA-Z0-9._-]+$").hasMatch(value.trim())) return 'Invalid username.';
    return null;
  }

  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your first name.';
    if (value.length < 2) return 'First name must be at least 2 characters.';
    if (value.length > 50) return 'First name must be at most 50 characters.';
    if (!RegExp(r"^[a-zA-ZÀ-ỹà-ỹ\s'-]+$").hasMatch(value.trim())) return 'Invalid first name.';
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your last name.';
    if (value.length < 2) return 'Last name must be at least 2 characters.';
    if (value.length > 50) return 'Last name must be at most 50 characters.';
    if (!RegExp(r"^[a-zA-ZÀ-ỹà-ỹ\s'-]+$").hasMatch(value.trim())) return 'Invalid last name.';
    return null;
  }

  String? validateBirthday(DateTime? date) {
    if (date == null) return 'Please select your birthday.';
    final now = DateTime.now();
    if (date.isAfter(now)) return 'Birthday cannot be in the future.';
    if (date.isBefore(DateTime(now.year - 120))) return 'Invalid birthday.';
    if (now.year - date.year < 18) return 'You must be at least 18 years old.';
    return null;
  }

  String? validateHeight(int? value) {
    if (value == null) return 'Please enter your height.';
    if (value < 100) return 'Height must be at least 100cm.';
    if (value > 250) return 'Height must be less than 250cm.';
    return null;
  }

  String? validateBio(String? value) {
    if (value != null && value.length > 1000) return 'Bio must be less than 1000 characters.';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(value.trim())) return 'Invalid email format';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your phone number';
    if (!RegExp(r"^[0-9]{8,15}$").hasMatch(value.trim())) return "Invalid phone number";
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter password';
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) return 'Please confirm password';
    if (value != password) return 'Passwords do not match';
    return null;
  }
}
