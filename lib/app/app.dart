import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import '../providers/settings_providers.dart';
import '../core/services/reminder_service.dart';

import '../providers/notification_providers.dart';

/// Guards the one-shot startup permission prompt against widget rebuilds.
bool _reminderPermissionsRequested = false;

/// Root widget for NotifyVault.
class NotifyVaultApp extends ConsumerWidget {
  const NotifyVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    // Alarm permissions need a resumed Activity, so they cannot be requested
    // from main() before the first frame exists — requestExactAlarmsPermission
    // launches a Settings screen. See ReminderService.requestPermissions.
    if (!_reminderPermissionsRequested) {
      _reminderPermissionsRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await ReminderService.instance.requestPermissions();
        } catch (_) {}
      });
    }

    // Perform silent background retention pruning on startup
    Future.microtask(() async {
      try {
        final retentionDays = ref.read(retentionPeriodProvider);
        await ref.read(notificationRepositoryProvider).deleteOlderThan(retentionDays);
      } catch (_) {}
    });

    return MaterialApp.router(
      title: 'NotifyVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
