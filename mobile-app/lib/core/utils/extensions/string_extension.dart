// lib/core/utils/extensions/string_extension.dart

// Hàm mở rộng cho String
extension StringExtension on String {
  // Kiểm tra xem chuỗi có phải là email hợp lệ hay không
  bool get isEmail =>
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(this);

  // Kiểm tra xem chuỗi có phải là số điện thoại hợp lệ hay không
  bool get isPhone =>
      RegExp(r"^(?:[+0]9)?[0-9]{9,12}$").hasMatch(this);

  // Viết hoa ký tự đầu tiên của chuỗi
  String capitalize() =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}