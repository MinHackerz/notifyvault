import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../database/app_database.dart';
import '../providers/settings_providers.dart';

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

/// Stats summary: total received in range.
final statsSummaryProvider =
    FutureProvider<StatsSummary>((ref) async {
  final days = ref.watch(statsTimeRangeProvider);
  final since = DateTime.now().subtract(Duration(days: days));
  final db = AppDatabase.instance;

  final totalReceived =
      await db.notificationDao.getCountSince(since);
  final totalDismissed =
      await db.notificationDao.getDismissedCountSince(since);
  final totalSaved = totalReceived - totalDismissed;

  return StatsSummary(
    totalReceived: totalReceived,
    totalSaved: totalSaved > 0 ? totalSaved : 0,
    totalDeleted: totalDismissed,
    days: days,
  );
});

/// Top N apps by notification count within the time range.
final topAppsStatsProvider =
    FutureProvider<List<AppStatEntry>>((ref) async {
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

/// Summary model for statistics.
class StatsSummary {
  final int totalReceived;
  final int totalSaved;
  final int totalDeleted;
  final int days;

  const StatsSummary({
    required this.totalReceived,
    required this.totalSaved,
    required this.totalDeleted,
    required this.days,
  });
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
