import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../app/theme/app_colors.dart';
import '../../app/config/app_config.dart';
import '../../app/router/app_router.dart';
import '../../providers/notification_providers.dart';
import '../../providers/permission_providers.dart';
import '../../models/category_model.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/notification_tile.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/section_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final permissionState = ref.watch(notificationPermissionProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Professional App Bar
          SliverAppBar(
            expandedHeight: 110,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConfig.appName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: theme.colorScheme.onSurface,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    _getGreeting(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              permissionState.when(
                data: (granted) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: granted
                        ? () => _showAboutDialog(context)
                        : () => context.push(AppRoutes.permission),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: granted
                              ? theme.colorScheme.primary.withValues(alpha: 0.2)
                              : AppColors.warning.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: granted
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.asset(
                                isDark
                                    ? 'assets/icons/app_icon_dark.png'
                                    : 'assets/icons/app_icon.png',
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedAlertCircle,
                                color: AppColors.warning,
                                size: 16,
                              ),
                            ),
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),

          // Permission banner if not granted
          permissionState.when(
            data: (granted) {
              if (granted) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: _PermissionBanner(
                  onTap: () => context.push(AppRoutes.permission),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Section 1: Overview
          const SliverToBoxAdapter(
            child: SectionHeader(
              index: '01',
              title: 'Overview',
            ),
          ),

          // Stats cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: _StatsGrid(),
            ),
          ),

          // Section 2: Categories
          const SliverToBoxAdapter(
            child: SectionHeader(
              index: '02',
              title: 'Categories',
            ),
          ),

          // Quick category chips
          SliverToBoxAdapter(
            child: _CategoryQuickAccess(),
          ),

          // Section 3: Recent Activity
          SliverToBoxAdapter(
            child: SectionHeader(
              index: '03',
              title: 'Recent Activity',
              action: TextButton.icon(
                onPressed: () => context.go(AppRoutes.timeline),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                label: const Text('View All', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),

          // Recent notifications list
          _RecentNotifications(),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
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
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              isDark
                  ? 'assets/icons/app_icon_dark.png'
                  : 'assets/icons/app_icon.png',
              width: 48,
              height: 48,
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
}

class _PermissionBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _PermissionBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedNotificationOff01,
                      color: AppColors.warning,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notification access required',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to enable notification capture',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  size: 16,
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayCount = ref.watch(todayCountProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final activeApps = ref.watch(activeAppsTodayProvider);
    final totalCount = ref.watch(totalCountProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: HugeIcons.strokeRoundedFlash,
                title: 'Today',
                value: todayCount.when(
                  data: (v) => '$v',
                  loading: () => '·',
                  error: (_, _) => '0',
                ),
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: HugeIcons.strokeRoundedNotification03,
                title: 'Unread',
                value: unreadCount.when(
                  data: (v) => '$v',
                  loading: () => '·',
                  error: (_, _) => '0',
                ),
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: HugeIcons.strokeRoundedGrid,
                title: 'Active Apps',
                value: activeApps.when(
                  data: (v) => '$v',
                  loading: () => '·',
                  error: (_, _) => '0',
                ),
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: HugeIcons.strokeRoundedArchive01,
                title: 'Total Saved',
                value: totalCount.when(
                  data: (v) => '$v',
                  loading: () => '·',
                  error: (_, _) => '0',
                ),
                color: AppColors.categoryPayments,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon in clean box
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: HugeIcon(icon: icon, size: 18, color: color),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.italic,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryQuickAccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topCategories = CategoryModel.all;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Categories',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: topCategories.length,
            itemBuilder: (context, index) {
              final cat = topCategories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CategoryChip(
                  category: cat,
                  onTap: () {
                    context.push('/category/${cat.id}');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentNotifications extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationStreamProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return notificationsAsync.when(
      data: (notifications) {
        if (notifications.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surface,
                        border: Border.all(
                          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedNotification01,
                          size: 24,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Captured notifications will show here.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final recent = notifications.take(10).toList();

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final notification = recent[index];
              return NotificationTile(
                notification: notification,
                onTap: () {
                  ref
                      .read(notificationRepositoryProvider)
                      .markAsRead(notification.id);
                  context.push('/notification/${notification.id}');
                },
                onDismiss: () {
                  ref
                      .read(notificationRepositoryProvider)
                      .deleteNotification(notification.id);
                },
              );
            },
            childCount: recent.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: DashboardShimmer()),
      error: (_, _) => const SliverToBoxAdapter(
        child: Center(child: Text('Error loading notifications')),
      ),
    );
  }
}
