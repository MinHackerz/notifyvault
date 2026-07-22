import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/notification_providers.dart';
import '../../core/widgets/notification_tile.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/fading_app_bar.dart';
import '../../models/notification_model.dart';
import '../../models/category_model.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync = ref.watch(filteredTimelineNotificationsProvider);
    final activeFilter = ref.watch(timelineFilterProvider);
    final hasActiveFilter = activeFilter.hasActiveFilter;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 8;

    return FadingScaffold(
      title: Text(
        'Timeline',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: hasActiveFilter ? const EdgeInsets.all(6) : EdgeInsets.zero,
            decoration: hasActiveFilter
                ? BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  )
                : null,
            child: HugeIcon(
              icon: hasActiveFilter
                  ? HugeIcons.strokeRoundedFilterHorizontal
                  : HugeIcons.strokeRoundedFilter,
              size: 20,
              color: hasActiveFilter
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          onPressed: () => _showFilterSheet(context, ref),
        ),
      ],
      body: groupedAsync.when(
        data: (grouped) {
          if (grouped.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: EmptyState(
                icon: HugeIcons.strokeRoundedClock01,
                title: 'No notifications yet',
                subtitle: 'Notifications matching filters will appear here.',
              ),
            );
          }

          // Flatten grouped map into a single list for high-performance scrolling
          final flatItems = <_TimelineItem>[];
          for (final entry in grouped.entries) {
            flatItems.add(_TimelineItem(
              isHeader: true,
              headerTitle: entry.key.label,
              headerCount: entry.value.length,
              groupNotifications: entry.value,
            ));
            for (final notification in entry.value) {
              flatItems.add(_TimelineItem(
                isHeader: false,
                notification: notification,
              ));
            }
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationStreamProvider);
            },
            edgeOffset: topPadding,
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: topPadding),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = flatItems[index];
                      if (item.isHeader) {
                        return _GroupHeader(
                          title: item.headerTitle!,
                          count: item.headerCount!,
                          onDelete: () => _confirmDeleteGroup(
                            context,
                            ref,
                            title: item.headerTitle!,
                            notifications: item.groupNotifications!,
                          ),
                        );
                      }

                      final notification = item.notification!;
                      return NotificationTile(
                        notification: notification,
                        onTap: () {
                          ref
                              .read(notificationRepositoryProvider)
                              .markAsRead(notification.id);
                          context
                              .push('/notification/${notification.id}');
                        },
                        onFavoriteToggle: () {
                          ref
                              .read(notificationRepositoryProvider)
                              .toggleFavorite(notification.id);
                        },
                        onDismiss: () {
                          ref
                              .read(notificationRepositoryProvider)
                              .deleteNotification(notification.id);
                        },
                      );
                    },
                    childCount: flatItems.length,
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          );
        },
        loading: () => Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: const ShimmerLoading(),
        ),
        error: (error, _) => Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: EmptyState(
            icon: HugeIcons.strokeRoundedAlertCircle,
            title: 'Something went wrong',
            subtitle: error.toString(),
            action: ElevatedButton(
              onPressed: () => ref.invalidate(notificationStreamProvider),
              child: const Text('Retry'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteGroup(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required List<NotificationModel> notifications,
  }) async {
    final count = notifications.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedDelete02,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete $title Notifications',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete $count notification${count == 1 ? '' : 's'} from $title? This action cannot be undone.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text(
                      'Delete All',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final ids = notifications.map((n) => n.id).toList();
      await ref.read(notificationRepositoryProvider).deleteNotifications(ids);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted $count notification${count == 1 ? '' : 's'}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final activeFilter = ref.watch(timelineFilterProvider);

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filters',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (activeFilter.hasActiveFilter)
                            TextButton(
                              onPressed: () {
                                ref.read(timelineFilterProvider.notifier).setFilter(
                                      const TimelineFilter(),
                                    );
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Clear All'),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Status Filters
                    const SectionHeader(index: '01', title: 'Status'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildFilterChip(
                            context: context,
                            label: 'All',
                            isSelected: activeFilter.onlyUnread == null,
                            onTap: () {
                              ref.read(timelineFilterProvider.notifier).setFilter(
                                activeFilter.copyWith(onlyUnread: null),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context: context,
                            label: 'Unread',
                            isSelected: activeFilter.onlyUnread == true,
                            onTap: () {
                              final isSel = activeFilter.onlyUnread == true;
                              ref.read(timelineFilterProvider.notifier).setFilter(
                                activeFilter.copyWith(onlyUnread: isSel ? null : true),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context: context,
                            label: 'Read',
                            isSelected: activeFilter.onlyUnread == false,
                            onTap: () {
                              final isSel = activeFilter.onlyUnread == false;
                              ref.read(timelineFilterProvider.notifier).setFilter(
                                activeFilter.copyWith(onlyUnread: isSel ? null : false),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Category Filters
                    const SectionHeader(index: '02', title: 'Categories'),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: CategoryModel.all.length,
                        itemBuilder: (context, index) {
                          final cat = CategoryModel.all[index];
                          final isSelected = activeFilter.categoryId == cat.id;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FilterChip(
                              label: Text(cat.name),
                              selected: isSelected,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onSelected: (selected) {
                                ref.read(timelineFilterProvider.notifier).setFilter(
                                  activeFilter.copyWith(
                                    categoryId: selected ? cat.id : null,
                                  ),
                                );
                              },
                              selectedColor: cat.color.withValues(alpha: 0.15),
                              checkmarkColor: cat.color,
                              labelStyle: TextStyle(
                                color: isSelected ? cat.color : theme.colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? cat.color
                                      : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Date Filters
                    const SectionHeader(index: '03', title: 'Date Range'),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildFilterChip(
                            context: context,
                            label: 'All Time',
                            isSelected: !activeFilter.hasDateFilter,
                            onTap: () {
                              ref.read(timelineFilterProvider.notifier).setFilter(
                                activeFilter.copyWith(datePreset: null, customDate: null),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context: context,
                            label: 'Today',
                            isSelected: activeFilter.datePreset == 'today',
                            onTap: () {
                              final isSel = activeFilter.datePreset == 'today';
                              ref.read(timelineFilterProvider.notifier).setFilter(
                                activeFilter.copyWith(
                                  datePreset: isSel ? null : 'today',
                                  customDate: null,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context: context,
                            label: 'Yesterday',
                            isSelected: activeFilter.datePreset == 'yesterday',
                            onTap: () {
                              final isSel = activeFilter.datePreset == 'yesterday';
                              ref.read(timelineFilterProvider.notifier).setFilter(
                                activeFilter.copyWith(
                                  datePreset: isSel ? null : 'yesterday',
                                  customDate: null,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context: context,
                            label: 'Last 7 Days',
                            isSelected: activeFilter.datePreset == '7days',
                            onTap: () {
                              final isSel = activeFilter.datePreset == '7days';
                              ref.read(timelineFilterProvider.notifier).setFilter(
                                activeFilter.copyWith(
                                  datePreset: isSel ? null : '7days',
                                  customDate: null,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context: context,
                            label: 'Last 30 Days',
                            isSelected: activeFilter.datePreset == '30days',
                            onTap: () {
                              final isSel = activeFilter.datePreset == '30days';
                              ref.read(timelineFilterProvider.notifier).setFilter(
                                activeFilter.copyWith(
                                  datePreset: isSel ? null : '30days',
                                  customDate: null,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context: context,
                            label: activeFilter.customDate != null
                                ? '${activeFilter.customDate!.day}/${activeFilter.customDate!.month}/${activeFilter.customDate!.year}'
                                : 'Custom Date...',
                            isSelected: activeFilter.customDate != null,
                            onTap: () async {
                              if (activeFilter.customDate != null) {
                                ref.read(timelineFilterProvider.notifier).setFilter(
                                  activeFilter.copyWith(customDate: null, datePreset: null),
                                );
                                return;
                              }
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                ref.read(timelineFilterProvider.notifier).setFilter(
                                  activeFilter.copyWith(customDate: picked, datePreset: null),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
        ),
      ),
    );
  }
}

class _TimelineItem {
  final bool isHeader;
  final String? headerTitle;
  final int? headerCount;
  final List<NotificationModel>? groupNotifications;
  final NotificationModel? notification;

  _TimelineItem({
    required this.isHeader,
    this.headerTitle,
    this.headerCount,
    this.groupNotifications,
    this.notification,
  });
}

class _GroupHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onDelete;

  const _GroupHeader({
    required this.title,
    required this.count,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionHeader(
      index: count < 10 ? '0$count' : '$count',
      title: title,
      action: IconButton(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedDelete02,
          size: 16,
          color: theme.colorScheme.error.withValues(alpha: 0.7),
        ),
        tooltip: 'Delete all $title notifications',
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onDelete,
      ),
    );
  }
}
