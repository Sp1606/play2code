import 'package:flutter/material.dart';

class GamingColors {
  GamingColors._();

  // Dark Cyber Gaming palette
  static const Color background = Color(0xFF050505); // Pure dark
  static const Color surface = Color(0xFF111111); // Dark grey surface
  static const Color surfaceLight = Color(0xFF1F2937); // Border grey

  // Neon gaming accents
  static const Color primary = Color(0xFF10B981); // Neon Green
  static const Color secondary = Color(0xFF3B82F6); // Neon Blue
  static const Color accent = Color(0xFF8B5CF6); // Neon Purple
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red

  // Text colors
  static const Color textPrimary = Color(0xFFF3F4F6); // Gray 100
  static const Color textSecondary = Color(0xFF9CA3AF); // Gray 400
  static const Color textMuted = Color(0xFF4B5563); // Gray 600

  // Glow gradients
  static const LinearGradient cyberGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [primary, Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Design System - XP Progression Colors & Gradients
  static const Color xpColor = primary;
  static const LinearGradient xpGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Design System - Level Highlights
  static const Color levelColor = secondary;
  static const LinearGradient levelGradient = LinearGradient(
    colors: [secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Design System - Badge Tier Colors & Gradients
  static const Color badgeBronze = Color(0xFFB45309);
  static const Color badgeSilver = Color(0xFF64748B);
  static const Color badgeGold = Color(0xFFD97706);
  static const Color badgeDiamond = secondary;
  static const Color badgeLegend = primary;

  static const LinearGradient badgeBronzeGradient = LinearGradient(
    colors: [Color(0xFF78350F), Color(0xFFB45309)],
  );
  static const LinearGradient badgeSilverGradient = LinearGradient(
    colors: [Color(0xFF475569), Color(0xFF94A3B8)],
  );
  static const LinearGradient badgeGoldGradient = LinearGradient(
    colors: [Color(0xFFB45309), Color(0xFFF59E0B)],
  );
  static const LinearGradient badgeDiamondGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), secondary],
  );
  static const LinearGradient badgeLegendGradient = LinearGradient(
    colors: [Color(0xFF064E3B), primary],
  );
}
