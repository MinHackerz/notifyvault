import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/app_management_providers.dart';
import '../../database/app_database.dart';
import '../../core/widgets/section_header.dart';

class AppManagementScreen extends ConsumerWidget {
  const AppManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appsAsync = ref.watch(appsWithPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'App Management',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surface,
                      border: Border.all(
                        color: isDark
                            ? AppColors.outlineDark
                            : AppColors.outlineLight,
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedGrid,
                        size: 24,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No apps found',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Apps will appear here once notifications are captured.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Group apps by status
          final priorityApps =
              apps.where((a) => a.status == 'priority').toList();
          final normalApps =
              apps.where((a) => a.status == 'normal').toList();
          final spamApps = apps.where((a) => a.status == 'spam').toList();
          final blockedApps =
              apps.where((a) => a.status == 'blocked').toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // Legend
              _buildLegend(context),
              const SizedBox(height: 16),

              // Priority section
              if (priorityApps.isNotEmpty) ...[
                const SectionHeader(
                    index: '⭐', title: 'Priority'),
                const SizedBox(height: 8),
                ...priorityApps.asMap().entries.map((entry) {
                  return _AppTile(
                    app: entry.value,
                    index: entry.key,
                    onStatusChanged: (status) =>
                        _setStatus(ref, entry.value, status),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Normal section
              if (normalApps.isNotEmpty) ...[
                SectionHeader(
                  index: '01',
                  title: 'Normal',
                  action: Text(
                    '${normalApps.length} apps',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...normalApps.asMap().entries.map((entry) {
                  return _AppTile(
                    app: entry.value,
                    index: entry.key,
                    onStatusChanged: (status) =>
                        _setStatus(ref, entry.value, status),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Spam section
              if (spamApps.isNotEmpty) ...[
                const SectionHeader(
                    index: '🚫', title: 'Spam'),
                const SizedBox(height: 8),
                ...spamApps.asMap().entries.map((entry) {
                  return _AppTile(
                    app: entry.value,
                    index: entry.key,
                    onStatusChanged: (status) =>
                        _setStatus(ref, entry.value, status),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Blocked section
              if (blockedApps.isNotEmpty) ...[
                const SectionHeader(
                    index: '🔒', title: 'Blocked'),
                const SizedBox(height: 8),
                ...blockedApps.asMap().entries.map((entry) {
                  return _AppTile(
                    app: entry.value,
                    index: entry.key,
                    onStatusChanged: (status) =>
                        _setStatus(ref, entry.value, status),
                  );
                }),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
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
          Text(
            'Manage how notifications from each app are handled',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _legendItem(context, Colors.amber, 'Priority',
                  'Shown at top'),
              const SizedBox(width: 16),
              _legendItem(context, AppColors.categorySpam, 'Spam',
                  'Shown at bottom'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _legendItem(context, AppColors.error, 'Blocked',
                  'Not saved'),
              const SizedBox(width: 16),
              _legendItem(
                  context,
                  theme.colorScheme.primary,
                  'Normal',
                  'Default'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(
      BuildContext context, Color color, String label, String desc) {
    final theme = Theme.of(context);
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: color,
                  ),
                ),
                Text(
                  desc,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setStatus(
      WidgetRef ref, AppWithPreference app, String status) {
    if (status == 'normal') {
      AppDatabase.instance.appPreferencesDao
          .removePreference(app.packageName);
    } else {
      AppDatabase.instance.appPreferencesDao
          .setPreference(app.packageName, app.appName, status);
    }
    ref.invalidate(appsWithPreferencesProvider);
    ref.invalidate(priorityPackagesProvider);
    ref.invalidate(blockedPackagesProvider);
    ref.invalidate(spamPackagesProvider);
  }
}

class _AppTile extends StatelessWidget {
  final AppWithPreference app;
  final int index;
  final ValueChanged<String> onStatusChanged;

  const _AppTile({
    required this.app,
    required this.index,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(app.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131A2D) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: app.status == 'priority'
                ? Colors.amber.withValues(alpha: 0.3)
                : app.status == 'blocked'
                    ? AppColors.error.withValues(alpha: 0.2)
                    : (isDark
                        ? AppColors.outlineDark
                        : AppColors.outlineLight),
            width: 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            leading: _buildAppIcon(theme, isDark),
            title: Text(
              app.appName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                decoration: app.status == 'blocked'
                    ? TextDecoration.lineThrough
                    : null,
                color: app.status == 'blocked'
                    ? theme.colorScheme.onSurfaceVariant
                    : null,
              ),
            ),
            subtitle: Text(
              '${app.notificationCount} notifications',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: onStatusChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark
                      ? AppColors.outlineDark
                      : AppColors.outlineLight,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getStatusLabel(app.status),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down,
                        size: 16, color: statusColor),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                _buildStatusItem(
                    context, 'normal', 'Normal', Icons.check_circle_outline,
                    theme.colorScheme.primary),
                _buildStatusItem(
                    context, 'priority', 'Priority', Icons.star_rounded,
                    Colors.amber),
                _buildStatusItem(
                    context, 'spam', 'Spam', Icons.report_outlined,
                    AppColors.categorySpam),
                _buildStatusItem(
                    context, 'blocked', 'Blocked', Icons.block,
                    AppColors.error),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: index * 50),
          duration: 250.ms,
          curve: Curves.easeOut,
        )
        .slideX(begin: 0.05, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildAppIcon(ThemeData theme, bool isDark) {
    if (app.iconPath != null && app.iconPath!.isNotEmpty) {
      final file = File(app.iconPath!);
      if (file.existsSync()) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.file(file,
                width: 40, height: 40, fit: BoxFit.cover),
          ),
        );
      }
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getStatusColor(app.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(app.status).withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Center(
        child: Text(
          app.appName.isNotEmpty
              ? app.appName[0].toUpperCase()
              : '?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _getStatusColor(app.status),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildStatusItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = app.status == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? color : null,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(Icons.check, size: 16, color: color),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'priority':
        return Colors.amber;
      case 'blocked':
        return AppColors.error;
      case 'spam':
        return AppColors.categorySpam;
      default:
        return AppColors.primary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'priority':
        return 'Priority';
      case 'blocked':
        return 'Blocked';
      case 'spam':
        return 'Spam';
      default:
        return 'Normal';
    }
  }
}
