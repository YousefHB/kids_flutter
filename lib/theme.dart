// Thème visuel : couleurs pastel enfant-friendly, typographie Nunito
import 'package:flutter/material.dart';

class AppColors {
  static const Color skyBlue = Color(0xFFA7D8FF);
  static const Color brightYellow = Color(0xFFFFD93D);
  static const Color successGreen = Color(0xFF6BCB77);
  static const Color softRed = Color(0xFFFF6B6B);
  static const Color magicPurple = Color(0xFFB39DDB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color softBlue = Color(0xFFD1E4FF);
}

class AppBorders {
  static const double radius = 20;
  static const double smallRadius = 12;
}

class AppSizes {
  static const double buttonHeight = 50;
  static const double buttonWidth = 100;
  static const double smallButtonHeight = 40;
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.magicPurple,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.skyBlue,
    fontFamily: 'Nunito',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brightYellow,
        foregroundColor: Colors.black87,
        minimumSize: const Size(AppSizes.buttonWidth, 52), // Taille plus normale
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.black.withOpacity(0.05), width: 2),
        ),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.3),
        textStyle: const TextStyle(
          fontSize: 18, // Un peu plus petit
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          fontFamily: 'Nunito',
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.magicPurple, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorders.smallRadius),
        ),
        minimumSize: const Size(100, AppSizes.smallButtonHeight),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.skyBlue,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      iconTheme: IconThemeData(color: Colors.black87),
    ),
  );
}
