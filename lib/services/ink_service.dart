// ink_service.dart - Version corrigée
import 'dart:async';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class InkService {
  DigitalInkRecognizer? _recognizer;
  final _modelManager = DigitalInkRecognizerModelManager();
  bool _initialized = false;

  // Singleton pour éviter de recréer le recognizer
  static final InkService _instance = InkService._internal();
  factory InkService() => _instance;
  InkService._internal() {
    _init();
  }

  Future<void> _init() async {
    try {
      const lang = 'en-US';
      // Télécharger le modèle si absent
      final downloaded = await _modelManager.isModelDownloaded(lang);
      if (!downloaded) {
        await _modelManager.downloadModel(lang);
      }
      _recognizer = DigitalInkRecognizer(languageCode: lang);
      _initialized = true;
    } catch (e) {
      print('InkService init error: $e');
    }
  }

  Future<String> recognizeLetter(List<dynamic> strokes) async {
    if (!_initialized || _recognizer == null || strokes.isEmpty) return '';

    try {
      final ink = Ink();
      // Timestamp réel en millisecondes
      final baseTime = DateTime.now().millisecondsSinceEpoch;

      for (int si = 0; si < strokes.length; si++) {
        final stroke = strokes[si];
        if (stroke is! List || stroke.isEmpty) continue;

        final points = <StrokePoint>[];
        for (int pi = 0; pi < stroke.length; pi++) {
          final point = stroke[pi];
          // Support Offset et Map {dx, dy}
          double? dx, dy;
          if (point.runtimeType.toString().contains('Offset')) {
            dx = (point as dynamic).dx as double;
            dy = (point as dynamic).dy as double;
          } else if (point is Map) {
            dx = (point['dx'] as num?)?.toDouble();
            dy = (point['dy'] as num?)?.toDouble();
          }
          if (dx == null || dy == null) continue;

          // Espacement réaliste : ~16ms entre points (60fps)
          points.add(StrokePoint(
            x: dx,
            y: dy,
            t: baseTime + (si * 1000) + (pi * 16),
          ));
        }

        if (points.isNotEmpty) {
          final s = Stroke()..points.addAll(points);
          ink.strokes.add(s);
        }
      }

      if (ink.strokes.isEmpty) return '';
      final candidates = await _recognizer!.recognize(ink);
      if (candidates.isEmpty) return '';

      print('Candidates: ${candidates.take(5).map((c) => c.text).toList()}');
      return candidates.first.text.toUpperCase();
    } catch (e) {
      print('Recognition error: $e');
      return '';
    }
  }

  void dispose() {
    _recognizer?.close();
  }
}
