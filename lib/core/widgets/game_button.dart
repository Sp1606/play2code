import 'package:flutter/material.dart';
import '../theme/gaming_colors.dart';

class GameButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? color;

  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.height = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null;

    if (isSecondary) {
      // Neon Outlined Button
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isEnabled 
                  ? (color ?? GamingColors.primary) 
                  : GamingColors.textMuted,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            foregroundColor: color ?? GamingColors.primary,
          ),
          child: _buildChild(theme, isEnabled, isSecondary: true),
        ),
      );
    }

    // Neon Gradient Solid Button
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: (color ?? GamingColors.primary).withValues(alpha: 0.3),
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
                  child: _buildChild(theme, isEnabled, isSecondary: false),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(ThemeData theme, bool isEnabled, {required bool isSecondary}) {
    final textColor = isSecondary
        ? (isEnabled ? (color ?? GamingColors.primary) : GamingColors.textMuted)
        : (isEnabled ? Colors.black : GamingColors.textMuted);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: textColor,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
