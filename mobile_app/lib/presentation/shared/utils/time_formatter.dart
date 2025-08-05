import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class TimeFormatter {
  /// Formats the time for display in chat list
  /// Returns a string like "12:34 PM", "Yesterday", or "Mar 15"
  static String formatChatTime(DateTime dateTime) {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (messageDate == today) {
        // Today, show time only
        return _formatTime(dateTime);
      } else if (messageDate == yesterday) {
        // Yesterday
        return 'Yesterday';
      } else if (now.difference(dateTime).inDays < 7) {
        // Within the last week, show day name
        return _getDayName(dateTime.weekday);
      } else {
        // Older, show date
        return '${_getShortMonthName(dateTime.month)} ${dateTime.day}';
      }
    } catch (e) {
      debugPrint('TimeFormatter: Error formatting chat time: $e');
      return 'Unknown';
    }
  }

  /// Formats the time for display in message bubble
  /// Returns a string like "12:34 PM"
  static String formatMessageTime(DateTime dateTime) {
    try {
      return _formatTime(dateTime);
    } catch (e) {
      debugPrint('TimeFormatter: Error formatting message time: $e');
      return 'Unknown';
    }
  }

  /// Format time to 12-hour format
  static String _formatTime(DateTime dateTime) {
    try {
      int hour = dateTime.hour;
      final minute = dateTime.minute;
      final period = hour >= 12 ? 'PM' : 'AM';

      hour = hour > 12 ? hour - 12 : hour;
      hour = hour == 0 ? 12 : hour;

      final minuteStr = minute < 10 ? '0$minute' : '$minute';

      return '$hour:$minuteStr $period';
    } catch (e) {
      debugPrint('TimeFormatter: Error formatting time: $e');
      return 'Unknown';
    }
  }

  /// Get the name of the day of week
  static String _getDayName(int weekday) {
    try {
      switch (weekday) {
        case 1: return 'Monday';
        case 2: return 'Tuesday';
        case 3: return 'Wednesday';
        case 4: return 'Thursday';
        case 5: return 'Friday';
        case 6: return 'Saturday';
        case 7: return 'Sunday';
        default: return '';
      }
    } catch (e) {
      debugPrint('TimeFormatter: Error getting day name: $e');
      return '';
    }
  }

  /// Get the short name of the month
  static String _getShortMonthName(int month) {
    try {
      switch (month) {
        case 1: return 'Jan';
        case 2: return 'Feb';
        case 3: return 'Mar';
        case 4: return 'Apr';
        case 5: return 'May';
        case 6: return 'Jun';
        case 7: return 'Jul';
        case 8: return 'Aug';
        case 9: return 'Sep';
        case 10: return 'Oct';
        case 11: return 'Nov';
        case 12: return 'Dec';
        default: return '';
      }
    } catch (e) {
      debugPrint('TimeFormatter: Error getting short month name: $e');
      return '';
    }
  }
}
