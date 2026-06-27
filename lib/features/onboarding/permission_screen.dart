import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../app/theme/app_colors.dart';
import '../../app/router/app_router.dart';
import '../../providers/permission_providers.dart';

class PermissionScreen extends ConsumerWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final permissionState = ref.watch(notificationPermissionProvider);

    // Auto-navigate when permission is granted
    ref.listen<AsyncValue<bool>>(notificationPermissionProvider, (prev, next) {
      next.whenData((granted) {
        if (granted) {
          context.go(AppRoutes.dashboard);
        }
      });
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Shield icon in a clean flat container with thin border
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedShield01,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Enable Notification\nAccess',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.normal,
                  height: 1.2,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'NotifyVault needs permission to read your notifications. '
                'This allows us to capture and save them locally on your device.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              // Privacy assurance items
              _buildPrivacyItem(
                context,
                HugeIcons.strokeRoundedSmartPhone01,
                'Stored locally on your device',
              ),
              const SizedBox(height: 12),
              _buildPrivacyItem(
                context,
                HugeIcons.strokeRoundedCloudOff,
                'No data sent to servers by default',
              ),
              const SizedBox(height: 12),
              _buildPrivacyItem(
                context,
                HugeIcons.strokeRoundedLock,
                'You control what gets captured',
              ),

              const Spacer(flex: 3),

              // Permission status
              permissionState.when(
                data: (granted) => granted
                    ? _buildGrantedUI(context)
                    : _buildRequestUI(context, ref),
                loading: () => const CircularProgressIndicator(),
                error: (_, _) => _buildRequestUI(context, ref),
              ),

              const SizedBox(height: 12),

              // Skip for now
              TextButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyItem(BuildContext context, List<List<dynamic>> icon, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
              width: 1.0,
            ),
          ),
          child: Center(
            child: HugeIcon(
              icon: icon,
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestUI(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          await ref
              .read(notificationPermissionProvider.notifier)
              .openSettings();
          // Re-check after returning from settings
          await Future.delayed(const Duration(seconds: 1));
          ref
              .read(notificationPermissionProvider.notifier)
              .checkPermission();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Enable Notification Access',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildGrantedUI(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => context.go(AppRoutes.dashboard),
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedCheckmarkCircle02,
          size: 18,
          color: Colors.white,
        ),
        label: const Text(
          'Permission Granted — Continue',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
