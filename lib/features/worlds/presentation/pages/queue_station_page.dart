import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/services/firebase_service.dart';
import 'package:go_router/go_router.dart';

class QueueStationPage extends StatefulWidget {
  const QueueStationPage({super.key});

  @override
  State<QueueStationPage> createState() => _QueueStationPageState();
}

class _QueueStationPageState extends State<QueueStationPage> {
  int _currentLevel = 1;
  final List<String> _stationQueue = [];
  final List<String> _servicedList = [];
  late List<String> _arrivalList;
  int _score = 0;
  int _requiredScore = 5;
  int _timerSeconds = 30;
  Timer? _gameTimer;
  bool _isGameOver = false;
  bool _isLevelCleared = false;
  String? _statusFeedback;



  @override
  void initState() {
    super.initState();
    _resetLevel();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _resetLevel() {
    _stationQueue.clear();
    _servicedList.clear();
    _isGameOver = false;
    _isLevelCleared = false;
    _score = 0;
    _statusFeedback = null;
    _gameTimer?.cancel();

    switch (_currentLevel) {
      case 1:
        _requiredScore = 5;
        _arrivalList = ['Student', 'Professor', 'Student', 'Developer', 'Designer'];
        // Initial queue populate
        _stationQueue.addAll(['Student', 'Professor']);
        break;
      case 2:
        _requiredScore = 8;
        _arrivalList = ['Developer', 'Student', 'Professor', 'Designer', 'Student', 'Developer', 'Professor', 'Designer'];
        _stationQueue.addAll(['Developer', 'Student', 'Professor']);
        break;
      case 3:
        _requiredScore = 10;
        _arrivalList = ['Designer', 'Developer', 'Student', 'Professor', 'Developer', 'Designer', 'Student', 'Professor', 'Student', 'Developer'];
        _stationQueue.addAll(['Designer', 'Developer', 'Student', 'Professor']);
        break;
      case 4: // Boss Level: Timer active
        _requiredScore = 8;
        _arrivalList = ['Developer', 'Professor', 'Student', 'Designer', 'Developer', 'Student', 'Professor', 'Designer'];
        _stationQueue.addAll(['Developer', 'Professor']);
        _timerSeconds = 25;
        _startTimer();
        break;
    }
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
          // Spawn new passenger occasionally in boss level
          if (_timerSeconds % 4 == 0 && _arrivalList.isNotEmpty && _stationQueue.length < 5) {
            _spawnPassenger();
          }
        } else {
          _isGameOver = true;
          _gameTimer?.cancel();
        }
      });
    });
  }

  void _spawnPassenger() {
    if (_arrivalList.isEmpty) return;
    setState(() {
      final nextPassenger = _arrivalList.removeAt(0);
      _stationQueue.add(nextPassenger);
      _statusFeedback = '$nextPassenger joined the back of the queue.';
    });
  }

  void _servePassenger(int index) {
    if (_isGameOver || _isLevelCleared || _stationQueue.isEmpty) return;

    setState(() {
      if (index != 0) {
        // Jump queue error! Violation of FIFO
        _statusFeedback = 'VIOLATION! You cannot serve ${_stationQueue[index]} first. They must wait their turn!';
        // Penalize moves/timer if boss level
        if (_currentLevel == 4) {
          _timerSeconds = (_timerSeconds - 3).clamp(0, 100);
        }
        return;
      }

      // Dequeue correct passenger
      final served = _stationQueue.removeAt(0);
      _servicedList.add(served);
      _score++;
      _statusFeedback = 'Successfully served $served (First In, First Out).';

      // Spawn next from arrival list if available
      if (_arrivalList.isNotEmpty) {
        _spawnPassenger();
      }

      _checkWinCondition();
    });
  }

  void _checkWinCondition() {
    if (_score >= _requiredScore) {
      _isLevelCleared = true;
      _gameTimer?.cancel();
      _saveProgress();
    }
  }

  Future<void> _saveProgress() async {
    await FirebaseService.instance.updateGameProgress('queue_station', _currentLevel, _currentLevel == 4);
  }

  void _nextLevel() {
    if (_currentLevel < 4) {
      setState(() {
        _currentLevel++;
        _resetLevel();
      });
    } else {
      context.go('/reflection/queue_station');
    }
  }

  IconData _getPassengerIcon(String type) {
    switch (type) {
      case 'Student':
        return Icons.school;
      case 'Professor':
        return Icons.psychology;
      case 'Developer':
        return Icons.code;
      case 'Designer':
        return Icons.brush;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('QUEUE STATION - LEVEL $_currentLevel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/worlds'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        key: ValueKey('queue_level_$_currentLevel'),
        child: Column(
          children: [
            // Instructions
            GameCard(
              title: _currentLevel == 4 ? 'BOSS QUEST: TICKET BOOTH CONGESTION' : 'STATION INSTRUCTIONS',
              borderColor: _currentLevel == 4 ? GamingColors.warning : GamingColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Serve passengers at the ticket booth. Passengers MUST be served in the order they arrived in line.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SCORE: $_score / $_requiredScore', style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.primary)),
                      if (_currentLevel == 4)
                        Text('TIME LEFT: $_timerSeconds s', style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.error))
                      else
                        Text('WAITING OUTSIDE: ${_arrivalList.length}', style: const TextStyle(color: GamingColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Queue Area
            Expanded(
              child: GameCard(
                title: 'TICKET LINE (FRONT -> BACK)',
                child: Expanded(
                  child: _stationQueue.isEmpty
                      ? const Center(child: Text('Line is empty.'))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _stationQueue.length,
                          itemBuilder: (context, index) {
                            final passenger = _stationQueue[index];
                            final isFront = index == 0;

                            return GestureDetector(
                              onTap: () => _servePassenger(index),
                              child: Container(
                                width: 90,
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: isFront ? GamingColors.primary.withValues(alpha: 0.15) : GamingColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isFront ? GamingColors.primary : GamingColors.surfaceLight,
                                    width: isFront ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isFront)
                                      const Chip(
                                        label: Text('FRONT', style: TextStyle(fontSize: 8, color: Colors.white)),
                                        backgroundColor: GamingColors.primary,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    Icon(_getPassengerIcon(passenger), size: 32, color: isFront ? GamingColors.primary : GamingColors.textSecondary),
                                    const SizedBox(height: 8),
                                    Text(passenger, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      isFront ? 'SERVE ME' : 'WAITING',
                                      style: TextStyle(fontSize: 10, color: isFront ? GamingColors.primary : GamingColors.textMuted),
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

            // Feedback Panel
            if (_statusFeedback != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _statusFeedback!.startsWith('VIOLATION') 
                      ? GamingColors.error.withValues(alpha: 0.1) 
                      : GamingColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusFeedback!.startsWith('VIOLATION') ? GamingColors.error : GamingColors.accent,
                  ),
                ),
                child: Text(
                  _statusFeedback!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _statusFeedback!.startsWith('VIOLATION') ? GamingColors.error : GamingColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

            // Game End State Controllers
            if (_isLevelCleared)
              _buildSuccessCard(theme)
            else if (_isGameOver)
              _buildFailureCard(theme)
            else
              GameCard(
                title: 'TICKET BOOTH INSTRUCTIONS',
                child: const Center(
                  child: Text(
                    'Tap the passenger at the FRONT of the queue to serve them tickets.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: GamingColors.textSecondary, fontSize: 13),
                  ),
                ),
              ),
          ],
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
              Text('QUEUE RESOLVED!', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.accent, fontSize: 16)),
              Text('All passengers served in order.', style: TextStyle(fontSize: 12)),
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
              Text('TIME EXPIRED!', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.error, fontSize: 16)),
              Text('Queue congestion got too high.', style: TextStyle(fontSize: 12)),
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
