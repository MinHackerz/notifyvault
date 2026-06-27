// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, Notification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bigTextMeta = const VerificationMeta(
    'bigText',
  );
  @override
  late final GeneratedColumn<String> bigText = GeneratedColumn<String>(
    'big_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _importanceMeta = const VerificationMeta(
    'importance',
  );
  @override
  late final GeneratedColumn<int> importance = GeneratedColumn<int>(
    'importance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDismissedMeta = const VerificationMeta(
    'isDismissed',
  );
  @override
  late final GeneratedColumn<bool> isDismissed = GeneratedColumn<bool>(
    'is_dismissed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dismissed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _senderNameMeta = const VerificationMeta(
    'senderName',
  );
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
    'sender_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconPathMeta = const VerificationMeta(
    'iconPath',
  );
  @override
  late final GeneratedColumn<String> iconPath = GeneratedColumn<String>(
    'icon_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    'extras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    appName,
    title,
    body,
    bigText,
    timestamp,
    category,
    importance,
    isRead,
    isDismissed,
    senderName,
    conversationId,
    imagePath,
    iconPath,
    extras,
    deviceId,
    isFavorite,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Notification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('big_text')) {
      context.handle(
        _bigTextMeta,
        bigText.isAcceptableOrUnknown(data['big_text']!, _bigTextMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('importance')) {
      context.handle(
        _importanceMeta,
        importance.isAcceptableOrUnknown(data['importance']!, _importanceMeta),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('is_dismissed')) {
      context.handle(
        _isDismissedMeta,
        isDismissed.isAcceptableOrUnknown(
          data['is_dismissed']!,
          _isDismissedMeta,
        ),
      );
    }
    if (data.containsKey('sender_name')) {
      context.handle(
        _senderNameMeta,
        senderName.isAcceptableOrUnknown(data['sender_name']!, _senderNameMeta),
      );
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('icon_path')) {
      context.handle(
        _iconPathMeta,
        iconPath.isAcceptableOrUnknown(data['icon_path']!, _iconPathMeta),
      );
    }
    if (data.containsKey('extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['extras']!, _extrasMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      bigText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}big_text'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      importance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}importance'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      isDismissed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dismissed'],
      )!,
      senderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_name'],
      ),
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      iconPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_path'],
      ),
      extras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extras'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class Notification extends DataClass implements Insertable<Notification> {
  final String id;
  final String packageName;
  final String appName;
  final String? title;
  final String? body;
  final String? bigText;
  final DateTime timestamp;
  final String category;
  final int importance;
  final bool isRead;
  final bool isDismissed;
  final String? senderName;
  final String? conversationId;
  final String? imagePath;
  final String? iconPath;
  final String? extras;
  final String? deviceId;
  final bool isFavorite;
  final bool isSynced;
  const Notification({
    required this.id,
    required this.packageName,
    required this.appName,
    this.title,
    this.body,
    this.bigText,
    required this.timestamp,
    required this.category,
    required this.importance,
    required this.isRead,
    required this.isDismissed,
    this.senderName,
    this.conversationId,
    this.imagePath,
    this.iconPath,
    this.extras,
    this.deviceId,
    required this.isFavorite,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['package_name'] = Variable<String>(packageName);
    map['app_name'] = Variable<String>(appName);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || bigText != null) {
      map['big_text'] = Variable<String>(bigText);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['category'] = Variable<String>(category);
    map['importance'] = Variable<int>(importance);
    map['is_read'] = Variable<bool>(isRead);
    map['is_dismissed'] = Variable<bool>(isDismissed);
    if (!nullToAbsent || senderName != null) {
      map['sender_name'] = Variable<String>(senderName);
    }
    if (!nullToAbsent || conversationId != null) {
      map['conversation_id'] = Variable<String>(conversationId);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || iconPath != null) {
      map['icon_path'] = Variable<String>(iconPath);
    }
    if (!nullToAbsent || extras != null) {
      map['extras'] = Variable<String>(extras);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      packageName: Value(packageName),
      appName: Value(appName),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      bigText: bigText == null && nullToAbsent
          ? const Value.absent()
          : Value(bigText),
      timestamp: Value(timestamp),
      category: Value(category),
      importance: Value(importance),
      isRead: Value(isRead),
      isDismissed: Value(isDismissed),
      senderName: senderName == null && nullToAbsent
          ? const Value.absent()
          : Value(senderName),
      conversationId: conversationId == null && nullToAbsent
          ? const Value.absent()
          : Value(conversationId),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      iconPath: iconPath == null && nullToAbsent
          ? const Value.absent()
          : Value(iconPath),
      extras: extras == null && nullToAbsent
          ? const Value.absent()
          : Value(extras),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      isFavorite: Value(isFavorite),
      isSynced: Value(isSynced),
    );
  }

  factory Notification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notification(
      id: serializer.fromJson<String>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      appName: serializer.fromJson<String>(json['appName']),
      title: serializer.fromJson<String?>(json['title']),
      body: serializer.fromJson<String?>(json['body']),
      bigText: serializer.fromJson<String?>(json['bigText']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      category: serializer.fromJson<String>(json['category']),
      importance: serializer.fromJson<int>(json['importance']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isDismissed: serializer.fromJson<bool>(json['isDismissed']),
      senderName: serializer.fromJson<String?>(json['senderName']),
      conversationId: serializer.fromJson<String?>(json['conversationId']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      iconPath: serializer.fromJson<String?>(json['iconPath']),
      extras: serializer.fromJson<String?>(json['extras']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'packageName': serializer.toJson<String>(packageName),
      'appName': serializer.toJson<String>(appName),
      'title': serializer.toJson<String?>(title),
      'body': serializer.toJson<String?>(body),
      'bigText': serializer.toJson<String?>(bigText),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'category': serializer.toJson<String>(category),
      'importance': serializer.toJson<int>(importance),
      'isRead': serializer.toJson<bool>(isRead),
      'isDismissed': serializer.toJson<bool>(isDismissed),
      'senderName': serializer.toJson<String?>(senderName),
      'conversationId': serializer.toJson<String?>(conversationId),
      'imagePath': serializer.toJson<String?>(imagePath),
      'iconPath': serializer.toJson<String?>(iconPath),
      'extras': serializer.toJson<String?>(extras),
      'deviceId': serializer.toJson<String?>(deviceId),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Notification copyWith({
    String? id,
    String? packageName,
    String? appName,
    Value<String?> title = const Value.absent(),
    Value<String?> body = const Value.absent(),
    Value<String?> bigText = const Value.absent(),
    DateTime? timestamp,
    String? category,
    int? importance,
    bool? isRead,
    bool? isDismissed,
    Value<String?> senderName = const Value.absent(),
    Value<String?> conversationId = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    Value<String?> iconPath = const Value.absent(),
    Value<String?> extras = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    bool? isFavorite,
    bool? isSynced,
  }) => Notification(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    appName: appName ?? this.appName,
    title: title.present ? title.value : this.title,
    body: body.present ? body.value : this.body,
    bigText: bigText.present ? bigText.value : this.bigText,
    timestamp: timestamp ?? this.timestamp,
    category: category ?? this.category,
    importance: importance ?? this.importance,
    isRead: isRead ?? this.isRead,
    isDismissed: isDismissed ?? this.isDismissed,
    senderName: senderName.present ? senderName.value : this.senderName,
    conversationId: conversationId.present
        ? conversationId.value
        : this.conversationId,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    iconPath: iconPath.present ? iconPath.value : this.iconPath,
    extras: extras.present ? extras.value : this.extras,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    isFavorite: isFavorite ?? this.isFavorite,
    isSynced: isSynced ?? this.isSynced,
  );
  Notification copyWithCompanion(NotificationsCompanion data) {
    return Notification(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      appName: data.appName.present ? data.appName.value : this.appName,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      bigText: data.bigText.present ? data.bigText.value : this.bigText,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      category: data.category.present ? data.category.value : this.category,
      importance: data.importance.present
          ? data.importance.value
          : this.importance,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isDismissed: data.isDismissed.present
          ? data.isDismissed.value
          : this.isDismissed,
      senderName: data.senderName.present
          ? data.senderName.value
          : this.senderName,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      iconPath: data.iconPath.present ? data.iconPath.value : this.iconPath,
      extras: data.extras.present ? data.extras.value : this.extras,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notification(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('bigText: $bigText, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('importance: $importance, ')
          ..write('isRead: $isRead, ')
          ..write('isDismissed: $isDismissed, ')
          ..write('senderName: $senderName, ')
          ..write('conversationId: $conversationId, ')
          ..write('imagePath: $imagePath, ')
          ..write('iconPath: $iconPath, ')
          ..write('extras: $extras, ')
          ..write('deviceId: $deviceId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    appName,
    title,
    body,
    bigText,
    timestamp,
    category,
    importance,
    isRead,
    isDismissed,
    senderName,
    conversationId,
    imagePath,
    iconPath,
    extras,
    deviceId,
    isFavorite,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notification &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.appName == this.appName &&
          other.title == this.title &&
          other.body == this.body &&
          other.bigText == this.bigText &&
          other.timestamp == this.timestamp &&
          other.category == this.category &&
          other.importance == this.importance &&
          other.isRead == this.isRead &&
          other.isDismissed == this.isDismissed &&
          other.senderName == this.senderName &&
          other.conversationId == this.conversationId &&
          other.imagePath == this.imagePath &&
          other.iconPath == this.iconPath &&
          other.extras == this.extras &&
          other.deviceId == this.deviceId &&
          other.isFavorite == this.isFavorite &&
          other.isSynced == this.isSynced);
}

class NotificationsCompanion extends UpdateCompanion<Notification> {
  final Value<String> id;
  final Value<String> packageName;
  final Value<String> appName;
  final Value<String?> title;
  final Value<String?> body;
  final Value<String?> bigText;
  final Value<DateTime> timestamp;
  final Value<String> category;
  final Value<int> importance;
  final Value<bool> isRead;
  final Value<bool> isDismissed;
  final Value<String?> senderName;
  final Value<String?> conversationId;
  final Value<String?> imagePath;
  final Value<String?> iconPath;
  final Value<String?> extras;
  final Value<String?> deviceId;
  final Value<bool> isFavorite;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.appName = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.bigText = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.category = const Value.absent(),
    this.importance = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isDismissed = const Value.absent(),
    this.senderName = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.extras = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationsCompanion.insert({
    required String id,
    required String packageName,
    required String appName,
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.bigText = const Value.absent(),
    required DateTime timestamp,
    this.category = const Value.absent(),
    this.importance = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isDismissed = const Value.absent(),
    this.senderName = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.extras = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       packageName = Value(packageName),
       appName = Value(appName),
       timestamp = Value(timestamp);
  static Insertable<Notification> custom({
    Expression<String>? id,
    Expression<String>? packageName,
    Expression<String>? appName,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? bigText,
    Expression<DateTime>? timestamp,
    Expression<String>? category,
    Expression<int>? importance,
    Expression<bool>? isRead,
    Expression<bool>? isDismissed,
    Expression<String>? senderName,
    Expression<String>? conversationId,
    Expression<String>? imagePath,
    Expression<String>? iconPath,
    Expression<String>? extras,
    Expression<String>? deviceId,
    Expression<bool>? isFavorite,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (appName != null) 'app_name': appName,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (bigText != null) 'big_text': bigText,
      if (timestamp != null) 'timestamp': timestamp,
      if (category != null) 'category': category,
      if (importance != null) 'importance': importance,
      if (isRead != null) 'is_read': isRead,
      if (isDismissed != null) 'is_dismissed': isDismissed,
      if (senderName != null) 'sender_name': senderName,
      if (conversationId != null) 'conversation_id': conversationId,
      if (imagePath != null) 'image_path': imagePath,
      if (iconPath != null) 'icon_path': iconPath,
      if (extras != null) 'extras': extras,
      if (deviceId != null) 'device_id': deviceId,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationsCompanion copyWith({
    Value<String>? id,
    Value<String>? packageName,
    Value<String>? appName,
    Value<String?>? title,
    Value<String?>? body,
    Value<String?>? bigText,
    Value<DateTime>? timestamp,
    Value<String>? category,
    Value<int>? importance,
    Value<bool>? isRead,
    Value<bool>? isDismissed,
    Value<String?>? senderName,
    Value<String?>? conversationId,
    Value<String?>? imagePath,
    Value<String?>? iconPath,
    Value<String?>? extras,
    Value<String?>? deviceId,
    Value<bool>? isFavorite,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return NotificationsCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      title: title ?? this.title,
      body: body ?? this.body,
      bigText: bigText ?? this.bigText,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      importance: importance ?? this.importance,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      senderName: senderName ?? this.senderName,
      conversationId: conversationId ?? this.conversationId,
      imagePath: imagePath ?? this.imagePath,
      iconPath: iconPath ?? this.iconPath,
      extras: extras ?? this.extras,
      deviceId: deviceId ?? this.deviceId,
      isFavorite: isFavorite ?? this.isFavorite,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (bigText.present) {
      map['big_text'] = Variable<String>(bigText.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (importance.present) {
      map['importance'] = Variable<int>(importance.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isDismissed.present) {
      map['is_dismissed'] = Variable<bool>(isDismissed.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (iconPath.present) {
      map['icon_path'] = Variable<String>(iconPath.value);
    }
    if (extras.present) {
      map['extras'] = Variable<String>(extras.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('bigText: $bigText, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('importance: $importance, ')
          ..write('isRead: $isRead, ')
          ..write('isDismissed: $isDismissed, ')
          ..write('senderName: $senderName, ')
          ..write('conversationId: $conversationId, ')
          ..write('imagePath: $imagePath, ')
          ..write('iconPath: $iconPath, ')
          ..write('extras: $extras, ')
          ..write('deviceId: $deviceId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, icon, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String icon;
  final int color;
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
    };
  }

  Category copyWith({String? id, String? name, String? icon, int? color}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        color: color ?? this.color,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, icon, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> color;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String icon,
    required int color,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       icon = Value(icon),
       color = Value(color);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? color,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppsTable extends Apps with TableInfo<$AppsTable, App> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconPathMeta = const VerificationMeta(
    'iconPath',
  );
  @override
  late final GeneratedColumn<String> iconPath = GeneratedColumn<String>(
    'icon_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificationCountMeta = const VerificationMeta(
    'notificationCount',
  );
  @override
  late final GeneratedColumn<int> notificationCount = GeneratedColumn<int>(
    'notification_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastNotificationAtMeta =
      const VerificationMeta('lastNotificationAt');
  @override
  late final GeneratedColumn<DateTime> lastNotificationAt =
      GeneratedColumn<DateTime>(
        'last_notification_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    packageName,
    appName,
    iconPath,
    notificationCount,
    lastNotificationAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'apps';
  @override
  VerificationContext validateIntegrity(
    Insertable<App> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('icon_path')) {
      context.handle(
        _iconPathMeta,
        iconPath.isAcceptableOrUnknown(data['icon_path']!, _iconPathMeta),
      );
    }
    if (data.containsKey('notification_count')) {
      context.handle(
        _notificationCountMeta,
        notificationCount.isAcceptableOrUnknown(
          data['notification_count']!,
          _notificationCountMeta,
        ),
      );
    }
    if (data.containsKey('last_notification_at')) {
      context.handle(
        _lastNotificationAtMeta,
        lastNotificationAt.isAcceptableOrUnknown(
          data['last_notification_at']!,
          _lastNotificationAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageName};
  @override
  App map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return App(
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      )!,
      iconPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_path'],
      ),
      notificationCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_count'],
      )!,
      lastNotificationAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_notification_at'],
      ),
    );
  }

  @override
  $AppsTable createAlias(String alias) {
    return $AppsTable(attachedDatabase, alias);
  }
}

class App extends DataClass implements Insertable<App> {
  final String packageName;
  final String appName;
  final String? iconPath;
  final int notificationCount;
  final DateTime? lastNotificationAt;
  const App({
    required this.packageName,
    required this.appName,
    this.iconPath,
    required this.notificationCount,
    this.lastNotificationAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_name'] = Variable<String>(packageName);
    map['app_name'] = Variable<String>(appName);
    if (!nullToAbsent || iconPath != null) {
      map['icon_path'] = Variable<String>(iconPath);
    }
    map['notification_count'] = Variable<int>(notificationCount);
    if (!nullToAbsent || lastNotificationAt != null) {
      map['last_notification_at'] = Variable<DateTime>(lastNotificationAt);
    }
    return map;
  }

  AppsCompanion toCompanion(bool nullToAbsent) {
    return AppsCompanion(
      packageName: Value(packageName),
      appName: Value(appName),
      iconPath: iconPath == null && nullToAbsent
          ? const Value.absent()
          : Value(iconPath),
      notificationCount: Value(notificationCount),
      lastNotificationAt: lastNotificationAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastNotificationAt),
    );
  }

  factory App.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return App(
      packageName: serializer.fromJson<String>(json['packageName']),
      appName: serializer.fromJson<String>(json['appName']),
      iconPath: serializer.fromJson<String?>(json['iconPath']),
      notificationCount: serializer.fromJson<int>(json['notificationCount']),
      lastNotificationAt: serializer.fromJson<DateTime?>(
        json['lastNotificationAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageName': serializer.toJson<String>(packageName),
      'appName': serializer.toJson<String>(appName),
      'iconPath': serializer.toJson<String?>(iconPath),
      'notificationCount': serializer.toJson<int>(notificationCount),
      'lastNotificationAt': serializer.toJson<DateTime?>(lastNotificationAt),
    };
  }

  App copyWith({
    String? packageName,
    String? appName,
    Value<String?> iconPath = const Value.absent(),
    int? notificationCount,
    Value<DateTime?> lastNotificationAt = const Value.absent(),
  }) => App(
    packageName: packageName ?? this.packageName,
    appName: appName ?? this.appName,
    iconPath: iconPath.present ? iconPath.value : this.iconPath,
    notificationCount: notificationCount ?? this.notificationCount,
    lastNotificationAt: lastNotificationAt.present
        ? lastNotificationAt.value
        : this.lastNotificationAt,
  );
  App copyWithCompanion(AppsCompanion data) {
    return App(
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      appName: data.appName.present ? data.appName.value : this.appName,
      iconPath: data.iconPath.present ? data.iconPath.value : this.iconPath,
      notificationCount: data.notificationCount.present
          ? data.notificationCount.value
          : this.notificationCount,
      lastNotificationAt: data.lastNotificationAt.present
          ? data.lastNotificationAt.value
          : this.lastNotificationAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('App(')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('iconPath: $iconPath, ')
          ..write('notificationCount: $notificationCount, ')
          ..write('lastNotificationAt: $lastNotificationAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    packageName,
    appName,
    iconPath,
    notificationCount,
    lastNotificationAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is App &&
          other.packageName == this.packageName &&
          other.appName == this.appName &&
          other.iconPath == this.iconPath &&
          other.notificationCount == this.notificationCount &&
          other.lastNotificationAt == this.lastNotificationAt);
}

class AppsCompanion extends UpdateCompanion<App> {
  final Value<String> packageName;
  final Value<String> appName;
  final Value<String?> iconPath;
  final Value<int> notificationCount;
  final Value<DateTime?> lastNotificationAt;
  final Value<int> rowid;
  const AppsCompanion({
    this.packageName = const Value.absent(),
    this.appName = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.notificationCount = const Value.absent(),
    this.lastNotificationAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppsCompanion.insert({
    required String packageName,
    required String appName,
    this.iconPath = const Value.absent(),
    this.notificationCount = const Value.absent(),
    this.lastNotificationAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : packageName = Value(packageName),
       appName = Value(appName);
  static Insertable<App> custom({
    Expression<String>? packageName,
    Expression<String>? appName,
    Expression<String>? iconPath,
    Expression<int>? notificationCount,
    Expression<DateTime>? lastNotificationAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageName != null) 'package_name': packageName,
      if (appName != null) 'app_name': appName,
      if (iconPath != null) 'icon_path': iconPath,
      if (notificationCount != null) 'notification_count': notificationCount,
      if (lastNotificationAt != null)
        'last_notification_at': lastNotificationAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppsCompanion copyWith({
    Value<String>? packageName,
    Value<String>? appName,
    Value<String?>? iconPath,
    Value<int>? notificationCount,
    Value<DateTime?>? lastNotificationAt,
    Value<int>? rowid,
  }) {
    return AppsCompanion(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      iconPath: iconPath ?? this.iconPath,
      notificationCount: notificationCount ?? this.notificationCount,
      lastNotificationAt: lastNotificationAt ?? this.lastNotificationAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (iconPath.present) {
      map['icon_path'] = Variable<String>(iconPath.value);
    }
    if (notificationCount.present) {
      map['notification_count'] = Variable<int>(notificationCount.value);
    }
    if (lastNotificationAt.present) {
      map['last_notification_at'] = Variable<DateTime>(
        lastNotificationAt.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppsCompanion(')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('iconPath: $iconPath, ')
          ..write('notificationCount: $notificationCount, ')
          ..write('lastNotificationAt: $lastNotificationAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<String> notificationId = GeneratedColumn<String>(
    'notification_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    notificationId,
    status,
    retryCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {notificationId};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String notificationId;
  final String status;
  final int retryCount;
  final DateTime createdAt;
  const SyncQueueData({
    required this.notificationId,
    required this.status,
    required this.retryCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['notification_id'] = Variable<String>(notificationId);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      notificationId: Value(notificationId),
      status: Value(status),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      notificationId: serializer.fromJson<String>(json['notificationId']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'notificationId': serializer.toJson<String>(notificationId),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueData copyWith({
    String? notificationId,
    String? status,
    int? retryCount,
    DateTime? createdAt,
  }) => SyncQueueData(
    notificationId: notificationId ?? this.notificationId,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('notificationId: $notificationId, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(notificationId, status, retryCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.notificationId == this.notificationId &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> notificationId;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.notificationId = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String notificationId,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : notificationId = Value(notificationId),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<String>? notificationId,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (notificationId != null) 'notification_id': notificationId,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith({
    Value<String>? notificationId,
    Value<String>? status,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SyncQueueCompanion(
      notificationId: notificationId ?? this.notificationId,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (notificationId.present) {
      map['notification_id'] = Variable<String>(notificationId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('notificationId: $notificationId, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $AppsTable apps = $AppsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final NotificationDao notificationDao = NotificationDao(
    this as AppDatabase,
  );
  late final AppDao appDao = AppDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    notifications,
    categories,
    apps,
    syncQueue,
  ];
}

typedef $$NotificationsTableCreateCompanionBuilder =
    NotificationsCompanion Function({
      required String id,
      required String packageName,
      required String appName,
      Value<String?> title,
      Value<String?> body,
      Value<String?> bigText,
      required DateTime timestamp,
      Value<String> category,
      Value<int> importance,
      Value<bool> isRead,
      Value<bool> isDismissed,
      Value<String?> senderName,
      Value<String?> conversationId,
      Value<String?> imagePath,
      Value<String?> iconPath,
      Value<String?> extras,
      Value<String?> deviceId,
      Value<bool> isFavorite,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$NotificationsTableUpdateCompanionBuilder =
    NotificationsCompanion Function({
      Value<String> id,
      Value<String> packageName,
      Value<String> appName,
      Value<String?> title,
      Value<String?> body,
      Value<String?> bigText,
      Value<DateTime> timestamp,
      Value<String> category,
      Value<int> importance,
      Value<bool> isRead,
      Value<bool> isDismissed,
      Value<String?> senderName,
      Value<String?> conversationId,
      Value<String?> imagePath,
      Value<String?> iconPath,
      Value<String?> extras,
      Value<String?> deviceId,
      Value<bool> isFavorite,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bigText => $composableBuilder(
    column: $table.bigText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDismissed => $composableBuilder(
    column: $table.isDismissed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extras => $composableBuilder(
    column: $table.extras,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bigText => $composableBuilder(
    column: $table.bigText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDismissed => $composableBuilder(
    column: $table.isDismissed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extras => $composableBuilder(
    column: $table.extras,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get bigText =>
      $composableBuilder(column: $table.bigText, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get isDismissed => $composableBuilder(
    column: $table.isDismissed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get iconPath =>
      $composableBuilder(column: $table.iconPath, builder: (column) => column);

  GeneratedColumn<String> get extras =>
      $composableBuilder(column: $table.extras, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$NotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationsTable,
          Notification,
          $$NotificationsTableFilterComposer,
          $$NotificationsTableOrderingComposer,
          $$NotificationsTableAnnotationComposer,
          $$NotificationsTableCreateCompanionBuilder,
          $$NotificationsTableUpdateCompanionBuilder,
          (
            Notification,
            BaseReferences<_$AppDatabase, $NotificationsTable, Notification>,
          ),
          Notification,
          PrefetchHooks Function()
        > {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> appName = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> bigText = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> importance = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isDismissed = const Value.absent(),
                Value<String?> senderName = const Value.absent(),
                Value<String?> conversationId = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> iconPath = const Value.absent(),
                Value<String?> extras = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationsCompanion(
                id: id,
                packageName: packageName,
                appName: appName,
                title: title,
                body: body,
                bigText: bigText,
                timestamp: timestamp,
                category: category,
                importance: importance,
                isRead: isRead,
                isDismissed: isDismissed,
                senderName: senderName,
                conversationId: conversationId,
                imagePath: imagePath,
                iconPath: iconPath,
                extras: extras,
                deviceId: deviceId,
                isFavorite: isFavorite,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String packageName,
                required String appName,
                Value<String?> title = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> bigText = const Value.absent(),
                required DateTime timestamp,
                Value<String> category = const Value.absent(),
                Value<int> importance = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isDismissed = const Value.absent(),
                Value<String?> senderName = const Value.absent(),
                Value<String?> conversationId = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> iconPath = const Value.absent(),
                Value<String?> extras = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationsCompanion.insert(
                id: id,
                packageName: packageName,
                appName: appName,
                title: title,
                body: body,
                bigText: bigText,
                timestamp: timestamp,
                category: category,
                importance: importance,
                isRead: isRead,
                isDismissed: isDismissed,
                senderName: senderName,
                conversationId: conversationId,
                imagePath: imagePath,
                iconPath: iconPath,
                extras: extras,
                deviceId: deviceId,
                isFavorite: isFavorite,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationsTable,
      Notification,
      $$NotificationsTableFilterComposer,
      $$NotificationsTableOrderingComposer,
      $$NotificationsTableAnnotationComposer,
      $$NotificationsTableCreateCompanionBuilder,
      $$NotificationsTableUpdateCompanionBuilder,
      (
        Notification,
        BaseReferences<_$AppDatabase, $NotificationsTable, Notification>,
      ),
      Notification,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String icon,
      required int color,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> icon,
      Value<int> color,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                icon: icon,
                color: color,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String icon,
                required int color,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$AppsTableCreateCompanionBuilder =
    AppsCompanion Function({
      required String packageName,
      required String appName,
      Value<String?> iconPath,
      Value<int> notificationCount,
      Value<DateTime?> lastNotificationAt,
      Value<int> rowid,
    });
typedef $$AppsTableUpdateCompanionBuilder =
    AppsCompanion Function({
      Value<String> packageName,
      Value<String> appName,
      Value<String?> iconPath,
      Value<int> notificationCount,
      Value<DateTime?> lastNotificationAt,
      Value<int> rowid,
    });

class $$AppsTableFilterComposer extends Composer<_$AppDatabase, $AppsTable> {
  $$AppsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationCount => $composableBuilder(
    column: $table.notificationCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastNotificationAt => $composableBuilder(
    column: $table.lastNotificationAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppsTableOrderingComposer extends Composer<_$AppDatabase, $AppsTable> {
  $$AppsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationCount => $composableBuilder(
    column: $table.notificationCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastNotificationAt => $composableBuilder(
    column: $table.lastNotificationAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppsTable> {
  $$AppsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<String> get iconPath =>
      $composableBuilder(column: $table.iconPath, builder: (column) => column);

  GeneratedColumn<int> get notificationCount => $composableBuilder(
    column: $table.notificationCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastNotificationAt => $composableBuilder(
    column: $table.lastNotificationAt,
    builder: (column) => column,
  );
}

class $$AppsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppsTable,
          App,
          $$AppsTableFilterComposer,
          $$AppsTableOrderingComposer,
          $$AppsTableAnnotationComposer,
          $$AppsTableCreateCompanionBuilder,
          $$AppsTableUpdateCompanionBuilder,
          (App, BaseReferences<_$AppDatabase, $AppsTable, App>),
          App,
          PrefetchHooks Function()
        > {
  $$AppsTableTableManager(_$AppDatabase db, $AppsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> packageName = const Value.absent(),
                Value<String> appName = const Value.absent(),
                Value<String?> iconPath = const Value.absent(),
                Value<int> notificationCount = const Value.absent(),
                Value<DateTime?> lastNotificationAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppsCompanion(
                packageName: packageName,
                appName: appName,
                iconPath: iconPath,
                notificationCount: notificationCount,
                lastNotificationAt: lastNotificationAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String packageName,
                required String appName,
                Value<String?> iconPath = const Value.absent(),
                Value<int> notificationCount = const Value.absent(),
                Value<DateTime?> lastNotificationAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppsCompanion.insert(
                packageName: packageName,
                appName: appName,
                iconPath: iconPath,
                notificationCount: notificationCount,
                lastNotificationAt: lastNotificationAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppsTable,
      App,
      $$AppsTableFilterComposer,
      $$AppsTableOrderingComposer,
      $$AppsTableAnnotationComposer,
      $$AppsTableCreateCompanionBuilder,
      $$AppsTableUpdateCompanionBuilder,
      (App, BaseReferences<_$AppDatabase, $AppsTable, App>),
      App,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      required String notificationId,
      Value<String> status,
      Value<int> retryCount,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<String> notificationId,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> notificationId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion(
                notificationId: notificationId,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String notificationId,
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                notificationId: notificationId,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$AppsTableTableManager get apps => $$AppsTableTableManager(_db, _db.apps);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
