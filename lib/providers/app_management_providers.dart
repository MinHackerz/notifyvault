import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../core/services/notification_channel_service.dart';

/// Session-level unlock state for app management (ad-gated).
final appManagementUnlockedProvider =
    NotifierProvider<AppManagementUnlockedNotifier, bool>(
        AppManagementUnlockedNotifier.new);

class AppManagementUnlockedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;
}

/// All app preferences (reactive stream).
final appPreferencesStreamProvider =
    StreamProvider<List<AppPreference>>((ref) {
  return AppDatabase.instance.appPreferencesDao.watchAllPreferences();
});

/// Priority package names as a Set for fast lookup.
final priorityPackagesProvider = FutureProvider<Set<String>>((ref) {
  // Re-evaluate when preferences change
  ref.watch(appPreferencesStreamProvider);
  return AppDatabase.instance.appPreferencesDao.getPriorityPackages();
});

/// Blocked package names as a Set for fast lookup.
final blockedPackagesProvider = FutureProvider<Set<String>>((ref) {
  ref.watch(appPreferencesStreamProvider);
  return AppDatabase.instance.appPreferencesDao.getBlockedPackages();
});

/// Spam package names as a Set for fast lookup.
final spamPackagesProvider = FutureProvider<Set<String>>((ref) {
  ref.watch(appPreferencesStreamProvider);
  return AppDatabase.instance.appPreferencesDao.getSpamPackages();
});

/// All tracked apps combined with their preference status.
final appsWithPreferencesProvider =
    FutureProvider<List<AppWithPreference>>((ref) async {
  ref.watch(appPreferencesStreamProvider);
  
  // Get all installed apps from Android native side
  final installedApps = await NotificationChannelService.instance.getInstalledApps();
  
  // Get tracked notification counts from AppDao
  final allTrackedApps = await AppDatabase.instance.appDao.getAllApps();
  final countsMap = {for (final app in allTrackedApps) app.packageName: app.notificationCount};
  
  // Get user-set priority preferences
  final prefs = await AppDatabase.instance.appPreferencesDao.getAllPreferences();
  final prefMap = {for (final p in prefs) p.packageName: p.status};

  return installedApps.map((map) {
    final packageName = map['packageName'] as String;
    final appName = map['appName'] as String;
    final iconPath = map['iconPath'] as String?;
    
    return AppWithPreference(
      packageName: packageName,
      appName: appName,
      iconPath: iconPath,
      notificationCount: countsMap[packageName] ?? 0,
      status: prefMap[packageName] ?? 'normal',
    );
  }).toList();
});

/// Combined model for displaying apps with their preference status.
class AppWithPreference {
  final String packageName;
  final String appName;
  final String? iconPath;
  final int notificationCount;
  final String status; // 'normal', 'priority', 'blocked', 'spam'

  const AppWithPreference({
    required this.packageName,
    required this.appName,
    this.iconPath,
    required this.notificationCount,
    required this.status,
  });
}
