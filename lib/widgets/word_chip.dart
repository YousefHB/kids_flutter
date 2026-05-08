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
