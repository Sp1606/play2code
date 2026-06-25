import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/player_header.dart';
import '../../../../core/widgets/resource_bar.dart';
import '../../../../core/widgets/world_scroll_banner.dart';
import '../../../../core/widgets/level_node.dart';
import '../../../../core/widgets/animated_play_button.dart';
import '../../../worlds/presentation/providers/progress_provider.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _torchController;

  @override
  void initState() {
    super.initState();
    // Continuous cloud float
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..repeat();

    // Torches flame flicker
    _torchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _torchController.dispose();
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

  String _getLevelSubtitle(int index) {
    switch (index) {
      case 1:
        return 'Start your adventure';
      case 2:
        return 'Bypass the memory gate';
      case 3:
        return 'Override the trap grid';
      case 4:
      default:
        return 'Defeat the Guardian';
    }
  }

  void _showActionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF7C3AED), width: 2),
          ),
          backgroundColor: const Color(0xFF0F172A),
          title: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFFFC300)),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('CONFIRM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final activeLevelTitle = _getLevelSubtitle(activeLevel);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mapWidth = constraints.maxWidth;
          final mapHeight = constraints.maxHeight;

          // Define coordinates for level nodes inside this layout
          final Map<int, Offset> nodeCoords = {
            1: Offset(mapWidth * 0.50, mapHeight * 0.28), // Level 1 (Top Center)
            2: Offset(mapWidth * 0.25, mapHeight * 0.50), // Level 2 (Middle Left)
            3: Offset(mapWidth * 0.75, mapHeight * 0.50), // Level 3 (Middle Right)
            4: Offset(mapWidth * 0.50, mapHeight * 0.70), // Boss (Bottom Center)
          };

          return Container(
            width: mapWidth,
            height: mapHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0C1033), // Deep space navy
                  const Color(0xFF1B1A55), // Twilight indigo
                  const Color(0xFF535C91), // Lighter slate blue
                  Colors.teal.shade900,     // Hill grass green
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                // Starry overlay (using simple dots)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.35,
                    child: CustomPaint(
                      painter: StarsPainter(),
                    ),
                  ),
                ),

                // Drifting clouds in twilight sky
                _buildFloatingCloud(mapWidth, y: mapHeight * 0.2, scale: 1.1),
                _buildFloatingCloud(mapWidth, y: mapHeight * 0.45, scale: 0.8),
                _buildFloatingCloud(mapWidth, y: mapHeight * 0.65, scale: 1.0),

                // Glowing Paths
                CustomPaint(
                  size: Size(mapWidth, mapHeight),
                  painter: CurvedPathPainter(coords: nodeCoords, activeLevel: activeLevel),
                ),

                // Torches flickering at Boss Gate
                _buildFlickeringTorch(nodeCoords[4]!.dx - 58, nodeCoords[4]!.dy - 10),
                _buildFlickeringTorch(nodeCoords[4]!.dx + 38, nodeCoords[4]!.dy - 10),

                // Level Nodes
                _buildMapNode(
                  index: 1,
                  title: 'The Lost Stones',
                  offset: nodeCoords[1]!,
                  status: progress[1] ?? 'Not Started',
                  activeLevel: activeLevel,
                ),
                _buildMapNode(
                  index: 2,
                  title: 'Temple Memory',
                  offset: nodeCoords[2]!,
                  status: progress[2] ?? 'Not Started',
                  activeLevel: activeLevel,
                ),
                _buildMapNode(
                  index: 3,
                  title: 'Trap Escape',
                  offset: nodeCoords[3]!,
                  status: progress[3] ?? 'Not Started',
                  activeLevel: activeLevel,
                ),
                _buildMapNode(
                  index: 4,
                  title: 'Guardian Escape',
                  offset: nodeCoords[4]!,
                  status: progress[4] ?? 'Not Started',
                  activeLevel: activeLevel,
                ),

                // Top Panel (Header, Currencies)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.black.withValues(alpha: 0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: PlayerHeader()),
                            ResourceBar(),
                          ],
                        ),
                        SizedBox(height: 12),
                        WorldScrollBanner(),
                      ],
                    ),
                  ),
                ),

                // Side Action Buttons (Left)
                Positioned(
                  top: mapHeight * 0.28,
                  left: 14,
                  child: Column(
                    children: [
                      _buildSideAction(
                        icon: Icons.calendar_month,
                        label: 'Daily Reward',
                        hasAlert: true,
                        onTap: () => _showActionDialog('Daily Reward 🎁', 'Your daily login reward chest is loaded! Claim +20 Coins!'),
                      ),
                      const SizedBox(height: 12),
                      _buildSideAction(
                        icon: Icons.emoji_events,
                        label: 'Arena',
                        hasAlert: true,
                        onTap: () => _showActionDialog('Algorithm Arena 🏆', 'Weekly competition details. Beat players globally to earn Diamond badging!'),
                      ),
                      const SizedBox(height: 12),
                      _buildSideAction(
                        icon: Icons.assignment,
                        label: 'Quests',
                        hasAlert: true,
                        onTap: () => _showActionDialog('Missions List 📜', 'Active Quest: Restore World 1 knowledge. Reward: +150 XP.'),
                      ),
                      const SizedBox(height: 12),
                      _buildSideAction(
                        icon: Icons.backpack,
                        label: 'Inventory',
                        onTap: () => _showActionDialog('Backpack 🎒', 'Inventory content: 2x Lockpicks, 1x Shield, 3x Runestones.'),
                      ),
                    ],
                  ),
                ),

                // Side Action Buttons (Right)
                Positioned(
                  top: mapHeight * 0.28,
                  right: 14,
                  child: Column(
                    children: [
                      _buildSideAction(
                        icon: Icons.workspace_premium,
                        label: 'Leaderboards',
                        onTap: () => _showActionDialog('Hall of Heroes 📊', '1. CodeGamer - 2850 XP\n2. ByteKnight - 2410 XP\n3. You - 1420 XP'),
                      ),
                      const SizedBox(height: 12),
                      _buildSideAction(
                        icon: Icons.group,
                        label: 'Friends',
                        onTap: () => _showActionDialog('Clan Lobby 👥', 'Join a programming clan or challenge friends to algorithm battles!'),
                      ),
                      const SizedBox(height: 12),
                      _buildSideAction(
                        icon: Icons.stars,
                        label: 'Achievements',
                        onTap: () => _showActionDialog('Gamer Feats 🏅', 'Achievements unlocked: HelloWorld, PortalTraverser. Pending: GuardianBreaker.'),
                      ),
                      const SizedBox(height: 12),
                      _buildSideAction(
                        icon: Icons.menu_book,
                        label: 'Codex',
                        hasAlert: true,
                        onTap: () => _showActionDialog('Algorithm Codex 📖', 'Locked until World 1 completion. Will contain detailed Stack, Queue and Search logic.'),
                      ),
                    ],
                  ),
                ),

                // Bottom Left Corner Booster Crate
                Positioned(
                  bottom: 84,
                  left: 16,
                  child: _buildSideAction(
                    icon: Icons.inventory_2,
                    label: 'Starter Pack',
                    iconColor: Colors.amber.shade700,
                    onTap: () => _showActionDialog('Starter Pack 🎁', 'Unlocks legendary avatar style skin + 50 Gems! Visit Shop to claim.'),
                  ),
                ),

                // Bottom Right Corner Booster Scroll
                Positioned(
                  bottom: 84,
                  right: 16,
                  child: _buildSideAction(
                    icon: Icons.workspace_premium_outlined,
                    label: 'XP Boost',
                    iconColor: Colors.cyan.shade600,
                    onTap: () => _showActionDialog('XP Boost ⚡', 'Double XP modifier is active for 2 hours! Clear levels now to maximize level gains.'),
                  ),
                ),

                // Bottom Centered Play Button
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedPlayButton(
                      label: activeLevel == 4 
                          ? 'Play Boss' 
                          : 'Play Level $activeLevel',
                      subtitle: activeLevelTitle,
                      onPressed: () {
                        context.go('/play');
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingCloud(double screenWidth, {required double y, required double scale}) {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) {
        final x = (_cloudController.value * (screenWidth + 200)) - 120;
        return Positioned(
          left: x,
          top: y,
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: 0.18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud, color: Colors.white70, size: 20),
                    SizedBox(width: 4),
                    Text('☁️', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlickeringTorch(double x, double y) {
    return Positioned(
      left: x,
      top: y,
      child: AnimatedBuilder(
        animation: _torchController,
        builder: (context, child) {
          final scale = 0.9 + (_torchController.value * 0.25);
          final opacity = 0.7 + (_torchController.value * 0.3);

          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.deepOrange,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSideAction({
    required IconData icon,
    required String label,
    Color? iconColor,
    bool hasAlert = false,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor ?? const Color(0xFFFFC300),
                    size: 20,
                  ),
                ),
              ),
              if (hasAlert)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label.split(' ')[0],
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: Colors.white70,
            shadows: [Shadow(color: Colors.black87, offset: Offset(0, 1), blurRadius: 2)],
          ),
        ),
      ],
    );
  }

  Widget _buildMapNode({
    required int index,
    required String title,
    required Offset offset,
    required String status,
    required int activeLevel,
  }) {
    final isActive = index == activeLevel;
    return Positioned(
      left: offset.dx - 36, // center node horizontally (node width is 72)
      top: offset.dy - 56,  // offset slightly higher to account for labels
      child: LevelNode(
        index: index,
        title: title,
        status: status,
        isActive: isActive,
        onTap: () {
          // Zoom transition animation triggers
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cinematic zoom: launching quest stage $index...')),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.go(_getLevelRoute(index));
            }
          });
        },
      ),
    );
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
}

// Simple painter to draw scattered star elements
class StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final rand = Random(42); // Seeded random for consistent starry positions

    for (int i = 0; i < 40; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height * 0.6; // stars mostly at the top
      final radius = rand.nextDouble() * 1.5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter to draw curved neon pathways between nodes
class CurvedPathPainter extends CustomPainter {
  final Map<int, Offset> coords;
  final int activeLevel;

  CurvedPathPainter({required this.coords, required this.activeLevel});

  @override
  void paint(Canvas canvas, Size size) {
    if (coords.length < 2) return;

    for (int i = 1; i < coords.length; i++) {
      final p1 = coords[i]!;
      final p2 = coords[i + 1]!;
      final isPathCompleted = i < activeLevel;

      final paint = Paint()
        ..color = isPathCompleted ? GamingColors.accent : Colors.grey.shade600.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      // Draw dashed path curve between p1 and p2
      _drawCurveDashedLine(canvas, p1, p2, paint);
    }
  }

  void _drawCurveDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    // Generate curved points using quadratic control point
    final controlX = (p1.dx + p2.dx) / 2 + (p1.dx > p2.dx ? 25 : -25);
    final controlY = (p1.dy + p2.dy) / 2;
    final controlPoint = Offset(controlX, controlY);

    const int segments = 24;
    List<Offset> pathPoints = [];

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      // Bezier curve interpolation formula
      final x = (1 - t) * (1 - t) * p1.dx + 2 * (1 - t) * t * controlPoint.dx + t * t * p2.dx;
      final y = (1 - t) * (1 - t) * p1.dy + 2 * (1 - t) * t * controlPoint.dy + t * t * p2.dy;
      pathPoints.add(Offset(x, y));
    }

    // Draw dashes
    for (int i = 0; i < pathPoints.length - 1; i += 2) {
      canvas.drawLine(pathPoints[i], pathPoints[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
