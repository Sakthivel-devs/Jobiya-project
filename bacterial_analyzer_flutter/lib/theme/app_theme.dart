import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00F5C4);
  static const Color secondaryColor = Color(0xFFFF6B6B);
  static const Color accentColor = Color(0xFFFFD93D);
  static const Color tertiaryColor = Color(0xFFC084FC);

  static const Color surfaceColor = Color(0xFF0C1520);
  static const Color surface2Color = Color(0xFF0A1826);
  static const Color borderColor = Color(0xFF1A2D42);
  static const Color textColor = Color(0xFFDDEEFF);
  static const Color text2Color = Color(0xFF7A9AB5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: Colors.white,
        onSurface: Color(0xFF0D1E2E),
        background: Color(0xFFF0F4F8),
      ),
      fontFamily: 'Syne',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0D1E2E),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: surfaceColor,
        onSurface: textColor,
        background: Color(0xFF06090F),
      ),
      fontFamily: 'Syne',
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: surfaceColor,
      ),
      scaffoldBackgroundColor: const Color(0xFF06090F),
    );
  }

  static TextStyle get titleStyle {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      letterSpacing: -1,
      color: primaryColor,
    );
  }

  static TextStyle get subtitleStyle {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: text2Color,
    );
  }

  static TextStyle get bodyStyle {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textColor,
    );
  }

  static TextStyle get monoStyle {
    return const TextStyle(
      fontFamily: 'SpaceMono',
      fontSize: 12,
      color: primaryColor,
    );
  }
}