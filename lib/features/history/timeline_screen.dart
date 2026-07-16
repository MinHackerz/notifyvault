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
import '../../models/notification_model.dart';
import '../../models/category_model.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync = ref.watch(filteredTimelineNotificationsProvider);
    final activeFilter = ref.watch(timelineFilterProvider);
    final hasActiveFilter = activeFilter.categoryId != null || activeFilter.onlyUnread != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Timeline',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedFilter,
              size: 20,
              color: hasActiveFilter ? Theme.of(context).colorScheme.primary : null,
            ),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: groupedAsync.when(
        data: (grouped) {
          if (grouped.isEmpty) {
            return EmptyState(
              icon: HugeIcons.strokeRoundedClock01,
              title: 'No notifications yet',
              subtitle: 'Notifications matching filters will appear here.',
            );
          }

          // Flatten grouped map into a single list for high-performance scrolling
          final flatItems = <_TimelineItem>[];
          for (final entry in grouped.entries) {
            flatItems.add(_TimelineItem(
              isHeader: true,
              headerTitle: entry.key.label,
              headerCount: entry.value.length,
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
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = flatItems[index];
                      if (item.isHeader) {
                        return _GroupHeader(
                          title: item.headerTitle!,
                          count: item.headerCount!,
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
        loading: () => const ShimmerLoading(),
        error: (error, _) => EmptyState(
          icon: HugeIcons.strokeRoundedAlertCircle,
          title: 'Something went wrong',
          subtitle: error.toString(),
          action: ElevatedButton(
            onPressed: () => ref.invalidate(notificationStreamProvider),
            child: const Text('Retry'),
          ),
        ),
      ),
    );
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
                          if (activeFilter.categoryId != null || activeFilter.onlyUnread != null)
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
                              ref.read(timelineFilterProvider.notifier).setFilter(TimelineFilter(
                                categoryId: activeFilter.categoryId,
                                onlyUnread: null,
                              ));
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context: context,
                            label: 'Unread',
                            isSelected: activeFilter.onlyUnread == true,
                            onTap: () {
                              ref.read(timelineFilterProvider.notifier).setFilter(TimelineFilter(
                                categoryId: activeFilter.categoryId,
                                onlyUnread: true,
                              ));
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context: context,
                            label: 'Read',
                            isSelected: activeFilter.onlyUnread == false,
                            onTap: () {
                              ref.read(timelineFilterProvider.notifier).setFilter(TimelineFilter(
                                categoryId: activeFilter.categoryId,
                                onlyUnread: false,
                              ));
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
                              onSelected: (selected) {
                                ref.read(timelineFilterProvider.notifier).setFilter(TimelineFilter(
                                  categoryId: selected ? cat.id : null,
                                  onlyUnread: activeFilter.onlyUnread,
                                ));
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
  final NotificationModel? notification;

  _TimelineItem({
    required this.isHeader,
    this.headerTitle,
    this.headerCount,
    this.notification,
  });
}

class _GroupHeader extends StatelessWidget {
  final String title;
  final int count;

  const _GroupHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      index: count < 10 ? '0$count' : '$count',
      title: title,
    );
  }
}
