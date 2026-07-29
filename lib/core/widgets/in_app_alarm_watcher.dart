import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reminder_providers.dart';
import 'alarm_ringing_dialog.dart';

class InAppAlarmWatcher extends ConsumerStatefulWidget {
  final Widget child;

  const InAppAlarmWatcher({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<InAppAlarmWatcher> createState() => _InAppAlarmWatcherState();
}

class _InAppAlarmWatcherState extends ConsumerState<InAppAlarmWatcher> {
  Timer? _checkTimer;
  final Set<int> _triggeredIds = {};

  @override
  void initState() {
    super.initState();
    _startWatcher();
  }

  void _startWatcher() {
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkAndRingReminders();
    });
  }

  void _checkAndRingReminders() {
    final remindersAsync = ref.read(upcomingRemindersProvider);
    final reminders = remindersAsync.value ?? [];

    if (reminders.isEmpty) return;

    final now = DateTime.now();

    for (final reminder in reminders) {
      if (_triggeredIds.contains(reminder.id)) continue;

      // Check if scheduledAt is within current minute or slightly past
      final isDue = reminder.scheduledAt.isBefore(now) ||
          (reminder.scheduledAt.year == now.year &&
              reminder.scheduledAt.month == now.month &&
              reminder.scheduledAt.day == now.day &&
              reminder.scheduledAt.hour == now.hour &&
              reminder.scheduledAt.minute == now.minute);

      if (isDue) {
        _triggeredIds.add(reminder.id);
        debugPrint('[InAppAlarmWatcher] Triggering Alarm Dialog for: ${reminder.title}');
        AlarmRingingDialog.show(context, reminder);
        break; // Show one alarm popup at a time
      }
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to upcoming reminders stream
    ref.listen<AsyncValue<List<ReminderItem>>>(
      upcomingRemindersProvider,
      (previous, next) {
        // Trigger immediate check whenever new reminder is scheduled/updated
        _checkAndRingReminders();
      },
    );

    return widget.child;
  }
}
