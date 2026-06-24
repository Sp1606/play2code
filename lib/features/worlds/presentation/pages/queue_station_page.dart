import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../presentation/providers/progress_provider.dart';
import 'package:go_router/go_router.dart';

class QueueStationPage extends ConsumerStatefulWidget {
  const QueueStationPage({super.key});

  @override
  ConsumerState<QueueStationPage> createState() => _QueueStationPageState();
}

class _QueueStationPageState extends ConsumerState<QueueStationPage> {
  final List<String> _waitingLine = [];
  final List<String> _escapedSpirits = [];
  late List<String> _incomingSpirits;

  int _score = 0;
  final int _targetScore = 6;
  bool _isGameOver = false;
  bool _isCleared = false;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _resetLevel();
  }

  void _resetLevel() {
    _waitingLine.clear();
    _escapedSpirits.clear();
    _score = 0;
    _isGameOver = false;
    _isCleared = false;
    _feedback = 'Guide the spirits into the energy portal in their exact sequence of arrival.';

    // Populate incoming queue stream
    _incomingSpirits = ['Green Spirit', 'Blue Spirit', 'Orange Spirit', 'Green Spirit', 'Orange Spirit', 'Blue Spirit'];
    
    // Spawn first two
    _waitingLine.add(_incomingSpirits.removeAt(0));
    _waitingLine.add(_incomingSpirits.removeAt(0));
  }

  void _serveSpirit(String spirit) {
    if (_isGameOver || _isCleared || _waitingLine.isEmpty) return;

    final firstInLine = _waitingLine.first;

    setState(() {
      if (spirit != firstInLine) {
        _feedback = 'REJECTED! The portal repels $spirit. The spirit at the FRONT of the queue must go first!';
        return;
      }

      // Dequeue correct spirit
      _waitingLine.removeAt(0);
      _escapedSpirits.add(spirit);
      _score++;
      _feedback = 'portal absorbed $spirit (First arrived, first released).';

      // Pull new spirit into queue
      if (_incomingSpirits.isNotEmpty) {
        _waitingLine.add(_incomingSpirits.removeAt(0));
      }

      _checkWinCondition();
    });
  }

  void _checkWinCondition() {
    if (_score >= _targetScore) {
      _isCleared = true;
      _feedback = 'All spirits successfully routed. The portal gate stabilizes!';
      _saveProgress();
    }
  }

  Future<void> _saveProgress() async {
    await ref.read(levelProgressProvider.notifier).completeLevel(2);
  }

  IconData _getSpiritIcon(String type) {
    switch (type) {
      case 'Green Spirit':
        return Icons.eco;
      case 'Blue Spirit':
        return Icons.water_drop;
      case 'Orange Spirit':
        return Icons.local_fire_department;
      default:
        return Icons.person;
    }
  }

  Color _getSpiritColor(String type) {
    switch (type) {
      case 'Green Spirit':
        return GamingColors.accent;
      case 'Blue Spirit':
        return GamingColors.primary;
      case 'Orange Spirit':
        return GamingColors.warning;
      default:
        return GamingColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text('LEVEL 2: TEMPLE MEMORY'),
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
              title: 'PORTAL RULES',
              borderColor: GamingColors.secondary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Release spirits into the portal. The ancient portal operates under a strict "Fair Queue" principle: spirits must leave in the exact order they lined up.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ROUTED SPIRITS: $_score / $_targetScore',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.secondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Entrance Portal (DragTarget)
            Expanded(
              child: Row(
                children: [
                  // Waiting spirits queue
                  Expanded(
                    child: GameCard(
                      title: 'SPIRIT LINE (FRONT -> BACK)',
                      child: Expanded(
                        child: _waitingLine.isEmpty
                            ? const Center(child: Text('No spirits waiting.'))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _waitingLine.length,
                                itemBuilder: (context, index) {
                                  final spirit = _waitingLine[index];
                                  final isFront = index == 0;
                                  final sColor = _getSpiritColor(spirit);

                                  return Draggable<String>(
                                    data: spirit,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: sColor.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: sColor, width: 2),
                                        ),
                                        child: Icon(_getSpiritIcon(spirit), color: sColor, size: 28),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: _buildSpiritItem(spirit, isFront),
                                    ),
                                    child: _buildSpiritItem(spirit, isFront),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Portal drop zone
            DragTarget<String>(
              onAcceptWithDetails: (details) => _serveSpirit(details.data),
              builder: (context, candidateData, rejectedData) {
                final isOver = candidateData.isNotEmpty;

                return Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isOver ? GamingColors.secondary.withValues(alpha: 0.1) : GamingColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isOver ? GamingColors.secondary : GamingColors.surfaceLight,
                      width: 2.5,
                    ),
                    boxShadow: isOver
                        ? [
                            BoxShadow(
                              color: GamingColors.secondary.withValues(alpha: 0.25),
                              blurRadius: 15,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.radar,
                          size: 40,
                          color: isOver ? GamingColors.secondary : GamingColors.textMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isOver ? 'RELEASE SPIRIT NOW!' : 'DRAG FRONT SPIRIT HERE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isOver ? GamingColors.secondary : GamingColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                      : (_feedback!.startsWith('REJECTED') ? GamingColors.error.withValues(alpha: 0.1) : GamingColors.secondary.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isCleared ? GamingColors.accent : (_feedback!.startsWith('REJECTED') ? GamingColors.error : GamingColors.secondary.withValues(alpha: 0.3)),
                  ),
                ),
                child: Text(
                  _feedback!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isCleared ? GamingColors.accent : (_feedback!.startsWith('REJECTED') ? GamingColors.error : GamingColors.secondary),
                  ),
                ),
              ),

            // Controls
            if (_isCleared)
              _buildSuccessCard()
            else if (_isGameOver)
              _buildFailureCard()
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpiritItem(String spirit, bool isFront) {
    final sColor = _getSpiritColor(spirit);
    return Container(
      width: 80,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isFront ? sColor.withValues(alpha: 0.1) : GamingColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFront ? sColor : GamingColors.surfaceLight,
          width: isFront ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isFront)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: sColor, borderRadius: BorderRadius.circular(4)),
              child: const Text('FRONT', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 4),
          Icon(_getSpiritIcon(spirit), size: 28, color: isFront ? sColor : GamingColors.textSecondary),
          const SizedBox(height: 4),
          Text(
            spirit.split(' ')[0],
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
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
              Text('PORTAL CLEAR!', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.accent, fontSize: 15)),
              Text('All spirits resolved in exact order.', style: TextStyle(fontSize: 12)),
            ],
          ),
          GameButton(
            height: 38,
            label: 'LEAVE ROOM',
            onPressed: () => context.go('/reflection/level_2'),
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
              Text('CONGESTION FAIL', style: TextStyle(fontWeight: FontWeight.w900, color: GamingColors.error, fontSize: 15)),
              Text('Queue congestion grew too high.', style: TextStyle(fontSize: 12)),
            ],
          ),
          GameButton(
            height: 38,
            label: 'TRY AGAIN',
            onPressed: _resetLevel,
            color: GamingColors.error,
          ),
        ],
      ),
    );
  }
}
