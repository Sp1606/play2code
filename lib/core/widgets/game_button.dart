import 'package:flutter/material.dart';
import '../theme/gaming_colors.dart';

enum GameButtonVariant {
  primaryGradient,
  secondaryOutline,
  glowAccent,
  textOnly,
}

class GameButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final GameButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? color;

  // Keep backward compatibility constructors
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    bool isSecondary = false,
    this.icon,
    this.width,
    this.height = 50,
    this.color,
  }) : variant = isSecondary ? GameButtonVariant.secondaryOutline : GameButtonVariant.primaryGradient;

  const GameButton.variant({
    super.key,
    required this.label,
    required this.onPressed,
    required this.variant,
    this.icon,
    this.width,
    this.height = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null;

    final primaryAccentColor = color ?? GamingColors.primary;

    switch (variant) {
      case GameButtonVariant.secondaryOutline:
        return SizedBox(
          width: width,
          height: height,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isEnabled ? primaryAccentColor : GamingColors.textMuted,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: primaryAccentColor,
            ),
            child: _buildChild(theme, isEnabled, foregroundColor: isEnabled ? primaryAccentColor : GamingColors.textMuted),
          ),
        );

      case GameButtonVariant.glowAccent:
        // solid accented button with heavy glow
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: primaryAccentColor.withValues(alpha: 0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: isEnabled ? primaryAccentColor : GamingColors.surfaceLight,
              child: InkWell(
                onTap: onPressed,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildChild(
                      theme,
                      isEnabled,
                      foregroundColor: isEnabled ? Colors.black : GamingColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

      case GameButtonVariant.textOnly:
        return SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: primaryAccentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _buildChild(
              theme,
              isEnabled,
              foregroundColor: isEnabled ? primaryAccentColor : GamingColors.textMuted,
            ),
          ),
        );

      case GameButtonVariant.primaryGradient:
        // Neon Gradient Solid Button
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: primaryAccentColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: isEnabled
                        ? (color != null
                            ? LinearGradient(colors: [color!, color!.withValues(alpha: 0.7)])
                            : GamingColors.cyberGradient)
                        : const LinearGradient(
                            colors: [GamingColors.surfaceLight, GamingColors.surface],
                          ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildChild(
                        theme,
                        isEnabled,
                        foregroundColor: isEnabled ? Colors.black : GamingColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }

  Widget _buildChild(ThemeData theme, bool isEnabled, {required Color foregroundColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: foregroundColor,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: foregroundColor,
          ),
        ),
      ],
    );
  }
}
