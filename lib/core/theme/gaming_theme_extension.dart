import 'package:flutter/material.dart';

class GamingThemeExtension extends ThemeExtension<GamingThemeExtension> {
  final Color? xpColor;
  final LinearGradient? xpGradient;
  final Color? levelColor;
  final LinearGradient? levelGradient;
  
  final Color? badgeBronze;
  final Color? badgeSilver;
  final Color? badgeGold;
  final Color? badgeDiamond;
  final Color? badgeLegend;

  final LinearGradient? badgeBronzeGradient;
  final LinearGradient? badgeSilverGradient;
  final LinearGradient? badgeGoldGradient;
  final LinearGradient? badgeDiamondGradient;
  final LinearGradient? badgeLegendGradient;

  const GamingThemeExtension({
    required this.xpColor,
    required this.xpGradient,
    required this.levelColor,
    required this.levelGradient,
    required this.badgeBronze,
    required this.badgeSilver,
    required this.badgeGold,
    required this.badgeDiamond,
    required this.badgeLegend,
    required this.badgeBronzeGradient,
    required this.badgeSilverGradient,
    required this.badgeGoldGradient,
    required this.badgeDiamondGradient,
    required this.badgeLegendGradient,
  });

  @override
  ThemeExtension<GamingThemeExtension> copyWith({
    Color? xpColor,
    LinearGradient? xpGradient,
    Color? levelColor,
    LinearGradient? levelGradient,
    Color? badgeBronze,
    Color? badgeSilver,
    Color? badgeGold,
    Color? badgeDiamond,
    Color? badgeLegend,
    LinearGradient? badgeBronzeGradient,
    LinearGradient? badgeSilverGradient,
    LinearGradient? badgeGoldGradient,
    LinearGradient? badgeDiamondGradient,
    LinearGradient? badgeLegendGradient,
  }) {
    return GamingThemeExtension(
      xpColor: xpColor ?? this.xpColor,
      xpGradient: xpGradient ?? this.xpGradient,
      levelColor: levelColor ?? this.levelColor,
      levelGradient: levelGradient ?? this.levelGradient,
      badgeBronze: badgeBronze ?? this.badgeBronze,
      badgeSilver: badgeSilver ?? this.badgeSilver,
      badgeGold: badgeGold ?? this.badgeGold,
      badgeDiamond: badgeDiamond ?? this.badgeDiamond,
      badgeLegend: badgeLegend ?? this.badgeLegend,
      badgeBronzeGradient: badgeBronzeGradient ?? this.badgeBronzeGradient,
      badgeSilverGradient: badgeSilverGradient ?? this.badgeSilverGradient,
      badgeGoldGradient: badgeGoldGradient ?? this.badgeGoldGradient,
      badgeDiamondGradient: badgeDiamondGradient ?? this.badgeDiamondGradient,
      badgeLegendGradient: badgeLegendGradient ?? this.badgeLegendGradient,
    );
  }

  @override
  ThemeExtension<GamingThemeExtension> lerp(
    covariant ThemeExtension<GamingThemeExtension>? other,
    double t,
  ) {
    if (other is! GamingThemeExtension) {
      return this;
    }
    return GamingThemeExtension(
      xpColor: Color.lerp(xpColor, other.xpColor, t),
      xpGradient: LinearGradient.lerp(xpGradient, other.xpGradient, t),
      levelColor: Color.lerp(levelColor, other.levelColor, t),
      levelGradient: LinearGradient.lerp(levelGradient, other.levelGradient, t),
      badgeBronze: Color.lerp(badgeBronze, other.badgeBronze, t),
      badgeSilver: Color.lerp(badgeSilver, other.badgeSilver, t),
      badgeGold: Color.lerp(badgeGold, other.badgeGold, t),
      badgeDiamond: Color.lerp(badgeDiamond, other.badgeDiamond, t),
      badgeLegend: Color.lerp(badgeLegend, other.badgeLegend, t),
      badgeBronzeGradient: LinearGradient.lerp(badgeBronzeGradient, other.badgeBronzeGradient, t),
      badgeSilverGradient: LinearGradient.lerp(badgeSilverGradient, other.badgeSilverGradient, t),
      badgeGoldGradient: LinearGradient.lerp(badgeGoldGradient, other.badgeGoldGradient, t),
      badgeDiamondGradient: LinearGradient.lerp(badgeDiamondGradient, other.badgeDiamondGradient, t),
      badgeLegendGradient: LinearGradient.lerp(badgeLegendGradient, other.badgeLegendGradient, t),
    );
  }
}
