import 'package:flutter/material.dart';

/// Application theme configuration
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF183D3D), // Dark teal background like map at night or menu
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00BFA5), // Teal accent
        primary: const Color(0xFF00BFA5),
        secondary: const Color(0xFF4FC3F7),
        surface: Colors.white,
        background: const Color(0xFF183D3D),
        brightness: Brightness.light,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'SansSerif',
          fontWeight: FontWeight.bold,
          color: Color(0xFF183D3D),
        ),
        bodyLarge: TextStyle(
          fontFamily: 'SansSerif',
          color: Color(0xFF333333),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SansSerif',
          color: Color(0xFF333333),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }

  /// Dark theme configuration (optional, for future use)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00BFA5),
        brightness: Brightness.dark,
      ),
    );
  }
}
