import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../app/config/app_config.dart';
import '../../providers/settings_providers.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/permission_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/history/timeline_screen.dart';
import '../../features/notification_details/notification_detail_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/app_management_screen.dart';
import '../../features/settings/read_out_loud_apps_screen.dart';
import '../../features/categories/category_screen.dart';
import '../../features/statistics/statistics_screen.dart';
import '../../core/widgets/banner_ad_widget.dart';
import '../theme/app_colors.dart';

/// Route paths.
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const permission = '/permission';
  static const dashboard = '/dashboard';
  static const timeline = '/timeline';
  static const notificationDetail = '/notification/:id';
  static const category = '/category/:id';
  static const search = '/search';
  static const settings = '/settings';
  static const appManagement = '/app-management';
  static const readOutLoudApps = '/read-out-loud-apps';
  static const statistics = '/statistics';
}

/// GoRouter provider.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.permission,
        builder: (context, state) => const PermissionScreen(),
      ),

      // Shell route for main app with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const DashboardScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.timeline,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const TimelineScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.search,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const SearchScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.statistics,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const StatisticsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const SettingsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.notificationDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            child: NotificationDetailScreen(notificationId: id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.category,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            child: CategoryScreen(categoryId: id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.appManagement,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const AppManagementScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.readOutLoudApps,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const ReadOutLoudAppsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),
    ],
  );
});

/// Main shell widget with flat minimalist bottom navigation.
class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late TutorialCoachMark tutorialCoachMark;
  
  // Keys for tutorial targets
  final GlobalKey _keyDashboard = GlobalKey();
  final GlobalKey _keyTimeline = GlobalKey();
  final GlobalKey _keySearch = GlobalKey();
  final GlobalKey _keyStatistics = GlobalKey();
  final GlobalKey _keySettings = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTour();
    });
  }

  Future<void> _checkAndShowTour() async {
    // Read directly from SharedPreferences to avoid the race condition
    // where the Notifier's initial synchronous value (false) is read
    // before the async _load() completes.
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTour = prefs.getBool(AppConfig.keyAppTourComplete) ?? false;
    if (hasSeenTour || !mounted) return;

    // Wait for layout to fully settle so GlobalKeys resolve to correct positions.
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
        ref.read(appTourCompleteProvider.notifier).complete();
      },
      onSkip: () {
        ref.read(appTourCompleteProvider.notifier).complete();
        return true;
      },
    );
  }

  List<TargetFocus> _createTargets() {
    const totalSteps = 5;
    return [
      _buildTarget(
        identify: 'dashboard',
        keyTarget: _keyDashboard,
        icon: HugeIcons.strokeRoundedDashboardCircle,
        title: 'Home',
        description: 'Your notification overview — unread counts, recent activity, and quick insights at a glance.',
        step: 1,
        totalSteps: totalSteps,
      ),
      _buildTarget(
        identify: 'timeline',
        keyTarget: _keyTimeline,
        icon: HugeIcons.strokeRoundedClock01,
        title: 'Timeline',
        description: 'Browse notifications chronologically. Filter by app or date range.',
        step: 2,
        totalSteps: totalSteps,
      ),
      _buildTarget(
        identify: 'search',
        keyTarget: _keySearch,
        icon: HugeIcons.strokeRoundedSearch01,
        title: 'Search',
        description: 'Instantly find any notification across all your connected apps.',
        step: 3,
        totalSteps: totalSteps,
      ),
      _buildTarget(
        identify: 'statistics',
        keyTarget: _keyStatistics,
        icon: HugeIcons.strokeRoundedChart,
        title: 'Statistics',
        description: 'Discover patterns — see which apps notify you the most.',
        step: 4,
        totalSteps: totalSteps,
      ),
      _buildTarget(
        identify: 'settings',
        keyTarget: _keySettings,
        icon: HugeIcons.strokeRoundedSettings01,
        title: 'Settings',
        description: 'Customize your experience, manage read-out-loud, and configure playback.',
        step: 5,
        totalSteps: totalSteps,
        isLast: true,
      ),
    ];
  }

  TargetFocus _buildTarget({
    required String identify,
    required GlobalKey keyTarget,
    required List<List<dynamic>> icon,
    required String title,
    required String description,
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
          align: ContentAlign.top,
          builder: (context, controller) {
            return _TutorialCard(
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

  static int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/timeline')) return 1;
    if (location.startsWith('/search')) return 2;
    if (location.startsWith('/statistics')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: widget.child,
      extendBody: false,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                  width: 1.0,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      key: _keyDashboard,
                      icon: HugeIcons.strokeRoundedDashboardCircle,
                      label: 'Home',
                      isSelected: currentIndex == 0,
                      onTap: () => context.go(AppRoutes.dashboard),
                    ),
                    _NavItem(
                      key: _keyTimeline,
                      icon: HugeIcons.strokeRoundedClock01,
                      label: 'Timeline',
                      isSelected: currentIndex == 1,
                      onTap: () => context.go(AppRoutes.timeline),
                    ),
                    _NavItem(
                      key: _keySearch,
                      icon: HugeIcons.strokeRoundedSearch01,
                      label: 'Search',
                      isSelected: currentIndex == 2,
                      onTap: () => context.go(AppRoutes.search),
                    ),
                    _NavItem(
                      key: _keyStatistics,
                      icon: HugeIcons.strokeRoundedChart,
                      label: 'Stats',
                      isSelected: currentIndex == 3,
                      onTap: () => context.go(AppRoutes.statistics),
                    ),
                    _NavItem(
                      key: _keySettings,
                      icon: HugeIcons.strokeRoundedSettings01,
                      label: 'Settings',
                      isSelected: currentIndex == 4,
                      onTap: () => context.go(AppRoutes.settings),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable tutorial tooltip card with frosted-glass aesthetic.
class _TutorialCard extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String description;
  final int step;
  final int totalSteps;
  final bool isLast;
  final VoidCallback onNext;

  const _TutorialCard({
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

    // Theme-adaptive colors
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
                // Step indicator + icon row
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
