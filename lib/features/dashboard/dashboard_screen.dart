import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/config/app_config.dart';
import '../../app/router/app_router.dart';
import '../../providers/notification_providers.dart';
import '../../providers/permission_providers.dart';
import '../../providers/app_management_providers.dart';
import '../../providers/financial_providers.dart';
import '../../models/category_model.dart';
import '../../models/notification_model.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/notification_tile.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/fading_app_bar.dart';

final dashboardTabProvider = NotifierProvider<DashboardTabNotifier, String>(DashboardTabNotifier.new);

class DashboardTabNotifier extends Notifier<String> {
  bool _hasAutoSelected = false;

  @override
  String build() {
    // Reset auto-selection when the notifier is rebuilt (e.g., provider invalidated)
    _hasAutoSelected = false;
    return 'priority';
  }

  // ignore: use_setters_to_change_properties
  void setTab(String tab) => state = tab;

  /// Called once when data is first available to pick the right default.
  void autoSelectIfNeeded(bool hasPriorityNotifications) {
    if (_hasAutoSelected) return;
    _hasAutoSelected = true;
    state = hasPriorityNotifications ? 'priority' : 'normal';
  }
}

final recentActivityNotificationsProvider = Provider.autoDispose<AsyncValue<Map<String, List<NotificationModel>>>>((ref) {
  final notificationsAsync = ref.watch(notificationStreamProvider);
  final priorityPkgsAsync = ref.watch(priorityPackagesProvider);
  final spamPkgsAsync = ref.watch(spamPackagesProvider);

  // Wait for ALL three providers to have data before classifying.
  // This prevents misclassification when priority/spam lists haven't loaded yet.
  if (notificationsAsync is AsyncLoading ||
      priorityPkgsAsync is AsyncLoading ||
      spamPkgsAsync is AsyncLoading) {
    return const AsyncLoading();
  }

  final notifications = notificationsAsync.whenData((v) => v).value ?? [];
  final priorityPkgs = priorityPkgsAsync.whenData((v) => v).value ?? <String>{};
  final spamPkgs = spamPkgsAsync.whenData((v) => v).value ?? <String>{};

  final now = DateTime.now();

  final priority = <NotificationModel>[];
  final normal = <NotificationModel>[];
  final spam = <NotificationModel>[];

  for (final n in notifications) {
    if (n.timestamp.year == now.year && n.timestamp.month == now.month && n.timestamp.day == now.day) {
      if (priorityPkgs.contains(n.packageName)) {
        priority.add(n);
      } else if (spamPkgs.contains(n.packageName)) {
        spam.add(n);
      } else {
        normal.add(n);
      }
    }
  }

  return AsyncData({
    'priority': priority,
    'normal': normal,
    'spam': spam,
  });
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Future<void> _onRefresh() async {
    // Invalidate all relevant providers to force re-fetch
    ref.invalidate(notificationStreamProvider);
    ref.invalidate(todayCountProvider);
    ref.invalidate(unreadCountProvider);
    ref.invalidate(activeAppsTodayProvider);
    ref.invalidate(totalCountProvider);
    ref.invalidate(priorityPackagesProvider);
    ref.invalidate(spamPackagesProvider);
    ref.invalidate(prioritySortedNotificationsProvider);
    ref.invalidate(recentActivityNotificationsProvider);
    ref.invalidate(dashboardTabProvider);

    // Wait a short moment for providers to re-evaluate
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final permissionState = ref.watch(notificationPermissionProvider);

    final topPadding = MediaQuery.of(context).padding.top + 72 + 4;

    return FadingScaffold(
      toolbarHeight: 72,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConfig.appName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
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
      actions: [
        permissionState.when(
          data: (granted) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
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
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        edgeOffset: topPadding,
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        displacement: 60,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: topPadding),
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

            // Tabs
            SliverToBoxAdapter(
              child: _RecentActivityTabs(),
            ),

            // Recent notifications list (priority sorted)
            const _RecentNotifications(),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
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
              )
                  .animate()
                  .fadeIn(duration: 350.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
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
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 350.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
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
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 350.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
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
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 350.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const _DashboardFinancialCard(),
      ],
    );
  }
}

class _DashboardFinancialCard extends ConsumerWidget {
  const _DashboardFinancialCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(financialSummaryProvider);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return summaryAsync.when(
      data: (summary) {
        if (summary.transactionCount == 0) return const SizedBox.shrink();

        return Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => context.push(AppRoutes.financialSummary),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.categoryBanking.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedBank,
                        color: AppColors.categoryBanking,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spent Recently',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(summary.totalSpent),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tracker',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A2D) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              HugeIcon(icon: icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
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

class _RecentActivityTabs extends ConsumerWidget {
  const _RecentActivityTabs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(dashboardTabProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              context,
              ref,
              'priority',
              'Priority',
              HugeIcons.strokeRoundedStar,
              selectedTab == 'priority',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTab(
              context,
              ref,
              'normal',
              'Normal',
              HugeIcons.strokeRoundedNotification01,
              selectedTab == 'normal',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTab(
              context,
              ref,
              'spam',
              'Spam',
              HugeIcons.strokeRoundedAlertCircle,
              selectedTab == 'spam',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    WidgetRef ref,
    String id,
    String label,
    List<List<dynamic>> icon,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeBg = isDark
        ? theme.colorScheme.primary.withValues(alpha: 0.18)
        : theme.colorScheme.primary.withValues(alpha: 0.1);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(dashboardTabProvider.notifier).setTab(id),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : isDark
                      ? AppColors.outlineDark
                      : AppColors.outlineLight,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: icon,
                size: 14,
                color: isSelected ? activeColor : inactiveColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentNotifications extends ConsumerStatefulWidget {
  const _RecentNotifications();

  @override
  ConsumerState<_RecentNotifications> createState() => _RecentNotificationsState();
}

class _RecentNotificationsState extends ConsumerState<_RecentNotifications> {
  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(recentActivityNotificationsProvider);
    final priorityPkgs = ref.watch(priorityPackagesProvider).whenData((v) => v).value ?? <String>{};
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedTab = ref.watch(dashboardTabProvider);

    return dataAsync.when(
      data: (data) {
        final priority = data['priority']!;

        // Schedule auto-select after the current frame to avoid modifying state during build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(dashboardTabProvider.notifier).autoSelectIfNeeded(priority.isNotEmpty);
          }
        });

        final notifications = data[selectedTab]!;

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
                      'No ${selectedTab[0].toUpperCase()}${selectedTab.substring(1)} notifications',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Check the other tabs for recent activity.',
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

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final notification = notifications[index];
              final isPriority = priorityPkgs.contains(notification.packageName);
              return NotificationTile(
                notification: notification,
                isPriority: isPriority,
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
            childCount: notifications.length,
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
