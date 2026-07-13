import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/permission_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/history/timeline_screen.dart';
import '../../features/notification_details/notification_detail_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/app_management_screen.dart';
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
    ],
  );
});

/// Main shell widget with flat minimalist bottom navigation.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

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
      body: child,
      extendBody: false, // Don't extend body to avoid floating nav overlap
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
                      icon: HugeIcons.strokeRoundedDashboardCircle,
                      label: 'Home',
                      isSelected: currentIndex == 0,
                      onTap: () => context.go(AppRoutes.dashboard),
                    ),
                    _NavItem(
                      icon: HugeIcons.strokeRoundedClock01,
                      label: 'Timeline',
                      isSelected: currentIndex == 1,
                      onTap: () => context.go(AppRoutes.timeline),
                    ),
                    _NavItem(
                      icon: HugeIcons.strokeRoundedSearch01,
                      label: 'Search',
                      isSelected: currentIndex == 2,
                      onTap: () => context.go(AppRoutes.search),
                    ),
                    _NavItem(
                      icon: HugeIcons.strokeRoundedChart,
                      label: 'Stats',
                      isSelected: currentIndex == 3,
                      onTap: () => context.go(AppRoutes.statistics),
                    ),
                    _NavItem(
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
