/// Represents a captured notification from any Android app.
class NotificationModel {
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
  final Map<String, dynamic>? extras;
  final String? deviceId;
  final bool isFavorite;
  final bool isSynced;

  const NotificationModel({
    required this.id,
    required this.packageName,
    required this.appName,
    this.title,
    this.body,
    this.bigText,
    required this.timestamp,
    this.category = 'other',
    this.importance = 3,
    this.isRead = false,
    this.isDismissed = false,
    this.senderName,
    this.conversationId,
    this.imagePath,
    this.iconPath,
    this.extras,
    this.deviceId,
    this.isFavorite = false,
    this.isSynced = false,
  });

  /// Create from platform channel map (data arriving from Android native).
  factory NotificationModel.fromPlatformData(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String? ??
          '${map['packageName']}_${DateTime.now().millisecondsSinceEpoch}',
      packageName: map['packageName'] as String? ?? 'unknown',
      appName: map['appName'] as String? ?? 'Unknown App',
      title: map['title'] as String?,
      body: map['body'] as String?,
      bigText: map['bigText'] as String?,
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
      category: map['category'] as String? ?? 'other',
      importance: map['importance'] as int? ?? 3,
      isRead: map['isRead'] as bool? ?? false,
      isDismissed: map['isDismissed'] as bool? ?? false,
      senderName: map['senderName'] as String?,
      conversationId: map['conversationId'] as String?,
      imagePath: map['imagePath'] as String?,
      iconPath: map['iconPath'] as String?,
      extras: map['extras'] as Map<String, dynamic>?,
      deviceId: map['deviceId'] as String?,
      isFavorite: false,
      isSynced: false,
    );
  }

  /// Convert to JSON for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageName': packageName,
      'appName': appName,
      'title': title,
      'body': body,
      'bigText': bigText,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'category': category,
      'importance': importance,
      'isRead': isRead,
      'isDismissed': isDismissed,
      'senderName': senderName,
      'conversationId': conversationId,
      'imagePath': imagePath,
      'iconPath': iconPath,
      'extras': extras,
      'deviceId': deviceId,
      'isFavorite': isFavorite,
      'isSynced': isSynced,
    };
  }

  /// Create from Firestore JSON.
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      title: json['title'] as String?,
      body: json['body'] as String?,
      bigText: json['bigText'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      category: json['category'] as String? ?? 'other',
      importance: json['importance'] as int? ?? 3,
      isRead: json['isRead'] as bool? ?? false,
      isDismissed: json['isDismissed'] as bool? ?? false,
      senderName: json['senderName'] as String?,
      conversationId: json['conversationId'] as String?,
      imagePath: json['imagePath'] as String?,
      iconPath: json['iconPath'] as String?,
      extras: json['extras'] as Map<String, dynamic>?,
      deviceId: json['deviceId'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }

  /// Copy with modified fields.
  NotificationModel copyWith({
    String? id,
    String? packageName,
    String? appName,
    String? title,
    String? body,
    String? bigText,
    DateTime? timestamp,
    String? category,
    int? importance,
    bool? isRead,
    bool? isDismissed,
    String? senderName,
    String? conversationId,
    String? imagePath,
    String? iconPath,
    Map<String, dynamic>? extras,
    String? deviceId,
    bool? isFavorite,
    bool? isSynced,
  }) {
    return NotificationModel(
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
    );
  }

  /// The display text — prefers bigText over body for richer content.
  String get displayText => bigText ?? body ?? '';

  @override
  String toString() =>
      'NotificationModel(id: $id, app: $appName, title: $title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
