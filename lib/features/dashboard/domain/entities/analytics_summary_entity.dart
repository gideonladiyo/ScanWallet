import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_summary_entity.freezed.dart';

/// One slice of the expense-per-category breakdown.
@freezed
class CategoryBreakdownEntity with _$CategoryBreakdownEntity {
  const factory CategoryBreakdownEntity({
    required String categoryId,
    required String name,
    String? color,
    required double totalAmount,
    required int transactionCount,
  }) = _CategoryBreakdownEntity;
}

/// Dashboard aggregate for a period (PLANNING.md §5.1).
@freezed
class AnalyticsSummaryEntity with _$AnalyticsSummaryEntity {
  const factory AnalyticsSummaryEntity({
    required double totalBalance,
    required double totalIncome,
    required double totalExpense,
    required DateTime periodStart,
    required DateTime periodEnd,
    @Default([]) List<CategoryBreakdownEntity> breakdown,
  }) = _AnalyticsSummaryEntity;
}
