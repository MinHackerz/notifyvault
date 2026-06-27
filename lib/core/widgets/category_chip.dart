import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../models/category_model.dart';

/// A premium flat colored chip displaying a notification category.
class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSmall;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSmall = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isSmall) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: category.color.withValues(alpha: 0.15),
            width: 1.0,
          ),
        ),
        child: Text(
          category.name,
          style: theme.textTheme.labelSmall?.copyWith(
            color: category.color,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 0.1,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withValues(alpha: 0.18)
              : category.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? category.color
                : category.color.withValues(alpha: 0.15),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: category.icon,
              size: 14,
              color: category.color,
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: theme.textTheme.labelMedium?.copyWith(
                color: category.color,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
