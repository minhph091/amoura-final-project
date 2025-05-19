// lib/core/utils/string_util.dart

// Tiện ích xử lý chuỗi cho app
class StringUtil {
  static String capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

  // Hàm ẩn đi một phần email, chỉ để lại ký tự đầu tiên và tên miền
  static String maskEmail(String email) {
    // Ví dụ: j***@gmail.com
    final atIdx = email.indexOf('@');
    if (atIdx <= 1) return email;
    return email[0] + '***' + email.substring(atIdx - 1);
  }
}