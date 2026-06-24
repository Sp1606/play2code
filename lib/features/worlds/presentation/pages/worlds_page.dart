import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../providers/worlds_providers.dart';

class WorldsPage extends ConsumerWidget {
  const WorldsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worldsState = ref.watch(worldsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CODING WORLDS'),
      ),
      body: SafeArea(
        child: worldsState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: GamingColors.primary),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading worlds: $err'),
            ),
          ),
          data: (worlds) {
            if (worlds.isEmpty) {
              return const Center(child: Text('No worlds found.'));
            }

            return ResponsiveLayout(
              mobile: _buildGrid(context, worlds, crossAxisCount: 1),
              tablet: _buildGrid(context, worlds, crossAxisCount: 2),
              desktop: _buildGrid(context, worlds, crossAxisCount: 3),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List worlds, {required int crossAxisCount}) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.25,
      ),
      itemCount: worlds.length,
      itemBuilder: (context, index) {
        final world = worlds[index];
        final worldColor = Color(int.parse(world.colorHex));

        return Opacity(
          opacity: world.isUnlocked ? 1.0 : 0.6,
          child: GameCard(
            borderColor: world.isUnlocked ? worldColor : GamingColors.surfaceLight,
            title: world.title.toUpperCase(),
            actions: [
              if (!world.isUnlocked)
                const Icon(Icons.lock, color: GamingColors.textMuted)
              else if (world.progress == 1.0)
                const Icon(Icons.stars, color: GamingColors.accent)
            ],
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    world.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: GamingColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Challenges: ${world.completedChallenges}/${world.totalChallenges}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: GamingColors.textMuted,
                            ),
                          ),
                          Text(
                            '${(world.progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: world.isUnlocked ? worldColor : GamingColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: world.progress,
                          backgroundColor: GamingColors.surfaceLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            world.isUnlocked ? worldColor : GamingColors.textMuted,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GameButton(
                      height: 36,
                      label: world.isUnlocked ? 'ENTER' : 'LOCKED',
                      color: world.isUnlocked ? worldColor : GamingColors.surfaceLight,
                      onPressed: world.isUnlocked
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Entering ${world.title}...'),
                                  backgroundColor: worldColor,
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
