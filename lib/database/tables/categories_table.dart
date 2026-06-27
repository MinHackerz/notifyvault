import 'package:drift/drift.dart';

/// Drift table for notification categories.
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
