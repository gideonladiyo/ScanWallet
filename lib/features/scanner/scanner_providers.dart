import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories/scanner_repository_impl.dart';
import 'domain/usecases/scan_receipt_usecase.dart';

final scanReceiptUsecaseProvider = Provider<ScanReceiptUsecase>(
  (ref) => ScanReceiptUsecase(ref.watch(scannerRepositoryProvider)),
);
