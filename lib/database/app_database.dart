import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../app/config/app_config.dart';
import 'tables/notifications_table.dart';
import 'tables/categories_table.dart';
import 'tables/apps_table.dart';
import 'tables/app_preferences_table.dart';
import 'daos/notification_dao.dart';
import 'daos/app_dao.dart';
import 'daos/app_preferences_dao.dart';

part 'app_database.g.dart';

/// Main Drift database for NotifyVault.
@DriftDatabase(
  tables: [Notifications, Categories, Apps, AppPreferences],
  daos: [NotificationDao, AppDao, AppPreferencesDao],
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(appPreferences);
        }
        if (from < 3) {
          await m.addColumn(appPreferences, appPreferences.readOutLoud);
        }
      },
    );
  }
}
