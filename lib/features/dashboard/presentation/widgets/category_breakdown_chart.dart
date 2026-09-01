import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_animated_entrance.dart';
import '../../domain/entities/analytics_summary_entity.dart';

/// Expense-per-category pie chart + legend (TASKS.md 7C.4).
class CategoryBreakdownChart extends StatelessWidget {
  const CategoryBreakdownChart({super.key, required this.breakdown});

  final List<CategoryBreakdownEntity> breakdown;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    if (breakdown.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          AppStrings.emptyBreakdown,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final total = breakdown.fold<double>(0, (sum, e) => sum + e.totalAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          key: ValueKey(Object.hashAll(breakdown.map((e) => e.totalAmount))),
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.resolve(context, AppMotion.slow),
          curve: AppMotion.standard,
          builder: (context, progress, _) => SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 48,
                sections: breakdown
                    .take(8)
                    .map(
                      (slice) => PieChartSectionData(
                        value: slice.totalAmount * progress,
                        color: tryParseColor(slice.color) ?? colors.primary,
                        radius: 22,
                        showTitle: false,
                      ),
                    )
                    .toList(),
              ),
              swapAnimationDuration: AppMotion.resolve(context, AppMotion.slow),
              swapAnimationCurve: AppMotion.standard,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...breakdown.take(8).indexed.map((entry) {
          final (index, slice) = entry;
          final color = tryParseColor(slice.color) ?? colors.primary;
          final percent = total > 0 ? slice.totalAmount / total * 100 : 0.0;
          return AppAnimatedEntrance(
            index: index,
            offset: const Offset(8, 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      slice.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${CurrencyFormatter.format(slice.totalAmount)} • ${percent.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
