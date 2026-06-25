import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/game_top_bar.dart';
import '../providers/game_state_provider.dart';
import '../providers/progress_provider.dart';
import 'package:go_router/go_router.dart';

class PlayLauncherPage extends ConsumerStatefulWidget {
  const PlayLauncherPage({super.key});

  @override
  ConsumerState<PlayLauncherPage> createState() => _PlayLauncherPageState();
}

class _PlayLauncherPageState extends ConsumerState<PlayLauncherPage> with SingleTickerProviderStateMixin {
  late AnimationController _portalController;

  @override
  void initState() {
    super.initState();
    _portalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _portalController.dispose();
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

  String _getLevelDescription(int index) {
    switch (index) {
      case 1:
        return 'Reconstruct the runic stone column on the altar pedestal using stack rules.';
      case 2:
        return 'Ticket and guide passenger spirits through portal gates in arrival order.';
      case 3:
        return 'Escape the hall of 15 security doors using sorted midpoint values.';
      case 4:
      default:
        return 'Decode the ancient guardian locks! Apply LIFO, FIFO, and binary split mechanisms.';
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

  Future<void> _launchQuest(BuildContext context, int activeLevel) async {
    final hasEnergy = await ref.read(gameStateProvider.notifier).useEnergy();
    if (hasEnergy) {
      // Smooth cinematic zoom transition simulation before launch
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cinematic zoom active! Launching quest...')),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            context.go(_getLevelRoute(activeLevel));
          }
        });
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('NO ENERGY! ⚡', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.error)),
              content: const Text('You do not have enough energy (lives) to start a quest. Go to the Shop to refuel!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/shop');
                  },
                  child: const Text('GO TO SHOP'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(levelProgressProvider);
    final activeLevel = _getActiveLevel(progress);
    final levelTitle = _getLevelTitle(activeLevel);
    final levelDesc = _getLevelDescription(activeLevel);

    return Scaffold(
      appBar: const GameTopBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Portal Animation Card
              GameCard(
                borderColor: GamingColors.secondary,
                glowColor: GamingColors.secondary,
                glowRadius: 10.0,
                child: Column(
                  children: [
                    const Text(
                      'ACTIVE PORTAL PATH',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: GamingColors.secondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Rotating portal visual
                    AnimatedBuilder(
                      animation: _portalController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _portalController.value * 2 * pi,
                          child: Container(
                            height: 140,
                            width: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  GamingColors.secondary.withValues(alpha: 0.8),
                                  GamingColors.primary.withValues(alpha: 0.5),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: GamingColors.secondary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.hourglass_empty,
                                size: 54,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Portal is stabilized. Ready for traversal.',
                      style: TextStyle(fontSize: 11, color: GamingColors.textSecondary, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Active Quest Card
              GameCard(
                title: 'CURRENT MISSION SPECIFICATION',
                borderColor: GamingColors.primary,
                child: Column(
                  children: [
                    Text(
                      levelTitle.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: GamingColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      levelDesc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: GamingColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Launch Button
              GameButton.variant(
                variant: GameButtonVariant.glowAccent,
                width: double.infinity,
                height: 52,
                label: 'LAUNCH QUEST (-1 ⚡)',
                icon: Icons.rocket_launch_rounded,
                onPressed: () => _launchQuest(context, activeLevel),
                color: GamingColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
