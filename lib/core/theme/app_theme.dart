import 'package:flutter/material.dart';
import 'gaming_colors.dart';
import 'gaming_theme_extension.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: const <ThemeExtension<dynamic>>[
        GamingThemeExtension(
          xpColor: GamingColors.xpColor,
          xpGradient: GamingColors.xpGradient,
          levelColor: GamingColors.levelColor,
          levelGradient: GamingColors.levelGradient,
          badgeBronze: GamingColors.badgeBronze,
          badgeSilver: GamingColors.badgeSilver,
          badgeGold: GamingColors.badgeGold,
          badgeDiamond: GamingColors.badgeDiamond,
          badgeLegend: GamingColors.badgeLegend,
          badgeBronzeGradient: GamingColors.badgeBronzeGradient,
          badgeSilverGradient: GamingColors.badgeSilverGradient,
          badgeGoldGradient: GamingColors.badgeGoldGradient,
          badgeDiamondGradient: GamingColors.badgeDiamondGradient,
          badgeLegendGradient: GamingColors.badgeLegendGradient,
        ),
      ],
      primaryColor: GamingColors.primary,
      scaffoldBackgroundColor: GamingColors.background,
      colorScheme: const ColorScheme.dark(
        primary: GamingColors.primary,
        secondary: GamingColors.secondary,
        surface: GamingColors.surface,
        error: GamingColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: GamingColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: GamingColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: GamingColors.primary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: GamingColors.surface,
        selectedItemColor: GamingColors.primary,
        unselectedItemColor: GamingColors.textMuted,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: GamingColors.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: GamingColors.surfaceLight,
            width: 1,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: GamingColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: GamingColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: GamingColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: GamingColors.textSecondary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: GamingColors.textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: GamingColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GamingColors.surface,
        hintStyle: const TextStyle(color: GamingColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GamingColors.surfaceLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GamingColors.surfaceLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GamingColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GamingColors.error),
        ),
      ),
    );
  }
}
