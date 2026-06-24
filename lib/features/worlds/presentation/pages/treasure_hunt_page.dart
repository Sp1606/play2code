import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../providers/progress_provider.dart';
import 'package:go_router/go_router.dart';

class TreasureHuntPage extends ConsumerStatefulWidget {
  const TreasureHuntPage({super.key});

  @override
  ConsumerState<TreasureHuntPage> createState() => _TreasureHuntPageState();
}

class _TreasureHuntPageState extends ConsumerState<TreasureHuntPage> {

  late List<int> _doors;
  late int _targetCode;
  late int _guessesLeft;
  final Map<int, String> _revealedDoors = {}; // Map of door index to its value/feedback
  int _selectedDoorIndex = -1;
  bool _isGameOver = false;
  bool _isLevelCleared = false;
  String? _hintText;

  @override
  void initState() {
    super.initState();
    _resetLevel();
  }

  void _resetLevel() {
    _revealedDoors.clear();
    _isGameOver = false;
    _isLevelCleared = false;
    _selectedDoorIndex = -1;
    _hintText = 'Interact with any door to reveal its passcode number.';

    // 15 doors sorted
    _doors = [3, 9, 14, 20, 28, 35, 42, 50, 58, 64, 73, 80, 88, 92, 97];
    _targetCode = 88;
    _guessesLeft = 4; // log2(15) rounded up is 4 guesses limit
  }

  void _openDoor(int index) {
    if (_isGameOver || _isLevelCleared || _guessesLeft <= 0 || _revealedDoors.containsKey(index)) return;

    final doorVal = _doors[index];
    setState(() {
      _selectedDoorIndex = index;
      _guessesLeft--;

      if (doorVal == _targetCode) {
        _revealedDoors[index] = '$doorVal (ACCESS)';
        _isLevelCleared = true;
        _hintText = 'System override successful! The escape door unlocks!';
        _saveProgress();
      } else if (doorVal < _targetCode) {
        _revealedDoors[index] = '$doorVal (<)';
        _hintText = 'The keycode is HIGHER than $doorVal. The lock mechanism responds further to the RIGHT!';
        // Auto-disable all doors to the left
        for (int i = 0; i <= index; i++) {
          if (!_revealedDoors.containsKey(i)) {
            _revealedDoors[i] = 'X';
          }
        }
      } else {
        _revealedDoors[index] = '$doorVal (>)';
        _hintText = 'The keycode is LOWER than $doorVal. The lock mechanism responds further to the LEFT!';
        // Auto-disable all doors to the right
        for (int i = index; i < _doors.length; i++) {
          if (!_revealedDoors.containsKey(i)) {
            _revealedDoors[i] = 'X';
          }
        }
      }

      if (_guessesLeft <= 0 && !_isLevelCleared) {
        _isGameOver = true;
        _hintText = 'Security lock triggered! The target code was $_targetCode.';
      }
    });
  }

  Future<void> _saveProgress() async {
    await ref.read(levelProgressProvider.notifier).completeLevel(3);
  }

  void _finishLevel() {
    context.go('/reflection/level_3');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LEVEL 3: TRAP ESCAPE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/worlds'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        key: const ValueKey('trap_escape_level_3'),
        child: Column(
          children: [
            // Level Description
            GameCard(
              title: 'ESCORT OBJECTIVE',
              borderColor: GamingColors.accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Locate the secret escape door corresponding to the target code. The doors are calibrated in ascending sequence. Systematically divide your search field to avoid setting off the alarm.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TARGET KEYCODE: $_targetCode', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.accent, fontSize: 16),
                      ),
                      Text(
                        'OVERRIDE CHARGES: $_guessesLeft', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.error),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Doors Grid Area
            Expanded(
              child: GameCard(
                title: 'SECURITY DOORS',
                child: Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _doors.length,
                    itemBuilder: (context, index) {
                      final isRevealed = _revealedDoors.containsKey(index);
                      final feedback = _revealedDoors[index];
                      final isDisabled = feedback == 'X';
                      final isTarget = feedback?.contains('ACCESS') ?? false;

                      Color doorColor = GamingColors.surfaceLight;
                      IconData doorIcon = Icons.lock;

                      if (isRevealed) {
                        if (isTarget) {
                          doorColor = GamingColors.accent.withValues(alpha: 0.2);
                          doorIcon = Icons.door_sliding;
                        } else if (isDisabled) {
                          doorColor = Colors.grey.shade200;
                          doorIcon = Icons.lock_open; // showing deactivated
                        } else {
                          doorColor = GamingColors.primary.withValues(alpha: 0.1);
                          doorIcon = Icons.no_meeting_room;
                        }
                      }

                      return GestureDetector(
                        onTap: (!isRevealed && !_isGameOver && !_isLevelCleared) 
                            ? () => _openDoor(index) 
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: doorColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isTarget 
                                  ? GamingColors.accent 
                                  : (index == _selectedDoorIndex ? GamingColors.primary : Colors.grey.shade300),
                              width: (index == _selectedDoorIndex || isTarget) ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                doorIcon,
                                color: isTarget 
                                    ? GamingColors.accent 
                                    : (isDisabled ? Colors.grey : GamingColors.primary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isRevealed 
                                    ? (isDisabled ? '-' : feedback!.split(' ')[0]) 
                                    : 'Door ${index + 1}',
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
                  color: GamingColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GamingColors.accent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _hintText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GamingColors.accent),
                ),
              ),

            // Action Card
            if (_isLevelCleared)
              _buildSuccessCard(theme)
            else if (_isGameOver)
              _buildFailureCard(theme)
            else
              GameCard(
                title: 'SECTOR SPECS',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('TOTAL DOORS', '${_doors.length}'),
                    _buildStatItem('OPTIMAL MOVES', '4'),
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
        Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: GamingColors.accent)),
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
              Text('ESCAPE SUCCESSFUL!', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.accent, fontSize: 16)),
              Text('You bypassed the guard sector.', style: TextStyle(fontSize: 12)),
            ],
          ),
          GameButton(
            height: 38,
            label: 'LEAVE ROOM',
            onPressed: _finishLevel,
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
              Text('TRAPPED!', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.error, fontSize: 16)),
              Text('Security grid locked down due to bad checks.', style: TextStyle(fontSize: 12)),
            ],
          ),
          GameButton(
            height: 38,
            label: 'REBOOT OVERRIDE',
            onPressed: () => setState(_resetLevel),
            color: GamingColors.error,
          ),
        ],
      ),
    );
  }
}
