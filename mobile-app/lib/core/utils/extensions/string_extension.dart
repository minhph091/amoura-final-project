// lib/core/utils/extensions/string_extension.dart

// String extension methods for common validations and formatting
extension StringExtension on String {

  // Checks if the string is a valid email address
  bool get isEmail =>
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(this);

  // Checks if the string is a valid phone number (9–12 digits, optionally starts with + or 0)
  bool get isPhone =>
      RegExp(r"^(?:[+0]9)?[0-9]{9,12}$").hasMatch(this);

  // Capitalizes the first letter of the string
  String capitalize() =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
