import 'package:shared_preferences/shared_preferences.dart';

class ProgressionService {
  static const String _unlockedLevelKey = 'unlocked_level_index';
  static const String _stickersKey = 'collected_stickers';
  
  static const List<String> alphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  /// Récupère l'index de la dernière lettre débloquée (0 pour 'A')
  static Future<int> getUnlockedLevelIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_unlockedLevelKey) ?? 0;
  }

  /// Débloque la lettre suivante
  static Future<void> unlockNextLevel(String currentLetter) async {
    final currentIndex = alphabet.indexOf(currentLetter.toUpperCase());
    final unlockedIndex = await getUnlockedLevelIndex();
    
    if (currentIndex == unlockedIndex && unlockedIndex < alphabet.length - 1) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_unlockedLevelKey, unlockedIndex + 1);
    }
  }

  /// Vérifie si une lettre est débloquée
  static Future<bool> isLetterUnlocked(String letter) async {
    final index = alphabet.indexOf(letter.toUpperCase());
    final unlockedIndex = await getUnlockedLevelIndex();
    return index <= unlockedIndex;
  }

  /// --- Système de Stickers ---

  static Future<void> collectSticker(String objectLabel) async {
    final prefs = await SharedPreferences.getInstance();
    final stickers = prefs.getStringList(_stickersKey) ?? [];
    if (!stickers.contains(objectLabel)) {
      stickers.add(objectLabel);
      await prefs.setStringList(_stickersKey, stickers);
    }
  }

  static Future<List<String>> getCollectedStickers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_stickersKey) ?? [];
  }
}
