import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/analytics_summary_entity.dart';

/// Total balance + period income/expense summary (TASKS.md 7C.3).
class BalanceSummaryCard extends StatefulWidget {
  const BalanceSummaryCard({super.key, required this.summary});

  final AnalyticsSummaryEntity summary;

  @override
  State<BalanceSummaryCard> createState() => _BalanceSummaryCardState();
}

class _BalanceSummaryCardState extends State<BalanceSummaryCard> {
  double _previousBalance = 0;
  double _previousIncome = 0;
  double _previousExpense = 0;

  @override
  void didUpdateWidget(covariant BalanceSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _previousBalance = oldWidget.summary.totalBalance;
    _previousIncome = oldWidget.summary.totalIncome;
    _previousExpense = oldWidget.summary.totalExpense;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final summary = widget.summary;
    final net = summary.totalIncome - summary.totalExpense;
    final previousNet = _previousIncome - _previousExpense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.totalBalance,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            _AnimatedAmount(
              begin: _previousBalance,
              end: summary.totalBalance,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.incomeThisPeriod,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      _AnimatedAmount(
                        begin: _previousIncome,
                        end: summary.totalIncome,
                        prefix: '+',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.expenseThisPeriod,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      _AnimatedAmount(
                        begin: _previousExpense,
                        end: summary.totalExpense,
                        prefix: '-',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.netFlow,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      _AnimatedAmount(
                        begin: previousNet.abs(),
                        end: net.abs(),
                        prefix: net >= 0 ? '+' : '-',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: net >= 0 ? colors.success : colors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedAmount extends StatelessWidget {
  const _AnimatedAmount({
    required this.begin,
    required this.end,
    required this.style,
    this.prefix = '',
  });

  final double begin;
  final double end;
  final TextStyle? style;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: AppMotion.resolve(context, AppMotion.slow),
      curve: AppMotion.standard,
      builder: (context, value, _) => Text(
        '$prefix${CurrencyFormatter.format(value)}',
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
