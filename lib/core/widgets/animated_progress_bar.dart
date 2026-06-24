import 'package:flutter/material.dart';
import '../theme/gaming_colors.dart';

class AnimatedProgressBar extends StatefulWidget {
  final double progress; // Between 0.0 and 1.0
  final LinearGradient gradient;
  final Color backgroundColor;
  final double height;
  final Duration duration;
  final bool showGlow;
  final Widget? label;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.gradient = GamingColors.cyberGradient,
    this.backgroundColor = GamingColors.surfaceLight,
    this.height = 10.0,
    this.duration = const Duration(milliseconds: 800),
    this.showGlow = true,
    this.label,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _oldProgress = widget.progress;
  }

  @override
  void didUpdateWidget(covariant AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _oldProgress = oldWidget.progress;
      _animation = Tween<double>(begin: _oldProgress, end: widget.progress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.gradient.colors.isNotEmpty
        ? widget.gradient.colors.first
        : GamingColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          widget.label!,
          const SizedBox(height: 8),
        ],
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final currentProgress = _animation.value;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Track
                Container(
                  height: widget.height,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
                
                // Neon Glow Effect
                if (widget.showGlow && currentProgress > 0)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: currentProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.height / 2),
                          boxShadow: [
                            BoxShadow(
                              color: glowColor.withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 1.5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Active Progress Bar with Gradient
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: currentProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: widget.gradient,
                        borderRadius: BorderRadius.circular(widget.height / 2),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
