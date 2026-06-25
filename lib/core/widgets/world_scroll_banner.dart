import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/gaming_colors.dart';
import '../../features/worlds/presentation/providers/progress_provider.dart';

class WorldScrollBanner extends ConsumerWidget {
  const WorldScrollBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(levelProgressProvider);
    final completedCount = progress.values.where((status) => status == 'Completed').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E1A0), // Parchment yellow-gold
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC69A3F), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Shield/Crest Badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B0000), Color(0xFFD90429)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC69A3F), width: 1.5),
            ),
            child: const Icon(
              Icons.shield,
              color: Color(0xFFF7E1A0),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Center: World Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'World 1',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7A581F),
                    letterSpacing: 0.5,
                  ),
                ),
                const Text(
                  'Ancient Kingdom',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3E2723), // Dark brown
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Restore the lost knowledge',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade800.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Right: Crate Chest/Status Indicator
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    completedCount == 4
                        ? 'Congratulations! You unlocked all World 1 Relics!'
                        : 'Complete all 4 stages to unlock the Ancient Crate!',
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF3E2723).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2,
                    color: completedCount == 4 ? GamingColors.accent : const Color(0xFFC69A3F),
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedCount/4 Levels',
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
