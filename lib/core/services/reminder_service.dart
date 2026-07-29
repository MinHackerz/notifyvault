import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Which system tone the reminder channel ended up using.
enum AlertTone {
  /// The user's alarm tone, played on the alarm volume stream.
  alarm,

  /// The user's notification tone, played on the notification stream. Used when
  /// no alarm tone could be resolved.
  notification,

  /// Nothing resolvable — the channel is left on Android's default sound.
  systemDefault,
}

class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const _audioChannel =
      MethodChannel('com.notifyvault.app/reminder_audio');

  /// Android freezes a channel's sound/vibration/importance at first creation
  /// and ignores later edits, so the id carries both a manual version and the
  /// resolved tone. Encoding the tone makes the channel self-healing: if a
  /// device that once had no playable alarm tone later gains one, the next
  /// launch lands on a *different* channel id and is created correctly, rather
  /// than being stuck silent forever.
  static const _channelVersion = 'v5';

  static String _channelIdFor(AlertTone tone) =>
      'notify_vault_reminders_${_channelVersion}_${tone.name}';

  /// Every channel id this app has ever shipped. Ids that are not the active one
  /// get deleted so the system notification settings screen does not accumulate
  /// dead "Reminders & Alarms" duplicates.
  static const _legacyChannelIds = <String>[
    'notify_vault_reminders',
    'notify_vault_reminders_v2',
    'notify_vault_reminders_v3',
    'notify_vault_reminders_v4',
  ];

  /// Remembers which channel id the last run committed to, so a change can be
  /// detected and the affected reminders re-scheduled.
  static const _lastChannelKey = 'reminder_active_channel_id';

  /// Set once the battery-exemption dialog has been shown, so it is never
  /// re-prompted.
  static const _batteryPromptKey = 'reminder_battery_prompt_shown';

  static const _channelName = 'Reminders & Alarms';
  static const _channelDescription =
      'Critical user set event reminders and alarms';

  static final _vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  AlertTone _tone = AlertTone.systemDefault;
  AndroidNotificationSound? _sound;
  bool _channelChanged = false;

  /// True when this run created a different channel than the previous run, which
  /// means any reminder still queued in AlarmManager points at a channel that is
  /// about to be deleted and must be re-scheduled. Cleared by
  /// [finalizeChannelMigration].
  bool get channelChanged => _channelChanged;

  /// The tone the channel was actually created with. Exposed for diagnostics.
  AlertTone get tone => _tone;

  String get channelId => _channelIdFor(_tone);

  /// Alarm-stream audio only makes sense paired with an alarm tone. Routing a
  /// notification tone through [AudioAttributesUsage.alarm] is another way to
  /// end up inaudible, so the usage follows whatever tone was resolved.
  AudioAttributesUsage get _usage => _tone == AlertTone.alarm
      ? AudioAttributesUsage.alarm
      : AudioAttributesUsage.notification;

  Future<void> init() async {
    if (_initialized) return;

    await _configureTimeZone();
    await _resolveAlertTone();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click if needed
      },
    );

    final android = _androidPlugin;

    // Detect a channel switch before anything is torn down. Alarms already sitting
    // in AlarmManager carry the *old* channel id inside their serialized payload,
    // and a notification posted to a deleted channel is dropped without a sound,
    // so those reminders have to be re-scheduled onto the new channel before the
    // old one is removed. Legacy cleanup is deferred to
    // [finalizeChannelMigration] for the same reason.
    try {
      final prefs = await SharedPreferences.getInstance();
      final previous = prefs.getString(_lastChannelKey);
      _channelChanged = previous != null && previous != channelId;
    } catch (e) {
      debugPrint('[ReminderService] Channel version check failed: $e');
      _channelChanged = false;
    }

    await android?.createNotificationChannel(AndroidNotificationChannel(
      channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      sound: _sound,
      enableVibration: true,
      vibrationPattern: _vibrationPattern,
      audioAttributesUsage: _usage,
    ));

    _initialized = true;
    debugPrint('[ReminderService] Initialized. channel=$channelId '
        'tone=${_tone.name} sound=${_sound?.sound ?? 'system default'} '
        'tz=${tz.local.name} (device offset: ${DateTime.now().timeZoneOffset})');
  }

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin =>
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> _configureTimeZone() async {
    tz.initializeTimeZones();
    try {
      String timeZoneName = await FlutterTimezone.getLocalTimezone();
      if (timeZoneName == 'Asia/Calcutta') {
        timeZoneName = 'Asia/Kolkata';
      }
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (_) {
        final offsetMs = DateTime.now().timeZoneOffset.inMilliseconds;
        for (final loc in tz.timeZoneDatabase.locations.values) {
          if (loc.timeZone(DateTime.now().millisecondsSinceEpoch).offset ==
              offsetMs) {
            tz.setLocalLocation(loc);
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to set local timezone: $e');
    }
  }

  /// Ask the native side for a tone it has verified is actually openable.
  ///
  /// An unresolvable channel sound does not degrade to a default on Android — the
  /// notification simply posts silently — and `content://settings/system/alarm_alert`
  /// is missing or unset on a number of Vivo/Xiaomi/Samsung builds. So the URI is
  /// probed natively before it is committed to a channel.
  Future<void> _resolveAlertTone() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final resolved = await _audioChannel
          .invokeMapMethod<String, String>('resolveAlertTone');
      final uri = resolved?['uri'];
      final type = resolved?['type'];
      if (uri == null || uri.isEmpty) {
        _tone = AlertTone.systemDefault;
        _sound = null;
        return;
      }
      _tone = type == 'alarm' ? AlertTone.alarm : AlertTone.notification;
      _sound = UriAndroidNotificationSound(uri);
    } catch (e) {
      // MissingPluginException on an unexpected engine, or a ROM that refuses
      // the query. A null sound leaves the channel on Android's default, which
      // is audible — better than a URI we could not verify.
      debugPrint('[ReminderService] Alert tone resolution failed: $e');
      _tone = AlertTone.systemDefault;
      _sound = null;
    }
  }

  /// Retire every channel that is not the active one and record the active id.
  ///
  /// Must run *after* any reminders still pointing at an old channel have been
  /// re-scheduled — see [channelChanged]. Idempotent.
  Future<void> finalizeChannelMigration() async {
    final android = _androidPlugin;
    for (final id in [
      ..._legacyChannelIds,
      for (final t in AlertTone.values)
        if (t != _tone) _channelIdFor(t),
    ]) {
      try {
        await android?.deleteNotificationChannel(id);
      } catch (_) {
        // Nothing to delete on a fresh install.
      }
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastChannelKey, channelId);
    } catch (e) {
      debugPrint('[ReminderService] Could not persist active channel id: $e');
    }
    _channelChanged = false;
  }

  /// Request the runtime grants the alarm needs.
  ///
  /// Kept out of [init] on purpose: `init` runs before `runApp`, and both of
  /// these need a resumed Activity. `requestExactAlarmsPermission` in particular
  /// launches a Settings screen, which should never happen off a cold start
  /// before the first frame exists.
  Future<void> requestPermissions() async {
    final android = _androidPlugin;
    try {
      await android?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('[ReminderService] Notification permission request failed: $e');
    }
    try {
      // With USE_EXACT_ALARM declared this is already granted on API 33+ and
      // returns without showing anything.
      await android?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('[ReminderService] Exact alarm permission request failed: $e');
    }
  }

  /// Ask to be exempted from battery optimisation, at most once ever.
  ///
  /// Funtouch/MIUI/OneUI put non-exempt apps into aggressive app-standby, where
  /// even `exactAllowWhileIdle` alarms are deferred or dropped outright. That is
  /// the single biggest cause of a reminder that simply never arrives on those
  /// ROMs, and no amount of channel configuration compensates for it — nor is
  /// there any way to detect the drop after the fact.
  ///
  /// Called when the user schedules a reminder, the point of clearest intent.
  /// Gated to a single lifetime prompt so a declined dialog is not re-shown on
  /// every save. Current state is reported by [describeReadiness].
  Future<void> promptForBackgroundExecutionOnce() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      if (await Permission.ignoreBatteryOptimizations.isGranted) return;
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_batteryPromptKey) ?? false) return;
      await prefs.setBool(_batteryPromptKey, true);
      await Permission.ignoreBatteryOptimizations.request();
    } catch (e) {
      debugPrint('[ReminderService] Battery exemption prompt failed: $e');
    }
  }

  /// Everything that decides whether a reminder will actually be seen and heard.
  /// Surfaced so delivery problems can be diagnosed on a real device instead of
  /// guessed at.
  Future<Map<String, Object?>> describeReadiness() async {
    final android = _androidPlugin;
    return {
      'channelId': channelId,
      'tone': _tone.name,
      'soundUri': _sound?.sound ?? '(system default)',
      'audioUsage': _usage.name,
      'timeZone': tz.local.name,
      'deviceUtcOffset': DateTime.now().timeZoneOffset.toString(),
      'notificationsEnabled':
          await android?.areNotificationsEnabled() ?? 'unknown',
      'canScheduleExactAlarms':
          await android?.canScheduleExactNotifications() ?? 'unknown',
      'batteryExempt': await Permission.ignoreBatteryOptimizations.isGranted,
      'pendingAlarms':
          (await _notificationsPlugin.pendingNotificationRequests()).length,
    };
  }

  /// Schedule a reminder notification at a specific date & time.
  Future<bool> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await init();
    await cancelReminder(id);

    final now = DateTime.now();
    DateTime targetTime = scheduledTime;

    if (targetTime.isBefore(now.subtract(const Duration(minutes: 1)))) {
      debugPrint(
          '[ReminderService] Scheduled time $scheduledTime is in the past! Current local time: $now');
      return false;
    }

    // If targetTime is within current minute or slightly past seconds, adjust to 5 seconds from now
    if (targetTime.isBefore(now)) {
      targetTime = now.add(const Duration(seconds: 5));
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: _sound,
      enableVibration: true,
      vibrationPattern: _vibrationPattern,
      audioAttributesUsage: _usage,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      icon: '@mipmap/ic_launcher',
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    // Convert the absolute instant rather than re-reading wall-clock parts in
    // tz.local: if timezone resolution fell back to UTC, rebuilding from
    // year/month/day/hour would shift the alarm by the whole UTC offset.
    final scheduledTz = tz.TZDateTime.from(targetTime, tz.local);

    debugPrint(
        '[ReminderService] Scheduling Alarm #$id for $scheduledTz (Target time: $targetTime, Now: ${DateTime.now()})');

    try {
      const MethodChannel('com.notifyvault.app/notifications').invokeMethod('scheduleNativeAlarm', {
        'id': id,
        'title': title,
        'body': body,
        'timeMs': targetTime.millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('[ReminderService] Native alarm schedule failed: $e');
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTz,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      return true;
    } catch (e) {
      // Exact modes need the SCHEDULE_EXACT_ALARM/USE_EXACT_ALARM grant, so a
      // permission failure rules them all out. Degrade to inexact delivery,
      // which needs no grant, rather than dropping the reminder entirely.
      debugPrint('[ReminderService] Exact alarm failed ($e), using inexact mode');
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTz,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
        return true;
      } catch (e2) {
        debugPrint('[ReminderService] Fallback alarm failed: $e2');
        return false;
      }
    }
  }

  /// Cancel a scheduled reminder notification by ID.
  Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id);
    try {
      await const MethodChannel('com.notifyvault.app/notifications').invokeMethod('cancelNativeAlarm', {'id': id});
    } catch (_) {}
  }

  /// Cancel all scheduled reminder notifications.
  Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }
}
