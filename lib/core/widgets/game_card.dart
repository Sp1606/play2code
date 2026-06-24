import 'package:flutter/material.dart';
import '../theme/gaming_colors.dart';

class GameCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final VoidCallback? onTap;
  final Color borderColor;
  final LinearGradient? borderGradient;
  final Color? glowColor;
  final double glowRadius;
  final double borderRadius;
  final List<Widget>? actions;

  const GameCard({
    super.key,
    required this.child,
    this.title,
    this.onTap,
    this.borderColor = GamingColors.surfaceLight,
    this.borderGradient,
    this.glowColor,
    this.glowRadius = 12.0,
    this.borderRadius = 16.0,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeGlowColor = glowColor ?? 
        (borderGradient != null && borderGradient!.colors.isNotEmpty 
            ? borderGradient!.colors.first 
            : (borderColor != GamingColors.surfaceLight ? borderColor : null));

    final hasGlow = activeGlowColor != null && glowRadius > 0;

    // Card Content Padding
    Widget cardContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || actions != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                if (actions != null)
                  Row(children: actions!),
              ],
            ),
            const Divider(
              color: GamingColors.surfaceLight,
              height: 24,
              thickness: 1,
            ),
          ],
          child,
        ],
      ),
    );

    // InkWell Tap Area
    Widget inkContent = ClipRRect(
      borderRadius: BorderRadius.circular(
        borderGradient != null ? borderRadius - 1.5 : borderRadius,
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              splashColor: (activeGlowColor ?? GamingColors.primary).withValues(alpha: 0.1),
              highlightColor: Colors.transparent,
              child: cardContent,
            )
          : cardContent,
    );

    if (borderGradient != null) {
      // Outer Glow + Gradient Border Container
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: borderGradient,
          boxShadow: hasGlow
              ? [
                  BoxShadow(
                    color: activeGlowColor.withValues(alpha: 0.25),
                    blurRadius: glowRadius,
                    spreadRadius: 1.5,
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(1.5), // Border thickness
        child: Container(
          decoration: BoxDecoration(
            color: GamingColors.surface,
            borderRadius: BorderRadius.circular(borderRadius - 1.5),
          ),
          child: inkContent,
        ),
      );
    }

    // Default Single Container layout
    return Container(
      decoration: BoxDecoration(
        color: GamingColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderColor == GamingColors.surfaceLight ? 1 : 1.5,
        ),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: activeGlowColor.withValues(alpha: 0.15),
                  blurRadius: glowRadius,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: inkContent,
    );
  }
}
