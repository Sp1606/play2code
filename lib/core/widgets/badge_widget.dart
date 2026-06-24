import 'package:flutter/material.dart';
import '../theme/gaming_colors.dart';
import '../theme/gaming_theme_extension.dart';

enum BadgeTier { bronze, silver, gold, diamond, legend }

class BadgeWidget extends StatelessWidget {
  final BadgeTier tier;
  final IconData icon;
  final String title;
  final String description;
  final bool isUnlocked;
  final double size;

  const BadgeWidget({
    super.key,
    required this.tier,
    required this.icon,
    required this.title,
    required this.description,
    this.isUnlocked = true,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<GamingThemeExtension>();

    // Retrieve theme colors and gradients depending on tier
    Color tierColor;
    LinearGradient tierGradient;

    switch (tier) {
      case BadgeTier.bronze:
        tierColor = ext?.badgeBronze ?? GamingColors.badgeBronze;
        tierGradient = ext?.badgeBronzeGradient ?? GamingColors.badgeBronzeGradient;
        break;
      case BadgeTier.silver:
        tierColor = ext?.badgeSilver ?? GamingColors.badgeSilver;
        tierGradient = ext?.badgeSilverGradient ?? GamingColors.badgeSilverGradient;
        break;
      case BadgeTier.gold:
        tierColor = ext?.badgeGold ?? GamingColors.badgeGold;
        tierGradient = ext?.badgeGoldGradient ?? GamingColors.badgeGoldGradient;
        break;
      case BadgeTier.diamond:
        tierColor = ext?.badgeDiamond ?? GamingColors.badgeDiamond;
        tierGradient = ext?.badgeDiamondGradient ?? GamingColors.badgeDiamondGradient;
        break;
      case BadgeTier.legend:
        tierColor = ext?.badgeLegend ?? GamingColors.badgeLegend;
        tierGradient = ext?.badgeLegendGradient ?? GamingColors.badgeLegendGradient;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer Badge Border (Glow effect when unlocked)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isUnlocked ? tierGradient : null,
                color: isUnlocked ? null : GamingColors.surfaceLight,
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: tierColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
            
            // Inner Shield/Core Container
            Container(
              width: size - 6,
              height: size - 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: GamingColors.surface,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isUnlocked ? tierColor : GamingColors.textMuted,
                  size: size * 0.45,
                ),
              ),
            ),

            // Lock Overlay if not unlocked
            if (!isUnlocked)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: GamingColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: GamingColors.textMuted,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isUnlocked ? GamingColors.textPrimary : GamingColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: size * 1.5,
          child: Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GamingColors.textMuted,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
