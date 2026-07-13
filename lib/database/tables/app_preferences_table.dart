import 'package:drift/drift.dart';

/// Drift table for storing per-app preference settings (priority/block/spam).
class AppPreferences extends Table {
  TextColumn get packageName => text()();
  TextColumn get appName => text()();

  /// Status: 'normal', 'priority', 'blocked', 'spam'
  TextColumn get status =>
      text().withDefault(const Constant('normal'))();

  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {packageName};
}
