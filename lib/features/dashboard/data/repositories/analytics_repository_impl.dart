import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/analytics_summary_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl(this._datasource);

  final AnalyticsRemoteDatasource _datasource;

  @override
  Future<Result<AnalyticsSummaryEntity>> getSummary(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return Success(await _datasource.getSummary(start, end));
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl(ref.watch(analyticsRemoteDatasourceProvider));
});
