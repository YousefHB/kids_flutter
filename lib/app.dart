import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tracing_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/word_game_screen.dart';
import 'screens/reward_screen.dart';
import 'screens/parent_screen.dart';
import 'screens/guided_tracing_screen.dart';
import 'screens/object_hunt_screen.dart';
import 'screens/souvenir_camera_screen.dart';
import 'screens/souvenir_gallery_screen.dart';
import 'screens/sticker_album_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/guided-tracing/:letter',
      builder: (context, state) {
        final letter = state.pathParameters['letter'] ?? 'A';
        return GuidedTracingScreen(letter: letter);
      },
    ),
    GoRoute(
      path: '/tracing/:letter',
      builder: (context, state) {
        final letter = state.pathParameters['letter'] ?? 'A';
        return TracingScreen(letter: letter);
      },
    ),
    GoRoute(
      path: '/scanner/:letter',
      builder: (context, state) {
        final letter = state.pathParameters['letter'] ?? 'A';
        return ScannerScreen(letter: letter);
      },
    ),
    GoRoute(
      path: '/object-hunt/:letter',
      builder: (context, state) {
        final letter = state.pathParameters['letter'] ?? 'A';
        final selectedWord = state.extra as String?;

        return ObjectHuntScreen(
          letter: letter,
          selectedWord: selectedWord,
        );
      },
    ),
    GoRoute(
      path: '/words/:letter',
      builder: (context, state) {
        final letter = state.pathParameters['letter'] ?? 'A';
        final scannedWords = state.extra as List<String>?;
        return WordGameScreen(letter: letter, scannedWords: scannedWords);
      },
    ),
    GoRoute(
      path: '/reward/:letter',
      builder: (context, state) {
        final letter = state.pathParameters['letter'] ?? 'A';
        return RewardScreen(letter: letter);
      },
    ),
    GoRoute(
      path: '/souvenir/:letter',
      builder: (context, state) {
        final letter = state.pathParameters['letter'] ?? 'A';
        return SouvenirCameraScreen(letter: letter);
      },
    ),
    GoRoute(
      path: '/parent',
      builder: (context, state) => const ParentScreen(),
    ),
    GoRoute(
      path: '/souvenirs',
      builder: (context, state) => const SouvenirGalleryScreen(),
    ),
    GoRoute(
      path: '/stickers',
      builder: (context, state) => const StickerAlbumScreen(),
    ),
  ],
);

class LetterQuestApp extends StatelessWidget {
  const LetterQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LetterQuest Kids',
      theme: buildAppTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
