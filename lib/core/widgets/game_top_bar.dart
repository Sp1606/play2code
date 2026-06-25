import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/gaming_colors.dart';
import '../../features/worlds/presentation/providers/game_state_provider.dart';
import '../../features/worlds/presentation/providers/progress_provider.dart';

class GameTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const GameTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: GamingColors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: GamingColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Left Side: Avatar, Name, Level & XP
            Expanded(
              child: Row(
                children: [
                  // Avatar with level badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: GamingColors.primary, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: GamingColors.primary.withValues(alpha: 0.2),
                              blurRadius: 6,
                            )
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: GamingColors.surfaceLight,
                          backgroundImage: NetworkImage(
                            'https://api.dicebear.com/7.x/pixel-art/png?seed=Hero',
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            gradient: GamingColors.levelGradient,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
                            ],
                          ),
                          child: Text(
                            'Lvl ${gameState.level}',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  // Name and XP Bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'CodeWarrior',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: GamingColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // XP progress bar
                        Stack(
                          children: [
                            Container(
                              height: 10,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: GamingColors.surfaceLight,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: (gameState.xp / 100).clamp(0.0, 1.0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 10,
                                decoration: BoxDecoration(
                                  gradient: GamingColors.xpGradient,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: GamingColors.xpColor.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  '${gameState.xp}/100 XP',
                                  style: const TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right Side: Currencies, Energy, Settings
            Row(
              children: [
                // Coins
                _buildCurrencyChip(
                  context,
                  label: '${gameState.coins}',
                  icon: '🪙',
                  color: Colors.amber.shade700,
                  bgColor: Colors.amber.shade50,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Need more coins? Clear levels or visit the Shop!')),
                    );
                  },
                ),
                const SizedBox(width: 6),

                // Gems
                _buildCurrencyChip(
                  context,
                  label: '${gameState.gems}',
                  icon: '💎',
                  color: Colors.cyan.shade700,
                  bgColor: Colors.cyan.shade50,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gems awarded for leveling up! Buy premium avatars in the Shop.')),
                    );
                  },
                ),
                const SizedBox(width: 6),

                // Energy
                _buildCurrencyChip(
                  context,
                  label: '${gameState.energy}/5',
                  icon: '⚡',
                  color: Colors.orange.shade800,
                  bgColor: Colors.orange.shade50,
                  onTap: () => _showEnergyRefillDialog(context, ref),
                ),
                const SizedBox(width: 6),

                // Settings
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.settings_rounded, color: GamingColors.textSecondary, size: 24),
                  onPressed: () => _showSettingsDialog(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyChip(
    BuildContext context, {
    required String label,
    required String icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEnergyRefillDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: const Text('REFUEL ENERGY ⚡', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.textPrimary)),
          content: const Text(
            'Energy (Lives) are needed to attempt stages. Would you like to refuel your energy back to 5 using 20 Coins?',
            style: TextStyle(color: GamingColors.textSecondary, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: GamingColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref.read(gameStateProvider.notifier).spendCoins(20);
                if (success) {
                  await ref.read(gameStateProvider.notifier).refillEnergy();
                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Energy fully recharged to 5! ⚡')),
                    );
                  }
                } else {
                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Not enough coins! Spend 20 coins to refuel.')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GamingColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('REFUEL (-20 Coins)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              'GAME SETTINGS',
              style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.textPrimary, letterSpacing: 1.0),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.volume_up, color: GamingColors.primary),
                title: const Text('Sound Effects', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Switch(value: true, onChanged: (v) {}),
              ),
              ListTile(
                leading: const Icon(Icons.music_note, color: GamingColors.primary),
                title: const Text('Ambient Music', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Switch(value: false, onChanged: (v) {}),
              ),
              ListTile(
                leading: const Icon(Icons.vibration, color: GamingColors.primary),
                title: const Text('Haptics', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Switch(value: true, onChanged: (v) {}),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.restart_alt, color: GamingColors.error),
                title: const Text('Reset All Progress', style: TextStyle(fontWeight: FontWeight.bold, color: GamingColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmResetProgress(context, ref);
                },
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold, color: GamingColors.primary)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmResetProgress(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('RESET PROGRESS?', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.error)),
          content: const Text('This will delete all completed stages and reset currencies. Are you absolutely sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(levelProgressProvider.notifier).resetProgress();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Game progress reset successfully!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: GamingColors.error),
              child: const Text('RESET', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
