import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../dashboard_providers.dart';
import '../../domain/entities/analytics_summary_entity.dart';

enum PeriodFilter { week, month, year }

class DashboardPeriodNotifier extends Notifier<PeriodFilter> {
  @override
  PeriodFilter build() => PeriodFilter.month;

  void set(PeriodFilter filter) => state = filter;
}

final dashboardPeriodProvider =
    NotifierProvider<DashboardPeriodNotifier, PeriodFilter>(
      DashboardPeriodNotifier.new,
    );

/// Computes the date range of [filter] in local time.
(DateTime, DateTime) periodRange(PeriodFilter filter) {
  final now = DateTime.now();
  return switch (filter) {
    PeriodFilter.week => (
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7)),
      DateTime(now.year, now.month, now.day),
    ),
    PeriodFilter.month => (
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 0),
    ),
    PeriodFilter.year => (DateTime(now.year, 1, 1), DateTime(now.year, 12, 31)),
  };
}

/// Dashboard aggregates for the selected period (TASKS.md 7C.1).
class DashboardController extends AsyncNotifier<AnalyticsSummaryEntity> {
  @override
  FutureOr<AnalyticsSummaryEntity> build() async {
    final period = ref.watch(dashboardPeriodProvider);
    final (start, end) = periodRange(period);
    final result = await ref
        .watch(getAnalyticsSummaryUsecaseProvider)
        .call(start, end);
    return result.fold((failure) => throw failure, (summary) => summary);
  }
}

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, AnalyticsSummaryEntity>(
      DashboardController.new,
    );
