import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories/analytics_repository_impl.dart';
import 'domain/usecases/get_analytics_summary_usecase.dart';

final getAnalyticsSummaryUsecaseProvider = Provider<GetAnalyticsSummaryUsecase>(
  (ref) => GetAnalyticsSummaryUsecase(ref.watch(analyticsRepositoryProvider)),
);
