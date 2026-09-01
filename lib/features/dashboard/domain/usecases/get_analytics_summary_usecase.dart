import '../../../../core/utils/result.dart';
import '../entities/analytics_summary_entity.dart';
import '../repositories/analytics_repository.dart';

class GetAnalyticsSummaryUsecase {
  const GetAnalyticsSummaryUsecase(this._repository);

  final AnalyticsRepository _repository;

  Future<Result<AnalyticsSummaryEntity>> call(DateTime start, DateTime end) {
    return _repository.getSummary(start, end);
  }
}
