// Service ML Kit OCR : reconnaît le texte photographié
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';

class OcrService {
  static final OcrService _instance = OcrService._internal();
  late TextRecognizer _textRecognizer;

  factory OcrService() => _instance;

  OcrService._internal() {
    _init();
  }

  void _init() {
    // ML Kit reconnaît le texte dans les images
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  Future<String> recognizeFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final words = <String>[];
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          for (final element in line.elements) {
            words.add(element.text);
          }
        }
      }

      return words.join(' ');
    } catch (e) {
      debugPrint('OCR error: $e');
      return '';
    }
  }

  void dispose() {
    try {
      _textRecognizer.close();
    } catch (e) {
      debugPrint('OCR dispose error: $e');
    }
  }
}
