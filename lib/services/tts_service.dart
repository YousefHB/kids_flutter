import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  bool _initialized = false;

  TtsService();

  Future<void> _initTts() async {
    if (_initialized) return;

    try {
      await _flutterTts.setLanguage('fr-FR');
      await _flutterTts.setPitch(1.35);
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);

      // Important Android
      await _flutterTts.awaitSpeakCompletion(false);

      _initialized = true;
      debugPrint('TTS initialized');
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  Future<void> speak(String text) async {
    try {
      await _initTts();

      await _flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 100));

      final result = await _flutterTts.speak(text);
      debugPrint('TTS speak result: $result');
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  Future<void> speakHappy(String text) async {
    try {
      await _initTts();

      await _flutterTts.stop();
      await _flutterTts.setPitch(1.45);
      await _flutterTts.setSpeechRate(0.48);

      await Future.delayed(const Duration(milliseconds: 100));
      await _flutterTts.speak(text);

      await _flutterTts.setPitch(1.35);
      await _flutterTts.setSpeechRate(0.45);
    } catch (e) {
      debugPrint('TTS happy error: $e');
    }
  }

  Future<void> speakSlow(String text) async {
    try {
      await _initTts();

      await _flutterTts.stop();
      await _flutterTts.setPitch(1.25);
      await _flutterTts.setSpeechRate(0.35);

      await Future.delayed(const Duration(milliseconds: 100));
      await _flutterTts.speak(text);

      await _flutterTts.setPitch(1.35);
      await _flutterTts.setSpeechRate(0.45);
    } catch (e) {
      debugPrint('TTS slow error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }
}
