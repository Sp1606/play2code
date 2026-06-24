import 'package:flutter/material.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/services/firebase_service.dart';
import 'package:go_router/go_router.dart';

class ReflectionPage extends StatefulWidget {
  final String gameId;

  const ReflectionPage({super.key, required this.gameId});

  @override
  State<ReflectionPage> createState() => _ReflectionPageState();
}

class _ReflectionPageState extends State<ReflectionPage> {
  int? _confidenceScore; // Start with no rating preselected (null)
  final TextEditingController _feedbackController = TextEditingController();
  bool _discoveredPattern = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  String _getReflectionQuestion() {
    switch (widget.gameId) {
      case 'level_1':
        return 'When you wanted to retrieve a block from the bottom, what did you have to do to the blocks on top of it? Describe the pattern you noticed.';
      case 'level_2':
        return 'What was the relationship between the order passenger spirits arrived in line and the order they got released into the portal?';
      case 'level_3':
        return 'By checking a door in the middle, how did it help you eliminate doors? How does this speed up your search compared to checking one by one?';
      case 'boss':
      default:
        return 'How did you combine these three lock patterns to disable the final guardian locks? What did you learn?';
    }
  }

  Future<void> _submitReflection() async {
    final analytics = {
      'gameId': widget.gameId,
      'confidenceScore': _confidenceScore ?? 0,
      'reflectionResponse': _feedbackController.text,
      'discoveredPattern': _discoveredPattern,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Save to Mock Firebase
    await FirebaseService.instance.submitGameAnalytics(analytics);

    if (mounted) {
      if (widget.gameId == 'boss') {
        context.go('/reveal');
      } else {
        context.go('/worlds');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POST-GAME REFLECTION'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Card
            const GameCard(
              title: 'CRITICAL REFLECTION',
              borderColor: GamingColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Before we reveal the engineering theory behind these challenges, take a moment to reflect on your gameplay experience. Formulating the pattern yourself helps solidify the concept.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Confidence rating
            GameCard(
              title: 'RATE YOUR CONFIDENCE',
              child: Column(
                children: [
                  const Text('How confident do you feel about the mechanics of the game you just solved?', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1;
                      final isSelected = _confidenceScore != null && starVal <= _confidenceScore!;
                      return IconButton(
                        icon: Icon(
                          isSelected ? Icons.star : Icons.star_border,
                          color: GamingColors.levelColor,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            _confidenceScore = starVal;
                          });
                        },
                      );
                    }),
                  ),
                  Text(
                    _confidenceScore == null
                        ? 'Select a Rating'
                        : (_confidenceScore == 5 
                            ? 'Master Coder' 
                            : (_confidenceScore! >= 3 ? 'Adept Solver' : 'Novice Explorer')),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reflection Question
            GameCard(
              title: 'PATTERN DISCOVERY QUESTION',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getReflectionQuestion(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: GamingColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Enter your observations here (optional)...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Discovered pattern checkbox
            GameCard(
              child: CheckboxListTile(
                title: const Text('I discovered the mathematical or structural pattern before reading the theory.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: const Text('Tick this if you noticed LIFO/FIFO or search splitting properties yourself.', style: TextStyle(fontSize: 10)),
                value: _discoveredPattern,
                activeColor: GamingColors.accent,
                onChanged: (val) {
                  setState(() {
                    _discoveredPattern = val ?? false;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button (always enabled)
            GameButton(
              width: double.infinity,
              label: widget.gameId == 'boss' ? 'SUBMIT & REVEAL ALL THEORY' : 'SUBMIT & CONTINUE ADVENTURE',
              onPressed: _submitReflection,
            ),
          ],
        ),
      ),
    );
  }
}
