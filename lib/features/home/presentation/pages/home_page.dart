import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../worlds/presentation/providers/progress_provider.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  int _getActiveLevel(Map<int, String> progress) {
    for (int i = 1; i <= 4; i++) {
      if (progress[i] != 'Completed') {
        return i;
      }
    }
    return 4; // Default to boss if all completed
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
        return 'Boss Level: Guardian Escape';
    }
  }

  String _getLevelDescription(int index) {
    switch (index) {
      case 1:
        return 'Restore the runic stone column on the altar pedestal. Take care: you can only push stones onto the top or pop them from the top of the stack.';
      case 2:
        return 'Ticket and guide the trapped spirits through the portal gates. Ensure they exit in the exact chronological order of their arrival.';
      case 3:
        return 'Escape the collapsing hall of 15 doors. Use sensory feedback from each chest room to isolate the escape path with minimal guesses.';
      case 4:
      default:
        return 'Decode the ancient guardian locks! Apply LIFO stacking keys, FIFO queue gates, and binary division maps to slip past the Guardian.';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(levelProgressProvider);
    final activeLevel = _getActiveLevel(progress);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PLAY2CODE ADVENTURE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield, color: GamingColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aegis shield active. Guarding algorithms!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(context, activeLevel, progress),
          desktop: _buildDesktopLayout(context, activeLevel, progress),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, int activeLevel, Map<int, String> progress) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHeroHeader(context),
        const SizedBox(height: 20),
        _buildContinueAdventureSection(context, activeLevel),
        const SizedBox(height: 20),
        _buildCurrentMissionCard(context, activeLevel),
        const SizedBox(height: 20),
        _buildWorldProgressionCard(context, progress),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, int activeLevel, Map<int, String> progress) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroHeader(context),
                  const SizedBox(height: 20),
                  _buildContinueAdventureSection(context, activeLevel),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Right Column
          Expanded(
            flex: 3,
            child: ListView(
              children: [
                _buildCurrentMissionCard(context, activeLevel),
                const SizedBox(height: 20),
                _buildWorldProgressionCard(context, progress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    final theme = Theme.of(context);
    return GameCard(
      borderColor: GamingColors.primary,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: GamingColors.primary, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: GamingColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                )
              ],
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: GamingColors.surfaceLight,
              backgroundImage: NetworkImage(
                'https://api.dicebear.com/7.x/pixel-art/svg?seed=CodeWarrior',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HERO LOBBY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: GamingColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CodeWarrior',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Rank: Adept Algorithmist (Level 5)',
                  style: TextStyle(fontSize: 11, color: GamingColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueAdventureSection(BuildContext context, int activeLevel) {
    return GameCard(
      borderColor: GamingColors.accent,
      glowColor: GamingColors.accent,
      glowRadius: 16,
      child: Column(
        children: [
          const Text(
            'Resume your quest immediately:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GameButton.variant(
            variant: GameButtonVariant.glowAccent,
            label: 'CONTINUE ADVENTURE',
            icon: Icons.play_arrow,
            width: double.infinity,
            onPressed: () => context.go(_getLevelRoute(activeLevel)),
            color: GamingColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMissionCard(BuildContext context, int activeLevel) {
    return GameCard(
      title: 'ACTIVE QUEST',
      borderColor: GamingColors.secondary,
      actions: const [
        Icon(Icons.shield_outlined, color: GamingColors.secondary),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GamingColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.explore, color: GamingColors.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLevelTitle(activeLevel).toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    const Text('World 1: Fundamental Thinking', style: TextStyle(fontSize: 11, color: GamingColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _getLevelDescription(activeLevel),
            style: const TextStyle(fontSize: 12, height: 1.4, color: GamingColors.textSecondary),
          ),
          const SizedBox(height: 16),
          GameButton(
            width: double.infinity,
            height: 40,
            label: 'LAUNCH QUEST',
            onPressed: () => context.go(_getLevelRoute(activeLevel)),
            color: GamingColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildWorldProgressionCard(BuildContext context, Map<int, String> progress) {
    return GameCard(
      title: 'WORLD PROGRESSION',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WORLD 1: FUNDAMENTAL THINKING',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          _buildLevelStatusRow(1, progress[1] ?? 'Not Started'),
          const SizedBox(height: 10),
          _buildLevelStatusRow(2, progress[2] ?? 'Not Started'),
          const SizedBox(height: 10),
          _buildLevelStatusRow(3, progress[3] ?? 'Not Started'),
          const SizedBox(height: 10),
          _buildLevelStatusRow(4, progress[4] ?? 'Not Started'),
        ],
      ),
    );
  }

  Widget _buildLevelStatusRow(int levelIndex, String status) {
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _getLevelTitle(levelIndex),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            border: Border.all(color: statusColor),
            borderRadius: BorderRadius.circular(20),
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
        ),
      ],
    );
  }
}
