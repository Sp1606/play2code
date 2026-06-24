import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/responsive_layout.dart';
import 'package:go_router/go_router.dart';
import '../providers/progress_provider.dart';

class WorldsPage extends ConsumerWidget {
  const WorldsPage({super.key});

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
        return 'Boss Level: Guardian Escape';
    }
  }

  String _getLevelDescription(int index) {
    switch (index) {
      case 1:
        return 'Restore the runic stone column on the altar pedestal. Drag and drop stones in push/pop sequences.';
      case 2:
        return 'Ticket and guide the passenger spirits through the portal. They must leave in their arrival sequence.';
      case 3:
        return 'Escape the hall of 15 doors using chest divisions. Minimize search guesses before trap triggers.';
      case 4:
      default:
        return 'Decode the ancient guardian locks! Apply combined LIFO, FIFO, and binary split mechanisms.';
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

  Color _getLevelColor(int index) {
    switch (index) {
      case 1:
        return GamingColors.primary;
      case 2:
        return GamingColors.secondary;
      case 3:
        return GamingColors.accent;
      case 4:
      default:
        return GamingColors.warning;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(levelProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADVENTURE MAP'),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildLevelList(context, progress, isMobile: true),
          desktop: _buildLevelList(context, progress, isMobile: false),
        ),
      ),
    );
  }

  Widget _buildLevelList(BuildContext context, Map<int, String> progress, {required bool isMobile}) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 48.0,
        vertical: 24.0,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final levelIndex = index + 1;
        final status = progress[levelIndex] ?? 'Not Started';
        final isUnlocked = status != 'Not Started';
        final isCompleted = status == 'Completed';
        final levelColor = _getLevelColor(levelIndex);

        return Column(
          children: [
            Opacity(
              opacity: isUnlocked ? 1.0 : 0.5,
              child: GameCard(
                borderColor: isCompleted 
                    ? GamingColors.accent 
                    : (isUnlocked ? levelColor : GamingColors.surfaceLight),
                glowColor: isUnlocked && !isCompleted ? levelColor : null,
                glowRadius: isUnlocked && !isCompleted ? 8.0 : 0.0,
                title: _getLevelTitle(levelIndex).toUpperCase(),
                actions: [
                  if (!isUnlocked)
                    const Icon(Icons.lock, color: GamingColors.textMuted)
                  else if (isCompleted)
                    const Icon(Icons.check_circle, color: GamingColors.accent)
                  else
                    const Icon(Icons.play_circle_outline, color: GamingColors.primary),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLevelDescription(levelIndex),
                      style: const TextStyle(fontSize: 13, color: GamingColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusChip(status),
                        GameButton(
                          height: 36,
                          label: isCompleted 
                              ? 'REPLAY' 
                              : (isUnlocked ? 'ENTER' : 'LOCKED'),
                          color: isUnlocked ? levelColor : GamingColors.surfaceLight,
                          onPressed: isUnlocked
                              ? () {
                                  context.go(_getLevelRoute(levelIndex));
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (levelIndex < 4) ...[
              // Connecting Path Element (RPG map connection)
              Container(
                width: 4,
                height: 30,
                color: isCompleted ? GamingColors.accent : GamingColors.surfaceLight,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color statusColor;
    switch (status) {
      case 'Completed':
        statusColor = GamingColors.accent;
        break;
      case 'In Progress':
        statusColor = GamingColors.primary;
        break;
      default:
        statusColor = GamingColors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w900,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
