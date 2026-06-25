import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_top_bar.dart';
import '../providers/progress_provider.dart';

class WorldsPage extends ConsumerWidget {
  const WorldsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(levelProgressProvider);
    final isWorld1Completed = progress[4] == 'Completed';

    final List<Map<String, dynamic>> worldsData = [
      {
        'index': 1,
        'title': 'Ancient Kingdom',
        'theme': '🏛 Temple • 🪨 Stone Pillars • 🔥 Torches',
        'description': 'Discover core structures while escaping the runic temple rooms.',
        'gradient': [Colors.amber.shade700, Colors.orange.shade900],
        'isUnlocked': true,
        'items': ['🏛', '🪨', '🔥'],
      },
      {
        'index': 2,
        'title': 'Enchanted Forest',
        'theme': '🌳 Giant Trees • 🍄 Mushrooms • 🌉 Wooden Bridges',
        'description': 'Traverse the mossy valley and balance memory flows among the giants.',
        'gradient': [Colors.green.shade600, Colors.teal.shade900],
        'isUnlocked': isWorld1Completed,
        'items': ['🌳', '🍄', '🌉'],
      },
      {
        'index': 3,
        'title': 'Pirate Islands',
        'theme': '🏴‍☠️ Ships • 🗺 Treasure • 🌊 Ocean Waves',
        'description': 'Sail between the secret binary coordinates of the sea.',
        'gradient': [Colors.blue.shade600, Colors.indigo.shade900],
        'isUnlocked': false,
        'items': ['🏴‍☠️', '🗺', '🌊'],
      },
      {
        'index': 4,
        'title': 'Crystal Mountains',
        'theme': '❄️ Ice Caves • 💎 Crystals • ⛰ Peaks',
        'description': 'Scale the freezing peaks and align crystal refractions.',
        'gradient': [Colors.cyan.shade600, Colors.blueGrey.shade900],
        'isUnlocked': false,
        'items': ['❄️', '💎', '⛰'],
      },
      {
        'index': 5,
        'title': 'Sky Realm',
        'theme': '☁️ Floating Islands • ⚡ Lightning • ✨ Magic Portals',
        'description': 'Ascend to the heavens and breach the final recursion gateway.',
        'gradient': [Colors.purple.shade600, Colors.deepPurple.shade900],
        'isUnlocked': false,
        'items': ['☁️', '⚡', '✨'],
      },
    ];

    return Scaffold(
      appBar: const GameTopBar(),
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADVENTURE WORLD MAP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: GamingColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Traverse Magical Sectors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Horizontal Worlds Carousel
            Expanded(
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: worldsData.length,
                itemBuilder: (context, index) {
                  final world = worldsData[index];
                  final isUnlocked = world['isUnlocked'] as bool;
                  final worldIndex = world['index'] as int;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isUnlocked 
                            ? world['gradient'] as List<Color> 
                            : [Colors.grey.shade800, Colors.grey.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isUnlocked ? Colors.white70 : Colors.white10,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isUnlocked 
                              ? (world['gradient'] as List<Color>).first 
                              : Colors.black).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Giant background watermark emoji
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Opacity(
                            opacity: 0.15,
                            child: Text(
                              world['items'][0],
                              style: const TextStyle(fontSize: 160),
                            ),
                          ),
                        ),

                        // World Content
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // World number badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'WORLD $worldIndex',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // World Title
                              Text(
                                world['title'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Theme Elements Row
                              Row(
                                children: (world['items'] as List<String>).map((item) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black26,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(item, style: const TextStyle(fontSize: 16)),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),

                              Text(
                                world['theme'],
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Description
                              Expanded(
                                child: Text(
                                  world['description'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    height: 1.4,
                                  ),
                                ),
                              ),

                              // Selection / Locked state button
                              SizedBox(
                                width: double.infinity,
                                child: isUnlocked
                                    ? GameButton(
                                        height: 44,
                                        label: 'ENTER SECTOR',
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Entering ${world['title']}!')),
                                          );
                                          // Worlds 1 is main lobby, just redirect to Lobby tab!
                                          Navigator.of(context).popUntil((route) => route.isFirst);
                                        },
                                        color: Colors.white.withValues(alpha: 0.2),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.lock, color: Colors.white38),
                                          const SizedBox(width: 8),
                                          Text(
                                            worldIndex == 2 
                                                ? 'CLEAR WORLD 1 TO UNLOCK' 
                                                : 'LOCKED',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                              color: Colors.white38,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
