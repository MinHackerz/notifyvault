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
  return repo.watchNotifications(limit: 1000);
});

/// Grouped notifications for the timeline view.
final groupedNotificationsProvider =
    Provider<AsyncValue<Map<DateGroup, List<NotificationModel>>>>((ref) {
  final notificationsAsync = ref.watch(notificationStreamProvider);
  return notificationsAsync.whenData(
    (notifications) => DateHelper.groupNotifications(notifications),
  );
});

const _sentinel = Object();

class TimelineFilter {
  final String? categoryId;
  final bool? onlyUnread;
  final String? datePreset; // 'today', 'yesterday', '7days', '30days', or null
  final DateTime? customDate;

  const TimelineFilter({
    this.categoryId,
    this.onlyUnread,
    this.datePreset,
    this.customDate,
  });

  bool get hasDateFilter => datePreset != null || customDate != null;

  bool get hasActiveFilter => categoryId != null || onlyUnread != null || hasDateFilter;

  TimelineFilter copyWith({
    Object? categoryId = _sentinel,
    Object? onlyUnread = _sentinel,
    Object? datePreset = _sentinel,
    Object? customDate = _sentinel,
  }) {
    return TimelineFilter(
      categoryId: categoryId == _sentinel ? this.categoryId : (categoryId as String?),
      onlyUnread: onlyUnread == _sentinel ? this.onlyUnread : (onlyUnread as bool?),
      datePreset: datePreset == _sentinel ? this.datePreset : (datePreset as String?),
      customDate: customDate == _sentinel ? this.customDate : (customDate as DateTime?),
    );
  }
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

    if (filter.customDate != null) {
      final target = filter.customDate!.toLocal();
      filtered = filtered.where((n) {
        final t = n.timestamp.toLocal();
        return t.year == target.year && t.month == target.month && t.day == target.day;
      }).toList();
    } else if (filter.datePreset != null) {
      final now = DateTime.now().toLocal();
      final todayStart = DateTime(now.year, now.month, now.day);

      if (filter.datePreset == 'today') {
        filtered = filtered.where((n) {
          final t = n.timestamp.toLocal();
          return t.year == todayStart.year && t.month == todayStart.month && t.day == todayStart.day;
        }).toList();
      } else if (filter.datePreset == 'yesterday') {
        final yesterday = todayStart.subtract(const Duration(days: 1));
        filtered = filtered.where((n) {
          final t = n.timestamp.toLocal();
          return t.year == yesterday.year && t.month == yesterday.month && t.day == yesterday.day;
        }).toList();
      } else if (filter.datePreset == '7days') {
        final start7 = todayStart.subtract(const Duration(days: 7));
        filtered = filtered.where((n) {
          final t = n.timestamp.toLocal();
          return t.isAfter(start7) || (t.year == start7.year && t.month == start7.month && t.day == start7.day);
        }).toList();
      } else if (filter.datePreset == '30days') {
        final start30 = todayStart.subtract(const Duration(days: 30));
        filtered = filtered.where((n) {
          final t = n.timestamp.toLocal();
          return t.isAfter(start30) || (t.year == start30.year && t.month == start30.month && t.day == start30.day);
        }).toList();
      }
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
