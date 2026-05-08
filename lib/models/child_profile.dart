import '../constants.dart';

class ChildProfile {
  final String name;
  final int age;
  final DateTime createdAt;
  final Map<String, bool> lettersCompleted;
  final int totalStars;
  final String mascotId;

  ChildProfile({
    required this.name,
    required this.age,
    required this.createdAt,
    required this.lettersCompleted,
    required this.totalStars,
    required this.mascotId,
  });

  factory ChildProfile.newChild(String name, int age, String mascotId) {
    return ChildProfile(
      name: name,
      age: age,
      createdAt: DateTime.now(),
      lettersCompleted: {
        for (final letter in ALPHABET) letter: false,
      },
      totalStars: 0,
      mascotId: mascotId,
    );
  }

  int get completedLettersCount {
    return lettersCompleted.values.where((value) => value).length;
  }

  int get completionPercentage {
    return ((completedLettersCount / TOTAL_LETTERS) * 100).round();
  }

  ChildProfile copyWith({
    String? name,
    int? age,
    DateTime? createdAt,
    Map<String, bool>? lettersCompleted,
    int? totalStars,
    String? mascotId,
  }) {
    return ChildProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
      lettersCompleted: lettersCompleted ?? this.lettersCompleted,
      totalStars: totalStars ?? this.totalStars,
      mascotId: mascotId ?? this.mascotId,
    );
  }

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      lettersCompleted: Map<String, bool>.from(
        json['lettersCompleted'] as Map? ??
            {
              for (final letter in ALPHABET) letter: false,
            },
      ),
      totalStars: json['totalStars'] as int? ?? 0,
      mascotId: json['mascotId'] as String? ?? 'lion',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'createdAt': createdAt.toIso8601String(),
      'lettersCompleted': lettersCompleted,
      'totalStars': totalStars,
      'mascotId': mascotId,
    };
  }
}
