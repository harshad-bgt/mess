import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat isoFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat dayMonthFormat = DateFormat('d MMM');
  static final DateFormat dayMonthYearFormat = DateFormat('d MMM yyyy');
  static final DateFormat fullReadableFormat = DateFormat('EEEE, d MMMM yyyy');
  static final DateFormat shortReadableFormat = DateFormat('EEE, d MMM');
  static final DateFormat time12Format = DateFormat('h:mm a');
  static final DateFormat time24Format = DateFormat('HH:mm');

  /// Strip hours/minutes/seconds for date comparison
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Format DateTime to ISO string "YYYY-MM-DD"
  static String toIsoDate(DateTime date) {
    return isoFormat.format(date);
  }

  /// Parse ISO string "YYYY-MM-DD" to DateTime
  static DateTime parseIsoDate(String dateStr) {
    try {
      return isoFormat.parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Human-friendly display: "Today", "Yesterday", or "Tue, 24 Nov"
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = dateOnly(now);
    final target = dateOnly(date);

    final difference = target.difference(today).inDays;
    if (difference == 0) {
      return 'Today, ${dayMonthFormat.format(date)}';
    } else if (difference == -1) {
      return 'Yesterday, ${dayMonthFormat.format(date)}';
    } else if (difference == 1) {
      return 'Tomorrow, ${dayMonthFormat.format(date)}';
    } else {
      return shortReadableFormat.format(date);
    }
  }

  /// Check if two dates represent the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
