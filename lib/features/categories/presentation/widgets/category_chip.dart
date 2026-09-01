import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/color_parser.dart';
import '../../domain/entities/category_entity.dart';

/// Colored category chip used in pickers and lists (TASKS.md 4C.4).
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
  });

  final CategoryEntity category;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        tryParseColor(category.color) ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.25)
              : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: selected ? color : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconForName(category.icon), size: 16, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(category.name, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
