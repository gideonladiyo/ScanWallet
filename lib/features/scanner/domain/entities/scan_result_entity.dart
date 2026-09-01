import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../transactions/domain/entities/transaction_entity.dart';

part 'scan_result_entity.freezed.dart';

/// Parsed OCR result shown in the Quick Edit Form. Nullable fields signal
/// "not detected — user fills manually" (PRD.md §6.4 fallback rule).
@freezed
class ScanResultEntity with _$ScanResultEntity {
  const factory ScanResultEntity({
    double? amount,
    DateTime? date,
    String? merchant,
    TransactionType? type,
    String? source,
    @Default('') String rawText,
  }) = _ScanResultEntity;
}
