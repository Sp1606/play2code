import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../presentation/providers/progress_provider.dart';
import 'package:go_router/go_router.dart';

class StackTemplePage extends ConsumerStatefulWidget {
  const StackTemplePage({super.key});

  @override
  ConsumerState<StackTemplePage> createState() => _StackTemplePageState();
}

class _StackTemplePageState extends ConsumerState<StackTemplePage> {
  final List<String> _altarStones = [];
  final List<String> _targetStones = ['Bronze Stone', 'Gold Stone', 'Silver Stone'];
  final List<String> _availableStones = ['Bronze Stone', 'Silver Stone', 'Gold Stone'];

  int _movesLeft = 8;
  bool _isGameOver = false;
  bool _isCleared = false;
  String? _feedback;

  void _resetLevel() {
    setState(() {
      _altarStones.clear();
      _movesLeft = 8;
      _isGameOver = false;
      _isCleared = false;
      _feedback = 'Drag runic stones onto the altar pedestal to build the pillar.';
    });
  }

  void _pushStone(String stone) {
    if (_isGameOver || _isCleared || _movesLeft <= 0) return;

    setState(() {
      _altarStones.add(stone);
      _movesLeft--;
      _feedback = 'Placed $stone onto the top of the altar.';
      _checkWinCondition();
    });
  }

  void _popStone() {
    if (_isGameOver || _isCleared || _movesLeft <= 0 || _altarStones.isEmpty) return;

    final removed = _altarStones.removeLast();
    setState(() {
      _movesLeft--;
      _feedback = 'Removed top stone: $removed.';
      _checkWinCondition();
    });
  }

  void _checkWinCondition() {
    if (_altarStones.length == _targetStones.length) {
      bool match = true;
      for (int i = 0; i < _altarStones.length; i++) {
        if (_altarStones[i] != _targetStones[i]) {
          match = false;
          break;
        }
      }
      if (match) {
        _isCleared = true;
        _feedback = 'The ancient runes align! Path unlocked!';
        _saveProgress();
      }
    }

    if (_movesLeft <= 0 && !_isCleared) {
      _isGameOver = true;
      _feedback = 'The energy fizzled out. Reset the runes to try again.';
    }
  }

  Future<void> _saveProgress() async {
    // Write completion status persistently to SharedPreferences
    await ref.read(levelProgressProvider.notifier).completeLevel(1);
  }

  Color _getStoneColor(String stone) {
    switch (stone) {
      case 'Bronze Stone':
        return Colors.brown.shade400;
      case 'Silver Stone':
        return Colors.blueGrey.shade300;
      case 'Gold Stone':
        return Colors.amber.shade600;
      default:
        return GamingColors.surfaceLight;
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text('LEVEL 1: THE LOST STONES'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/worlds'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Objective Card
            GameCard(
              title: 'ALTAR BLUEPRINT',
              borderColor: GamingColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reconstruct the stone pillar shown in the blueprint. Drag stones onto the pedestal. Note: You can only modify the pillar by adding to or removing from the TOP.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'POWER CHARGES LEFT: $_movesLeft',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.error),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pedestals
            Expanded(
              child: Row(
                children: [
                  // Blueprint Pedestal
                  Expanded(
                    child: GameCard(
                      title: 'BLUEPRINT',
                      child: Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: _targetStones.reversed.map((stone) {
                            return _buildStoneTile(stone);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Altar Pedestal (DragTarget)
                  Expanded(
                    child: DragTarget<String>(
                      onAcceptWithDetails: (details) => _pushStone(details.data),
                      builder: (context, candidateData, rejectedData) {
                        final isOver = candidateData.isNotEmpty;

                        return GameCard(
                          title: 'ALTAR PEDESTAL',
                          borderColor: isOver ? GamingColors.accent : GamingColors.surfaceLight,
                          child: Expanded(
                            child: _altarStones.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Pedestal is empty.\nDrag runes here!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: GamingColors.textMuted, fontSize: 12),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: _altarStones.reversed.map((stone) {
                                      return _buildStoneTile(stone, isInteractable: true);
                                    }).toList(),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Feedback Card
            if (_feedback != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _isCleared 
                      ? GamingColors.accent.withValues(alpha: 0.1) 
                      : (_isGameOver ? GamingColors.error.withValues(alpha: 0.1) : GamingColors.primary.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isCleared ? GamingColors.accent : (_isGameOver ? GamingColors.error : GamingColors.primary.withValues(alpha: 0.3)),
                  ),
                ),
                child: Text(
                  _feedback!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isCleared ? GamingColors.accent : (_isGameOver ? GamingColors.error : GamingColors.primary),
                  ),
                ),
              ),

            // Drag Items and controls
            if (_isCleared)
              _buildSuccessCard()
            else if (_isGameOver)
              _buildFailureCard()
            else
              _buildControlPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoneTile(String stone, {bool isInteractable = false}) {
    final tile = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _getStoneColor(stone),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Center(
        child: Text(
          stone.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );

    if (isInteractable && stone == _altarStones.last) {
      // Top element is clickable to pop
      return GestureDetector(
        onTap: _popStone,
        child: Stack(
          alignment: Alignment.center,
          children: [
            tile,
            Positioned(
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                child: const Icon(Icons.remove, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      );
    }

    return tile;
  }

  Widget _buildControlPanel() {
    return GameCard(
      title: 'STONES ON THE GROUND',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _availableStones.map((stone) {
          return Draggable<String>(
            data: stone,
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 120,
                child: _buildStoneTile(stone),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.4,
              child: SizedBox(
                width: 80,
                child: _buildStoneTile(stone),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: GamingColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GamingColors.textMuted.withValues(alpha: 0.5)),
              ),
              child: Text(
                stone.split(' ')[0],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return GameCard(
      borderColor: GamingColors.accent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BLUEPRINT COMPLETE!', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.accent, fontSize: 15)),
              Text('The altar energy clears the pathway.', style: TextStyle(fontSize: 12)),
            ],
          ),
          GameButton(
            height: 38,
            label: 'LEAVE ROOM',
            onPressed: () => context.go('/reflection/level_1'),
            color: GamingColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildFailureCard() {
    return GameCard(
      borderColor: GamingColors.error,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('COLUMN DISSOLVED', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.error, fontSize: 15)),
              Text('Runes depleted of active charges.', style: TextStyle(fontSize: 12)),
            ],
          ),
          GameButton(
            height: 38,
            label: 'RESET RUNES',
            onPressed: _resetLevel,
            color: GamingColors.error,
          ),
        ],
      ),
    );
  }
}
