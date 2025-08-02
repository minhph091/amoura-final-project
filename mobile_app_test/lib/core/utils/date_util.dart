// lib/core/utils/date_util.dart

// Utility class for handling date-related operations in the app.
class DateUtil {
  // Formats a [DateTime] object into a string in "dd/MM/yyyy" format.
  static String formatDDMMYYYY(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  // Formats a [DateTime] object into a string in "yyyy-MM-dd" format.
  static String formatYYYYMMDD(DateTime date) {
    return "${date.year}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  // Parses a date string in "yyyy-MM-dd" format into a [DateTime] object.
  // Returns `null` if the input is invalid or parsing fails.
  static DateTime? parseYYYYMMDD(String? str) {
    if (str == null || str.isEmpty) return null;
    try {
      final parts = str.split('-');
      if (parts.length != 3) return null;
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      return null;
    }
  }

  // Parses a date string in "dd/MM/yyyy" format into a [DateTime] object.
  // Returns `null` if the input is invalid or parsing fails.
  static DateTime? parseDDMMYYYY(String? str) {
    if (str == null || str.isEmpty) return null;
    try {
      final parts = str.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  // Checks whether the given [date] is today's date.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  // Calculates the age from the given [birthDate] until today.
  static int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Returns a human-readable relative time string (e.g., "2 hours ago", "just now").
  static String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago";
    }
    if (diff.inHours < 24) {
      return "${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago";
    }
    if (diff.inDays < 7) {
      return "${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago";
    }
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return "$weeks week${weeks == 1 ? '' : 's'} ago";
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return "$months month${months == 1 ? '' : 's'} ago";
    }
    final years = (diff.inDays / 365).floor();
    return "$years year${years == 1 ? '' : 's'} ago";
  }
}
