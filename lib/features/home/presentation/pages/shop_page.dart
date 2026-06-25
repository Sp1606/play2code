import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/game_top_bar.dart';
import '../../../worlds/presentation/providers/game_state_provider.dart';

class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key});

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> with SingleTickerProviderStateMixin {
  late AnimationController _chestAnimController;
  bool _isOpeningChest = false;
  String _chestRewardText = '';

  @override
  void initState() {
    super.initState();
    _chestAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _chestAnimController.dispose();
    super.dispose();
  }

  void _triggerChestOpening() {
    setState(() {
      _isOpeningChest = true;
      _chestRewardText = 'Decrypting ancient chest...';
    });

    // Run shake sequence
    _chestAnimController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 1500), () async {
      _chestAnimController.stop();
      final coinsReward = Random().nextInt(60) + 40; // 40-100 coins
      final gemsReward = Random().nextInt(8) + 2;   // 2-10 gems
      
      await ref.read(gameStateProvider.notifier).addCoins(coinsReward);
      await ref.read(gameStateProvider.notifier).addGems(gemsReward);

      if (!mounted) return;
      setState(() {
        _isOpeningChest = false;
        _chestRewardText = 'REWARD RECIEVED!\n🪙 +$coinsReward Coins\n💎 +$gemsReward Gems';
      });
      _showRewardDialog(context, coinsReward, gemsReward);
    });
  }

  void _showRewardDialog(BuildContext context, int coins, int gems) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              '🎉 CHEST UNLOCKED 🎉',
              style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.accent),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, size: 48, color: GamingColors.warning),
              const SizedBox(height: 16),
              const Text(
                'You extracted ancient relics from the vault!',
                textAlign: TextAlign.center,
                style: TextStyle(color: GamingColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(16)),
                    child: Text('🪙 +$coins', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.amber.shade900)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.cyan.shade50, borderRadius: BorderRadius.circular(16)),
                    child: Text('💎 +$gems', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.cyan.shade900)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: GamingColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('AWESOME!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: const GameTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GamingColors.primary, GamingColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: GamingColors.secondary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MERCHANT TERMINAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Exchange Relics & Energize!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Use your earned coins to boost resources and unlock secret items.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Chest opening zone if active
            if (_isOpeningChest || _chestRewardText.isNotEmpty)
              AnimatedBuilder(
                animation: _chestAnimController,
                builder: (context, child) {
                  final dx = sin(_chestAnimController.value * 2 * pi) * 4;
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: GameCard(
                      borderColor: GamingColors.warning,
                      glowColor: GamingColors.warning,
                      glowRadius: 12.0,
                      title: 'ANCIENT TREASURE VAULT',
                      child: Column(
                        children: [
                          const Icon(Icons.inventory_2, size: 72, color: GamingColors.warning),
                          const SizedBox(height: 12),
                          Text(
                            _chestRewardText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: GamingColors.warning),
                          ),
                          if (!_isOpeningChest) ...[
                            const SizedBox(height: 12),
                            GameButton(
                              height: 36,
                              label: 'OK',
                              onPressed: () => setState(() => _chestRewardText = ''),
                              color: GamingColors.warning,
                            )
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            if (_isOpeningChest || _chestRewardText.isNotEmpty) const SizedBox(height: 16),

            // Items grid
            const Text(
              'AVAILABLE BOOSTER ITEMS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: GamingColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
              children: [
                // Item 1: Energy Recharge
                _buildShopItem(
                  title: 'Energy Refuel',
                  description: 'Recharges your energy capacity back to 5 units.',
                  icon: '⚡',
                  cost: '20 Coins',
                  color: Colors.orange.shade700,
                  onBuy: () async {
                    if (gameState.energy >= 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Energy is already fully recharged!')),
                      );
                      return;
                    }
                    final success = await ref.read(gameStateProvider.notifier).spendCoins(20);
                    if (success) {
                      await ref.read(gameStateProvider.notifier).refillEnergy();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Energy recharged back to 5! ⚡')),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Insufficient Coins! Clear stages to earn coins.')),
                        );
                      }
                    }
                  },
                ),

                // Item 2: Mystery Chest
                _buildShopItem(
                  title: 'Golden Chest',
                  description: 'Extract mystery coins and gems from an encrypted safe.',
                  icon: '🎁',
                  cost: '50 Coins',
                  color: Colors.amber.shade800,
                  onBuy: () async {
                    final success = await ref.read(gameStateProvider.notifier).spendCoins(50);
                    if (success) {
                      if (context.mounted) {
                        _triggerChestOpening();
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Insufficient Coins! Clear stages to earn coins.')),
                        );
                      }
                    }
                  },
                ),

                // Item 3: Gem Pack
                _buildShopItem(
                  title: 'Super Gem Pack',
                  description: 'Exchange coins directly for premium ruby gems (+15 Gems).',
                  icon: '💎',
                  cost: '100 Coins',
                  color: Colors.cyan.shade700,
                  onBuy: () async {
                    final success = await ref.read(gameStateProvider.notifier).spendCoins(100);
                    if (success) {
                      await ref.read(gameStateProvider.notifier).addGems(15);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Acquired 15 ruby gems! 💎')),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Insufficient Coins!')),
                        );
                      }
                    }
                  },
                ),

                // Item 4: Premium Skin
                _buildShopItem(
                  title: 'Cyber Skin',
                  description: 'Unlock a legendary glowing avatar style skin.',
                  icon: '👾',
                  cost: '15 Gems',
                  color: Colors.purple.shade700,
                  onBuy: () async {
                    final success = await ref.read(gameStateProvider.notifier).spendGems(15);
                    if (success) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cyber Warrior skin unlocked! Set in profile.')),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Insufficient Gems! Level up to get gems.')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopItem({
    required String title,
    required String description,
    required String icon,
    required String cost,
    required Color color,
    required VoidCallback onBuy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GamingColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GamingColors.surfaceLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: GamingColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                color: GamingColors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Cost button
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: onBuy,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 1,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                cost,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
