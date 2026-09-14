import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// On-device OCR service using Google ML Kit Text Recognition.
/// Operates 100% offline with zero cloud requests.
class OcrService {
  OcrService._();
  static final OcrService instance = OcrService._();

  TextRecognizer? _recognizer;

  TextRecognizer get recognizer {
    _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _recognizer!;
  }

  /// Extracts plain text from an image file on disk.
  Future<String> extractTextFromImagePath(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await recognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('ML Kit OCR error: $e');
      rethrow;
    }
  }

  /// Disposes of the underlying ML Kit recognizer resources.
  void dispose() {
    _recognizer?.close();
    _recognizer = null;
  }
}
