import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/animated_progress_bar.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PLAY2CODE ADVENTURE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: GamingColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shield defenses fully active!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(context),
          desktop: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHeroHeader(context),
        const SizedBox(height: 20),
        _buildContinueAdventureSection(context),
        const SizedBox(height: 20),
        _buildCurrentMissionCard(context),
        const SizedBox(height: 20),
        _buildWorldProgressionCard(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Hero status and Continue button
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroHeader(context),
                  const SizedBox(height: 20),
                  _buildContinueAdventureSection(context),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Right Column: Active mission and world progress
          Expanded(
            flex: 3,
            child: ListView(
              children: [
                _buildCurrentMissionCard(context),
                const SizedBox(height: 20),
                _buildWorldProgressionCard(context),
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
              border: Border.all(color: GamingColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: GamingColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
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
                Text(
                  'WELCOME BACK, HERO!',
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
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

  Widget _buildContinueAdventureSection(BuildContext context) {
    return GameCard(
      borderColor: GamingColors.accent,
      glowColor: GamingColors.accent,
      glowRadius: 15,
      child: Column(
        children: [
          const Text(
            'Ready to resume your algorithm quest?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GameButton.variant(
            variant: GameButtonVariant.glowAccent,
            label: 'CONTINUE ADVENTURE',
            icon: Icons.play_arrow,
            width: double.infinity,
            onPressed: () => context.go('/worlds'),
            color: GamingColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMissionCard(BuildContext context) {
    return GameCard(
      title: 'ACTIVE QUEST',
      borderColor: GamingColors.secondary,
      actions: [
        const Icon(Icons.bolt, color: GamingColors.secondary),
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
                child: const Icon(Icons.landscape, color: GamingColors.secondary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stack Temple'.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Text('Stage 3: The Tower of LIFO', style: TextStyle(fontSize: 11, color: GamingColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Objective: Assemble blocks matching the blueprint. Keep in mind: you can only push new blocks or pop off the top of the stack. Retrieve the LIFO scroll to proceed.',
            style: TextStyle(fontSize: 12, height: 1.4, color: GamingColors.textSecondary),
          ),
          const SizedBox(height: 16),
          GameButton(
            width: double.infinity,
            height: 40,
            label: 'LAUNCH QUEST',
            onPressed: () => context.go('/game/stack_temple'),
            color: GamingColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildWorldProgressionCard(BuildContext context) {
    return GameCard(
      title: 'WORLD PROGRESSION',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WORLD 1: FUNDAMENTAL THINKING',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                '66% Complete',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GamingColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const AnimatedProgressBar(
            progress: 0.66,
            gradient: GamingColors.xpGradient,
            height: 10,
          ),
          const SizedBox(height: 16),
          _buildSubProgressRow('Stack Temple', 1.0, GamingColors.accent),
          const SizedBox(height: 8),
          _buildSubProgressRow('Queue Station', 0.5, GamingColors.primary),
          const SizedBox(height: 8),
          _buildSubProgressRow('Treasure Hunt', 0.0, GamingColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildSubProgressRow(String title, double value, Color accentColor) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, color: GamingColors.textSecondary),
          ),
        ),
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: GamingColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 32,
          child: Text(
            '${(value * 100).toInt()}%',
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
