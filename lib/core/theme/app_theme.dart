import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color.fromARGB(255, 243, 144, 39);
  static const _accentColor = Color(0xFFA29BFE);
  static const _surfaceDark = Color(0xFF1A1A2E);
  static const _backgroundDark = Color.fromARGB(255, 0, 0, 12);
  static const _cardDark = Color(0xFF222240);
  static const _textPrimary = Color(0xFFF5F5F5);
  static const _textSecondary = Color(0xFFB0B0C8);
  static const _errorRed = Color(0xFFFF6B6B);

  static Color get primary => _primaryColor;
  static Color get accent => _accentColor;
  static Color get surface => _surfaceDark;
  static Color get background => _backgroundDark;
  static Color get card => _cardDark;
  static Color get textPrimary => _textPrimary;
  static Color get textSecondary => _textSecondary;
  static Color get errorRed => _errorRed;

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _backgroundDark,
      primaryColor: _primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: _primaryColor,
        secondary: _accentColor,
        surface: _surfaceDark,
        error: _errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _backgroundDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: _textPrimary),
      ),
      cardTheme: CardThemeData(
        color: _cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: _textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: _textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: _textSecondary, fontSize: 13),
        bodySmall: TextStyle(color: _textSecondary, fontSize: 12),
        labelSmall: TextStyle(
          color: _accentColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
