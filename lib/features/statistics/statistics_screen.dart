import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/statistics_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/notification_providers.dart';
import '../../core/widgets/section_header.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.invalidate(notificationStreamProvider);
        ref.invalidate(statsSummaryProvider);
        ref.invalidate(topAppsStatsProvider);
        ref.invalidate(top5AppsStatsProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ref.watch(statsTimeRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => _showPeriodPicker(context, ref, days),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedCalendar01,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              label: Text(
                'Last $days days',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationStreamProvider);
          ref.invalidate(statsSummaryProvider);
          ref.invalidate(topAppsStatsProvider);
          ref.invalidate(top5AppsStatsProvider);
        },
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // Summary Cards
            const SectionHeader(index: '01', title: 'Summary'),
            const SizedBox(height: 8),
            _SummaryCards(),

            const SizedBox(height: 20),

            // Top 5 Apps Chart
            const SectionHeader(index: '02', title: 'Top 5 Apps'),
            const SizedBox(height: 8),
            _TopAppsChart(),

            const SizedBox(height: 20),

            // All Apps Table
            const SectionHeader(index: '03', title: 'All Apps'),
            const SizedBox(height: 8),
            _AllAppsTable(),
          ],
        ),
      ),
    );
  }

  void _showPeriodPicker(BuildContext context, WidgetRef ref, int current) {
    final theme = Theme.of(context);
    final retentionDays = ref.read(retentionPeriodProvider);
    final options = [3, 7, 14, 30];
    // Filter out options beyond retention
    final available = retentionDays == -1
        ? options
        : options.where((d) => d <= retentionDays).toList();

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
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Time Range',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ...available.map((days) {
                  final isSelected = days == current;
                  return ListTile(
                    title: Text('Last $days days'),
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      ref
                          .read(statsTimeRangeProvider.notifier)
                          .setDays(days);
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryCards extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(statsSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        return Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                icon: HugeIcons.strokeRoundedNotification03,
                title: 'Received',
                value: '${summary.totalReceived}',
                color: theme.colorScheme.primary,
              )
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.1, end: 0),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStatCard(
                icon: HugeIcons.strokeRoundedArchive01,
                title: 'Saved',
                value: '${summary.totalSaved}',
                color: AppColors.success,
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 350.ms)
                  .slideY(begin: 0.1, end: 0),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStatCard(
                icon: HugeIcons.strokeRoundedDelete02,
                title: 'Deleted',
                value: '${summary.totalDeleted}',
                color: AppColors.error,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 350.ms)
                  .slideY(begin: 0.1, end: 0),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String value;
  final Color color;

  const _MiniStatCard({
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
        color: isDark ? const Color(0xFF131A2D) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(icon: icon, size: 18, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopAppsChart extends ConsumerWidget {
  static const _chartColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF3B82F6), // Blue
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topAppsAsync = ref.watch(top5AppsStatsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A2D) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1.0,
        ),
      ),
      child: topAppsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'No data available',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            );
          }

          final maxCount =
              apps.fold(0, (max, a) => a.count > max ? a.count : max);

          return SizedBox(
            height: 50.0 * apps.length + 20,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxCount.toDouble() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${apps[group.x].appName}\n${rod.toY.toInt()} notifications',
                        TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < apps.length) {
                          final name = apps[idx].appName;
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              name.length > 8
                                  ? '${name.substring(0, 8)}…'
                                  : name,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxCount / 4).ceilToDouble().clamp(1, double.infinity),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: apps.asMap().entries.map((entry) {
                  final i = entry.key;
                  final app = entry.value;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: app.count.toDouble(),
                        width: 28,
                        color: _chartColors[i % _chartColors.length],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxCount.toDouble() * 1.2,
                          color: _chartColors[i % _chartColors.length]
                              .withValues(alpha: 0.06),
                        ),
                      ),
                    ],
                    showingTooltipIndicators: [],
                  );
                }).toList(),
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutQuad,
            ),
          );
        },
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => SizedBox(
          height: 200,
          child: Center(child: Text('Error: $e')),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideY(begin: 0.05, end: 0);
  }
}

class _AllAppsTable extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allAppsAsync = ref.watch(topAppsStatsProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A2D) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1.0,
        ),
      ),
      child: allAppsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No notification data yet',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? AppColors.outlineDark
                            : AppColors.outlineLight,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          '#',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'APP',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        'NOTIFICATIONS',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Table rows
                ...apps.asMap().entries.map((entry) {
                  final i = entry.key;
                  final app = entry.value;
                  final isLast = i == apps.length - 1;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? AppColors.outlineDark
                                    : AppColors.outlineLight,
                              ),
                            ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${i + 1}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: i < 3
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        _buildAppIcon(app.iconPath, app.packageName, app.appName, theme, isDark),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            app.appName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${app.count}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 400 + i * 50),
                        duration: 200.ms,
                      )
                      .slideX(begin: 0.03, end: 0);
                }),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(32),
          child: Center(child: Text('Error: $e')),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 400.ms)
        .slideY(begin: 0.05, end: 0);
  }

  Widget _buildAppIcon(
      String? iconPath, String packageName, String appName, ThemeData theme, bool isDark) {
    String? path = iconPath;
    if (path == null || path.isEmpty) {
      path = '/data/user/0/com.notifyvault.app/files/icons/$packageName.png';
    }

    var file = File(path);
    if (!file.existsSync()) {
      file = File('/data/data/com.notifyvault.app/files/icons/$packageName.png');
    }

    if (file.existsSync()) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            width: 0.8,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.file(file, width: 24, height: 24, fit: BoxFit.cover),
        ),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Center(
        child: Text(
          appName.isNotEmpty ? appName[0].toUpperCase() : '?',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
