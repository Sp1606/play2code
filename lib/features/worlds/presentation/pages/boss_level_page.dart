import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../providers/progress_provider.dart';
import 'package:go_router/go_router.dart';

class BossLevelPage extends ConsumerStatefulWidget {
  const BossLevelPage({super.key});

  @override
  ConsumerState<BossLevelPage> createState() => _BossLevelPageState();
}

class _BossLevelPageState extends ConsumerState<BossLevelPage> {
  int _currentStage = 1; // 1: Stack Lock, 2: Queue Lock, 3: Split Lock
  bool _isCleared = false;
  bool _isGameOver = false;
  String _feedback = 'The Guardian blocks the exit! Decode the three terminal locks.';

  // Stage 1 (Stack Lock) States
  final List<String> _stackState = [];
  final List<String> _targetStack = ['Omega', 'Delta'];
  final List<String> _availableStackRunes = ['Omega', 'Sigma', 'Delta'];

  // Stage 2 (Queue Lock) States
  final List<String> _queueState = [];
  final List<String> _targetQueue = ['Solar', 'Lunar', 'Astra'];
  final List<String> _incomingQueueRunes = ['Solar', 'Lunar', 'Astra'];
  int _queueNextIndex = 0;

  // Stage 3 (Split Lock) States
  final List<int> _numbers = [15, 30, 45, 60, 75, 90, 105];
  final int _targetNumber = 75;
  int _guessesRemaining = 3;
  final Set<int> _disabledNumbers = {};
  int _selectedNumber = -1;

  void _resetStage() {
    setState(() {
      _isGameOver = false;
      if (_currentStage == 1) {
        _stackState.clear();
        _feedback = 'Lock 1 (LIFO Altar): Match the blueprint. Pushing elements stacks them; popping removes the topmost.';
      } else if (_currentStage == 2) {
        _queueState.clear();
        _queueNextIndex = 0;
        _feedback = 'Lock 2 (FIFO Flow): Pass the runes into the receiver. They must exit the entry pipe in order of arrival.';
      } else {
        _guessesRemaining = 3;
        _disabledNumbers.clear();
        _selectedNumber = -1;
        _feedback = 'Lock 3 (Binary Split): Find target $_targetNumber in sorted matrix. Narrow the range using midpoint clues!';
      }
    });
  }

  // --- STAGE 1 (STACK) HANDLERS ---
  void _pushStack(String rune) {
    if (_isGameOver || _stackState.length >= 4) return;
    setState(() {
      _stackState.add(rune);
      _feedback = 'Pushed $rune onto the top of the stack.';
      _checkStage1Win();
    });
  }

  void _popStack() {
    if (_isGameOver || _stackState.isEmpty) return;
    setState(() {
      final removed = _stackState.removeLast();
      _feedback = 'Popped $removed from the top of the stack.';
      _checkStage1Win();
    });
  }

  void _checkStage1Win() {
    if (_stackState.length == _targetStack.length) {
      bool match = true;
      for (int i = 0; i < _stackState.length; i++) {
        if (_stackState[i] != _targetStack[i]) {
          match = false;
          break;
        }
      }
      if (match) {
        setState(() {
          _feedback = 'Lock 1 unlocked! Advancing to Lock 2.';
          _currentStage = 2;
          _resetStage();
        });
      }
    }
  }

  // --- STAGE 2 (QUEUE) HANDLERS ---
  void _enqueueRunes() {
    if (_queueNextIndex >= _incomingQueueRunes.length) return;
    setState(() {
      final rune = _incomingQueueRunes[_queueNextIndex++];
      _queueState.add(rune);
      _feedback = 'Enqueued $rune at the back of the queue.';
    });
  }

  void _dequeueRunes() {
    if (_queueState.isEmpty) return;
    setState(() {
      final dequeued = _queueState.removeAt(0);
      final expected = _targetQueue[_targetQueue.length - _queueState.length - 1 - (_incomingQueueRunes.length - _queueNextIndex)];
      
      if (dequeued == expected) {
        _feedback = 'Dequeued $dequeued from front. Correct!';
        if (_queueState.isEmpty && _queueNextIndex == _incomingQueueRunes.length) {
          _feedback = 'Lock 2 unlocked! Advancing to Lock 3.';
          _currentStage = 3;
          _resetStage();
        }
      } else {
        _feedback = 'MISALIGNMENT! Dequeued $dequeued, but expected $expected. Re-align flow!';
        _isGameOver = true;
      }
    });
  }

  // --- STAGE 3 (SPLIT LOCK) HANDLERS ---
  void _guessNumber(int val) {
    if (_isGameOver || _guessesRemaining <= 0 || _disabledNumbers.contains(val)) return;

    setState(() {
      _selectedNumber = val;
      _guessesRemaining--;

      if (val == _targetNumber) {
        _feedback = 'All locks released! The Guardian retreats!';
        _isCleared = true;
        _saveProgress();
      } else if (val < _targetNumber) {
        _feedback = 'Keycode is HIGHER than $val. Discarding left values.';
        for (int item in _numbers) {
          if (item <= val) {
            _disabledNumbers.add(item);
          }
        }
      } else {
        _feedback = 'Keycode is LOWER than $val. Discarding right values.';
        for (int item in _numbers) {
          if (item >= val) {
            _disabledNumbers.add(item);
          }
        }
      }

      if (_guessesRemaining <= 0 && !_isCleared) {
        _isGameOver = true;
        _feedback = 'Alarm triggered! Matrix locked. Reboot system.';
      }
    });
  }

  Future<void> _saveProgress() async {
    await ref.read(levelProgressProvider.notifier).completeLevel(4);
  }

  void _finishBoss() {
    context.go('/reflection/boss');
  }

  @override
  void initState() {
    super.initState();
    _resetStage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BOSS QUEST: GUARDIAN ESCAPE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/worlds'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Guardian / Stage Indicator Card
            GameCard(
              title: 'GUARDIAN OVERWATCH',
              borderColor: GamingColors.warning,
              glowColor: GamingColors.warning,
              glowRadius: 6.0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STAGE $_currentStage / 3: ${
                          _currentStage == 1 ? 'LIFO LOCK' : (_currentStage == 2 ? 'FIFO FLOW' : 'BINARY MATRIX')
                        }',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: GamingColors.warning, fontSize: 14),
                      ),
                      _buildStageStatusDots(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress or feedback box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GamingColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GamingColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _feedback,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GamingColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Middle Dynamic Gameplay Area
            Expanded(
              child: GameCard(
                title: 'TERMINAL CONSOLE',
                child: Center(
                  child: _isCleared
                      ? _buildClearedScreen()
                      : (_isGameOver ? _buildGameOverScreen() : _buildActiveStageScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageStatusDots() {
    return Row(
      children: List.generate(3, (index) {
        final stageNum = index + 1;
        Color dotColor = GamingColors.surfaceLight;
        if (stageNum < _currentStage || _isCleared) {
          dotColor = GamingColors.accent;
        } else if (stageNum == _currentStage) {
          dotColor = GamingColors.warning;
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildClearedScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified, size: 80, color: GamingColors.accent),
        const SizedBox(height: 16),
        const Text(
          'SECURE EXIT SECURED!',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: GamingColors.accent),
        ),
        const SizedBox(height: 8),
        const Text(
          'The energy gates open. The algorithms behind the temple await.',
          textAlign: TextAlign.center,
          style: TextStyle(color: GamingColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),
        GameButton(
          label: 'FINISH ADVENTURE',
          onPressed: _finishBoss,
          color: GamingColors.accent,
        ),
      ],
    );
  }

  Widget _buildGameOverScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 80, color: GamingColors.error),
        const SizedBox(height: 16),
        const Text(
          'SECURITY LOCKOUT',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: GamingColors.error),
        ),
        const SizedBox(height: 8),
        const Text(
          'The lock mechanisms have scrambled. You must reboot.',
          textAlign: TextAlign.center,
          style: TextStyle(color: GamingColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),
        GameButton(
          label: 'REBOOT STAGE',
          onPressed: _resetStage,
          color: GamingColors.error,
        ),
      ],
    );
  }

  Widget _buildActiveStageScreen() {
    switch (_currentStage) {
      case 1:
        return _buildStackStage();
      case 2:
        return _buildQueueStage();
      case 3:
      default:
        return _buildSplitStage();
    }
  }

  // --- STAGE 1 WIDGET ---
  Widget _buildStackStage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Target Blueprint
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Blueprint: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ..._targetStack.map((r) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: GamingColors.primary.withValues(alpha: 0.1), border: Border.all(color: GamingColors.primary), borderRadius: BorderRadius.circular(4)),
              child: Text(r, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            )),
          ],
        ),
        const SizedBox(height: 20),
        // Visual Stack Container
        Container(
          width: 140,
          height: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: GamingColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GamingColors.primary.withValues(alpha: 0.5), width: 2),
          ),
          child: _stackState.isEmpty
              ? const Center(child: Text('Stack is empty', style: TextStyle(color: GamingColors.textMuted, fontSize: 11)))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _stackState.reversed.map((rune) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      height: 24,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: GamingColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(rune.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 20),
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ..._availableStackRunes.map((rune) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () => _pushStack(rune),
                child: Text('Push $rune', style: const TextStyle(fontSize: 11)),
              ),
            )),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _stackState.isNotEmpty ? _popStack : null,
          icon: const Icon(Icons.remove, size: 14),
          label: const Text('Pop Top Rune', style: TextStyle(fontSize: 11)),
          style: ElevatedButton.styleFrom(backgroundColor: GamingColors.error.withValues(alpha: 0.2), foregroundColor: GamingColors.error),
        ),
      ],
    );
  }

  // --- STAGE 2 WIDGET ---
  Widget _buildQueueStage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Required Exit Order: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ..._targetQueue.map((r) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: GamingColors.secondary.withValues(alpha: 0.1), border: Border.all(color: GamingColors.secondary), borderRadius: BorderRadius.circular(4)),
              child: Text(r, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            )),
          ],
        ),
        const SizedBox(height: 20),
        // Queue Pipeline (Horizontal layout)
        Container(
          height: 80,
          width: 280,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: GamingColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GamingColors.secondary.withValues(alpha: 0.5), width: 2),
          ),
          child: _queueState.isEmpty
              ? const Center(child: Text('Pipeline is empty', style: TextStyle(color: GamingColors.textMuted, fontSize: 11)))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _queueState.length,
                  itemBuilder: (context, index) {
                    final rune = _queueState[index];
                    final isFront = index == 0;
                    return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: GamingColors.secondary,
                        borderRadius: BorderRadius.circular(6),
                        border: isFront ? Border.all(color: Colors.white, width: 1.5) : null,
                      ),
                      child: Text(
                        '${isFront ? "FRONT: " : ""}$rune',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 20),
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _queueNextIndex < _incomingQueueRunes.length ? _enqueueRunes : null,
              icon: const Icon(Icons.add, size: 14),
              label: Text(_queueNextIndex < _incomingQueueRunes.length 
                ? 'Enqueue ${_incomingQueueRunes[_queueNextIndex]}' 
                : 'All Enqueued',
                style: const TextStyle(fontSize: 11)
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _queueState.isNotEmpty ? _dequeueRunes : null,
              icon: const Icon(Icons.output, size: 14),
              label: const Text('Dequeue Front', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(backgroundColor: GamingColors.accent.withValues(alpha: 0.2), foregroundColor: GamingColors.accent),
            ),
          ],
        ),
      ],
    );
  }

  // --- STAGE 3 WIDGET ---
  Widget _buildSplitStage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Target: $_targetNumber', style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.warning, fontSize: 13)),
            Text('Guesses Left: $_guessesRemaining', style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.error, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 20),
        // Row of numbers
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _numbers.map((val) {
            final isDeactivated = _disabledNumbers.contains(val);
            final isSelected = val == _selectedNumber;
            Color btnColor = GamingColors.surfaceLight;
            Color textColor = GamingColors.textPrimary;

            if (isDeactivated) {
              btnColor = Colors.grey.shade200;
              textColor = Colors.grey;
            } else if (isSelected) {
              btnColor = GamingColors.warning;
              textColor = Colors.white;
            }

            return GestureDetector(
              onTap: isDeactivated ? null : () => _guessNumber(val),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: btnColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? GamingColors.warning : (isDeactivated ? Colors.transparent : GamingColors.surfaceLight),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    isDeactivated ? '-' : '$val',
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
