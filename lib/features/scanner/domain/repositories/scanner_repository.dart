import '../../../../core/utils/result.dart';
import '../entities/scan_result_entity.dart';

abstract class ScannerRepository {
  /// Runs OCR on an image file and parses the recognized text.
  Future<Result<ScanResultEntity>> scanImage(String imagePath);

  /// Parses raw OCR text into a scan result (pure, testable).
  Future<Result<ScanResultEntity>> parseText(String rawText);
}
