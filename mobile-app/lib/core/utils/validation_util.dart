// lib/core/utils/validation_util.dart

import '../constants/app_constants.dart';

// A utility class that provides static methods for validating user inputs.
class ValidationUtil {
  // Regex-based Validation

  // Checks if the given [input] is a valid email address.
  static bool isEmail(String input) =>
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(input);

  // Checks if the given [input] is a valid phone number.
  static bool isPhoneNumber(String input) =>
      RegExp(r"^(\+?[0-9]{10,15})$").hasMatch(input);

  // Checks if the given [input] is a valid password based on length and character complexity.
  static bool isPasswordValid(String input) =>
      input.length >= AppConstants.passwordMinLength &&
          RegExp(r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=!*()_])(?=\S+$).{8,}$")
              .hasMatch(input);

  // Common Input Validators
  // Validates the OTP value.
  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) return 'OTP is required!';
    if (value.length != AppConstants.otpLength) return 'Invalid OTP length!';
    return null;
  }

  // Personal Info Validators
  // Validates a username's length and format.
  String? validateUsernameLength(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your username.';
    if (value.length < 3) return 'Username must be at least 3 characters.';
    if (value.length > 50) return 'Username must be at most 50 characters.';
    if (!RegExp(r"^[a-zA-Z0-9._-]+$").hasMatch(value.trim())) return 'Invalid username.';
    return null;
  }

  // Validates a first name.
  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your first name.';
    if (value.length < 2) return 'First name must be at least 2 characters.';
    if (value.length > 50) return 'First name must be at most 50 characters.';
    if (!RegExp(r"^[a-zA-ZÀ-ỹà-ỹ\s'-]+$").hasMatch(value.trim())) return 'Invalid first name.';
    return null;
  }

  // Validates a last name.
  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your last name.';
    if (value.length < 2) return 'Last name must be at least 2 characters.';
    if (value.length > 50) return 'Last name must be at most 50 characters.';
    if (!RegExp(r"^[a-zA-ZÀ-ỹà-ỹ\s'-]+$").hasMatch(value.trim())) return 'Invalid last name.';
    return null;
  }

  // Validates a birthday date.
  String? validateBirthday(DateTime? date) {
    if (date == null) return 'Please select your birthday.';
    final now = DateTime.now();
    if (date.isAfter(now)) return 'Birthday cannot be in the future.';
    if (date.isBefore(DateTime(now.year - 120))) return 'Invalid birthday.';
    if (now.year - date.year < 18) return 'You must be at least 18 years old.';
    return null;
  }

  // Validates height in centimeters.
  String? validateHeight(int? value) {
    if (value == null) return 'Please enter your height.';
    if (value < 100) return 'Height must be at least 100cm.';
    if (value > 250) return 'Height must be less than 250cm.';
    return null;
  }

  // Validates a short biography.
  String? validateBio(String? value) {
    if (value != null && value.length > 1000) return 'Bio must be less than 1000 characters.';
    return null;
  }

  // Validates an email address.
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email.';
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(value.trim())) return 'Invalid email format.';
    return null;
  }

  // Validates a phone number.
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your phone number.';
    if (!RegExp(r"^[0-9]{8,15}$").hasMatch(value.trim())) return "Invalid phone number.";
    return null;
  }

  // Validates a password.
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter password.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  // Validates the confirmation password.
  String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) return 'Please confirm password.';
    if (value != password) return 'Passwords do not match.';
    return null;
  }
}
