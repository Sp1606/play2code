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
}
