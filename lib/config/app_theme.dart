import 'package:flutter/material.dart';

/// Tema visual aplikasi North dengan nuansa Nordic Specialty Coffee Bar.
class AppTheme {
  static const Color primaryEspresso = Color(0xFF2C1E18);
  static const Color accentRoast = Color(0xFF8C5A3C);
  static const Color warmCaramel = Color(0xFFC88A56);
  static const Color creamBackground = Color(0xFFF9F6F0);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color softLatte = Color(0xFFEDE4D7);
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
        backgroundColor: primaryEspresso,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: softLatte),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: softLatte, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentRoast, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryEspresso,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: softLatte.withValues(alpha: 0.6),
        selectedColor: primaryEspresso,
        labelStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
