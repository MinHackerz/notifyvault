import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/reminder_providers.dart';

class AlarmRingingDialog extends ConsumerStatefulWidget {
  final ReminderItem reminder;

  const AlarmRingingDialog({
    super.key,
    required this.reminder,
  });

  static Future<void> show(BuildContext context, ReminderItem reminder) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => AlarmRingingDialog(reminder: reminder),
    );
  }

  @override
  ConsumerState<AlarmRingingDialog> createState() => _AlarmRingingDialogState();
}

class _AlarmRingingDialogState extends ConsumerState<AlarmRingingDialog> {
  final FlutterTts _tts = FlutterTts();
  Timer? _ringerTimer;
  bool _isStopping = false;

  @override
  void initState() {
    super.initState();
    _startRingtone();
  }

  Future<void> _startRingtone() async {
    try {
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.1);
      
      // Speak out loud immediately
      await _speak();

      // Repeat speech announcement and vibration every 4 seconds until dismissed
      _ringerTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
        if (_isStopping) return;
        HapticFeedback.vibrate();
        await SystemSound.play(SystemSoundType.click);
        await _speak();
      });
    } catch (e) {
      debugPrint('[AlarmRingingDialog] Ringtone error: $e');
    }
  }

  Future<void> _speak() async {
    if (_isStopping) return;
    await _tts.speak('Reminder Alert: ${widget.reminder.title}');
  }

  Future<void> _stopRingtone() async {
    _isStopping = true;
    _ringerTimer?.cancel();
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> _dismissAlarm() async {
    await _stopRingtone();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    await ref.read(reminderControllerProvider).deleteReminder(widget.reminder.id);
  }

  Future<void> _snoozeAlarm() async {
    await _stopRingtone();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    await ref.read(reminderControllerProvider).snoozeReminder(widget.reminder);
  }

  @override
  void dispose() {
    _stopRingtone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = DateFormat('hh:mm a').format(widget.reminder.scheduledAt);

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedAlarmClock,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REMINDER DUE',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            timeStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.reminder.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
                if (widget.reminder.body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.reminder.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _snoozeAlarm,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(
                            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Snooze 5m',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _dismissAlarm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Dismiss',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
