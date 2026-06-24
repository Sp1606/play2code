import 'package:flutter/material.dart';

class GamingColors {
  GamingColors._();

  // Dark obsidian/space background
  static const Color background = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceLight = Color(0xFF202736);

  // Neon gaming accents
  static const Color primary = Color(0xFF00F0FF); // Cyber Cyan
  static const Color secondary = Color(0xFFB026FF); // Neon Purple
  static const Color accent = Color(0xFF39FF14); // Cyber Lime
  static const Color warning = Color(0xFFFF9F00); // Neon Orange
  static const Color error = Color(0xFFFF0055); // Neon Red

  // Text colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Glow gradients
  static const LinearGradient cyberGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [accent, Color(0xFF00B0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Design System - XP Progression Colors & Gradients
  static const Color xpColor = Color(0xFF00FFCC);
  static const LinearGradient xpGradient = LinearGradient(
    colors: [Color(0xFF00F0FF), Color(0xFF00FFCC)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Design System - Level Highlights
  static const Color levelColor = Color(0xFFFFD700);
  static const LinearGradient levelGradient = LinearGradient(
    colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Design System - Badge Tier Colors & Gradients
  static const Color badgeBronze = Color(0xFFCD7F32);
  static const Color badgeSilver = Color(0xFFC0C0C0);
  static const Color badgeGold = Color(0xFFFFD700);
  static const Color badgeDiamond = Color(0xFFB9F2FF);
  static const Color badgeLegend = Color(0xFFFF007F);

  static const LinearGradient badgeBronzeGradient = LinearGradient(
    colors: [Color(0xFF8B4513), Color(0xFFCD7F32)],
  );
  static const LinearGradient badgeSilverGradient = LinearGradient(
    colors: [Color(0xFF708090), Color(0xFFC0C0C0)],
  );
  static const LinearGradient badgeGoldGradient = LinearGradient(
    colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
  );
  static const LinearGradient badgeDiamondGradient = LinearGradient(
    colors: [Color(0xFF00BFFF), Color(0xFFB9F2FF)],
  );
  static const LinearGradient badgeLegendGradient = LinearGradient(
    colors: [Color(0xFF8B008B), Color(0xFFFF007F)],
  );
}
