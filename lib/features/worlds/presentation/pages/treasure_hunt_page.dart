import 'package:flutter/material.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/services/firebase_service.dart';
import 'package:go_router/go_router.dart';

class TreasureHuntPage extends StatefulWidget {
  const TreasureHuntPage({super.key});

  @override
  State<TreasureHuntPage> createState() => _TreasureHuntPageState();
}

class _TreasureHuntPageState extends State<TreasureHuntPage> {
  int _currentLevel = 1;
  late List<int> _chests;
  late int _targetValue;
  late int _guessesLeft;
  final Map<int, String> _revealedChests = {}; // Map of chest index to its value/feedback
  int _selectedChestIndex = -1;
  bool _isGameOver = false;
  bool _isLevelCleared = false;
  String? _hintText;

  @override
  void initState() {
    super.initState();
    _resetLevel();
  }

  void _resetLevel() {
    _revealedChests.clear();
    _isGameOver = false;
    _isLevelCleared = false;
    _selectedChestIndex = -1;
    _hintText = 'Click any chest to check its value.';

    switch (_currentLevel) {
      case 1:
        // 7 chests sorted
        _chests = [10, 22, 35, 47, 50, 68, 85];
        _targetValue = 68;
        _guessesLeft = 3; // log2(7) rounded up is 3
        break;
      case 2:
        // 11 chests sorted
        _chests = [5, 12, 19, 27, 33, 45, 52, 60, 71, 84, 99];
        _targetValue = 19;
        _guessesLeft = 4; // log2(11) rounded up is 4
        break;
      case 3:
        // 15 chests sorted
        _chests = [3, 9, 14, 20, 28, 35, 42, 50, 58, 64, 73, 80, 88, 92, 97];
        _targetValue = 88;
        _guessesLeft = 4; // log2(15) rounded up is 4
        break;
      case 4: // Boss Level: 31 chests
        _chests = List.generate(31, (index) => (index + 1) * 3 + (index % 2));
        _targetValue = _chests[22]; // Pick value at index 22
        _guessesLeft = 5; // log2(31) rounded up is 5
        break;
    }
  }

  void _openChest(int index) {
    if (_isGameOver || _isLevelCleared || _guessesLeft <= 0 || _revealedChests.containsKey(index)) return;

    final chestVal = _chests[index];
    setState(() {
      _selectedChestIndex = index;
      _guessesLeft--;

      if (chestVal == _targetValue) {
        _revealedChests[index] = '$chestVal (FOUND!)';
        _isLevelCleared = true;
        _hintText = 'Congratulations! You found the treasure key!';
        _saveProgress();
      } else if (chestVal < _targetValue) {
        _revealedChests[index] = '$chestVal (<)';
        _hintText = 'The target is HIGHER than $chestVal. The treasure must be to the RIGHT!';
        // Auto-disable all chests to the left
        for (int i = 0; i <= index; i++) {
          if (!_revealedChests.containsKey(i)) {
            _revealedChests[i] = 'X';
          }
        }
      } else {
        _revealedChests[index] = '$chestVal (>)';
        _hintText = 'The target is LOWER than $chestVal. The treasure must be to the LEFT!';
        // Auto-disable all chests to the right
        for (int i = index; i < _chests.length; i++) {
          if (!_revealedChests.containsKey(i)) {
            _revealedChests[i] = 'X';
          }
        }
      }

      if (_guessesLeft <= 0 && !_isLevelCleared) {
        _isGameOver = true;
        _hintText = 'Out of guesses! The treasure key was hidden in chest value $_targetValue.';
      }
    });
  }

  Future<void> _saveProgress() async {
    await FirebaseService.instance.updateGameProgress('treasure_hunt', _currentLevel, _currentLevel == 4);
  }

  void _nextLevel() {
    if (_currentLevel < 4) {
      setState(() {
        _currentLevel++;
        _resetLevel();
      });
    } else {
      context.go('/reflection/treasure_hunt');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('TREASURE HUNT - LEVEL $_currentLevel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/worlds'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        key: ValueKey('treasure_level_$_currentLevel'),
        child: Column(
          children: [
            // Level Description
            GameCard(
              title: _currentLevel == 4 ? 'BOSS QUEST: THE ARCHIVE OF 31 CHESTS' : 'QUEST OVERVIEW',
              borderColor: _currentLevel == 4 ? GamingColors.warning : GamingColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find the chest containing the value $_targetValue. The chests are SORTED in ascending order. Eliminate halves to save moves!',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TARGET KEY: $_targetValue', style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.primary, fontSize: 16)),
                      Text('GUESSES REMAINING: $_guessesLeft', style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.error)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Chest Grid/List Area
            Expanded(
              child: GameCard(
                title: 'SORTED CHESTS',
                child: Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 6 : 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _chests.length,
                    itemBuilder: (context, index) {
                      final isRevealed = _revealedChests.containsKey(index);
                      final feedback = _revealedChests[index];
                      final isDisabled = feedback == 'X';
                      final isTarget = feedback?.contains('FOUND') ?? false;

                      Color chestColor = GamingColors.surfaceLight;
                      IconData chestIcon = Icons.inventory_2;

                      if (isRevealed) {
                        if (isTarget) {
                          chestColor = GamingColors.accent.withValues(alpha: 0.2);
                          chestIcon = Icons.vpn_key;
                        } else if (isDisabled) {
                          chestColor = Colors.grey.shade200;
                          chestIcon = Icons.block;
                        } else {
                          chestColor = GamingColors.primary.withValues(alpha: 0.1);
                          chestIcon = Icons.drafts;
                        }
                      }

                      return GestureDetector(
                        onTap: (!isRevealed && !_isGameOver && !_isLevelCleared) 
                            ? () => _openChest(index) 
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: chestColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isTarget 
                                  ? GamingColors.accent 
                                  : (index == _selectedChestIndex ? GamingColors.primary : Colors.grey.shade300),
                              width: (index == _selectedChestIndex || isTarget) ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                chestIcon,
                                color: isTarget 
                                    ? GamingColors.accent 
                                    : (isDisabled ? Colors.grey : GamingColors.primary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isRevealed 
                                    ? (isDisabled ? '-' : feedback!.split(' ')[0]) 
                                    : 'Chest ${index + 1}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isTarget ? GamingColors.accent : GamingColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Hint/Feedback Area
            if (_hintText != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: GamingColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GamingColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _hintText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GamingColors.primary),
                ),
              ),

            // Action Card
            if (_isLevelCleared)
              _buildSuccessCard(theme)
            else if (_isGameOver)
              _buildFailureCard(theme)
            else
              GameCard(
                title: 'EXPLORATION STATS',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('TOTAL CHESTS', '${_chests.length}'),
                    _buildStatItem('MIN GUESSES POSSIBLE', 'log₂(${_chests.length}) ≈ ${_guessesLeft + 1}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: GamingColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: GamingColors.textMuted)),
      ],
    );
  }

  Widget _buildSuccessCard(ThemeData theme) {
    return GameCard(
      borderColor: GamingColors.accent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TREASURE RETRIEVED!', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.accent, fontSize: 16)),
              Text('You used search division rules.', style: TextStyle(fontSize: 12)),
            ],
          ),
          GameButton(
            height: 38,
            label: _currentLevel == 4 ? 'REVEAL PATTERN' : 'NEXT STAGE',
            onPressed: _nextLevel,
            color: GamingColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildFailureCard(ThemeData theme) {
    return GameCard(
      borderColor: GamingColors.error,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TREASURE LOST!', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.error, fontSize: 16)),
              Text('Linear searching took too many moves.', style: TextStyle(fontSize: 12)),
            ],
          ),
          GameButton(
            height: 38,
            label: 'TRY AGAIN',
            onPressed: () => setState(_resetLevel),
            color: GamingColors.error,
          ),
        ],
      ),
    );
  }
}
