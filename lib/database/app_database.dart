import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../app/config/app_config.dart';
import 'tables/notifications_table.dart';
import 'tables/categories_table.dart';
import 'tables/apps_table.dart';
import 'tables/sync_queue_table.dart';
import 'daos/notification_dao.dart';
import 'daos/app_dao.dart';

part 'app_database.g.dart';

/// Main Drift database for NotifyVault.
@DriftDatabase(
  tables: [Notifications, Categories, Apps, SyncQueue],
  daos: [NotificationDao, AppDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(driftDatabase(name: AppConfig.databaseName));

  static AppDatabase? _instance;

  /// Singleton database instance.
  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  @override
  int get schemaVersion => AppConfig.databaseVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here
      },
    );
  }
}
