class SouvenirPhoto {
  final String id;
  final String letter;
  final String imagePath;
  final DateTime createdAt;

  const SouvenirPhoto({
    required this.id,
    required this.letter,
    required this.imagePath,
    required this.createdAt,
  });

  factory SouvenirPhoto.fromJson(Map<String, dynamic> json) {
    return SouvenirPhoto(
      id: json['id'] as String,
      letter: json['letter'] as String,
      imagePath: json['imagePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'letter': letter,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
