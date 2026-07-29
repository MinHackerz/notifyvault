import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:drift/drift.dart';
import 'dart:async';
import '../database/app_database.dart';
import '../models/notification_model.dart';
import '../core/services/reminder_service.dart';

class ReminderItem {
  final int id;
  final String notificationId;
  final String title;
  final String body;
  final String packageName;
  final String appName;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final bool isCompleted;

  const ReminderItem({
    required this.id,
    required this.notificationId,
    required this.title,
    required this.body,
    required this.packageName,
    required this.appName,
    required this.scheduledAt,
    required this.createdAt,
    required this.isCompleted,
  });

  factory ReminderItem.fromData(Reminder data) {
    return ReminderItem(
      id: data.id,
      notificationId: data.notificationId,
      title: data.title,
      body: data.body,
      packageName: data.packageName,
      appName: data.appName,
      scheduledAt: data.scheduledAt,
      createdAt: data.createdAt,
      isCompleted: data.isCompleted,
    );
  }
}

/// Reminders stay visible this long past their scheduled time before being purged.
const _expirationGrace = Duration(minutes: 1);

/// How often the active-reminder stream re-evaluates the expiration window.
const _tickInterval = Duration(seconds: 20);

bool _purgeInFlight = false;
bool _channelMigrationDone = false;

/// Re-arm reminders whose queued alarm still points at a retired channel.
///
/// A notification posted to a deleted channel is dropped silently, so whenever
/// [ReminderService] lands on a different channel id than the previous run —
/// a version bump, or a device that newly resolved a real alarm tone — every
/// still-future reminder has to be handed back to AlarmManager under the new
/// channel. Only then is it safe to delete the old one.
Future<void> _migrateChannelIfNeeded(AppDatabase db) async {
  if (_channelMigrationDone) return;
  _channelMigrationDone = true;
  try {
    await ReminderService.instance.init();
    if (ReminderService.instance.channelChanged) {
      final pending = await (db.select(db.reminders)
            ..where((r) =>
                r.isCompleted.equals(false) &
                r.scheduledAt.isBiggerThanValue(DateTime.now())))
          .get();
      for (final item in pending) {
        await ReminderService.instance.scheduleReminder(
          id: item.id,
          title: '🔔 ${item.title}',
          body: item.body,
          scheduledTime: item.scheduledAt,
          payload: item.notificationId,
        );
      }
    }
    await ReminderService.instance.finalizeChannelMigration();
  } catch (e) {
    // The flag stays set: retrying on every tick would re-arm alarms in a loop.
    debugPrint('[Reminders] Channel migration failed: $e');
  }
}

/// Auto-delete reminders whose post-expiration window has lapsed.
Future<void> _purgeExpiredReminders(AppDatabase db) async {
  if (_purgeInFlight) return;
  _purgeInFlight = true;
  try {
    final cutoff = DateTime.now().subtract(_expirationGrace);
    // Only the row is dropped. Deliberately no cancelReminder() here: the
    // plugin's cancel() also runs notificationManager.cancel(id), which would
    // swipe the alarm out of the tray a minute after it fired — while the user
    // may still be reading it. Everything older than the cutoff has already
    // fired, so there is no pending AlarmManager entry left to release either.
    await (db.delete(db.reminders)
          ..where((r) => r.scheduledAt.isSmallerThanValue(cutoff)))
        .go();
  } finally {
    _purgeInFlight = false;
  }
}

/// Emits active reminders on every table change *and* on a periodic tick.
///
/// The tick is what makes an entry vanish once its window lapses: a Drift query
/// stream only re-emits on table writes, so a time-based cutoff compiled into
/// the SQL would stay frozen at whatever "now" was when the query was built.
Stream<List<ReminderItem>> _watchActiveReminders(AppDatabase db) {
  final rows = (db.select(db.reminders)
        ..orderBy([
          (r) => OrderingTerm(expression: r.scheduledAt, mode: OrderingMode.asc),
        ]))
      .watch();

  late StreamController<List<ReminderItem>> controller;
  StreamSubscription<List<Reminder>>? rowsSub;
  Timer? ticker;
  var latest = const <Reminder>[];

  void emit() {
    final cutoff = DateTime.now().subtract(_expirationGrace);
    controller.add(latest
        .where((r) => !r.isCompleted && r.scheduledAt.isAfter(cutoff))
        .map(ReminderItem.fromData)
        .toList());
  }

  controller = StreamController<List<ReminderItem>>(
    onListen: () {
      rowsSub = rows.listen(
        (data) {
          latest = data;
          emit();
        },
        onError: controller.addError,
      );
      ticker = Timer.periodic(_tickInterval, (_) {
        emit();
        _purgeExpiredReminders(db);
      });
      _migrateChannelIfNeeded(db);
      _purgeExpiredReminders(db);
    },
    onCancel: () async {
      ticker?.cancel();
      await rowsSub?.cancel();
    },
  );

  return controller.stream;
}

/// Single source of truth for active reminders, ordered soonest-first.
final allRemindersProvider = StreamProvider<List<ReminderItem>>((ref) {
  return _watchActiveReminders(AppDatabase.instance);
});

/// Upcoming active reminders. Derived so there is only one DB watch and ticker.
final upcomingRemindersProvider =
    Provider<AsyncValue<List<ReminderItem>>>((ref) {
  return ref.watch(allRemindersProvider);
});

/// Provider returning set of notification IDs that have an active scheduled reminder.
final activeReminderNotificationIdsProvider = Provider<Set<String>>((ref) {
  final remindersAsync = ref.watch(allRemindersProvider);
  return remindersAsync.whenData((list) {
    return list.map((r) => r.notificationId).toSet();
  }).value ?? <String>{};
});

/// Active reminder for a single notification, or null once its window lapses.
final existingReminderForNotificationProvider =
    Provider.family<AsyncValue<ReminderItem?>, String>((ref, notificationId) {
  return ref.watch(allRemindersProvider).whenData<ReminderItem?>((list) {
    for (final reminder in list) {
      if (reminder.notificationId == notificationId) return reminder;
    }
    return null;
  });
});

/// Provider for reminder operations controller.
final reminderControllerProvider = Provider((ref) => ReminderController(ref));

class ReminderController {
  final Ref ref;

  ReminderController(this.ref);

  /// Schedule or update a reminder for a specific notification.
  Future<bool> scheduleReminder({
    required NotificationModel notification,
    required String title,
    required DateTime scheduledTime,
  }) async {
    final db = AppDatabase.instance;

    final existingList = await (db.select(db.reminders)
          ..where((r) => r.notificationId.equals(notification.id) & r.isCompleted.equals(false)))
        .get();

    final existing = existingList.isNotEmpty ? existingList.first : null;

    // If duplicate active reminders exist for this notification, clean up extras
    if (existingList.length > 1) {
      for (int i = 1; i < existingList.length; i++) {
        await (db.delete(db.reminders)..where((r) => r.id.equals(existingList[i].id))).go();
        await ReminderService.instance.cancelReminder(existingList[i].id);
      }
    }

    int id;
    if (existing != null) {
      id = existing.id;
      await (db.update(db.reminders)..where((r) => r.id.equals(id))).write(
        RemindersCompanion(
          title: Value(title),
          body: Value(
            notification.displayText.isNotEmpty
                ? notification.displayText
                : (notification.title ?? 'Notification Reminder'),
          ),
          scheduledAt: Value(scheduledTime),
          isCompleted: const Value(false),
        ),
      );
    } else {
      id = await db.into(db.reminders).insert(
            RemindersCompanion.insert(
              notificationId: notification.id,
              title: title,
              body: notification.displayText.isNotEmpty
                  ? notification.displayText
                  : (notification.title ?? 'Notification Reminder'),
              packageName: notification.packageName,
              appName: notification.appName,
              scheduledAt: scheduledTime,
            ),
          );
    }

    final scheduled = await ReminderService.instance.scheduleReminder(
      id: id,
      title: '🔔 $title',
      body: notification.displayText.isNotEmpty
          ? notification.displayText
          : 'Tap to view reminder details in NotifyVault',
      scheduledTime: scheduledTime,
      payload: notification.id,
    );

    if (scheduled) {
      // Fire-and-forget: an OEM battery restriction would silently defer this
      // alarm, and the user is right here having just asked for it.
      ReminderService.instance.promptForBackgroundExecutionOnce();
    }

    if (!scheduled) {
      // Keep SQLite and AlarmManager in agreement. A row left behind here would
      // render the ⏰ badge, the active status card and a /reminders entry for an
      // alarm that will never fire.
      if (existing != null) {
        await (db.update(db.reminders)..where((r) => r.id.equals(id))).write(
          RemindersCompanion(
            title: Value(existing.title),
            body: Value(existing.body),
            scheduledAt: Value(existing.scheduledAt),
            isCompleted: Value(existing.isCompleted),
          ),
        );
      } else {
        await (db.delete(db.reminders)..where((r) => r.id.equals(id))).go();
      }
    }

    return scheduled;
  }

  /// Delete a reminder and cancel its pending system alarm.
  Future<void> deleteReminder(int id) async {
    final db = AppDatabase.instance;
    await (db.delete(db.reminders)..where((r) => r.id.equals(id))).go();
    await ReminderService.instance.cancelReminder(id);
  }

  /// Snooze an existing reminder for 5 minutes.
  Future<void> snoozeReminder(ReminderItem reminder) async {
    final db = AppDatabase.instance;
    final snoozeTime = DateTime.now().add(const Duration(minutes: 5));

    await (db.update(db.reminders)..where((r) => r.id.equals(reminder.id))).write(
      RemindersCompanion(
        scheduledAt: Value(snoozeTime),
      ),
    );

    await ReminderService.instance.scheduleReminder(
      id: reminder.id,
      title: reminder.title,
      body: reminder.body,
      scheduledTime: snoozeTime,
      payload: reminder.notificationId,
    );
  }
}
