import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// On-device ML Kit text recognition wrapper (PRD.md §4.2 — offline, no
/// third-party cloud OCR).
class OcrLocalDatasource {
  Future<String> recognizeText(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognized = await recognizer.processImage(inputImage);
      return recognized.text;
    } finally {
      await recognizer.close();
    }
  }
}

final ocrLocalDatasourceProvider = Provider<OcrLocalDatasource>((ref) {
  return OcrLocalDatasource();
});
