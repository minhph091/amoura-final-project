// lib/core/utils/validation_util.dart

// Các hàm validate dữ liệu cho form, trường nhập liệu
class ValidationUtil {
  static bool isEmail(String input) =>
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(input);

  static bool isPhoneNumber(String input) =>
      RegExp(r"^(?:[+0]9)?[0-9]{9,12}$").hasMatch(input);

  static bool isPasswordValid(String input) => input.length >= 6;

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required!';
    if (!isEmail(value)) return 'Invalid email format!';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone is required!';
    if (!isPhoneNumber(value)) return 'Invalid phone number!';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required!';
    if (!isPasswordValid(value)) return 'Password must be at least 6 characters!';
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirm) {
    if (confirm == null || confirm.trim().isEmpty) return 'Confirm password!';
    if (password != confirm) return 'Passwords do not match!';
    return null;
  }
}