import 'package:drift/drift.dart';

/// Drift table for cloud sync queue.
class SyncQueue extends Table {
  TextColumn get notificationId => text()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending, synced, failed
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {notificationId};
}
