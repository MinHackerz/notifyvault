import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_preferences_table.dart';

part 'app_preferences_dao.g.dart';

/// Data Access Object for app preference operations (priority/block/spam).
@DriftAccessor(tables: [AppPreferences])
class AppPreferencesDao extends DatabaseAccessor<AppDatabase>
    with _$AppPreferencesDaoMixin {
  AppPreferencesDao(super.db);

  /// Get preference for a specific app.
  Future<AppPreference?> getPreference(String packageName) {
    return (select(appPreferences)
          ..where((t) => t.packageName.equals(packageName)))
        .getSingleOrNull();
  }

  /// Set or update preference for an app.
  Future<void> setPreference(
      String packageName, String appName, String status) {
    return into(appPreferences).insertOnConflictUpdate(
      AppPreferencesCompanion(
        packageName: Value(packageName),
        appName: Value(appName),
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Toggle readOutLoud preference for an app.
  Future<void> setReadOutLoud(String packageName, String appName, bool readOutLoud) async {
    final existing = await getPreference(packageName);
    final status = existing?.status ?? 'normal';
    
    await into(appPreferences).insertOnConflictUpdate(
      AppPreferencesCompanion(
        packageName: Value(packageName),
        appName: Value(appName),
        status: Value(status),
        readOutLoud: Value(readOutLoud),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get all app preferences.
  Future<List<AppPreference>> getAllPreferences() {
    return (select(appPreferences)
          ..orderBy([(t) => OrderingTerm.asc(t.appName)]))
        .get();
  }

  /// Watch all app preferences (reactive).
  Stream<List<AppPreference>> watchAllPreferences() {
    return (select(appPreferences)
          ..orderBy([(t) => OrderingTerm.asc(t.appName)]))
        .watch();
  }

  /// Get preferences by status.
  Future<List<AppPreference>> getByStatus(String status) {
    return (select(appPreferences)
          ..where((t) => t.status.equals(status))
          ..orderBy([(t) => OrderingTerm.asc(t.appName)]))
        .get();
  }

  /// Watch preferences by status.
  Stream<List<AppPreference>> watchByStatus(String status) {
    return (select(appPreferences)
          ..where((t) => t.status.equals(status))
          ..orderBy([(t) => OrderingTerm.asc(t.appName)]))
        .watch();
  }

  /// Remove preference for an app (reset to normal).
  Future<void> removePreference(String packageName) {
    return (delete(appPreferences)
          ..where((t) => t.packageName.equals(packageName)))
        .go();
  }

  /// Delete all preferences.
  Future<int> deleteAll() {
    return delete(appPreferences).go();
  }

  /// Check if a package is blocked.
  Future<bool> isBlocked(String packageName) async {
    final pref = await getPreference(packageName);
    return pref?.status == 'blocked';
  }

  /// Get all blocked package names as a Set for fast lookup.
  Future<Set<String>> getBlockedPackages() async {
    final blocked = await getByStatus('blocked');
    return blocked.map((p) => p.packageName).toSet();
  }

  /// Get all priority package names as a Set for fast lookup.
  Future<Set<String>> getPriorityPackages() async {
    final priority = await getByStatus('priority');
    return priority.map((p) => p.packageName).toSet();
  }

  /// Get all spam package names as a Set for fast lookup.
  Future<Set<String>> getSpamPackages() async {
    final spam = await getByStatus('spam');
    return spam.map((p) => p.packageName).toSet();
  }
}
