import 'package:flutter/material.dart';

/// Represents an app that has sent notifications.
class AppModel {
  final String packageName;
  final String appName;
  final String? iconPath;
  final int notificationCount;
  final DateTime? lastNotificationAt;

  const AppModel({
    required this.packageName,
    required this.appName,
    this.iconPath,
    this.notificationCount = 0,
    this.lastNotificationAt,
  });

  AppModel copyWith({
    String? packageName,
    String? appName,
    String? iconPath,
    int? notificationCount,
    DateTime? lastNotificationAt,
  }) {
    return AppModel(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      iconPath: iconPath ?? this.iconPath,
      notificationCount: notificationCount ?? this.notificationCount,
      lastNotificationAt: lastNotificationAt ?? this.lastNotificationAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appName': appName,
        'iconPath': iconPath,
        'notificationCount': notificationCount,
        'lastNotificationAt': lastNotificationAt?.millisecondsSinceEpoch,
      };

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      iconPath: json['iconPath'] as String?,
      notificationCount: json['notificationCount'] as int? ?? 0,
      lastNotificationAt: json['lastNotificationAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['lastNotificationAt'] as int)
          : null,
    );
  }

  /// Get the first letter for avatar display.
  String get initial => appName.isNotEmpty ? appName[0].toUpperCase() : '?';

  /// Generate a consistent color from the package name.
  Color get avatarColor {
    final hash = packageName.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppModel &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;
}
