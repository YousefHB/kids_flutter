import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  OnDeviceTranslator? _translator;
  final _modelManager = OnDeviceTranslatorModelManager();
  final Completer<void> _initCompleter = Completer<void>();
  bool _isInitializing = false;

  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  Future<void> _ensureInitialized() async {
    if (_initCompleter.isCompleted) return;
    if (_isInitializing) return _initCompleter.future;

    _isInitializing = true;
    try {
      debugPrint('TranslationService: Initializing models...');
      for (final lang in [
        TranslateLanguage.french,
        TranslateLanguage.arabic,
      ]) {
        final downloaded = await _modelManager.isModelDownloaded(lang.bcpCode);
        if (!downloaded) {
          debugPrint('Downloading ${lang.name} model...');
          await _modelManager.downloadModel(lang.bcpCode);
        }
      }

      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.french,
        targetLanguage: TranslateLanguage.arabic,
      );
      debugPrint('TranslationService ready');
      _initCompleter.complete();
    } catch (e) {
      debugPrint('TranslationService init error: $e');
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e);
      }
    } finally {
      _isInitializing = false;
    }
  }

  final Map<String, String> _cache = {};

  Future<String> translate(String word) async {
    await _ensureInitialized().catchError((e) => null);
    if (_translator == null) return '—';
    if (_cache.containsKey(word)) return _cache[word]!;
    
    try {
      final result = await _translator!.translateText(word);
      _cache[word] = result;
      return result;
    } catch (e) {
      debugPrint('Translation error ($word): $e');
      return '—';
    }
  }

  Future<Map<String, String>> translateAll(List<String> words) async {
    final results = await Future.wait(
      words.map((w) async => MapEntry(w, await translate(w))),
    );
    return Map.fromEntries(results);
  }

  void dispose() {
    _translator?.close();
  }
}
