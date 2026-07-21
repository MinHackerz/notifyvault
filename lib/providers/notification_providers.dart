import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/notification_repository.dart';
import '../models/notification_model.dart';
import '../core/helpers/date_helper.dart';
import '../database/app_database.dart';
import 'app_management_providers.dart';

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
final todayCountProvider = Provider<AsyncValue<int>>((ref) {
  final notificationsAsync = ref.watch(notificationStreamProvider);
  return notificationsAsync.whenData((list) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return list
        .where((n) =>
            n.timestamp.isAfter(startOfDay) ||
            n.timestamp.isAtSameMomentAs(startOfDay))
        .length;
  });
});

/// Unread notification count.
final unreadCountProvider = Provider<AsyncValue<int>>((ref) {
  final notificationsAsync = ref.watch(notificationStreamProvider);
  return notificationsAsync
      .whenData((list) => list.where((n) => !n.isRead).length);
});

/// Total notification count.
final totalCountProvider = Provider<AsyncValue<int>>((ref) {
  final notificationsAsync = ref.watch(notificationStreamProvider);
  return notificationsAsync.whenData((list) => list.length);
});

/// Active apps today count.
final activeAppsTodayProvider = Provider<AsyncValue<int>>((ref) {
  final notificationsAsync = ref.watch(notificationStreamProvider);
  return notificationsAsync.whenData((list) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return list
        .where((n) =>
            n.timestamp.isAfter(startOfDay) ||
            n.timestamp.isAtSameMomentAs(startOfDay))
        .map((n) => n.packageName)
        .toSet()
        .length;
  });
});

/// Category counts map.
final categoryCoutsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final notificationsAsync = ref.watch(notificationStreamProvider);
  return notificationsAsync.whenData((list) {
    final counts = <String, int>{};
    for (final n in list) {
      final cat = n.category.isEmpty ? 'other' : n.category;
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts;
  });
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

/// Notifications sorted with priority apps at the top, spam at the bottom.
final prioritySortedNotificationsProvider =
    Provider<AsyncValue<List<NotificationModel>>>((ref) {
  final notificationsAsync = ref.watch(notificationStreamProvider);
  final priorityPkgsAsync = ref.watch(priorityPackagesProvider);
  final spamPkgsAsync = ref.watch(spamPackagesProvider);

  return notificationsAsync.whenData((notifications) {
    final priorityPkgs = priorityPkgsAsync.whenData((v) => v).value ?? <String>{};
    final spamPkgs = spamPkgsAsync.whenData((v) => v).value ?? <String>{};

    if (priorityPkgs.isEmpty && spamPkgs.isEmpty) return notifications;

    final priority = <NotificationModel>[];
    final normal = <NotificationModel>[];
    final spam = <NotificationModel>[];

    for (final n in notifications) {
      if (priorityPkgs.contains(n.packageName)) {
        priority.add(n);
      } else if (spamPkgs.contains(n.packageName)) {
        spam.add(n);
      } else {
        normal.add(n);
      }
    }

    return [...priority, ...normal, ...spam];
  });
});
