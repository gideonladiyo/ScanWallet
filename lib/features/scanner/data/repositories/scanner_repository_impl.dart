import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/scan_result_entity.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/ocr_local_datasource.dart';
import '../datasources/ocr_parser_datasource.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  ScannerRepositoryImpl(this._ocr, this._parser);

  final OcrLocalDatasource _ocr;
  final OcrParserDatasource _parser;

  @override
  Future<Result<ScanResultEntity>> scanImage(String imagePath) async {
    try {
      final rawText = await _ocr.recognizeText(imagePath);
      return Success(_parser.parse(rawText));
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<ScanResultEntity>> parseText(String rawText) async {
    return Success(_parser.parse(rawText));
  }
}

final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  return ScannerRepositoryImpl(
    ref.watch(ocrLocalDatasourceProvider),
    ref.watch(ocrParserDatasourceProvider),
  );
});
