import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../providers/profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GAMER PROFILE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: GamingColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings placeholder clicked.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: profileState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: GamingColors.primary),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading profile: $err'),
            ),
          ),
          data: (profile) {
            return ResponsiveLayout(
              mobile: _buildMobileLayout(context, profile, ref),
              desktop: _buildDesktopLayout(context, profile, ref),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, dynamic profile, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildAvatarSection(context, profile),
        const SizedBox(height: 24),
        _buildStatsSection(context, profile),
        const SizedBox(height: 24),
        _buildAchievementsSection(context, profile),
        const SizedBox(height: 24),
        _buildActionSection(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, dynamic profile, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildAvatarSection(context, profile),
                  const SizedBox(height: 24),
                  _buildActionSection(context),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: ListView(
              children: [
                _buildStatsSection(context, profile),
                const SizedBox(height: 24),
                _buildAchievementsSection(context, profile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, dynamic profile) {
    final theme = Theme.of(context);
    return GameCard(
      borderColor: GamingColors.primary,
      child: Center(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: GamingColors.primary, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: GamingColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: GamingColors.surfaceLight,
                backgroundImage: NetworkImage(profile.avatarUrl),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.username.toUpperCase(),
              style: theme.textTheme.displayMedium?.copyWith(
                letterSpacing: 1.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile.email,
              style: const TextStyle(color: GamingColors.textMuted),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: GamingColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GamingColors.secondary),
              ),
              child: Text(
                profile.rank.toUpperCase(),
                style: const TextStyle(
                  color: GamingColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, dynamic profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STATISTICS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: GamingColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GameCard(
                child: _buildStatBadge('LEVEL', '${profile.level}', Icons.grade, GamingColors.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GameCard(
                child: _buildStatBadge('TOTAL XP', '${profile.xp}', Icons.bolt, GamingColors.warning),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GameCard(
                child: _buildStatBadge('BADGES', '${profile.achievements.length}', Icons.stars, GamingColors.accent),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBadge(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: GamingColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: GamingColors.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(BuildContext context, dynamic profile) {
    final List<Map<String, dynamic>> mockBadges = [
      {
        'id': 'HelloWorld',
        'title': 'Hello World',
        'desc': 'Write your first line of code.',
        'icon': Icons.chat_bubble_outline,
        'color': GamingColors.primary,
      },
      {
        'id': 'RecursionRider',
        'title': 'Recursion Rider',
        'desc': 'Complete the recursive challenge.',
        'icon': Icons.repeat,
        'color': GamingColors.secondary,
      },
      {
        'id': 'ArrayAce',
        'title': 'Array Ace',
        'desc': 'Master arrays and matrixes.',
        'icon': Icons.grid_on,
        'color': GamingColors.accent,
      },
      {
        'id': 'LoopLegend',
        'title': 'Loop Legend',
        'desc': 'Traverse loops with zero infinite errors.',
        'icon': Icons.sync,
        'color': GamingColors.warning,
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACHIEVEMENTS UNLOCKED',
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
          itemCount: mockBadges.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final badge = mockBadges[index];
            final hasUnlocked = profile.achievements.contains(badge['id']);

            return Opacity(
              opacity: hasUnlocked ? 1.0 : 0.4,
              child: GameCard(
                borderColor: hasUnlocked ? badge['color'] as Color : GamingColors.surfaceLight,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (badge['color'] as Color).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: hasUnlocked ? badge['color'] as Color : GamingColors.surfaceLight,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        badge['icon'] as IconData,
                        color: hasUnlocked ? badge['color'] as Color : GamingColors.textMuted,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            badge['title'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: GamingColors.textPrimary,
                            ),
                          ),
                          Text(
                            badge['desc'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: GamingColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasUnlocked)
                      const Icon(Icons.verified, color: GamingColors.accent, size: 20)
                    else
                      const Icon(Icons.lock_outline, color: GamingColors.textMuted, size: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return GameCard(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.shield_outlined, color: GamingColors.primary),
            title: const Text('Account Security'),
            trailing: const Icon(Icons.chevron_right, color: GamingColors.textMuted),
            onTap: () {},
          ),
          const Divider(color: GamingColors.surfaceLight, height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline, color: GamingColors.primary),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right, color: GamingColors.textMuted),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          GameButton(
            label: 'LOG OUT',
            color: GamingColors.error,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Firebase Auth: Logging out...'),
                  backgroundColor: GamingColors.error,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
