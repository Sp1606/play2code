import 'package:flutter/material.dart';

class GamingColors {
  GamingColors._();

  // Light Cyber Gaming palette
  static const Color background = Color(0xFFF8FAFC); // Very light slate
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceLight = Color(0xFFE2E8F0); // Border slate

  // Neon gaming accents (adapted for light background contrast)
  static const Color primary = Color(0xFF0284C7); // Vibrant sky blue
  static const Color secondary = Color(0xFF7C3AED); // Vivid violet
  static const Color accent = Color(0xFF059669); // Emerald green
  static const Color warning = Color(0xFFD97706); // Darker amber/orange
  static const Color error = Color(0xFFDC2626); // Bright crimson

  // Text colors (high contrast for light background)
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Glow gradients
  static const LinearGradient cyberGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [accent, Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Design System - XP Progression Colors & Gradients
  static const Color xpColor = Color(0xFF0D9488); // Darker Teal
  static const LinearGradient xpGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF0D9488)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Design System - Level Highlights
  static const Color levelColor = Color(0xFFD97706);
  static const LinearGradient levelGradient = LinearGradient(
    colors: [Color(0xFFEA580C), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Design System - Badge Tier Colors & Gradients
  static const Color badgeBronze = Color(0xFFB45309); // bronze tint
  static const Color badgeSilver = Color(0xFF64748B); // silver tint
  static const Color badgeGold = Color(0xFFB45309); // gold tint
  static const Color badgeDiamond = Color(0xFF0369A1); // diamond blue
  static const Color badgeLegend = Color(0xFFBE123C); // legend red

  static const LinearGradient badgeBronzeGradient = LinearGradient(
    colors: [Color(0xFF78350F), Color(0xFFB45309)],
  );
  static const LinearGradient badgeSilverGradient = LinearGradient(
    colors: [Color(0xFF475569), Color(0xFF94A3B8)],
  );
  static const LinearGradient badgeGoldGradient = LinearGradient(
    colors: [Color(0xFFCA8A04), Color(0xFFF59E0B)],
  );
  static const LinearGradient badgeDiamondGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
  );
  static const LinearGradient badgeLegendGradient = LinearGradient(
    colors: [Color(0xFF9D174D), Color(0xFFEC4899)],
  );
}
