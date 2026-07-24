import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/helpers/distraction_analyzer.dart';
import '../database/app_database.dart';
import 'notification_providers.dart';
import 'statistics_providers.dart';

final distractionAnalyticsProvider = FutureProvider<DistractionMetrics>((ref) async {
  final notifications = await ref.watch(notificationStreamProvider.future);
  final days = ref.watch(statsTimeRangeProvider);
  final since = DateTime.now().subtract(Duration(days: days));

  final filtered = notifications.where((n) => n.timestamp.isAfter(since)).toList();

  final db = AppDatabase.instance;
  final apps = await db.appDao.getAllApps();

  final appNameMap = <String, String>{};
  final appIconMap = <String, String?>{};

  for (final app in apps) {
    appNameMap[app.packageName] = app.appName;
    appIconMap[app.packageName] = app.iconPath;
  }

  return DistractionAnalyzer.analyze(
    notifications: filtered,
    days: days,
    appNameMap: appNameMap,
    appIconMap: appIconMap,
  );
});
