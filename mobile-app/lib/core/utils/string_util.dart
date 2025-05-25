// lib/core/utils/string_util.dart

// Utility class for common string operations used throughout the app
class StringUtil {

  // Capitalizes the first letter of a given string
  static String capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

  // Masks part of an email address, leaving only the first character and domain
  // StringUtil.maskEmail("john.doe@gmail.com") // Output: j***@gmail.com
  static String maskEmail(String email) {
    final atIdx = email.indexOf('@');
    if (atIdx <= 1) return email;
    return email[0] + '***' + email.substring(atIdx - 1);
  }
}
