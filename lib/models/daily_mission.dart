// Modèle : mission du jour (lettre à apprendre)
class DailyMission {
  final String letter;
  final DateTime createdAt;
  final bool isCompleted;
  final int starsEarned;

  DailyMission({
    required this.letter,
    required this.createdAt,
    this.isCompleted = false,
    this.starsEarned = 0,
  });

  factory DailyMission.today(String letter) {
    return DailyMission(
      letter: letter,
      createdAt: DateTime.now(),
      isCompleted: false,
      starsEarned: 0,
    );
  }

  DailyMission copyWith({
    String? letter,
    DateTime? createdAt,
    bool? isCompleted,
    int? starsEarned,
  }) {
    return DailyMission(
      letter: letter ?? this.letter,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      starsEarned: starsEarned ?? this.starsEarned,
    );
  }
}
