import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_top_bar.dart';
import '../providers/progress_provider.dart';
import 'package:go_router/go_router.dart';

class WorldsPage extends ConsumerStatefulWidget {
  const WorldsPage({super.key});

  @override
  ConsumerState<WorldsPage> createState() => _WorldsPageState();
}

class _WorldsPageState extends ConsumerState<WorldsPage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _portalController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _portalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _portalController.dispose();
    super.dispose();
  }

  void _scrollToWorld(double yOffset) {
    _scrollController.animateTo(
      yOffset,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  void _showWorldDetail(String title, String theme, String desc, Color color) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: color, width: 2),
          ),
          backgroundColor: const Color(0xFF0F172A),
          title: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, color: color),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                theme,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('UNDERSTOOD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final isWorld1Completed = progress[4] == 'Completed';

    return Scaffold(
      appBar: const GameTopBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mapWidth = constraints.maxWidth;
          const mapHeight = 2500.0; // Winding path height mapping all 5 worlds

          // Dynamic coordinates for all 25 nodes
          final Map<int, Offset> mapCoords = {
            // World 1 (Ancient Kingdom): Nodes 1-5
            1: Offset(mapWidth * 0.50, 140),  // Level 1
            2: Offset(mapWidth * 0.24, 240),  // Level 2
            3: Offset(mapWidth * 0.76, 240),  // Level 3
            4: Offset(mapWidth * 0.50, 350),  // Boss 1
            5: Offset(mapWidth * 0.50, 460),  // Portal 1 -> 2

            // World 2 (Enchanted Forest): Nodes 6-10
            6: Offset(mapWidth * 0.50, 620),  // Level 5
            7: Offset(mapWidth * 0.24, 720),  // Level 6
            8: Offset(mapWidth * 0.76, 720),  // Level 7
            9: Offset(mapWidth * 0.50, 830),  // Boss 2
            10: Offset(mapWidth * 0.50, 940), // Portal 2 -> 3

            // World 3 (Pirate Islands): Nodes 11-15
            11: Offset(mapWidth * 0.50, 1100), // Level 9
            12: Offset(mapWidth * 0.24, 1200), // Level 10
            13: Offset(mapWidth * 0.76, 1200), // Level 11
            14: Offset(mapWidth * 0.50, 1310), // Boss 3
            15: Offset(mapWidth * 0.50, 1420), // Portal 3 -> 4

            // World 4 (Crystal Mountains): Nodes 16-20
            16: Offset(mapWidth * 0.50, 1580), // Level 13
            17: Offset(mapWidth * 0.24, 1680), // Level 14
            18: Offset(mapWidth * 0.76, 1680), // Level 15
            19: Offset(mapWidth * 0.50, 1790), // Boss 4
            20: Offset(mapWidth * 0.50, 1900), // Portal 4 -> 5

            // World 5 (Sky Realm): Nodes 21-25
            21: Offset(mapWidth * 0.50, 2060), // Level 17
            22: Offset(mapWidth * 0.24, 2160), // Level 18
            23: Offset(mapWidth * 0.76, 2160), // Level 19
            24: Offset(mapWidth * 0.50, 2270), // Boss 5
            25: Offset(mapWidth * 0.50, 2380), // Victory Portal
          };

          return Container(
            color: const Color(0xFF0F172A),
            child: Stack(
              children: [
                // Scrollable macro path map
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Container(
                    height: mapHeight,
                    width: mapWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0F172A),
                          const Color(0xFF1E1B4B),
                          const Color(0xFF311042),
                          const Color(0xFF0F172A),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Path Painter drawing dash tracks
                        CustomPaint(
                          size: Size(mapWidth, mapHeight),
                          painter: MacroPathPainter(coords: mapCoords, isWorld1Completed: isWorld1Completed),
                        ),

                        // --- WORLD 1 BANNER & NODES ---
                        _buildWorldBanner(y: 40, title: 'World 1: Ancient Kingdom', completed: true, color: Colors.amber.shade700, onTap: () => _showWorldDetail('Ancient Kingdom 🏛', '🏛 Temple • 🪨 Pillars • 🔥 Torches', 'World 1 challenges focus on stack sequence ordering (LIFO) and passenger queueing portals (FIFO).', Colors.amber.shade700)),
                        _buildLevelNode(index: 1, title: 'Lost Stones', offset: mapCoords[1]!, status: progress[1] ?? 'Not Started', route: '/game/level_1', isWorldUnlocked: true),
                        _buildLevelNode(index: 2, title: 'Temple Memory', offset: mapCoords[2]!, status: progress[2] ?? 'Not Started', route: '/game/level_2', isWorldUnlocked: true),
                        _buildLevelNode(index: 3, title: 'Trap Escape', offset: mapCoords[3]!, status: progress[3] ?? 'Not Started', route: '/game/level_3', isWorldUnlocked: true),
                        _buildLevelNode(index: 4, title: 'Boss: Guardian', offset: mapCoords[4]!, status: progress[4] ?? 'Not Started', route: '/game/boss', isWorldUnlocked: true, isBoss: true),
                        _buildPortalNode(index: 5, title: 'Gate 1 ➔ 2', offset: mapCoords[5]!, isUnlocked: isWorld1Completed, onTap: () {
                          if (isWorld1Completed) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Portal traverser unlocked! Snapping to World 2.')));
                            _scrollToWorld(510);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Portal locked. Clear the World 1 Boss first!')));
                          }
                        }),

                        // --- WORLD 2 BANNER & NODES ---
                        _buildWorldBanner(y: 520, title: 'World 2: Enchanted Forest', completed: false, color: Colors.green.shade600, onTap: () => _showWorldDetail('Enchanted Forest 🌳', '🌳 Giant Trees • 🍄 Mushrooms • 🌉 Bridges', 'World 2 challenges require balancing tree canopy indexes and routing mushrooms in specific flow sequences.', Colors.green.shade600)),
                        _buildLevelNode(index: 5, title: 'Mushroom Path', offset: mapCoords[6]!, status: 'Not Started', route: '', isWorldUnlocked: isWorld1Completed),
                        _buildLevelNode(index: 6, title: 'Tree Canopy', offset: mapCoords[7]!, status: 'Not Started', route: '', isWorldUnlocked: isWorld1Completed),
                        _buildLevelNode(index: 7, title: 'Wooden Bridge', offset: mapCoords[8]!, status: 'Not Started', route: '', isWorldUnlocked: isWorld1Completed),
                        _buildLevelNode(index: 8, title: 'Boss: Grove', offset: mapCoords[9]!, status: 'Not Started', route: '', isWorldUnlocked: isWorld1Completed, isBoss: true),
                        _buildPortalNode(index: 10, title: 'Gate 2 ➔ 3', offset: mapCoords[10]!, isUnlocked: false, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Portal locked. Clear World 2 first!')))),

                        // --- WORLD 3 BANNER & NODES ---
                        _buildWorldBanner(y: 1000, title: 'World 3: Pirate Islands', completed: false, color: Colors.blue.shade600, onTap: () => _showWorldDetail('Pirate Islands 🏴‍☠️', '🏴‍☠️ Ships • 🗺 Treasure • 🌊 Ocean', 'World 3 introduces multi-dimensional grids, routing pirate sloops through binary coordinate blocks.', Colors.blue.shade600)),
                        _buildLevelNode(index: 9, title: 'Shipwreck Reef', offset: mapCoords[11]!, status: 'Not Started', route: '', isWorldUnlocked: false),
                        _buildLevelNode(index: 10, title: 'Treasure Reef', offset: mapCoords[12]!, status: 'Not Started', route: '', isWorldUnlocked: false),
                        _buildLevelNode(index: 11, title: 'Sand Cove', offset: mapCoords[13]!, status: 'Not Started', route: '', isWorldUnlocked: false),
                        _buildLevelNode(index: 12, title: 'Boss: Corsair', offset: mapCoords[14]!, status: 'Not Started', route: '', isWorldUnlocked: false, isBoss: true),
                        _buildPortalNode(index: 15, title: 'Gate 3 ➔ 4', offset: mapCoords[15]!, isUnlocked: false, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Portal locked. Clear World 3 first!')))),

                        // --- WORLD 4 BANNER & NODES ---
                        _buildWorldBanner(y: 1480, title: 'World 4: Crystal Mountains', completed: false, color: Colors.cyan.shade600, onTap: () => _showWorldDetail('Crystal Peaks 💎', '❄️ Ice Caves • 💎 Crystals • ⛰ Peaks', 'World 4 focuses on tree structures and traversal nodes across frozen peak altars.', Colors.cyan.shade600)),
                        _buildLevelNode(index: 13, title: 'Ice Cave', offset: mapCoords[16]!, status: 'Not Started', route: '', isWorldUnlocked: false),
                        _buildLevelNode(index: 14, title: 'Peak Altar', offset: mapCoords[17]!, status: 'Not Started', route: '', isWorldUnlocked: false),
                        _buildLevelNode(index: 15, title: 'Glacial Spire', offset: mapCoords[18]!, status: 'Not Started', route: '', isWorldUnlocked: false),
                        _buildLevelNode(index: 16, title: 'Boss: Golem', offset: mapCoords[19]!, status: 'Not Started', route: '', isWorldUnlocked: false, isBoss: true),
                        _buildPortalNode(index: 20, title: 'Gate 4 ➔ 5', offset: mapCoords[20]!, isUnlocked: false, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Portal locked. Clear World 4 first!')))),

                        // --- WORLD 5 BANNER & NODES ---
                        _buildWorldBanner(y: 1960, title: 'World 5: Sky Realm', completed: false, color: Colors.purple.shade600, onTap: () => _showWorldDetail('Sky Realm ☁️', '☁️ Floating Islands • ⚡ Lightning • ✨ Portals', 'World 5 is the final recursion spires. Breach the Sky Core to unlock the logic logs.', Colors.purple.shade600)),
                        _buildLevelNode(index: 17, title: 'Spire Peak', offset: mapCoords[21]!, status: 'Not Started', route: '', isWorldUnlocked: false),
                        _buildLevelNode(index: 18, title: 'Void Gateway', offset: mapCoords[22]!, status: 'Not Started', route: '', isWorldUnlocked: false),
                        _buildLevelNode(index: 19, title: 'Lightning Spire', offset: mapCoords[23]!, status: 'Not Started', route: '', isWorldUnlocked: false),
                        _buildLevelNode(index: 20, title: 'Boss: Core', offset: mapCoords[24]!, status: 'Not Started', route: '', isWorldUnlocked: false, isBoss: true),
                        _buildPortalNode(index: 25, title: 'Void Gateway', offset: mapCoords[25]!, isUnlocked: false, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Traverse to victory spires.')))),
                      ],
                    ),
                  ),
                ),

                // Top Quick Navigation Bar (Horizontal jump chips)
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildJumpChip(context, label: 'W1', yOffset: 0.0, active: true),
                          _buildJumpChip(context, label: 'W2', yOffset: 480.0, active: isWorld1Completed),
                          _buildJumpChip(context, label: 'W3', yOffset: 960.0, active: false),
                          _buildJumpChip(context, label: 'W4', yOffset: 1440.0, active: false),
                          _buildJumpChip(context, label: 'W5', yOffset: 1920.0, active: false),
                        ],
                      ),
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

  Widget _buildJumpChip(BuildContext context, {required String label, required double yOffset, required bool active}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        label: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? Colors.white : Colors.white30)),
        backgroundColor: active ? GamingColors.primary.withValues(alpha: 0.3) : Colors.black26,
        side: BorderSide(color: active ? GamingColors.primary : Colors.transparent),
        padding: EdgeInsets.zero,
        onPressed: active ? () => _scrollToWorld(yOffset) : null,
      ),
    );
  }

  Widget _buildWorldBanner({
    required double y,
    required String title,
    required bool completed,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Positioned(
      top: y,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 2),
                  const Text('Click for world lore and details', style: TextStyle(fontSize: 9, color: Colors.white54)),
                ],
              ),
              Icon(
                completed ? Icons.check_circle : Icons.lock_outline,
                color: completed ? GamingColors.accent : Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelNode({
    required int index,
    required String title,
    required Offset offset,
    required String status,
    required String route,
    required bool isWorldUnlocked,
    bool isBoss = false,
  }) {
    final isCompleted = status == 'Completed';
    final isLocked = !isWorldUnlocked || (status == 'Not Started' && route.isEmpty);

    Color nodeColor = isLocked ? Colors.grey.shade800 : (isCompleted ? GamingColors.accent : GamingColors.primary);

    return Positioned(
      left: offset.dx - 30, // center on coordinate
      top: offset.dy - 30,
      child: Column(
        children: [
          GestureDetector(
            onTap: !isLocked
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cinematic zoom: traversing to $title...')),
                    );
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        context.go(route);
                      }
                    });
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Stage locked. Clear previous sectors in sequence!')),
                    );
                  },
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey.shade900 : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: nodeColor,
                  width: isBoss ? 3.5 : 2.0,
                ),
                boxShadow: [
                  if (!isLocked && !isCompleted)
                    BoxShadow(color: GamingColors.primary.withValues(alpha: 0.35), blurRadius: 10, spreadRadius: 1),
                  const BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 3)),
                ],
              ),
              child: Center(
                child: isLocked
                    ? const Icon(Icons.lock, color: Colors.white24, size: 20)
                    : (isCompleted
                        ? const Icon(Icons.check, color: GamingColors.accent, size: 26)
                        : Icon(isBoss ? Icons.shield : Icons.grade, color: nodeColor, size: 24)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.white30 : Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortalNode({
    required int index,
    required String title,
    required Offset offset,
    required bool isUnlocked,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: offset.dx - 32,
      top: offset.dy - 32,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: AnimatedBuilder(
              animation: _portalController,
              builder: (context, child) {
                final angle = isUnlocked ? _portalController.value * 2 * pi : 0.0;
                return Transform.rotate(
                  angle: angle,
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: isUnlocked
                            ? [GamingColors.secondary, GamingColors.primary.withValues(alpha: 0.6), Colors.transparent]
                            : [Colors.grey.shade800, const Color(0xFF0F172A), Colors.transparent],
                      ),
                      boxShadow: [
                        if (isUnlocked)
                          BoxShadow(color: GamingColors.secondary.withValues(alpha: 0.4), blurRadius: 12)
                      ],
                      border: Border.all(
                        color: isUnlocked ? GamingColors.secondary : Colors.grey.shade600,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isUnlocked ? Icons.hdr_strong : Icons.lock,
                        color: isUnlocked ? Colors.white : Colors.white24,
                        size: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? GamingColors.secondary : Colors.white24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw curved neon pathways between nodes in macro path
class MacroPathPainter extends CustomPainter {
  final Map<int, Offset> coords;
  final bool isWorld1Completed;

  MacroPathPainter({required this.coords, required this.isWorld1Completed});

  @override
  void paint(Canvas canvas, Size size) {
    if (coords.length < 2) return;

    for (int i = 1; i < coords.length; i++) {
      final p1 = coords[i]!;
      final p2 = coords[i + 1]!;
      
      // Determine if this path segment is unlocked/completed
      // Segment belongs to World 1 if node index <= 4
      final isCompleted = i < 4 || (i == 4 && isWorld1Completed);

      final paint = Paint()
        ..color = isCompleted ? GamingColors.primary : Colors.grey.shade800.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      _drawCurveDashedLine(canvas, p1, p2, paint);
    }
  }

  void _drawCurveDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    // Generate curved points using quadratic control point
    final controlX = (p1.dx + p2.dx) / 2 + (p1.dx > p2.dx ? 25 : -25);
    final controlY = (p1.dy + p2.dy) / 2;
    final controlPoint = Offset(controlX, controlY);

    const int segments = 20;
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
