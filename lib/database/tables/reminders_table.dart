import 'package:drift/drift.dart';

/// Drift table for storing user-scheduled reminders.
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get notificationId => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get packageName => text()();
  TextColumn get appName => text()();
  DateTimeColumn get scheduledAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}
