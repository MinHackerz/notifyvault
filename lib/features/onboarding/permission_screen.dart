import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';
import '../../app/router/app_router.dart';
import '../../providers/permission_providers.dart';

class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationPermissionProvider.notifier).checkPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationPermissionProvider.notifier).checkPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
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

              // Shield icon in a clean flat container with thin border and glow shadow
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      blurRadius: 16,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedShield01,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              Text(
                'Enable Notification\nAccess',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.6,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 300.ms)
                  .slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad),

              const SizedBox(height: 16),

              Text(
                'NotifyVault needs permission to read your notifications. '
                'This allows us to capture and save them locally on your device.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 350.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),

              const SizedBox(height: 36),

              // Privacy assurance items with staggered animation
              Column(
                children: [
                  _buildPrivacyItem(
                    context,
                    HugeIcons.strokeRoundedSmartPhone01,
                    'Stored locally on your device',
                  )
                      .animate()
                      .fadeIn(delay: 450.ms, duration: 300.ms)
                      .slideX(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
                  const SizedBox(height: 12),
                  _buildPrivacyItem(
                    context,
                    HugeIcons.strokeRoundedCloudOff,
                    'No data sent to servers',
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 300.ms)
                      .slideX(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
                  const SizedBox(height: 12),
                  _buildPrivacyItem(
                    context,
                    HugeIcons.strokeRoundedLock,
                    'You control what gets captured',
                  )
                      .animate()
                      .fadeIn(delay: 750.ms, duration: 300.ms)
                      .slideX(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
                ],
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
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
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
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
              width: 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedAlertCircle,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Running a USB / Sideloaded Build?',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'If Android says "Restricted setting":\n'
                      '1. Long press the NotifyVault app icon > App Info.\n'
                      '2. Tap the three-dot menu (top-right) > Allow restricted settings.\n'
                      '3. Open this app and tap the button above again.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
