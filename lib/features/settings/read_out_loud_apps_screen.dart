import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/app_management_providers.dart';
import '../../database/app_database.dart';
import '../../core/widgets/section_header.dart';

import '../../providers/settings_providers.dart';

class ReadOutLoudAppsScreen extends ConsumerWidget {
  const ReadOutLoudAppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appsAsync = ref.watch(appsWithPreferencesProvider);
    final playbackMode = ref.watch(ttsPlaybackModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Read Out Loud',
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
                        color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
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
                ],
              ),
            );
          }

          final readOutLoudApps = apps.where((a) => a.readOutLoud).toList();
          final otherApps = apps.where((a) => !a.readOutLoud).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _buildPlaybackModeSelector(context, ref, playbackMode),
              const SizedBox(height: 16),
              _buildLegend(context),
              const SizedBox(height: 16),
              
              if (readOutLoudApps.isNotEmpty) ...[
                const SectionHeader(index: '🔊', title: 'Enabled Apps'),
                const SizedBox(height: 8),
                ...readOutLoudApps.asMap().entries.map((entry) {
                  return _AppToggleTile(
                    app: entry.value,
                    index: entry.key,
                    onToggle: (val) => _setReadOutLoud(ref, entry.value, val),
                  );
                }),
                const SizedBox(height: 16),
              ],
              
              if (otherApps.isNotEmpty) ...[
                const SectionHeader(index: '01', title: 'Available Apps'),
                const SizedBox(height: 8),
                ...otherApps.asMap().entries.map((entry) {
                  return _AppToggleTile(
                    app: entry.value,
                    index: entry.key,
                    onToggle: (val) => _setReadOutLoud(ref, entry.value, val),
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
            'Select which apps should announce their notifications out loud when received.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackModeSelector(BuildContext context, WidgetRef ref, TtsPlaybackMode playbackMode) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A2D) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedSettings02,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Playback Behavior',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'When should the app read notifications out loud?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          _buildOption(context, ref, 'Anytime (Default)', TtsPlaybackMode.anytime, playbackMode),
          const SizedBox(height: 8),
          _buildOption(context, ref, 'Only when unlocked', TtsPlaybackMode.onlyUnlocked, playbackMode),
          const SizedBox(height: 8),
          _buildOption(context, ref, 'Only when locked', TtsPlaybackMode.onlyLocked, playbackMode),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, WidgetRef ref, String title, TtsPlaybackMode mode, TtsPlaybackMode current) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = mode == current;
      
    return GestureDetector(
      onTap: () => ref.read(ttsPlaybackModeProvider.notifier).setMode(mode),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setReadOutLoud(WidgetRef ref, AppWithPreference app, bool readOutLoud) {
    AppDatabase.instance.appPreferencesDao.setReadOutLoud(
      app.packageName,
      app.appName,
      readOutLoud,
    );
    ref.invalidate(appsWithPreferencesProvider);
  }
}

class _AppToggleTile extends StatelessWidget {
  final AppWithPreference app;
  final int index;
  final ValueChanged<bool> onToggle;

  const _AppToggleTile({
    required this.app,
    required this.index,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131A2D) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: app.readOutLoud
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
            width: 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            leading: _buildAppIcon(theme, isDark),
            title: Text(
              app.appName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            trailing: GestureDetector(
              onTap: () => onToggle(!app.readOutLoud),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: app.readOutLoud 
                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                      : (isDark ? const Color(0xFF1A2235) : Colors.grey.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: app.readOutLoud 
                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                        : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: app.readOutLoud ? HugeIcons.strokeRoundedMegaphone01 : HugeIcons.strokeRoundedNotificationOff01,
                      size: 14,
                      color: app.readOutLoud ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      app.readOutLoud ? 'Enabled' : 'Disabled',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: app.readOutLoud ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: (index % 10) * 50),
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
            child: Image.file(file, width: 40, height: 40, fit: BoxFit.cover),
          ),
        );
      }
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Center(
        child: Text(
          app.appName.isNotEmpty ? app.appName[0].toUpperCase() : '?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
