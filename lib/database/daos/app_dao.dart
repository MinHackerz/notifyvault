import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/apps_table.dart';

part 'app_dao.g.dart';

/// Data Access Object for app tracking operations.
@DriftAccessor(tables: [Apps])
class AppDao extends DatabaseAccessor<AppDatabase> with _$AppDaoMixin {
  AppDao(super.db);

  /// Insert or update an app entry.
  Future<void> upsertApp(AppsCompanion app) {
    return into(apps).insertOnConflictUpdate(app);
  }

  /// Increment the notification count for an app.
  Future<void> incrementCount(String packageName, String appName, {String? iconPath}) async {
    final existing = await getApp(packageName);
    if (existing != null) {
      await (update(apps)..where((t) => t.packageName.equals(packageName)))
          .write(AppsCompanion(
        notificationCount: Value(existing.notificationCount + 1),
        lastNotificationAt: Value(DateTime.now()),
        iconPath: iconPath != null ? Value(iconPath) : const Value.absent(),
      ));
    } else {
      await upsertApp(AppsCompanion.insert(
        packageName: packageName,
        appName: appName,
        notificationCount: const Value(1),
        lastNotificationAt: Value(DateTime.now()),
        iconPath: Value(iconPath),
      ));
    }
  }

  /// Get an app by package name.
  Future<App?> getApp(String packageName) {
    return (select(apps)..where((t) => t.packageName.equals(packageName)))
        .getSingleOrNull();
  }

  /// Get all tracked apps ordered by notification count.
  Future<List<App>> getAllApps() {
    return (select(apps)
          ..orderBy([(t) => OrderingTerm.desc(t.notificationCount)]))
        .get();
  }

  /// Watch all apps.
  Stream<List<App>> watchAllApps() {
    return (select(apps)
          ..orderBy([(t) => OrderingTerm.desc(t.notificationCount)]))
        .watch();
  }

  /// Get top apps by notification count.
  Future<List<App>> getTopApps({int limit = 5}) {
    return (select(apps)
          ..orderBy([(t) => OrderingTerm.desc(t.notificationCount)])
          ..limit(limit))
        .get();
  }

  /// Get the total number of tracked apps.
  Future<int> getAppCount() async {
    final count = apps.packageName.count();
    final query = selectOnly(apps)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Delete all app data.
  Future<int> deleteAll() {
    return delete(apps).go();
  }
}
