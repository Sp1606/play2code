import 'package:flutter/material.dart';
import '../theme/gaming_colors.dart';

class GameCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final VoidCallback? onTap;
  final Color borderColor;
  final List<Widget>? actions;

  const GameCard({
    super.key,
    required this.child,
    this.title,
    this.onTap,
    this.borderColor = GamingColors.surfaceLight,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

    return Container(
      decoration: BoxDecoration(
        color: GamingColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: borderColor == GamingColors.surfaceLight ? 1 : 1.5,
        ),
        boxShadow: borderColor != GamingColors.surfaceLight
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                splashColor: borderColor.withValues(alpha: 0.1),
                highlightColor: Colors.transparent,
                child: cardContent,
              )
            : cardContent,
      ),
    );
  }
}
