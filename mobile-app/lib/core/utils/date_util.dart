// lib/core/utils/date_util.dart

// Tiện ích xử lý ngày tháng cho app
class DateUtil {
  /// Định dạng ngày thành chuỗi "dd/MM/yyyy"
  static String formatDDMMYYYY(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  // Định dạng ngày thành chuỗi "yyyy-MM-dd"
  static String formatYYYYMMDD(DateTime date) {
    return "${date.year}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  // Chuyển chuỗi "yyyy-MM-dd" sang DateTime
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

  // Kiểm tra ngày có phải hôm nay không
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year && now.month == date.month && now.day == date.day;
  }

  // Trả về chuỗi thời gian tương đối (ví dụ: "2 hours ago", "just now")
  static String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago";
    if (diff.inHours < 24) return "${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago";
    if (diff.inDays < 7) return "${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago";
    if (diff.inDays < 30) return "${(diff.inDays / 7).floor()} week${(diff.inDays / 7).floor() == 1 ? '' : 's'} ago";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()} month${(diff.inDays / 30).floor() == 1 ? '' : 's'} ago";
    return "${(diff.inDays / 365).floor()} year${(diff.inDays / 365).floor() == 1 ? '' : 's'} ago";
  }
}