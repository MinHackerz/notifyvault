import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../app/theme/app_colors.dart';

/// Beautiful flat empty state widget with HugeIcon.
class EmptyState extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Clean flat circular background for icon
            Container(
              width: 80,
              height: 80,
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
                  icon: icon,
                  size: 28,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
