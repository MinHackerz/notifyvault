import 'package:drift/drift.dart';

/// Drift table for stored notifications.
class Notifications extends Table {
  // Primary key
  TextColumn get id => text()();

  // App identification
  TextColumn get packageName => text()();
  TextColumn get appName => text()();

  // Content
  TextColumn get title => text().nullable()();
  TextColumn get body => text().nullable()();
  TextColumn get bigText => text().nullable()();

  // Metadata
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get category => text().withDefault(const Constant('other'))();
  IntColumn get importance => integer().withDefault(const Constant(3))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isDismissed => boolean().withDefault(const Constant(false))();

  // Sender / Conversation
  TextColumn get senderName => text().nullable()();
  TextColumn get conversationId => text().nullable()();

  // Media
  TextColumn get imagePath => text().nullable()();
  TextColumn get iconPath => text().nullable()();

  // Extra data stored as JSON string
  TextColumn get extras => text().nullable()();

  // Device
  TextColumn get deviceId => text().nullable()();

  // User actions
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [];
}
