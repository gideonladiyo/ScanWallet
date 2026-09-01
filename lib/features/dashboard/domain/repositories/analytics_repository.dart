import '../../../../core/utils/result.dart';
import '../entities/analytics_summary_entity.dart';

abstract class AnalyticsRepository {
  Future<Result<AnalyticsSummaryEntity>> getSummary(
    DateTime start,
    DateTime end,
  );
}
