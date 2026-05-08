// Écran récompense : célébration avec étoiles
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../theme.dart';
import '../providers/profile_provider.dart';
import '../providers/mission_provider.dart';
import '../widgets/lettrobot_avatar.dart';
import '../widgets/star_counter.dart';
import '../widgets/mission_progress_bar.dart';

class RewardScreen extends StatefulWidget {
  final String letter;

  const RewardScreen({required this.letter, super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveReward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.brightYellow.withOpacity(0.3),
              AppColors.skyBlue,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: MissionProgressBar(currentStep: 3),
                ),
                const SizedBox(height: 24),
                const LettrobotAvatar(message: '🎉 Bravo !'),
                const SizedBox(height: 32),
                StarCounter(
                  starCount: STARS_PER_LETTER,
                  maxStars: STARS_PER_LETTER,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppBorders.radius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tu as appris la lettre ${widget.letter} !',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '+$STARS_PER_LETTER étoiles',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continuer'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/souvenir/${widget.letter}'),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Photo souvenir'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveReward() async {
    if (_saved) return;
    _saved = true;

    await context
        .read<ProfileProvider>()
        .completeLetterWithStars(widget.letter);
    context.read<MissionProvider>().completeMission();
  }
}
