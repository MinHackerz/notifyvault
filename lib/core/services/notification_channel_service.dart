import 'dart:async';
import 'package:flutter/services.dart';
import '../../app/config/app_config.dart';

/// Service for communicating with Android's NotificationListenerService
/// via platform channels.
class NotificationChannelService {
  NotificationChannelService._();

  static final NotificationChannelService instance =
      NotificationChannelService._();

  final MethodChannel _methodChannel =
      const MethodChannel(AppConfig.notificationMethodChannel);
  final EventChannel _eventChannel =
      const EventChannel(AppConfig.notificationEventChannel);

  Stream<Map<String, dynamic>>? _notificationStream;

  /// Check if notification listener permission is granted.
  Future<bool> isPermissionGranted() async {
    try {
      final result =
          await _methodChannel.invokeMethod<bool>('isPermissionGranted');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Open system settings for notification access.
  Future<void> openPermissionSettings() async {
    try {
      await _methodChannel.invokeMethod('openPermissionSettings');
    } on PlatformException catch (_) {
      // Silently fail — user can navigate manually
    }
  }

  /// Get currently active notifications on the status bar.
  Future<List<Map<String, dynamic>>> getActiveNotifications() async {
    try {
      final result =
          await _methodChannel.invokeMethod<List>('getActiveNotifications');
      if (result == null) return [];
      return result
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } on PlatformException catch (_) {
      return [];
    }
  }

  /// Stream of new notifications arriving from Android native side.
  Stream<Map<String, dynamic>> get notificationStream {
    _notificationStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event as Map))
        .asBroadcastStream();
    return _notificationStream!;
  }

  /// Dismiss a notification from the status bar.
  Future<void> dismissNotification(String key) async {
    try {
      await _methodChannel.invokeMethod('dismissNotification', {'key': key});
    } on PlatformException catch (_) {
      // Silently fail
    }
  }

  /// Launch an app by its package name.
  /// Returns true if the app was launched successfully, false otherwise.
  Future<bool> launchApp(String packageName) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'launchApp',
        {'packageName': packageName},
      );
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Get all installed apps with notification enabled status and saved icon paths.
  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final result = await _methodChannel.invokeMethod<List>('getInstalledApps');
      if (result == null) return [];
      return result
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } on PlatformException catch (_) {
      return [];
    }
  }
}
