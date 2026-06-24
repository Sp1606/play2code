import 'package:flutter/material.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import 'package:go_router/go_router.dart';

class AlgorithmArenaPage extends StatelessWidget {
  const AlgorithmArenaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock active Arena competition data
    const activeChallengeTitle = 'WEEKLY ARENA #24: HEAP RUSH';
    const activeChallengeDesc = 'Organize unstructured integers into a Max-Heap structure using the fewest operations. Compete globally with engineering students!';
    const countdownText = '1d 14h 22m remaining';

    final List<Map<String, dynamic>> leaderboard = [
      {'rank': 1, 'name': 'AlgoAce', 'score': 980, 'time': '1m 24s', 'isUser': false},
      {'rank': 2, 'name': 'LIFO_Master', 'score': 945, 'time': '1m 40s', 'isUser': false},
      {'rank': 3, 'name': 'CodeWarrior', 'score': 890, 'time': '1m 58s', 'isUser': true}, // Highlight current user
      {'rank': 4, 'name': 'RecursionRider', 'score': 850, 'time': '2m 12s', 'isUser': false},
      {'rank': 5, 'name': 'GraphGuru', 'score': 810, 'time': '2m 30s', 'isUser': false},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALGORITHM ARENA'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Arena banner
            GameCard(
              title: activeChallengeTitle,
              borderColor: GamingColors.secondary,
              glowColor: GamingColors.secondary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    activeChallengeDesc,
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer, color: GamingColors.secondary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            countdownText,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.secondary, fontSize: 12),
                          ),
                        ],
                      ),
                      const Chip(
                        label: Text('ACTIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                        backgroundColor: GamingColors.secondary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Compete Button
            GameButton(
              width: double.infinity,
              label: 'ENTER ARENA CHALLENGE',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Launching Heap Rush Arena editor...'),
                    backgroundColor: GamingColors.secondary,
                  ),
                );
              },
              color: GamingColors.secondary,
            ),
            const SizedBox(height: 24),

            // Leaderboard section
            const Text(
              'ARENA LEADERBOARD',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: GamingColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaderboard.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                final isUser = entry['isUser'] as bool;

                return Container(
                  decoration: BoxDecoration(
                    color: isUser ? GamingColors.primary.withValues(alpha: 0.1) : GamingColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUser ? GamingColors.primary : GamingColors.surfaceLight,
                      width: isUser ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: entry['rank'] == 1 
                          ? GamingColors.levelColor 
                          : (entry['rank'] == 2 ? GamingColors.textMuted : GamingColors.surfaceLight),
                      child: Text(
                        '#${entry['rank']}',
                        style: TextStyle(
                          color: entry['rank'] == 1 ? Colors.white : GamingColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      entry['name'] as String,
                      style: TextStyle(
                        fontWeight: isUser ? FontWeight.w800 : FontWeight.normal,
                        color: isUser ? GamingColors.primary : GamingColors.textPrimary,
                      ),
                    ),
                    subtitle: Text('Time taken: ${entry['time']}'),
                    trailing: Text(
                      '${entry['score']} PTS',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: GamingColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
