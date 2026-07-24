import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import '../providers/settings_providers.dart';

import '../providers/notification_providers.dart';

/// Root widget for NotifyVault.
class NotifyVaultApp extends ConsumerWidget {
  const NotifyVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

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
