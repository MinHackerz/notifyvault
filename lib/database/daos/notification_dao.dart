import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/notifications_table.dart';

part 'notification_dao.g.dart';

/// Data Access Object for notification operations.
@DriftAccessor(tables: [Notifications])
class NotificationDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationDaoMixin {
  NotificationDao(super.db);

  /// Insert or replace a notification.
  Future<void> insertNotification(NotificationsCompanion notification) {
    return into(notifications).insertOnConflictUpdate(notification);
  }

  /// Get all notifications ordered by timestamp descending, with pagination.
  Future<List<Notification>> getNotifications({
    int limit = 30,
    int offset = 0,
  }) {
    return (select(notifications)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Watch all notifications as a reactive stream.
  Stream<List<Notification>> watchNotifications({int limit = 100}) {
    return (select(notifications)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit))
        .watch();
  }

  /// Get a single notification by ID.
  Future<Notification?> getNotificationById(String id) {
    return (select(notifications)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Watch a single notification by ID.
  Stream<Notification?> watchNotificationById(String id) {
    return (select(notifications)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Get the most recent notification for a specific package.
  Future<Notification?> getMostRecentNotificationForPackage(String packageName) {
    return (select(notifications)
          ..where((t) => t.packageName.equals(packageName))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Search notifications using LIKE queries on title, body, bigText, appName.
  Future<List<Notification>> searchNotifications(
    String query, {
    int limit = 20,
    int offset = 0,
  }) {
    final searchPattern = '%$query%';
    return (select(notifications)
          ..where((t) =>
              t.title.like(searchPattern) |
              t.body.like(searchPattern) |
              t.bigText.like(searchPattern) |
              t.appName.like(searchPattern) |
              t.senderName.like(searchPattern) |
              t.packageName.like(searchPattern))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Get notifications filtered by category.
  Future<List<Notification>> getByCategory(
    String category, {
    int limit = 30,
    int offset = 0,
  }) {
    return (select(notifications)
          ..where((t) => t.category.equals(category))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Get favorite notifications.
  Future<List<Notification>> getFavorites({
    int limit = 30,
    int offset = 0,
  }) {
    return (select(notifications)
          ..where((t) => t.isFavorite.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Watch favorite notifications.
  Stream<List<Notification>> watchFavorites() {
    return (select(notifications)
          ..where((t) => t.isFavorite.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .watch();
  }

  /// Get notifications from today.
  Future<List<Notification>> getTodayNotifications() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return (select(notifications)
          ..where((t) => t.timestamp.isBiggerOrEqualValue(startOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  /// Get notification count for today.
  Future<int> getTodayCount() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final count = notifications.id.count();
    final query = selectOnly(notifications)
      ..addColumns([count])
      ..where(notifications.timestamp.isBiggerOrEqualValue(startOfDay));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Get unread notification count.
  Future<int> getUnreadCount() async {
    final count = notifications.id.count();
    final query = selectOnly(notifications)
      ..addColumns([count])
      ..where(notifications.isRead.equals(false));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Get total notification count.
  Future<int> getTotalCount() async {
    final count = notifications.id.count();
    final query = selectOnly(notifications)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Toggle favorite status.
  Future<void> toggleFavorite(String id) async {
    final notification = await getNotificationById(id);
    if (notification != null) {
      await (update(notifications)..where((t) => t.id.equals(id))).write(
        NotificationsCompanion(
          isFavorite: Value(!notification.isFavorite),
        ),
      );
    }
  }

  /// Mark a notification as read.
  Future<void> markAsRead(String id) {
    return (update(notifications)..where((t) => t.id.equals(id))).write(
      const NotificationsCompanion(isRead: Value(true)),
    );
  }

  /// Mark a notification as dismissed.
  Future<void> markAsDismissed(String id) {
    return (update(notifications)
          ..where((t) => t.id.equals(id) | t.id.like('$id%')))
        .write(
      const NotificationsCompanion(isDismissed: Value(true)),
    );
  }

  /// Delete a notification.
  Future<void> deleteNotification(String id) {
    return (delete(notifications)..where((t) => t.id.equals(id))).go();
  }

  /// Delete notifications older than the given date.
  Future<int> deleteOlderThan(DateTime date) {
    return (delete(notifications)
          ..where((t) => t.timestamp.isSmallerThanValue(date)))
        .go();
  }

  /// Delete all notifications.
  Future<int> deleteAll() {
    return delete(notifications).go();
  }

  /// Get distinct app names that have sent notifications.
  Future<List<String>> getDistinctAppNames() async {
    final query = selectOnly(notifications, distinct: true)
      ..addColumns([notifications.appName]);
    final results = await query.get();
    return results
        .map((row) => row.read(notifications.appName))
        .whereType<String>()
        .toList();
  }

  /// Get notification count per category.
  Future<Map<String, int>> getCategoryCounts() async {
    final count = notifications.id.count();
    final query = selectOnly(notifications)
      ..addColumns([notifications.category, count])
      ..groupBy([notifications.category]);
    final results = await query.get();
    return Map.fromEntries(
      results.map((row) => MapEntry(
            row.read(notifications.category) ?? 'other',
            row.read(count) ?? 0,
          )),
    );
  }

  /// Get the count of distinct apps active today.
  Future<int> getActiveAppsToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final count = notifications.packageName.count(distinct: true);
    final query = selectOnly(notifications)
      ..addColumns([count])
      ..where(notifications.timestamp.isBiggerOrEqualValue(startOfDay));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Get total notification count since a given date.
  Future<int> getCountSince(DateTime since) async {
    final count = notifications.id.count();
    final query = selectOnly(notifications)
      ..addColumns([count])
      ..where(notifications.timestamp.isBiggerOrEqualValue(since));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Get dismissed notification count since a given date.
  Future<int> getDismissedCountSince(DateTime since) async {
    final count = notifications.id.count();
    final query = selectOnly(notifications)
      ..addColumns([count])
      ..where(notifications.timestamp.isBiggerOrEqualValue(since) &
          notifications.isDismissed.equals(true));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Get notification counts grouped by app (package name) since a given date.
  Future<Map<String, int>> getNotificationCountsByApp(DateTime since) async {
    final count = notifications.id.count();
    final query = selectOnly(notifications)
      ..addColumns([notifications.packageName, count])
      ..where(notifications.timestamp.isBiggerOrEqualValue(since))
      ..groupBy([notifications.packageName]);
    final results = await query.get();
    return Map.fromEntries(
      results.map((row) => MapEntry(
            row.read(notifications.packageName) ?? 'unknown',
            row.read(count) ?? 0,
          )),
    );
  }
}
