import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../models/category_model.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_providers.dart';
import '../../core/widgets/notification_tile.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/section_header.dart';

/// Riverpod provider family to load notifications for a specific category
final categoryNotificationsProvider = FutureProvider.family<List<NotificationModel>, String>((ref, categoryId) {
  final repo = ref.watch(notificationRepositoryProvider);
  // Auto-invalidate when the main notification stream updates
  ref.watch(notificationStreamProvider);
  return repo.getByCategory(categoryId, limit: 100);
});

class CategoryScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryScreen({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final category = CategoryModel.findById(categoryId);
    final notificationsAsync = ref.watch(categoryNotificationsProvider(categoryId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, size: 22),
          onPressed: () => context.pop(),
        ),
        title: Text(
          category.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category Header Emblem ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: category.color.withValues(alpha: 0.15),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: category.icon,
                        color: category.color,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Filtered view of all captured notifications.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SectionHeader(index: '01', title: 'Captured Alerts'),

          // ── Notifications List ──
          Expanded(
            child: notificationsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    icon: category.icon,
                    title: 'No notifications',
                    subtitle: 'Notifications belonging to this category will show here.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final notification = list[index];
                    return NotificationTile(
                      notification: notification,
                      onTap: () {
                        ref.read(notificationRepositoryProvider).markAsRead(notification.id);
                        context.push('/notification/${notification.id}');
                      },
                      onFavoriteToggle: () {
                        ref.read(notificationRepositoryProvider).toggleFavorite(notification.id);
                      },
                      onDismiss: () {
                        ref.read(notificationRepositoryProvider).deleteNotification(notification.id);
                      },
                    );
                  },
                );
              },
              loading: () => const ShimmerLoading(),
              error: (error, _) => EmptyState(
                icon: HugeIcons.strokeRoundedAlertCircle,
                title: 'Something went wrong',
                subtitle: error.toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
