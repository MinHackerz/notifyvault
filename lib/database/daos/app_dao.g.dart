// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_dao.dart';

// ignore_for_file: type=lint
mixin _$AppDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppsTable get apps => attachedDatabase.apps;
  AppDaoManager get managers => AppDaoManager(this);
}

class AppDaoManager {
  final _$AppDaoMixin _db;
  AppDaoManager(this._db);
  $$AppsTableTableManager get apps =>
      $$AppsTableTableManager(_db.attachedDatabase, _db.apps);
}
