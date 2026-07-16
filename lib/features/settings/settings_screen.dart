import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/config/app_config.dart';
import '../../app/theme/app_colors.dart';
import '../../app/router/app_router.dart';
import '../../providers/settings_providers.dart';
import '../../providers/notification_providers.dart';
import '../../providers/permission_providers.dart';
import '../../providers/app_management_providers.dart';
import '../../core/widgets/section_header.dart';
import '../../core/helpers/ad_helper.dart';

import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TutorialCoachMark tutorialCoachMark;
  
  // Keys for tutorial targets
  final GlobalKey _keyAppearance = GlobalKey();
  final GlobalKey _keyRetention = GlobalKey();
  final GlobalKey _keyReadOutLoud = GlobalKey();
  final GlobalKey _keyAppManagement = GlobalKey();
  final GlobalKey _keyData = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTour();
    });
  }

  Future<void> _checkAndShowTour() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTour = prefs.getBool(AppConfig.keySettingsTourComplete) ?? false;
    if (hasSeenTour || !mounted) return;

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    _initTutorial();
    tutorialCoachMark.show(context: context);
  }

  void _initTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: const Color(0xFF0B0F19),
      textSkip: "SKIP",
      textStyleSkip: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.5,
      ),
      paddingFocus: 8,
      opacityShadow: 0.88,
      focusAnimationDuration: const Duration(milliseconds: 400),
      unFocusAnimationDuration: const Duration(milliseconds: 400),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      onFinish: () {
        ref.read(settingsTourCompleteProvider.notifier).complete();
      },
      onSkip: () {
        ref.read(settingsTourCompleteProvider.notifier).complete();
        return true;
      },
    );
  }

  List<TargetFocus> _createTargets() {
    const totalSteps = 5;
    return [
      _buildSettingsTarget(
        identify: 'appearance',
        keyTarget: _keyAppearance,
        icon: HugeIcons.strokeRoundedPaintBoard,
        title: 'Appearance',
        description: 'Switch between light and dark mode for comfortable viewing.',
        align: ContentAlign.bottom,
        step: 1,
        totalSteps: totalSteps,
      ),
      _buildSettingsTarget(
        identify: 'retention',
        keyTarget: _keyRetention,
        icon: HugeIcons.strokeRoundedClock01,
        title: 'Retention Period',
        description: 'Choose how long to keep your notification history.',
        align: ContentAlign.bottom,
        step: 2,
        totalSteps: totalSteps,
      ),
      _buildSettingsTarget(
        identify: 'read_out_loud',
        keyTarget: _keyReadOutLoud,
        icon: HugeIcons.strokeRoundedVolumeMute02,
        title: 'Read Out Loud',
        description: 'Configure apps to read notifications aloud and customize lock screen behavior.',
        align: ContentAlign.bottom,
        step: 3,
        totalSteps: totalSteps,
      ),
      _buildSettingsTarget(
        identify: 'app_management',
        keyTarget: _keyAppManagement,
        icon: HugeIcons.strokeRoundedSettings01,
        title: 'App Management',
        description: 'Set priority apps, block spam, and manage notification categories.',
        align: ContentAlign.bottom,
        step: 4,
        totalSteps: totalSteps,
      ),
      _buildSettingsTarget(
        identify: 'clear_data',
        keyTarget: _keyData,
        icon: HugeIcons.strokeRoundedDelete02,
        title: 'Clear Data',
        description: 'Wipe all your saved notifications instantly.',
        align: ContentAlign.top,
        step: 5,
        totalSteps: totalSteps,
        isLast: true,
      ),
    ];
  }

  TargetFocus _buildSettingsTarget({
    required String identify,
    required GlobalKey keyTarget,
    required List<List<dynamic>> icon,
    required String title,
    required String description,
    required ContentAlign align,
    required int step,
    required int totalSteps,
    bool isLast = false,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.RRect,
      radius: 12,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            return _SettingsTutorialCard(
              icon: icon,
              title: title,
              description: description,
              step: step,
              totalSteps: totalSteps,
              isLast: isLast,
              onNext: () => controller.next(),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final permissionState = ref.watch(notificationPermissionProvider);
    final retentionDays = ref.watch(retentionPeriodProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Appearance ──
          const _SectionHeader(index: '01', title: 'Appearance'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                key: _keyAppearance,
                icon: HugeIcons.strokeRoundedPaintBoard,
                title: 'Theme',
                subtitle: _themeModeLabel(themeMode),
                iconColor: theme.colorScheme.primary,
                onTap: () => _showAdAndProceed(
                  context,
                  () => _showThemeSelector(context, ref, themeMode),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Notifications ──
          const _SectionHeader(index: '02', title: 'Notifications'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: HugeIcons.strokeRoundedNotification03,
                title: 'Notification Access',
                subtitle: permissionState.when(
                  data: (granted) => granted ? 'Enabled' : 'Disabled',
                  loading: () => 'Checking...',
                  error: (_, _) => 'Unknown',
                ),
                iconColor: AppColors.accent,
                trailing: permissionState.when(
                  data: (granted) => Container(
                     width: 8,
                     height: 8,
                     decoration: BoxDecoration(
                       color: granted ? AppColors.success : AppColors.error,
                       shape: BoxShape.circle,
                     ),
                  ),
                  loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                onTap: () {
                  ref
                      .read(notificationPermissionProvider.notifier)
                      .openSettings();
                },
              ),
              _buildDivider(context),
              _SettingsTile(
                key: _keyRetention,
                icon: HugeIcons.strokeRoundedClock01,
                title: 'Retention Period',
                subtitle: retentionDays == -1
                    ? 'Unlimited (Premium)'
                    : '$retentionDays days',
                iconColor: AppColors.warning,
                onTap: () => _showAdAndProceed(
                  context,
                  () => _showRetentionSelector(context, ref, retentionDays),
                ),
              ),
              _buildDivider(context),
              _SettingsTile(
                key: _keyReadOutLoud,
                icon: HugeIcons.strokeRoundedMegaphone01,
                title: 'Read Out Loud',
                subtitle: 'Select apps to announce notifications',
                iconColor: AppColors.categoryWork,
                onTap: () => _showAdAndProceed(
                  context,
                  () => context.push(AppRoutes.readOutLoudApps),
                ),
              ),
              _buildDivider(context),
              _SettingsTile(
                key: _keyAppManagement,
                icon: HugeIcons.strokeRoundedDashboardSquare01,
                title: 'App Management',
                subtitle: 'Priority, block & spam apps',
                iconColor: AppColors.categorySocial,
                onTap: () => _showAdAndProceed(
                  context,
                  () {
                    ref.read(appManagementUnlockedProvider.notifier).unlock();
                    context.push(AppRoutes.appManagement);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Data ──
          const _SectionHeader(index: '03', title: 'Data'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                key: _keyData,
                icon: HugeIcons.strokeRoundedDelete02,
                title: 'Clear All Data',
                subtitle: 'Delete all saved notifications',
                iconColor: AppColors.error,
                onTap: () => _showClearDataDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── About ──
          const _SectionHeader(index: '04', title: 'About'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: HugeIcons.strokeRoundedInformationCircle,
                title: AppConfig.appName,
                subtitle: 'Version ${AppConfig.appVersion}',
                iconColor: theme.colorScheme.primary,
                onTap: () => _showAboutDialog(context),
              ),
              _buildDivider(context),
              _SettingsTile(
                icon: HugeIcons.strokeRoundedSecurityLock,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                iconColor: AppColors.categoryWork,
                onTap: () => _showPrivacyPolicyDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── App Info Footer ──
          Center(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                      width: 1.0,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(
                      isDark
                          ? 'assets/icons/app_icon_dark.png'
                          : 'assets/icons/app_icon.png',
                      width: 44,
                      height: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppConfig.appTagline,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeSelector(
      BuildContext context, WidgetRef ref, ThemeMode current) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose Theme',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                RadioGroup<ThemeMode>(
                  groupValue: current,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: ThemeMode.values.map((mode) {
                      final icon = mode == ThemeMode.system
                          ? HugeIcons.strokeRoundedDashboardCircle
                          : mode == ThemeMode.light
                              ? HugeIcons.strokeRoundedSun03
                              : HugeIcons.strokeRoundedMoon02;
                      return RadioListTile<ThemeMode>(
                        value: mode,
                        title: Text(_themeModeLabel(mode)),
                        secondary: HugeIcon(icon: icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRetentionSelector(
      BuildContext context, WidgetRef ref, int current) {
    final theme = Theme.of(context);
    final options = [3, 7, 14, 30, 90];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Retention Period',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                RadioGroup<int>(
                  groupValue: current,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(retentionPeriodProvider.notifier)
                          .setDays(value);
                      Navigator.pop(context);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((days) {
                      return RadioListTile<int>(
                        value: days,
                        title: Text('$days days'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all saved notifications. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(notificationRepositoryProvider).clearAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: AppConfig.appName,
        applicationVersion: AppConfig.appVersion,
        applicationIcon: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.asset(
              isDark
                  ? 'assets/icons/app_icon_dark.png'
                  : 'assets/icons/app_icon.png',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
        ),
        children: [
          const Text(
            AppConfig.appTagline,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.categoryWork.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedSecurityLock,
                        color: AppColors.categoryWork,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Privacy Policy',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Divider
              Container(
                height: 1.0,
                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
              ),
              const SizedBox(height: 16),
              
              // Scrollable Policy Content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPolicySection(
                        context,
                        '1. Local-First Storage',
                        'NotifyVault processes and stores all captured notifications locally on your device in a secure sandboxed database. No notification text, personal info, or application metadata is ever sent to external servers or shared with third parties.',
                      ),
                      const SizedBox(height: 12),
                      _buildPolicySection(
                        context,
                        '2. Essential Device Permissions',
                        '• Notification Access: Allows capture of incoming notifications.\n'
                        '• Post Notifications: Allows system status updates in the status bar.\n'
                        '• Boot Completed: Resumes capturing after device restart.\n'
                        '• Query All Packages: Maps captured app package identifiers to human-readable names and icons.',
                      ),
                      const SizedBox(height: 12),
                      _buildPolicySection(
                        context,
                        '3. Complete Data Ownership',
                        'You can view, search, and delete your notification logs at any time. The "Clear All Data" setting deletes all records and cached app icons from your device permanently.',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'I Understand',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection(BuildContext context, String title, String body) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  void _showAdAndProceed(BuildContext context, VoidCallback onProceed) {
    if (AdHelper.isRewardedAdLoaded) {
      AdHelper.showRewardedAd(
        onAdClosed: onProceed,
        onRewardEarned: () {},
      );
    } else {
      // If ad not loaded, preload next and open content directly
      AdHelper.preloadRewardedAd();
      onProceed();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String index;
  final String title;

  const _SectionHeader({required this.index, required this.title});

  @override
  Widget build(BuildContext context) {
    return SectionHeader(index: index, title: title);
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color iconColor;
  final bool enabled;

  const _SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
    required this.iconColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: HugeIcon(icon: icon, color: iconColor, size: 18),
            ),
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          trailing:
              trailing ?? const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 16, color: Colors.grey),
          onTap: enabled ? onTap : null,
        ),
      ),
    );
  }
}

/// Reusable tutorial card for settings tour with frosted-glass aesthetic.
class _SettingsTutorialCard extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String description;
  final int step;
  final int totalSteps;
  final bool isLast;
  final VoidCallback onNext;

  const _SettingsTutorialCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.step,
    required this.totalSteps,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final cardColors = isDark
        ? [const Color(0xFF1E293B).withOpacity(0.95), const Color(0xFF0F172A).withOpacity(0.98)]
        : [Colors.white.withOpacity(0.97), const Color(0xFFF8FAFC).withOpacity(0.98)];
    final borderColor = isDark ? primaryColor.withOpacity(0.2) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final descColor = isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF64748B);
    final inactiveDotColor = isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cardColors,
        ),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(isDark ? 0.08 : 0.06),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor.withOpacity(isDark ? 0.3 : 0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '$step of $totalSteps',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(isDark ? 0.1 : 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: HugeIcon(icon: icon, color: primaryColor, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: descColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: List.generate(totalSteps, (i) {
                          final isActive = i < step;
                          return Container(
                            width: isActive ? 16 : 6,
                            height: 4,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: isActive ? primaryColor : inactiveDotColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onNext,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, primaryColor.withOpacity(0.85)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          isLast ? 'Done' : 'Next',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
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
