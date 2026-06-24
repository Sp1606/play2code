import 'package:flutter/material.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/services/firebase_service.dart';
import 'package:go_router/go_router.dart';

class StackTemplePage extends StatefulWidget {
  const StackTemplePage({super.key});

  @override
  State<StackTemplePage> createState() => _StackTemplePageState();
}

class _StackTemplePageState extends State<StackTemplePage> {
  int _currentLevel = 1; // 1, 2, 3, 4 (Boss)
  final List<String> _userStack = [];
  late List<String> _targetStack;
  int _movesLeft = 10;
  bool _isGameOver = false;
  bool _isLevelCleared = false;

  final List<String> _availableBlocks = ['Red Block', 'Blue Block', 'Green Block', 'Yellow Block'];

  @override
  void initState() {
    super.initState();
    _resetLevel();
  }

  void _resetLevel() {
    _userStack.clear();
    _isGameOver = false;
    _isLevelCleared = false;

    // Different targets/moves for different levels
    switch (_currentLevel) {
      case 1:
        _targetStack = ['Red Block', 'Blue Block'];
        _movesLeft = 6;
        break;
      case 2:
        _targetStack = ['Blue Block', 'Green Block', 'Red Block'];
        _movesLeft = 8;
        break;
      case 3:
        _targetStack = ['Yellow Block', 'Red Block', 'Blue Block', 'Green Block'];
        _movesLeft = 10;
        break;
      case 4: // Boss Level
        _targetStack = ['Green Block', 'Yellow Block', 'Red Block', 'Blue Block'];
        _movesLeft = 6; // Very tight moves restriction
        break;
    }
  }

  void _pushBlock(String block) {
    if (_isGameOver || _isLevelCleared || _movesLeft <= 0) return;

    setState(() {
      _userStack.add(block);
      _movesLeft--;
      _checkWinCondition();
    });
  }

  void _popBlock() {
    if (_isGameOver || _isLevelCleared || _movesLeft <= 0 || _userStack.isEmpty) return;

    setState(() {
      _userStack.removeLast();
      _movesLeft--;
      _checkWinCondition();
    });
  }

  void _checkWinCondition() {
    // Check if stacks match exactly
    if (_userStack.length == _targetStack.length) {
      bool match = true;
      for (int i = 0; i < _userStack.length; i++) {
        if (_userStack[i] != _targetStack[i]) {
          match = false;
          break;
        }
      }
      if (match) {
        _isLevelCleared = true;
        _saveProgress();
      }
    }

    if (_movesLeft <= 0 && !_isLevelCleared) {
      _isGameOver = true;
    }
  }

  Future<void> _saveProgress() async {
    // Record to Firebase placeholder database
    await FirebaseService.instance.updateGameProgress('stack_temple', _currentLevel, _currentLevel == 4);
  }

  void _nextLevel() {
    if (_currentLevel < 4) {
      setState(() {
        _currentLevel++;
        _resetLevel();
      });
    } else {
      // Completed boss level! Go to reflection
      context.go('/reflection/stack_temple');
    }
  }

  Color _getBlockColor(String blockName) {
    switch (blockName) {
      case 'Red Block':
        return Colors.redAccent.shade200;
      case 'Blue Block':
        return Colors.blueAccent.shade200;
      case 'Green Block':
        return Colors.greenAccent.shade400;
      case 'Yellow Block':
        return Colors.amber.shade400;
      default:
        return GamingColors.surfaceLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('STACK TEMPLE - LEVEL $_currentLevel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/worlds'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        key: ValueKey('stack_level_$_currentLevel'),
        child: Column(
          children: [
            // Level Goal
            GameCard(
              title: _currentLevel == 4 ? 'BOSS QUEST: THE COLUMN OF LIFO' : 'QUEST GOAL',
              borderColor: _currentLevel == 4 ? GamingColors.warning : GamingColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Match the target block assembly. You can only modify blocks by adding or removing from the top.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('MOVES LEFT: $_movesLeft', style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.error)),
                      if (_currentLevel == 4)
                        const Chip(
                          label: Text('BOSS LEVEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          backgroundColor: GamingColors.error,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Target Stack and User Stack Display
            Expanded(
              child: Row(
                children: [
                  // Target Stack
                  Expanded(
                    child: GameCard(
                      title: 'TARGET DESIGN',
                      child: Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: _targetStack.reversed.map((block) {
                            return _buildRenderBlock(block);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // User Stack Assembly Area
                  Expanded(
                    child: GameCard(
                      title: 'YOUR ASSEMBLY',
                      child: Expanded(
                        child: _userStack.isEmpty
                            ? const Center(child: Text('Stack is empty.\nPush blocks below!', textAlign: TextAlign.center, style: TextStyle(color: GamingColors.textMuted)))
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: _userStack.reversed.map((block) {
                                  return _buildRenderBlock(block);
                                }).toList(),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Gameplay State Overlay
            if (_isLevelCleared)
              _buildSuccessCard(theme)
            else if (_isGameOver)
              _buildFailureCard(theme)
            else
              _buildControlPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildRenderBlock(String blockName) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _getBlockColor(blockName),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          blockName.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
        ),
      ),
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
              Text('LEVEL CLEARED!', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.accent, fontSize: 16)),
              Text('Great work, you solved it!', style: TextStyle(fontSize: 12)),
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
              Text('QUEST FAILED!', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.error, fontSize: 16)),
              Text('You ran out of moves.', style: TextStyle(fontSize: 12)),
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

  Widget _buildControlPanel() {
    return GameCard(
      title: 'CONTROL CONSOLE',
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _availableBlocks.map((block) {
              return GameButton(
                height: 38,
                label: 'PUSH ${block.split(' ')[0]}',
                onPressed: () => _pushBlock(block),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          GameButton(
            width: double.infinity,
            label: 'POP TOP BLOCK',
            onPressed: _userStack.isNotEmpty ? _popBlock : null,
            isSecondary: true,
            color: GamingColors.error,
          ),
        ],
      ),
    );
  }
}
