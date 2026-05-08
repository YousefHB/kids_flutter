// Widget : chip animée pour les mots (vert/rouge/neutre)
import 'package:flutter/material.dart';
import '../theme.dart';

enum WordStatus { correct, wrong, neutral }

class WordChip extends StatelessWidget {
  final String word;
  final WordStatus status;
  final VoidCallback onTap;
  final bool isSelected;

  const WordChip({
    required this.word,
    required this.status,
    required this.onTap,
    this.isSelected = false,
    super.key,
  });

  Color get _backgroundColor {
    return switch (status) {
      WordStatus.correct => AppColors.successGreen.withOpacity(0.3),
      WordStatus.wrong => AppColors.softRed.withOpacity(0.3),
      WordStatus.neutral => AppColors.magicPurple.withOpacity(0.2),
    };
  }

  Color get _borderColor {
    return switch (status) {
      WordStatus.correct => AppColors.successGreen,
      WordStatus.wrong => AppColors.softRed,
      WordStatus.neutral => AppColors.magicPurple,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _backgroundColor,
          border: Border.all(color: _borderColor, width: 2),
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _borderColor.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Text(
          word,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

// Widget : compteur d'étoiles pour la progression
class StarCounter extends StatelessWidget {
  final int starCount;
  final int maxStars;

  const StarCounter({
    super.key,
    required this.starCount,
    required this.maxStars,
  });

  @override
  Widget build(BuildContext context) {
    // Si le nombre d'étoiles est petit (ex: progression d'une lettre), on affiche les icônes
    if (maxStars <= 5) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          maxStars,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              index < starCount ? Icons.star : Icons.star_border,
              color: AppColors.brightYellow,
              size: 32,
            ),
          ),
        ),
      );
    }

    // Sinon (ex: total du profil), on affiche un compteur numérique stylisé
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.brightYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: AppColors.brightYellow,
            size: 30,
          ),
          const SizedBox(width: 8),
          Text(
            '$starCount / $maxStars',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.magicPurple,
                ),
          ),
        ],
      ),
    );
  }
}
