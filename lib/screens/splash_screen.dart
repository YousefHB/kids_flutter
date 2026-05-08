import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../services/sound_service.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final TtsService _ttsService = TtsService();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _startApp();
  }

  Future<void> _startApp() async {
    _controller.forward();
    
    // Jouer le son enfantin
    Future.delayed(const Duration(milliseconds: 500), () {
      SoundService.playEffect('welcome.mp3');
    });

    // Charger les données en arrière-plan
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    
    await Future.wait([
      authProvider.loadAuthState(),
      profileProvider.loadProfile(),
      Future.delayed(const Duration(seconds: 3)), // Temps minimum pour le splash
    ]);

    if (!mounted) return;

    if (authProvider.isLoggedIn && profileProvider.profile != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.magicPurple.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🦁',
                      style: TextStyle(fontSize: 100),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    'LetterQuest',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 42,
                      color: Colors.white,
                      shadows: [
                        const Shadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 10),
                      ],
                    ),
                  ),
                  Text(
                    'KIDS',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 56,
                      color: AppColors.brightYellow,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        const Shadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
