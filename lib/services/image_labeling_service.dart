import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ImageLabelingService {
  static final ImageLabelingService _instance =
      ImageLabelingService._internal();

  factory ImageLabelingService() => _instance;

  ImageLabelingService._internal();

  final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(
      confidenceThreshold: 0.55,
    ),
  );

  Future<List<ImageLabel>> labelImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final labels = await _imageLabeler.processImage(inputImage);

      debugPrint(
        'Labels ML Kit: ${labels.map((e) => '${e.label} ${e.confidence}').toList()}',
      );

      return labels;
    } catch (e) {
      debugPrint('Image labeling error: $e');
      return [];
    }
  }

  List<String> extractLabelTexts(List<ImageLabel> labels) {
    return labels.map((label) => label.label.toLowerCase()).toList();
  }

  void dispose() {
    _imageLabeler.close();
  }
}
