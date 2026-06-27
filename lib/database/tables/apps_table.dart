import 'package:drift/drift.dart';

/// Drift table for tracking apps that send notifications.
class Apps extends Table {
  TextColumn get packageName => text()();
  TextColumn get appName => text()();
  TextColumn get iconPath => text().nullable()();
  IntColumn get notificationCount =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lastNotificationAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {packageName};
}
