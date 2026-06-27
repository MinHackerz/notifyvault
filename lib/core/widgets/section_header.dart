import 'package:flutter/material.dart';

/// A premium, technical/editorial section header inspired by Latch.
/// Displays as: `01 ────── SECTION TITLE ──────`
class SectionHeader extends StatelessWidget {
  final String index;
  final String title;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.index,
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            index,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: theme.colorScheme.outline,
              thickness: 1.0,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: theme.colorScheme.outline,
              thickness: 1.0,
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 10),
            action!,
          ],
        ],
      ),
    );
  }
}
