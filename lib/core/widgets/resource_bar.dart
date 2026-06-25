import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/gaming_colors.dart';
import '../../features/worlds/presentation/providers/game_state_provider.dart';

class ResourceBar extends ConsumerWidget {
  const ResourceBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Coins pill
        _buildPill(
          context,
          icon: '🪙',
          value: '${gameState.coins}',
          color: Colors.amber.shade400,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coins earned by completing levels!')),
            );
          },
        ),
        const SizedBox(width: 8),

        // Gems pill
        _buildPill(
          context,
          icon: '💎',
          value: '${gameState.gems}',
          color: Colors.purple.shade300,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gems awarded upon leveling up!')),
            );
          },
        ),
        const SizedBox(width: 8),

        // Energy pill (⚡)
        _buildPill(
          context,
          icon: '⚡',
          value: '${gameState.energy}/5',
          color: Colors.orange.shade400,
          onTap: () => _showEnergyRefillDialog(context, ref),
          showPlus: false,
        ),
      ],
    );
  }

  Widget _buildPill(
    BuildContext context, {
    required String icon,
    required String value,
    required Color color,
    required VoidCallback onTap,
    bool showPlus = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.indigo.shade900.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.indigo.shade400.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            if (showPlus) ...[
              const SizedBox(width: 4),
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ],
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
            'Spend 20 Coins to restore your energy back to 5?',
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
}
