import 'package:drift/drift.dart';

/// Drift table for stored notifications.
@TableIndex(name: 'idx_notifications_timestamp', columns: {#timestamp})
@TableIndex(name: 'idx_notifications_package', columns: {#packageName})
@TableIndex(name: 'idx_notifications_category', columns: {#category})
@TableIndex(name: 'idx_notifications_is_read', columns: {#isRead})
@TableIndex(name: 'idx_notifications_is_favorite', columns: {#isFavorite})
@TableIndex(name: 'idx_notifications_ts_dismissed', columns: {#timestamp, #isDismissed})
@TableIndex(name: 'idx_notifications_ts_category', columns: {#timestamp, #category})
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
