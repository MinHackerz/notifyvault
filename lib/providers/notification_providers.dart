import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/notification_repository.dart';
import '../models/notification_model.dart';
import '../core/helpers/date_helper.dart';
import '../database/app_database.dart';

/// Singleton notification repository provider.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final repo = NotificationRepository();
  repo.startListening();
  ref.onDispose(() => repo.stopListening());
  return repo;
});

/// Stream of all notifications (reactive).
final notificationStreamProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.watchNotifications(limit: 200);
});

/// Grouped notifications for the timeline view.
final groupedNotificationsProvider =
    Provider<AsyncValue<Map<DateGroup, List<NotificationModel>>>>((ref) {
  final notificationsAsync = ref.watch(notificationStreamProvider);
  return notificationsAsync.whenData(
    (notifications) => DateHelper.groupNotifications(notifications),
  );
});

class TimelineFilter {
  final String? categoryId;
  final bool? onlyUnread;

  const TimelineFilter({this.categoryId, this.onlyUnread});
}

class TimelineFilterNotifier extends Notifier<TimelineFilter> {
  @override
  TimelineFilter build() {
    return const TimelineFilter();
  }

  void setFilter(TimelineFilter filter) {
    state = filter;
  }
}

final timelineFilterProvider =
    NotifierProvider<TimelineFilterNotifier, TimelineFilter>(TimelineFilterNotifier.new);

final filteredTimelineNotificationsProvider =
    Provider<AsyncValue<Map<DateGroup, List<NotificationModel>>>>((ref) {
  final filter = ref.watch(timelineFilterProvider);
  final notificationsAsync = ref.watch(notificationStreamProvider);

  return notificationsAsync.whenData((notifications) {
    var filtered = notifications;
    if (filter.categoryId != null) {
      filtered = filtered.where((n) => n.category == filter.categoryId).toList();
    }
    if (filter.onlyUnread != null) {
      filtered = filtered.where((n) => filter.onlyUnread! ? !n.isRead : n.isRead).toList();
    }
    return DateHelper.groupNotifications(filtered);
  });
});

/// Today's notification count.
final todayCountProvider = FutureProvider<int>((ref) {
  ref.watch(notificationStreamProvider); // Invalidate when notifications change
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getTodayCount();
});

/// Unread notification count.
final unreadCountProvider = FutureProvider<int>((ref) {
  ref.watch(notificationStreamProvider);
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getUnreadCount();
});

/// Total notification count.
final totalCountProvider = FutureProvider<int>((ref) {
  ref.watch(notificationStreamProvider);
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getTotalCount();
});

/// Active apps today count.
final activeAppsTodayProvider = FutureProvider<int>((ref) {
  ref.watch(notificationStreamProvider);
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getActiveAppsToday();
});

/// Category counts map.
final categoryCoutsProvider = FutureProvider<Map<String, int>>((ref) {
  ref.watch(notificationStreamProvider);
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getCategoryCounts();
});

/// Single notification detail provider.
final notificationDetailProvider =
    FutureProvider.family<NotificationModel?, String>((ref, id) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getNotificationById(id);
});

/// Top apps provider.
final topAppsProvider = FutureProvider<List<App>>((ref) {
  ref.watch(notificationStreamProvider);
  return AppDatabase.instance.appDao.getTopApps(limit: 5);
});

/// Favorites stream.
final favoritesStreamProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.watchFavorites();
});
