import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/animated_progress_bar.dart';
import '../providers/home_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesState = ref.watch(dailyChallengesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PLAY2CODE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: GamingColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(dailyChallengesProvider.notifier).loadChallenges(),
          child: ResponsiveLayout(
            mobile: _buildMobileLayout(context, challengesState, ref),
            desktop: _buildDesktopLayout(context, challengesState, ref),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    AsyncValue challengesState,
    WidgetRef ref,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildStatsSection(context),
        const SizedBox(height: 24),
        _buildChallengesHeader(context),
        const SizedBox(height: 12),
        _buildChallengesList(context, challengesState, ref),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    AsyncValue challengesState,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: _buildStatsSection(context),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChallengesHeader(context),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildChallengesList(context, challengesState, ref),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GameCard(
          borderColor: GamingColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: GamingColors.surfaceLight,
                    backgroundImage: const NetworkImage(
                      'https://api.dicebear.com/7.x/pixel-art/svg?seed=CodeWarrior',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CodeWarrior',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: GamingColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Level 5 • Pro Coder',
                        style: TextStyle(color: GamingColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('XP: 1,420 / 2,000'),
                  Text(
                    '71%',
                    style: TextStyle(
                      color: GamingColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const AnimatedProgressBar(
                progress: 0.71,
                gradient: GamingColors.xpGradient,
                height: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GameCard(
                child: _buildStatItem('STREAK', '7 Days', Icons.local_fire_department, GamingColors.warning),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GameCard(
                child: _buildStatItem('COMPLETED', '28 Quest', Icons.emoji_events, GamingColors.accent),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: GamingColors.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: GamingColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildChallengesHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'DAILY QUESTS',
          style: theme.textTheme.titleLarge?.copyWith(
            letterSpacing: 1.0,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Icon(Icons.bolt, color: GamingColors.primary),
      ],
    );
  }

  Widget _buildChallengesList(
    BuildContext context,
    AsyncValue challengesState,
    WidgetRef ref,
  ) {
    return challengesState.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: GamingColors.primary),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error loading challenges: $err'),
        ),
      ),
      data: (challenges) {
        if (challenges.isEmpty) {
          return const Center(child: Text('No challenges today!'));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: challenges.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            Color difficultyColor;
            switch (challenge.difficulty.toLowerCase()) {
              case 'easy':
                difficultyColor = GamingColors.accent;
                break;
              case 'medium':
                difficultyColor = GamingColors.warning;
                break;
              default:
                difficultyColor = GamingColors.error;
            }

            return GameCard(
              borderColor: challenge.isCompleted
                  ? GamingColors.surfaceLight
                  : GamingColors.primary.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: difficultyColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: difficultyColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          challenge.difficulty.toUpperCase(),
                          style: TextStyle(
                            color: difficultyColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '+${challenge.points} XP',
                        style: const TextStyle(
                          color: GamingColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: GamingColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: GamingColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (challenge.isCompleted)
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: GamingColors.accent),
                            SizedBox(width: 4),
                            Text(
                              'COMPLETED',
                              style: TextStyle(
                                color: GamingColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      else
                        GameButton(
                          height: 36,
                          label: 'SOLVE',
                          onPressed: () {
                            ref
                                .read(dailyChallengesProvider.notifier)
                                .completeChallenge(challenge.id);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
