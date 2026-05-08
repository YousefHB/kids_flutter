// Modèle : un mot appris avec sa date et son statut
import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 0)
class WordEntry extends HiveObject {
  @HiveField(0)
  final String word;

  @HiveField(1)
  final String letter;

  @HiveField(2)
  final DateTime learnedAt;

  @HiveField(3)
  final bool isCorrect;

  WordEntry({
    required this.word,
    required this.letter,
    required this.learnedAt,
    required this.isCorrect,
  });

  factory WordEntry.create(String word, String letter) {
    return WordEntry(
      word: word,
      letter: letter,
      learnedAt: DateTime.now(),
      isCorrect: true,
    );
  }
}
