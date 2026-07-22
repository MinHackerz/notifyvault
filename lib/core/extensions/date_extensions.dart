/// Extension methods for DateTime.
extension DateExtensions on DateTime {
  /// Check if this date is today.
  bool get isToday {
    final now = DateTime.now();
    final local = toLocal();
    return local.year == now.year && local.month == now.month && local.day == now.day;
  }

  /// Check if this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final local = toLocal();
    return local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day;
  }

  /// Check if this date is within this week (last 7 days).
  bool get isThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final local = toLocal();
    return local.isAfter(weekAgo) && !isToday && !isYesterday;
  }

  /// Check if this date is within last week (7-14 days ago).
  bool get isLastWeek {
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final local = toLocal();
    return local.isAfter(twoWeeksAgo) && local.isBefore(oneWeekAgo);
  }

  /// Check if this date is within this month.
  bool get isThisMonth {
    final now = DateTime.now();
    final local = toLocal();
    return local.year == now.year && local.month == now.month && !isThisWeek && !isToday && !isYesterday;
  }

  /// Get the start of the day (midnight).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get the end of the day (23:59:59).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Format as time string (e.g., "2:30 PM").
  String get timeString {
    final hour = this.hour > 12 ? this.hour - 12 : this.hour;
    final displayHour = hour == 0 ? 12 : hour;
    final minute = this.minute.toString().padLeft(2, '0');
    final period = this.hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:$minute $period';
  }

  /// Format as short date string (e.g., "Jun 26").
  String get shortDateString {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[month - 1]} $day';
  }

  /// Format as full date string (e.g., "June 26, 2026").
  String get fullDateString {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[month - 1]} $day, $year';
  }

  /// Smart relative time string for notification display.
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (isToday) return timeString;
    if (isYesterday) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return shortDateString;
  }
}
