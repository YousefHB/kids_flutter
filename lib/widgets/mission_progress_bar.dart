import 'package:flutter/material.dart';
import '../theme.dart';

class MissionProgressBar extends StatelessWidget {
  final int currentStep;

  const MissionProgressBar({
    required this.currentStep,
    super.key,
  });

  static const List<String> _steps = [
    'Trace',
    'Texte',
    'Mots',
    'Objet',
    'Bravo',
  ];

  static const List<IconData> _icons = [
    Icons.edit_rounded,
    Icons.camera_alt_rounded,
    Icons.text_fields_rounded,
    Icons.search_rounded,
    Icons.star_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorders.radius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_steps.length, (index) {
          final isDone = index < currentStep;
          final isCurrent = index == currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isCurrent ? 44 : 36,
                        height: isCurrent ? 44 : 36,
                        decoration: BoxDecoration(
                          color: isDone || isCurrent
                              ? AppColors.brightYellow
                              : AppColors.lightGray,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrent
                                ? AppColors.magicPurple
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          isDone ? Icons.check_rounded : _icons[index],
                          size: 22,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _steps[index],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight:
                                  isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: Colors.black87,
                            ),
                      ),
                    ],
                  ),
                ),
                if (index != _steps.length - 1)
                  Container(
                    width: 20,
                    height: 4,
                    decoration: BoxDecoration(
                      color: index < currentStep
                          ? AppColors.successGreen
                          : Colors.black12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
