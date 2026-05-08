import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ObjectDetectionService {
  static final ObjectDetectionService _instance =
      ObjectDetectionService._internal();

  factory ObjectDetectionService() => _instance;

  ObjectDetectionService._internal();

  // Utilisation de l'ImageLabeler qui est plus riche en labels par défaut (400+)
  final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(
      confidenceThreshold: 0.2, // Plus sensible pour les enfants
    ),
  );

  Future<List<ImageLabel>> detectObjects(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final labels = await _imageLabeler.processImage(inputImage);

      debugPrint(
        'Labels ML Kit détectés: ${labels.length}',
      );

      for (var label in labels) {
        debugPrint(' - Label: ${label.label} (${label.confidence})');
      }

      return labels;
    } catch (e) {
      debugPrint('Object detection error: $e');
      return [];
    }
  }

  /// Extrait tous les labels uniques des objets détectés
  List<String> extractLabels(List<ImageLabel> labels) {
    return labels.map((label) => label.label.toLowerCase()).toList();
  }

  void dispose() {
    _imageLabeler.close();
  }
}
