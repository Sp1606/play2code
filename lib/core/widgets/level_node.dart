import 'package:flutter/material.dart';
import '../theme/gaming_colors.dart';

class LevelNode extends StatefulWidget {
  final int index;
  final String title;
  final String status;
  final bool isActive;
  final VoidCallback onTap;

  const LevelNode({
    super.key,
    required this.index,
    required this.title,
    required this.status,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<LevelNode> createState() => _LevelNodeState();
}

class _LevelNodeState extends State<LevelNode> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant LevelNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.status == 'Not Started' && !widget.isActive;
    final isCompleted = widget.status == 'Completed';

    Color nodeBorderColor = Colors.grey.shade400;
    Color nodeColor = Colors.grey.shade300;
    Color textColor = Colors.white70;

    if (isCompleted) {
      nodeBorderColor = GamingColors.accent;
      nodeColor = Colors.teal.shade50;
      textColor = GamingColors.accent;
    } else if (widget.isActive) {
      nodeBorderColor = Colors.amber.shade600;
      nodeColor = Colors.white;
      textColor = Colors.amber.shade800;
    }

    // Node body
    final Widget nodeContent = Container(
      width: 72,
      height: 80,
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade800 : nodeColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(36),
          bottom: Radius.circular(12),
        ),
        border: Border.all(
          color: isLocked ? Colors.grey.shade600 : nodeBorderColor,
          width: widget.isActive ? 4.5 : 3.0,
        ),
        boxShadow: [
          if (widget.isActive)
            BoxShadow(
              color: Colors.amber.shade600.withValues(alpha: 0.6),
              blurRadius: 18,
              spreadRadius: 3,
            )
          else if (isCompleted)
            BoxShadow(
              color: GamingColors.accent.withValues(alpha: 0.35),
              blurRadius: 10,
            ),
          const BoxShadow(
            color: Colors.black45,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Stone texture lines (simulated with icons)
          Positioned(
            top: 4,
            child: Icon(
              Icons.architecture,
              size: 20,
              color: isLocked ? Colors.white10 : nodeBorderColor.withValues(alpha: 0.15),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 6),
              if (isLocked)
                const Icon(Icons.lock, color: Colors.white30, size: 24)
              else if (isCompleted)
                const Icon(Icons.check_circle_rounded, color: GamingColors.accent, size: 30)
              else
                Text(
                  widget.index == 4 ? 'BOSS' : '${widget.index}',
                  style: TextStyle(
                    fontSize: widget.index == 4 ? 14 : 28,
                    fontWeight: FontWeight.w900,
                    color: isLocked ? Colors.white30 : textColor,
                    shadows: const [
                      Shadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 2),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: !isLocked ? widget.onTap : null,
          child: widget.isActive
              ? ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.05).animate(_pulseController),
                  child: nodeContent,
                )
              : nodeContent,
        ),
        const SizedBox(height: 8),

        // Title and Status Card
        Column(
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.indigo.shade900, offset: const Offset(0, 1.5), blurRadius: 4),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Status Chip
            _buildStatusChip(isLocked, isCompleted),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool isLocked, bool isCompleted) {
    String label = 'Available';
    Color bgColor = Colors.green.shade800;
    Color textColor = Colors.white;

    if (isLocked) {
      label = 'Locked';
      bgColor = Colors.indigo.shade900.withValues(alpha: 0.6);
      textColor = Colors.white54;
    } else if (isCompleted) {
      label = 'Cleared';
      bgColor = GamingColors.accent;
      textColor = Colors.white;
    } else if (widget.isActive) {
      label = 'Available';
      bgColor = Colors.green.shade600;
      textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
