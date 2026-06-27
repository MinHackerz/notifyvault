import '../../models/notification_model.dart';
import '../extensions/date_extensions.dart';

/// Grouping key for notification timeline.
enum DateGroup {
  today('Today'),
  yesterday('Yesterday'),
  thisWeek('This Week'),
  lastWeek('Last Week'),
  thisMonth('This Month'),
  older('Older');

  const DateGroup(this.label);
  final String label;
}

/// Helper for grouping notifications by date period.
class DateHelper {
  DateHelper._();

  /// Determine the date group for a given DateTime.
  static DateGroup getGroup(DateTime date) {
    if (date.isToday) return DateGroup.today;
    if (date.isYesterday) return DateGroup.yesterday;
    if (date.isThisWeek) return DateGroup.thisWeek;
    if (date.isLastWeek) return DateGroup.lastWeek;
    if (date.isThisMonth) return DateGroup.thisMonth;
    return DateGroup.older;
  }

  /// Group a list of notifications by date period.
  /// Returns an ordered map preserving the group order.
  static Map<DateGroup, List<NotificationModel>> groupNotifications(
    List<NotificationModel> notifications,
  ) {
    final grouped = <DateGroup, List<NotificationModel>>{};

    for (final notification in notifications) {
      final group = getGroup(notification.timestamp);
      grouped.putIfAbsent(group, () => []).add(notification);
    }

    // Sort the map by DateGroup index to maintain order
    final sortedMap = <DateGroup, List<NotificationModel>>{};
    for (final group in DateGroup.values) {
      if (grouped.containsKey(group)) {
        sortedMap[group] = grouped[group]!;
      }
    }

    return sortedMap;
  }
}
