import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pokémon GO Dex — Design Token System
/// Palette inspired by the classic Pokédex: deep navy bg, Pokémon Red accent,
/// clean white surfaces and readable type chips.
class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────
  static const pokedexRed    = Color(0xFFCC0000);
  static const pokedexRedDim = Color(0xFF9E0000);
  static const accent        = Color(0xFFFFCB05); // Pikachu yellow
  static const accentDark    = Color(0xFFF0A800);

  // ── Backgrounds ───────────────────────────────────────────
  static const bgDark   = Color(0xFF0A0A0F); // Deep near-black navy
  static const bgMid    = Color(0xFF12121A); // Slightly lighter for grouping
  static const bgCard   = Color(0xFF1C1C26); // Surface for cards
  static const bgSurface = Color(0xFFF7F7FA);

  // ── Text ──────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFF5F5F7); // High contrast off-white
  static const textSecondary = Color(0xFF8E8E93); // Medium contrast grey
  static const textOnDark    = Color(0xFFFFFFFF);
  static const textOnDarkDim = Color(0xFFB0B8C8);

  // ── Divider / border ──────────────────────────────────────
  static const divider = Color(0xFFE5E7EB);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.pokedexRed,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.bgMid,
        onSurface: AppColors.textOnDark,
        error: Color(0xFFEF4444),
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textOnDark,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textOnDark,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textOnDark,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textOnDarkDim,
          letterSpacing: 0.2,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textOnDark,
          letterSpacing: 0.8,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textOnDark,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textOnDark),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
