import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../worlds/presentation/providers/game_state_provider.dart';
import 'package:go_router/go_router.dart';

class ArenaChallengePage extends ConsumerStatefulWidget {
  const ArenaChallengePage({super.key});

  @override
  ConsumerState<ArenaChallengePage> createState() => _ArenaChallengePageState();
}

class _ArenaChallengePageState extends ConsumerState<ArenaChallengePage> {
  final List<Map<String, dynamic>> _allBlocks = [
    {'id': 0, 'code': 'final stack = <String>[];'},
    {'id': 1, 'code': 'for (var char in s.split(\'\')) {'},
    {'id': 2, 'code': '  if ([\'(\', \'{\', \'[\'].contains(char)) { stack.add(char); }'},
    {'id': 3, 'code': '  else {'},
    {'id': 4, 'code': '    if (stack.isEmpty) return false;'},
    {'id': 5, 'code': '    final top = stack.removeLast();'},
    {'id': 6, 'code': '    if ((char == \')\' && top != \'(\') || (char == \'}\' && top != \'{\') || (char == \']\' && top != \'[\')) return false;'},
    {'id': 7, 'code': '  }'},
    {'id': 8, 'code': '}'},
    {'id': 9, 'code': 'return stack.isEmpty;'},
  ];

  final List<Map<String, dynamic>> _selectedBlocks = [];
  final List<Map<String, dynamic>> _availableBlocks = [];
  final List<String> _visualStack = [];

  bool _isTesting = false;
  bool _isSolved = false;
  String _consoleOutput = 'SYSTEM STANDBY.\nReady to compile and run tests...';
  final List<String> _testCases = ['()', '()[]{}', '(]'];

  @override
  void initState() {
    super.initState();
    // Scramble the blocks on load
    _availableBlocks.addAll(List.from(_allBlocks));
    _availableBlocks.shuffle();
  }

  void _selectBlock(Map<String, dynamic> block) {
    if (_isTesting || _isSolved) return;
    setState(() {
      _availableBlocks.remove(block);
      _selectedBlocks.add(block);
    });
  }

  void _deselectBlock(Map<String, dynamic> block) {
    if (_isTesting || _isSolved) return;
    setState(() {
      _selectedBlocks.remove(block);
      _availableBlocks.add(block);
    });
  }

  void _resetPuzzle() {
    if (_isTesting || _isSolved) return;
    setState(() {
      _selectedBlocks.clear();
      _availableBlocks.clear();
      _availableBlocks.addAll(List.from(_allBlocks));
      _availableBlocks.shuffle();
      _consoleOutput = 'SYSTEM RESET.\nReady to compile...';
      _visualStack.clear();
    });
  }

  Future<void> _runTests() async {
    if (_isTesting || _isSolved) return;
    
    setState(() {
      _isTesting = true;
      _consoleOutput = 'COMPILING CODE SEGMENTS...\n';
      _visualStack.clear();
    });

    await Future.delayed(const Duration(milliseconds: 800));

    // Verify correct order: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
    bool isOrderCorrect = _selectedBlocks.length == _allBlocks.length;
    if (isOrderCorrect) {
      for (int i = 0; i < _selectedBlocks.length; i++) {
        if (_selectedBlocks[i]['id'] != i) {
          isOrderCorrect = false;
          break;
        }
      }
    }

    if (!isOrderCorrect) {
      setState(() {
        _consoleOutput += 'CRITICAL COMPILER ERROR!\n';
        _consoleOutput += 'Sequence logic mismatch. Expected block order does not form a correct Stack flow.\n';
        _consoleOutput += 'STATUS: COMPILE FAILED ❌';
        _isTesting = false;
      });
      return;
    }

    // Correct order: run simulated tests
    for (int t = 0; t < _testCases.length; t++) {
      final testStr = _testCases[t];
      setState(() {
        _consoleOutput += '\nRUNNING TEST CASE ${t + 1}: s = "$testStr"\n';
      });

      await Future.delayed(const Duration(milliseconds: 600));
      _visualStack.clear();

      bool localPass = true;
      for (int c = 0; c < testStr.length; c++) {
        final char = testStr[c];
        if (char == '(' || char == '{' || char == '[') {
          setState(() {
            _visualStack.add(char);
            _consoleOutput += '  -> PUSH "$char" onto Stack\n';
          });
        } else {
          if (_visualStack.isEmpty) {
            localPass = false;
            setState(() {
              _consoleOutput += '  -> ERROR: Stack empty on pop attempt!\n';
            });
            break;
          }
          final top = _visualStack.removeLast();
          setState(() {
            _consoleOutput += '  -> POP "$top" off Stack. Check match with "$char".\n';
          });

          if ((char == ')' && top != '(') || (char == '}' && top != '{') || (char == ']' && top != '[')) {
            localPass = false;
            setState(() {
              _consoleOutput += '  -> ERROR: Mismatched brackets: top "$top" vs char "$char"!\n';
            });
            break;
          }
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (localPass && _visualStack.isNotEmpty) {
        localPass = false;
        setState(() {
          _consoleOutput += '  -> ERROR: Stack still contains elements at end of string!\n';
        });
      }

      final expected = (testStr == '()' || testStr == '()[]{}');
      if (localPass == expected) {
        setState(() {
          _consoleOutput += '  TEST CASE ${t + 1} PASSED ✅\n';
        });
      } else {
        setState(() {
          _consoleOutput += '  TEST CASE ${t + 1} FAILED ❌\n';
        });
        setState(() {
          _isTesting = false;
        });
        return;
      }
    }

    setState(() {
      _consoleOutput += '\nALL TESTS PASSED SUCCESSFULLY! 🎉\n';
      _consoleOutput += 'STATUS: SOLUTION VERIFIED.';
      _isSolved = true;
      _isTesting = false;
    });
  }

  Future<void> _claimReward() async {
    // Award 150 XP and 20 Coins
    await ref.read(gameStateProvider.notifier).addXp(150);
    await ref.read(gameStateProvider.notifier).addCoins(20);

    // Refresh userProfileProvider to update levels
    ref.invalidate(userProfileProvider);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: GamingColors.accent, width: 2),
            ),
            backgroundColor: const Color(0xFF0F172A),
            title: const Center(
              child: Text(
                'ARENA CONQUERED!',
                style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.accent),
              ),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, size: 56, color: GamingColors.warning),
                SizedBox(height: 16),
                Text(
                  'Your stack validator code is globally verified by the Arena Core.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
                SizedBox(height: 16),
                Text(
                  '🪙 +20 COINS\n⚡ +150 XP',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    context.go('/arena');   // return to arena lobby
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: GamingColors.accent),
                  child: const Text('CLAIM & EXIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARENA #24: CODING PUZZLE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/arena'),
        ),
      ),
      body: Container(
        color: const Color(0xFF0C0B1E),
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;

            final Widget problemDescription = GameCard(
              borderColor: GamingColors.primary,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHALLENGE: VALID PARENTHESES',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: GamingColors.primary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Arrange the code blocks to build a stack-based bracket validator.\n\nRules:\n1. Open brackets must be closed by the same type.\n2. Open brackets must be closed in the correct LIFO order.',
                    style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            );

            final Widget assemblerBoard = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ASSEMBLED CODE SEQUENCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                    if (!_isSolved && !_isTesting)
                      TextButton.icon(
                        onPressed: _resetPuzzle,
                        icon: const Icon(Icons.refresh, size: 14, color: GamingColors.error),
                        label: const Text('RESET', style: TextStyle(fontSize: 9, color: GamingColors.error, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(minHeight: 180),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: _selectedBlocks.isEmpty
                      ? const Center(child: Text('Tap blocks below to assemble your code...', style: TextStyle(color: Colors.white24, fontSize: 11)))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _selectedBlocks.map((block) {
                            return GestureDetector(
                              onTap: () => _deselectBlock(block),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 2.0),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: GamingColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: GamingColors.primary.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  block['code'] as String,
                                  style: const TextStyle(fontFamily: 'Courier', fontSize: 9, color: Colors.white),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            );

            final Widget blockVault = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('CODE VAULT (AVAILABLE BLOCKS)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableBlocks.map((block) {
                    return InkWell(
                      onTap: () => _selectBlock(block),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: GamingColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Text(
                          block['code'] as String,
                          style: const TextStyle(fontFamily: 'Courier', fontSize: 8, color: Colors.white70),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );

            final Widget visualStackPanel = Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('STACK\nSTATE', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white30)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _visualStack.length,
                      itemBuilder: (context, index) {
                        final char = _visualStack[index];
                        return Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 44),
                          decoration: BoxDecoration(
                            color: GamingColors.accent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(color: GamingColors.accent.withValues(alpha: 0.3), blurRadius: 6)
                            ],
                          ),
                          child: Center(
                            child: Text(
                              char,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );

            final Widget outputConsole = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('TEST COMPILER OUTPUT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                const SizedBox(height: 6),
                Container(
                  height: 110,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GamingColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _consoleOutput,
                      style: const TextStyle(fontFamily: 'Courier', fontSize: 9, color: Colors.greenAccent, height: 1.4),
                    ),
                  ),
                ),
              ],
            );

            final Widget controls = Row(
              children: [
                if (!_isSolved)
                  Expanded(
                    child: GameButton(
                      label: _isTesting ? 'COMPILING...' : 'RUN TESTS & COMPILE',
                      onPressed: (_isTesting || _selectedBlocks.isEmpty) ? null : _runTests,
                      color: GamingColors.primary,
                    ),
                  )
                else
                  Expanded(
                    child: GameButton(
                      label: 'CLAIM REWARD (+150 XP)',
                      onPressed: _claimReward,
                      color: GamingColors.accent,
                    ),
                  ),
              ],
            );

            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          problemDescription,
                          const SizedBox(height: 16),
                          visualStackPanel,
                          const SizedBox(height: 16),
                          outputConsole,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          assemblerBoard,
                          const SizedBox(height: 16),
                          blockVault,
                          const SizedBox(height: 24),
                          controls,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    problemDescription,
                    const SizedBox(height: 16),
                    assemblerBoard,
                    const SizedBox(height: 16),
                    blockVault,
                    const SizedBox(height: 16),
                    visualStackPanel,
                    const SizedBox(height: 16),
                    outputConsole,
                    const SizedBox(height: 20),
                    controls,
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
