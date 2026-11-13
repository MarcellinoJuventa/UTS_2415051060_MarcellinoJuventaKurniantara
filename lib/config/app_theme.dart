import 'package:flutter/material.dart';

/// Tema visual aplikasi North — Minimalis, Elegan, & Modern.
class AppTheme {
  static const Color primaryEspresso = Color(0xFF231915);
  static const Color accentRoast = Color(0xFF7D5338);
  static const Color warmCaramel = Color(0xFFC08552);
  static const Color creamBackground = Color(0xFFF7F5F2);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color softLatte = Color(0xFFECE6DF);
  static const Color icedBlue = Color(0xFF2B6CB0);
  static const Color hotAmber = Color(0xFFB75D28);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryEspresso,
      primary: primaryEspresso,
      secondary: accentRoast,
      tertiary: warmCaramel,
      surface: cardSurface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: creamBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: cardSurface,
        foregroundColor: primaryEspresso,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: creamBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: softLatte, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryEspresso, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryEspresso,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardSurface,
        selectedColor: primaryEspresso,
        checkmarkColor: Colors.white,
        side: const BorderSide(color: softLatte),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: primaryEspresso,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
