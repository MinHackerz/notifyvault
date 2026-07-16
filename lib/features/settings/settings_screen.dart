import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
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

  void _checkAndShowTour() {
    final hasSeenTour = ref.read(settingsTourCompleteProvider);
    if (!hasSeenTour) {
      _initTutorial();
      tutorialCoachMark.show(context: context);
    }
  }

  void _initTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black,
      textSkip: "SKIP",
      textStyleSkip: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
      paddingFocus: 10,
      opacityShadow: 0.85,
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
    return [
      TargetFocus(
        identify: "appearance",
        keyTarget: _keyAppearance,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                ),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Appearance", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Switch between light and dark mode for comfortable viewing.", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.next(),
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
                    child: const Text("Next"),
                  ),
                ],
              ),);
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "retention",
        keyTarget: _keyRetention,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                ),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Retention Period", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Choose how long you want to keep your notification history.", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.next(),
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
                    child: const Text("Next"),
                  ),
                ],
              ),);
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "read_out_loud",
        keyTarget: _keyReadOutLoud,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                ),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Read Out Loud", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Configure apps to read their notifications out loud, and customize lock screen behavior.", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.next(),
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
                    child: const Text("Next"),
                  ),
                ],
              ),);
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "app_management",
        keyTarget: _keyAppManagement,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                ),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("App Management", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Set priority apps, block spam, and manage notification categories.", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.next(),
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
                    child: const Text("Next"),
                  ),
                ],
              ),);
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "clear_data",
        keyTarget: _keyData,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                ),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Clear Data", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Wipe all your saved notifications instantly.", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.next(),
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
                    child: const Text("Finish"),
                  ),
                ],
              ),);
            },
          ),
        ],
      ),
    ];
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
