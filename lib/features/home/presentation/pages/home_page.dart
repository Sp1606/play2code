import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../worlds/presentation/providers/progress_provider.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
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

  String _getLevelName(int index) {
    switch (index) {
      case 1:
        return 'The Lost Stones';
      case 2:
        return 'Temple Memory';
      case 3:
        return 'Trap Escape';
      case 4:
      default:
        return 'Guardian Escape (Boss)';
    }
  }

  String _getLevelSubtitle(int index) {
    switch (index) {
      case 1:
        return 'Stack Sequence Ordering (LIFO)';
      case 2:
        return 'Passenger Queueing Portals (FIFO)';
      case 3:
        return 'Binary Search Division';
      case 4:
      default:
        return 'The Ultimate Logic Override';
    }
  }

  int _getDifficultyStars(int index) {
    switch (index) {
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 3;
      case 4:
      default:
        return 5;
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
  Widget build(BuildContext context) {
    final progress = ref.watch(levelProgressProvider);
    final profileState = ref.watch(userProfileProvider);
    final activeLevelIndex = _getActiveLevel(progress);
    final activeLevelName = _getLevelName(activeLevelIndex);
    final activeLevelSubtitle = _getLevelSubtitle(activeLevelIndex);
    final difficulty = _getDifficultyStars(activeLevelIndex);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A), // Dark slate
              Color(0xFF1E1B4B), // Dark indigo
              Color(0xFF311042), // Dark violet-eggplant
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: profileState.when(
          loading: () => const Center(child: CircularProgressIndicator(color: GamingColors.primary)),
          error: (err, stack) => Center(child: Text('Error loading profile: $err', style: const TextStyle(color: Colors.white))),
          data: (profile) {
            final xpPercent = (profile.xp % 500) / 500.0;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- TOP PLAYER HEADER BAR ---
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: GamingColors.surfaceLight,
                          backgroundImage: NetworkImage(profile.avatarUrl),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.username.toUpperCase(),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'LVL ${profile.level}',
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: GamingColors.secondary),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: xpPercent,
                                        minHeight: 4,
                                        backgroundColor: Colors.white10,
                                        valueColor: const AlwaysStoppedAnimation<Color>(GamingColors.primary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Resource Pill: Coins & Shop Button
                        GestureDetector(
                          onTap: () => context.push('/shop'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: GamingColors.warning.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars, color: GamingColors.warning, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${profile.xp} XP',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.storefront, color: GamingColors.accent, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- CURRENT WORLD SECTOR BANNER ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GamingColors.primary.withValues(alpha: 0.4), width: 1.5),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=500&auto=format&fit=crop'),
                          fit: BoxFit.cover,
                          opacity: 0.15,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CURRENT SECTOR',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: GamingColors.textMuted, letterSpacing: 1.0),
                              ),
                              Chip(
                                label: Text('WORLD 1', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                                backgroundColor: GamingColors.primary,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'ANCIENT KINGDOM',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Explore the runic monuments to unlock the secrets of fundamental algorithm operations.',
                            style: TextStyle(fontSize: 11, color: Colors.white70, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- ACTIVE QUEST BOARD ---
                    const Text(
                      'ACTIVE MISSION',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: GamingColors.textPrimary, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 10),
                    GameCard(
                      borderColor: GamingColors.secondary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'LEVEL $activeLevelIndex: $activeLevelName'.toUpperCase(),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: GamingColors.secondary),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < difficulty ? Icons.star : Icons.star_border,
                                    color: GamingColors.warning,
                                    size: 14,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            activeLevelSubtitle,
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          const Divider(color: Colors.white12, height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bolt, color: GamingColors.warning, size: 14),
                                  SizedBox(width: 4),
                                  Text('REWARD: 50 XP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.query_builder, color: GamingColors.accent, size: 14),
                                  SizedBox(width: 4),
                                  Text('EST: 5 MINS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- LARGE PULSING PLAY BUTTON ---
                    Center(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: GamingColors.primary.withValues(alpha: 0.3 + (_pulseController.value * 0.2)),
                                  blurRadius: 15 + (_pulseController.value * 15),
                                  spreadRadius: 2 + (_pulseController.value * 4),
                                )
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: GamingColors.primary,
                          child: InkWell(
                            onTap: () {
                              // Direct launch of current active level
                              final route = _getLevelRoute(activeLevelIndex);
                              context.go(route);
                            },
                            borderRadius: BorderRadius.circular(56),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
                                Text(
                                  'PLAY',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'CONTINUE ADVENTURE',
                        style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- QUICK NAV LINKS ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickLink(
                            context,
                            label: 'ARENA',
                            icon: Icons.emoji_events,
                            color: GamingColors.secondary,
                            onTap: () => context.push('/arena'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickLink(
                            context,
                            label: 'CODEX',
                            icon: Icons.menu_book,
                            color: GamingColors.accent,
                            onTap: () => context.push('/reveal'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickLink(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
