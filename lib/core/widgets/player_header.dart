import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/gaming_colors.dart';
import '../../features/worlds/presentation/providers/game_state_provider.dart';

class PlayerHeader extends ConsumerWidget {
  const PlayerHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    // Standardize XP threshold at 100 for this level system
    const int xpThreshold = 100;

    return Row(
      children: [
        // Avatar circle with overlapping Level badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber.shade600, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: GamingColors.surfaceLight,
                backgroundImage: NetworkImage(
                  'https://api.dicebear.com/7.x/pixel-art/png?seed=Hero',
                ),
              ),
            ),
            Positioned(
              bottom: -4,
              left: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  gradient: GamingColors.levelGradient,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
                  ],
                ),
                child: Text(
                  '${gameState.level}',
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),

        // Name and XP Bar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Code Adventurer',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black38, offset: Offset(0, 1.5), blurRadius: 3),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // XP Progress Bar
              Stack(
                children: [
                  Container(
                    height: 14,
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade900.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Colors.purple.shade300.withValues(alpha: 0.3), width: 1.5),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: (gameState.xp / xpThreshold).clamp(0.0, 1.0),
                    child: Container(
                      height: 14,
                      width: 130,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '${gameState.xp} / $xpThreshold XP',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
