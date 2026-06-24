import 'package:flutter/material.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/services/firebase_service.dart';
import 'package:go_router/go_router.dart';

class RevealTheoryPage extends StatelessWidget {
  final String gameId;

  const RevealTheoryPage({super.key, required this.gameId});

  String _getAlgoName() {
    switch (gameId) {
      case 'stack_temple':
        return 'STACK DATA STRUCTURE (LIFO)';
      case 'queue_station':
        return 'QUEUE DATA STRUCTURE (FIFO)';
      case 'treasure_hunt':
        return 'BINARY SEARCH ALGORITHM';
      default:
        return 'UNKNOWN ALGORITHM';
    }
  }

  String _getDefinition() {
    switch (gameId) {
      case 'stack_temple':
        return 'A Stack is a linear data structure that follows the LIFO (Last In, First Out) principle. The last element added to the stack is the first one to be removed. Operations are restricted to the top of the stack.';
      case 'queue_station':
        return 'A Queue is a linear data structure that follows the FIFO (First In, First Out) principle. The first element added to the queue is the first one to be removed. New elements are added at the back (enqueue) and removed from the front (dequeue).';
      case 'treasure_hunt':
        return 'Binary Search is an efficient algorithm for finding an item from a sorted list of items. It works by repeatedly dividing in half the portion of the list that could contain the item, until you have narrowed down the possible locations to just one.';
    }
    return '';
  }

  String _getAnalogy() {
    switch (gameId) {
      case 'stack_temple':
        return '🥞 Analogy: Think of a stack of dinner plates. You can only place a new plate on top (Push), and you can only wash the top-most plate first (Pop). Trying to pull a plate from the bottom breaks the stack!';
      case 'queue_station':
        return '🎟️ Analogy: Think of a line of customers waiting at a movie ticket counter. The person who arrived first is ticketed first. Jumping the queue is not permitted!';
      case 'treasure_hunt':
        return '📖 Analogy: Think of looking up a word in a dictionary. You open to the middle page. If your word starts with "S" and the page is "M", you discard the entire first half of the book and repeat the process on the remaining pages.';
    }
    return '';
  }

  String _getComplexity() {
    switch (gameId) {
      case 'stack_temple':
        return 'Push: O(1) | Pop: O(1) | Peek: O(1)';
      case 'queue_station':
        return 'Enqueue: O(1) | Dequeue: O(1) | Front: O(1)';
      case 'treasure_hunt':
        return 'Time Complexity: O(log N) | Space Complexity: O(1)';
    }
    return '';
  }

  String _getCodeSnippet() {
    switch (gameId) {
      case 'stack_temple':
        return '''class Stack<T> {
  final List<T> _list = [];

  void push(T value) => _list.add(value);

  T pop() {
    if (_list.isEmpty) throw StateError('Stack empty');
    return _list.removeLast();
  }

  T peek() => _list.last;
  bool get isEmpty => _list.isEmpty;
}''';
      case 'queue_station':
        return '''class Queue<T> {
  final List<T> _list = [];

  void enqueue(T value) => _list.add(value);

  T dequeue() {
    if (_list.isEmpty) throw StateError('Queue empty');
    return _list.removeAt(0); // Dequeue from front
  }

  T get front => _list.first;
  bool get isEmpty => _list.isEmpty;
}''';
      case 'treasure_hunt':
        return '''int binarySearch(List<int> sortedList, int target) {
  int low = 0;
  int high = sortedList.length - 1;

  while (low <= high) {
    int mid = low + (high - low) ~/ 2;
    int guess = sortedList[mid];

    if (guess == target) return mid; // Found it!
    if (guess > target) {
      high = mid - 1; // Search left half
    } else {
      low = mid + 1;  // Search right half
    }
  }
  return -1; // Target not found
}''';
    }
    return '';
  }

  Future<void> _claimRewards(BuildContext context) async {
    // Reward user with 100 XP
    await FirebaseService.instance.updateDocument('users', 'mock_user_123', {
      'xpGained': 100,
      'achievementUnlocked': 'TheoryUnlocked_$gameId',
    });

    // Go back to worlds dashboard
    if (context.mounted) {
      context.go('/worlds');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('THEORY UNLOCKED'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner/Header Card
            GameCard(
              title: _getAlgoName(),
              borderColor: GamingColors.accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDefinition(),
                    style: const TextStyle(fontSize: 14, height: 1.5, color: GamingColors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visual diagram placeholder or text analogy
            GameCard(
              title: 'REAL-WORLD ANALOGY',
              child: Text(
                _getAnalogy(),
                style: const TextStyle(fontSize: 13, height: 1.5, color: GamingColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),

            // Complexity Stats
            GameCard(
              title: 'ALGORITHM COMPLEXITY',
              child: Row(
                children: [
                  const Icon(Icons.speed, color: GamingColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    _getComplexity(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.primary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Code Sniffer
            GameCard(
              title: 'DART REFERENCE CODE',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        _getCodeSnippet(),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Claim Reward Button
            GameButton(
              width: double.infinity,
              label: 'CLAIM +100 XP AND FINISH LEVEL',
              onPressed: () => _claimRewards(context),
              color: GamingColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
