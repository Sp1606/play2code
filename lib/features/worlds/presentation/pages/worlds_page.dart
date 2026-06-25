import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_top_bar.dart';
import '../providers/progress_provider.dart';
import '../providers/game_state_provider.dart';
import 'package:go_router/go_router.dart';

class WorldsPage extends ConsumerStatefulWidget {
  const WorldsPage({super.key});

  @override
  ConsumerState<WorldsPage> createState() => _WorldsPageState();
}

class _WorldsPageState extends ConsumerState<WorldsPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _cloudController;
  late AnimationController _treeController;

  @override
  void initState() {
    super.initState();
    // Current level pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Continuous cloud float animation
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    // Tree sway animation
    _treeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cloudController.dispose();
    _treeController.dispose();
    super.dispose();
  }

  int _getActiveLevel(Map<int, String> progress) {
    for (int i = 1; i <= 4; i++) {
      if (progress[i] != 'Completed') {
        return i;
      }
    }
    return 4; // Default to boss
  }

  String _getLevelTitle(int index) {
    switch (index) {
      case 1:
        return 'Level 1: The Lost Stones';
      case 2:
        return 'Level 2: Temple Memory';
      case 3:
        return 'Level 3: Trap Escape';
      case 4:
      default:
        return 'Boss: Guardian Escape';
    }
  }

  String _getLevelRoute(int index) {
    switch (index) {
      case 1:
        return '/game/level_1';
      case 2:
        return '/game/level_2';
      case 3:
        return '/game/level_3';
      case 4:
      default:
        return '/game/boss';
    }
  }

  void _showRPGModal(BuildContext context, String title, Widget content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: GamingColors.primary, width: 2),
          ),
          backgroundColor: Colors.white,
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, color: GamingColors.primary),
          ),
          content: content,
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GamingColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(levelProgressProvider);
    final activeLevel = _getActiveLevel(progress);
    final totalCompleted = progress.values.where((status) => status == 'Completed').length;

    return Scaffold(
      appBar: const GameTopBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mapWidth = constraints.maxWidth;
          const mapHeight = 960.0;

          // Define coordinates for level islands
          final Map<int, Offset> islandCoords = {
            1: Offset(mapWidth * 0.22, 740),
            2: Offset(mapWidth * 0.72, 530),
            3: Offset(mapWidth * 0.24, 320),
            4: Offset(mapWidth * 0.58, 110),
          };

          return Stack(
            children: [
              // Scrollable Adventure Map
              SingleChildScrollView(
                child: Container(
                  height: mapHeight,
                  width: mapWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.lightBlue.shade50,
                        Colors.teal.shade50,
                        Colors.lightGreen.shade50,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Floating clouds in environment
                      _buildFloatingCloud(mapWidth, y: 160.0, scale: 1.2),
                      _buildFloatingCloud(mapWidth, y: 480.0, scale: 0.8),
                      _buildFloatingCloud(mapWidth, y: 720.0, scale: 1.0),

                      // Waterfall animated details
                      _buildWaterfall(x: mapWidth * 0.88, y: 220),

                      // Swaying forest details
                      _buildSwayingForest(x: mapWidth * 0.1, y: 640),
                      _buildSwayingForest(x: mapWidth * 0.8, y: 400),

                      // Glowing Connecting Paths
                      CustomPaint(
                        size: Size(mapWidth, mapHeight),
                        painter: PathPainter(coords: islandCoords, activeLevel: activeLevel),
                      ),

                      // Interactive Chest Nodes
                      _buildTreasureChestNode(x: mapWidth * 0.8, y: 750, rewardAmount: 30),
                      _buildTreasureChestNode(x: mapWidth * 0.15, y: 440, rewardAmount: 50),

                      // Level Islands
                      for (int levelIndex = 1; levelIndex <= 4; levelIndex++)
                        _buildIslandNode(
                          index: levelIndex,
                          offset: islandCoords[levelIndex]!,
                          progressStatus: progress[levelIndex] ?? 'Not Started',
                          activeLevel: activeLevel,
                        ),

                      // World Header Banner
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: _buildWorldHeader(totalCompleted),
                      ),
                    ],
                  ),
                ),
              ),

              // Left side button panel
              Positioned(
                bottom: 84,
                left: 16,
                child: Column(
                  children: [
                    _buildSideButton(
                      icon: Icons.card_giftcard,
                      color: Colors.red.shade400,
                      tooltip: 'Daily Reward',
                      onTap: () => _showRPGModal(
                        context,
                        'DAILY BONUS 🎁',
                        const Text(
                          'Your daily adventure crate has refreshed! Claim +20 Coins tomorrow!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSideButton(
                      icon: Icons.emoji_events,
                      color: Colors.amber.shade600,
                      tooltip: 'Weekly Event',
                      onTap: () => _showRPGModal(
                        context,
                        'ALGORITHM ARENA 🏆',
                        const Text(
                          'Arena starts in 2 days. Prep your stack keys and queue bypasses to compete on leaderboards!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSideButton(
                      icon: Icons.backpack,
                      color: Colors.brown.shade400,
                      tooltip: 'Inventory',
                      onTap: () => _showRPGModal(
                        context,
                        'EQUIPMENT CHEST 🎒',
                        const Text(
                          'Inventory: 3/10 Items\n- Aegis Lockpick (Qty: 2)\n- Chrono Portal Token (Qty: 1)',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right side button panel
              Positioned(
                bottom: 84,
                right: 16,
                child: Column(
                  children: [
                    _buildSideButton(
                      icon: Icons.leaderboard,
                      color: Colors.blue.shade500,
                      tooltip: 'Leaderboard',
                      onTap: () => _showRPGModal(
                        context,
                        'HALL OF HEROES 📊',
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('1. CodeGamer - 2850 XP'),
                            Text('2. ByteKnight - 2410 XP'),
                            Text('3. Hero (You) - 1420 XP'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSideButton(
                      icon: Icons.people,
                      color: Colors.teal.shade500,
                      tooltip: 'Friends',
                      onTap: () => _showRPGModal(
                        context,
                        'FRIENDS CLAN 👥',
                        const Text('Clans are locked. Progress further in World 1 to unlock online social options.'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSideButton(
                      icon: Icons.verified_user,
                      color: Colors.purple.shade400,
                      tooltip: 'Achievements',
                      onTap: () => _showRPGModal(
                        context,
                        'ACCOMPLISHMENTS 🏅',
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('✅ Hello World: Cleared Stage 1 (+50 XP)'),
                            Text('✅ Portal Master: Traversed Stage 2 (+100 XP)'),
                            Text('🔒 Arch-Bypasser: Complete Boss Stage (+200 XP)'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Large Floating Play Button
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1.04).animate(_pulseController),
                    child: Container(
                      width: mapWidth * 0.65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: GamingColors.accent.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: GameButton.variant(
                        variant: GameButtonVariant.glowAccent,
                        height: 48,
                        label: activeLevel == 4 
                            ? 'PLAY BOSS QUEST' 
                            : 'PLAY LEVEL $activeLevel',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () {
                          // Launch current level directly
                          context.go('/play');
                        },
                        color: GamingColors.accent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWorldHeader(int completedCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GamingColors.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WORLD 1 • ANCIENT KINGDOM',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: GamingColors.primary,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Restore the Lost Knowledge',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: GamingColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: GamingColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$completedCount/4 CLEARED',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: GamingColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _buildFloatingCloud(double screenWidth, {required double y, required double scale}) {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) {
        final x = (_cloudController.value * (screenWidth + 160)) - 100;
        return Positioned(
          left: x,
          top: y,
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: 0.45,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud, color: Colors.white70, size: 24),
                    SizedBox(width: 4),
                    Text('☁️', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaterfall({required double x, required double y}) {
    return Positioned(
      left: x,
      top: y,
      child: Container(
        height: 60,
        width: 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.teal.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(color: Colors.blue.withValues(alpha: 0.2), blurRadius: 4, spreadRadius: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildSwayingForest({required double x, required double y}) {
    return Positioned(
      left: x,
      top: y,
      child: AnimatedBuilder(
        animation: _treeController,
        builder: (context, child) {
          final angle = sin(_treeController.value * 2 * pi) * 0.08;
          return Transform.rotate(
            angle: angle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.park, color: Colors.green.shade400, size: 20),
                Icon(Icons.park, color: Colors.green.shade500, size: 24),
                Icon(Icons.park, color: Colors.green.shade300, size: 18),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTreasureChestNode({required double x, required double y, required int rewardAmount}) {
    return Positioned(
      left: x,
      top: y,
      child: ShakingTreasureChest(rewardAmount: rewardAmount),
    );
  }

  Widget _buildIslandNode({
    required int index,
    required Offset offset,
    required String progressStatus,
    required int activeLevel,
  }) {
    final isLocked = progressStatus == 'Not Started' && index > activeLevel;
    final isCompleted = progressStatus == 'Completed';
    final isActive = index == activeLevel;

    Color islandColor;
    Color glowColor;
    if (isCompleted) {
      islandColor = GamingColors.accent;
      glowColor = GamingColors.accent;
    } else if (isActive) {
      islandColor = GamingColors.primary;
      glowColor = GamingColors.primary;
    } else {
      islandColor = isLocked ? Colors.grey.shade400 : GamingColors.secondary;
      glowColor = Colors.transparent;
    }

    final islandWidget = Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade300 : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: islandColor,
          width: isActive ? 3 : 2,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: glowColor.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 3,
            )
          else if (isCompleted)
            BoxShadow(
              color: GamingColors.accent.withValues(alpha: 0.25),
              blurRadius: 10,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: isLocked
            ? Icon(Icons.lock, color: Colors.grey.shade600, size: 28)
            : (isCompleted
                ? const Icon(Icons.check_circle_rounded, color: GamingColors.accent, size: 36)
                : Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: islandColor,
                    ),
                  )),
      ),
    );

    return Positioned(
      left: offset.dx - 36, // center it
      top: offset.dy - 36,
      child: Column(
        children: [
          GestureDetector(
            onTap: !isLocked
                ? () {
                    // Zoom transition simulation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cinematic zoom: entering stage $index...')),
                    );
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (!mounted) return;
                      context.go(_getLevelRoute(index));
                    });
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Stage $index is locked. Clear Stage ${index - 1} first!')),
                    );
                  },
            child: isActive
                ? ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.05).animate(_pulseController),
                    child: islandWidget,
                  )
                : islandWidget,
          ),
          const SizedBox(height: 6),
          // Level title card underneath
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getLevelTitle(index).split(': ').last,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw connecting paths between levels
class PathPainter extends CustomPainter {
  final Map<int, Offset> coords;
  final int activeLevel;

  PathPainter({required this.coords, required this.activeLevel});

  @override
  void paint(Canvas canvas, Size size) {
    if (coords.length < 2) return;

    for (int i = 1; i < coords.length; i++) {
      final p1 = coords[i]!;
      final p2 = coords[i + 1]!;
      final isPathCompleted = i < activeLevel;

      final paint = Paint()
        ..color = isPathCompleted ? GamingColors.accent : Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      // Draw dashed line path
      _drawDashedLine(canvas, p1, p2, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double distance = sqrt(dx * dx + dy * dy);

    const double dashLength = 8.0;
    const double spaceLength = 6.0;
    final int count = (distance / (dashLength + spaceLength)).floor();

    final double stepX = dx / distance;
    final double stepY = dy / distance;

    for (int i = 0; i < count; i++) {
      final double startDist = i * (dashLength + spaceLength);
      final double endDist = startDist + dashLength;

      final Offset startPoint = Offset(
        p1.dx + stepX * startDist,
        p1.dy + stepY * startDist,
      );
      final Offset endPoint = Offset(
        p1.dx + stepX * endDist,
        p1.dy + stepY * endDist,
      );

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Stateful shaking treasure chest widget
class ShakingTreasureChest extends StatefulWidget {
  final int rewardAmount;
  const ShakingTreasureChest({super.key, required this.rewardAmount});

  @override
  State<ShakingTreasureChest> createState() => _ShakingTreasureChestState();
}

class _ShakingTreasureChestState extends State<ShakingTreasureChest> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpened = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChestTap(BuildContext context, WidgetRef ref) {
    if (_isOpened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chest is empty! You already claimed this reward.')),
      );
      return;
    }

    _controller.forward(from: 0.0).then((_) async {
      setState(() {
        _isOpened = true;
      });
      // award coins
      await ref.read(gameStateProvider.notifier).addCoins(widget.rewardAmount);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('✨ REWARD ACQUIRED ✨', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.accent)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('You cracked the secret map chest!', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text('🪙 +${widget.rewardAmount} Coins', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.amber.shade900)),
                ],
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                )
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return GestureDetector(
          onTap: () => _onChestTap(context, ref),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Shake offset using sin
              final dx = sin(_controller.value * 4 * pi) * 6 * (1 - _controller.value);
              return Transform.translate(
                offset: Offset(dx, 0),
                child: Icon(
                  _isOpened ? Icons.drafts_outlined : Icons.card_giftcard_rounded,
                  color: _isOpened ? Colors.grey : GamingColors.warning,
                  size: 32,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
