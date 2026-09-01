import '../../../../core/utils/result.dart';
import '../entities/scan_result_entity.dart';
import '../repositories/scanner_repository.dart';

class ScanReceiptUsecase {
  const ScanReceiptUsecase(this._repository);

  final ScannerRepository _repository;

  Future<Result<ScanResultEntity>> call(String imagePath) {
    return _repository.scanImage(imagePath);
  }

  Future<Result<ScanResultEntity>> parseText(String rawText) {
    return _repository.parseText(rawText);
  }
}
