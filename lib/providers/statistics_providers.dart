import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../core/helpers/deleted_tracker.dart';
import '../database/app_database.dart';
import '../providers/settings_providers.dart';
import 'notification_providers.dart';

/// Time range for statistics (in days).
final statsTimeRangeProvider =
    NotifierProvider<StatsTimeRangeNotifier, int>(StatsTimeRangeNotifier.new);

class StatsTimeRangeNotifier extends Notifier<int> {
  @override
  int build() {
    // Default to user's retention period
    return ref.watch(retentionPeriodProvider);
  }

  void setDays(int days) => state = days;
}

/// Stats summary model.
class StatsSummary {
  final int totalReceived;
  final int totalRead;
  final int totalCleared; // Notifications deleted/cleared within time period
  final int days;

  const StatsSummary({
    this.totalReceived = 0,
    this.totalRead = 0,
    this.totalCleared = 0,
    this.days = 7,
  });

  // Backward compatibility getters
  int get totalSaved => totalReceived;
  int get totalUnread => totalReceived - totalRead;
  int get totalDeleted => totalCleared;
}

/// Stats summary: total received, read, and cleared in range.
final statsSummaryProvider = FutureProvider<StatsSummary>((ref) async {
  ref.watch(notificationStreamProvider);
  final days = ref.watch(statsTimeRangeProvider);
  final since = DateTime.now().subtract(Duration(days: days));
  final db = AppDatabase.instance;

  final totalReceived = await db.notificationDao.getCountSince(since);
  final totalRead = await db.notificationDao.getReadCountSince(since);
  final totalCleared = await DeletedTracker.getDeletedCountSince(since);

  return StatsSummary(
    totalReceived: totalReceived,
    totalRead: totalRead,
    totalCleared: totalCleared,
    days: days,
  );
});

/// Top N apps by notification count within the time range.
final topAppsStatsProvider =
    FutureProvider<List<AppStatEntry>>((ref) async {
  ref.watch(notificationStreamProvider);
  final days = ref.watch(statsTimeRangeProvider);
  final since = DateTime.now().subtract(Duration(days: days));
  final counts =
      await AppDatabase.instance.notificationDao.getNotificationCountsByApp(since);

  final sortedEntries = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final supportDir = await getApplicationSupportDirectory();

  // Resolve app names and icons from the apps table
  final resolvedEntries = <AppStatEntry>[];
  for (final entry in sortedEntries) {
    final app = await AppDatabase.instance.appDao.getApp(entry.key);
    
    String? iconPath = app?.iconPath;
    if (iconPath == null || iconPath.isEmpty) {
      final file = File('${supportDir.path}/icons/${entry.key}.png');
      if (file.existsSync()) {
        iconPath = file.path;
      }
    }
    
    resolvedEntries.add(AppStatEntry(
      packageName: entry.key,
      appName: app?.appName ?? _extractAppName(entry.key),
      iconPath: iconPath,
      count: entry.value,
    ));
  }

  return resolvedEntries;
});

/// Top 5 apps for chart display.
final top5AppsStatsProvider = FutureProvider<List<AppStatEntry>>((ref) async {
  final allApps = await ref.watch(topAppsStatsProvider.future);
  return allApps.take(5).toList();
});

/// Extract a readable app name from package name as fallback.
String _extractAppName(String packageName) {
  final parts = packageName.split('.');
  if (parts.length >= 2) {
    final name = parts.last;
    // Capitalize first letter
    return name[0].toUpperCase() + name.substring(1);
  }
  return packageName;
}



/// Single app stat entry.
class AppStatEntry {
  final String packageName;
  final String appName;
  final String? iconPath;
  final int count;

  const AppStatEntry({
    required this.packageName,
    required this.appName,
    this.iconPath,
    required this.count,
  });
}
