import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/widgets/game_card.dart';
import 'package:go_router/go_router.dart';

class RevealTheoryPage extends StatefulWidget {
  const RevealTheoryPage({super.key});

  @override
  State<RevealTheoryPage> createState() => _RevealTheoryPageState();
}

class _RevealTheoryPageState extends State<RevealTheoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Stack Simulator State ---
  final List<int> _simulatorStack = [42, 17, 88];
  String _stackFeedback = 'Initial stack loaded. Try pushing or popping values!';

  // --- Queue Simulator State ---
  final List<int> _simulatorQueue = [10, 20, 30];
  String _queueFeedback = 'Initial queue loaded. Try enqueuing or dequeuing values!';

  // --- Binary Search Simulator State ---
  final List<int> _searchArray = [12, 24, 35, 47, 58, 69, 80, 91, 102, 115, 128, 140, 155, 168, 180];
  int _searchTarget = 115;
  int _searchLow = 0;
  int _searchHigh = 14;
  int _searchMid = -1;
  int _searchStep = 0;
  bool _searchCompleted = false;
  String _searchFeedback = 'Press "Step Search" to simulate binary division.';

  // --- Mobile System Design State ---
  String _selectedHldLayer = 'None';
  String _hldLayerDetails = 'Tap any HLD layer box above to analyze its core engineering responsibility and interview trade-offs.';
  String _selectedRealtimeScenario = 'Chat App';
  bool _isOfflineMode = false;
  final List<String> _localDatabase = ['Post 1: Welcome to Play2Code'];
  final List<String> _syncQueue = [];
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    // 4 Tabs: Stack, Queue, Binary Search, and System Design
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- STACK SIMULATION ACTIONS ---
  void _pushStack() {
    if (_simulatorStack.length >= 6) {
      setState(() => _stackFeedback = 'Stack overflow! Cannot exceed 6 elements in simulator.');
      return;
    }
    final val = Random().nextInt(90) + 10;
    setState(() {
      _simulatorStack.add(val);
      _stackFeedback = 'Pushed $val to top of stack. (LIFO)';
    });
  }

  void _popStack() {
    if (_simulatorStack.isEmpty) {
      setState(() => _stackFeedback = 'Stack underflow! Stack is empty.');
      return;
    }
    setState(() {
      final val = _simulatorStack.removeLast();
      _stackFeedback = 'Popped $val from top of stack. (LIFO)';
    });
  }

  // --- QUEUE SIMULATION ACTIONS ---
  void _enqueueQueue() {
    if (_simulatorQueue.length >= 6) {
      setState(() => _queueFeedback = 'Queue overflow! Cannot exceed 6 elements in simulator.');
      return;
    }
    final val = Random().nextInt(90) + 10;
    setState(() {
      _simulatorQueue.add(val);
      _queueFeedback = 'Enqueued $val at the back. (FIFO)';
    });
  }

  void _dequeueQueue() {
    if (_simulatorQueue.isEmpty) {
      setState(() => _queueFeedback = 'Queue underflow! Queue is empty.');
      return;
    }
    setState(() {
      final val = _simulatorQueue.removeAt(0);
      _queueFeedback = 'Dequeued $val from the front. (FIFO)';
    });
  }

  // --- BINARY SEARCH SIMULATION ACTIONS ---
  void _resetSearch() {
    setState(() {
      _searchLow = 0;
      _searchHigh = _searchArray.length - 1;
      _searchMid = -1;
      _searchStep = 0;
      _searchCompleted = false;
      _searchTarget = _searchArray[Random().nextInt(_searchArray.length)];
      _searchFeedback = 'Search rebooted. Target code is $_searchTarget.';
    });
  }

  void _stepSearch() {
    if (_searchCompleted) return;

    if (_searchLow > _searchHigh) {
      setState(() {
        _searchCompleted = true;
        _searchFeedback = 'Value not found in matrix.';
      });
      return;
    }

    setState(() {
      _searchStep++;
      _searchMid = _searchLow + (_searchHigh - _searchLow) ~/ 2;
      final guess = _searchArray[_searchMid];

      if (guess == _searchTarget) {
        _searchCompleted = true;
        _searchFeedback = 'Step $_searchStep: Midpoint index $_searchMid is $guess. TARGET FOUND!';
      } else if (guess > _searchTarget) {
        _searchHigh = _searchMid - 1;
        _searchFeedback = 'Step $_searchStep: Mid point $guess > $_searchTarget. Discarding right half.';
      } else {
        _searchLow = _searchMid + 1;
        _searchFeedback = 'Step $_searchStep: Mid point $guess < $_searchTarget. Discarding left half.';
      }
    });
  }

  // --- SYSTEM DESIGN ACTIONS ---
  void _selectHldLayer(String layer) {
    setState(() {
      _selectedHldLayer = layer;
      switch (layer) {
        case 'UI Layer':
          _hldLayerDetails = 'UI Layer:\n• Handles rendering and user gestures (screens, buttons, compose views).\n• Observes state. Must remain thin and dumb—no network or business logic should live here.';
          break;
        case 'Business Layer':
          _hldLayerDetails = 'Business Logic Layer:\n• Houses ViewModels and Domain logic (use cases, algorithms, routing rules).\n• No Android/iOS platform framework dependencies allowed to guarantee testability.';
          break;
        case 'Data Layer':
          _hldLayerDetails = 'Data Layer (Repositories):\n• The Single Source of Truth. Combines local database caching and remote network APIs.\n• Abstract contracts hide data retrieval details from business logic.';
          break;
        case 'Network/DB Engine':
          _hldLayerDetails = 'Network & Database engines:\n• Sockets, SQL, cache eviction (LRU), and HTTP engines.\n• Implements retries, timeouts, offline synchronization queues, and cache policies.';
          break;
        default:
          _hldLayerDetails = 'Tap any HLD layer box above to analyze its core engineering responsibility.';
      }
    });
  }

  void _toggleNetworkMode() {
    setState(() {
      _isOfflineMode = !_isOfflineMode;
    });
  }

  void _addPostOffline() {
    final text = 'Post ${_localDatabase.length + _syncQueue.length + 1}: Offline update';
    setState(() {
      // Optimistic update: instantly render locally
      _localDatabase.add('$text (Pending Sync)');
      _syncQueue.add(text);
    });
  }

  Future<void> _triggerSyncQueue() async {
    if (_isOfflineMode || _syncQueue.isEmpty || _isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    for (int i = 0; i < _syncQueue.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (_isOfflineMode) {
        setState(() => _isSyncing = false);
        return; // aborted due to offline toggling
      }
    }

    setState(() {
      // Confirm all pending sync items in database
      for (int i = 0; i < _localDatabase.length; i++) {
        _localDatabase[i] = _localDatabase[i].replaceAll(' (Pending Sync)', '');
      }
      _syncQueue.clear();
      _isSyncing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('THE ARCHIVE OF ALGORITHMS'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: GamingColors.accent,
          labelColor: GamingColors.accent,
          unselectedLabelColor: GamingColors.textMuted,
          isScrollable: true,
          tabs: const [
            Tab(text: 'STACK (LIFO)'),
            Tab(text: 'QUEUE (FIFO)'),
            Tab(text: 'BINARY SEARCH'),
            Tab(text: 'SYSTEM DESIGN'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStackTab(),
          _buildQueueTab(),
          _buildSearchTab(),
          _buildSystemDesignTab(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GameButton(
            width: double.infinity,
            label: 'RETURN TO ADVENTURE',
            onPressed: () => context.go('/worlds'),
            color: GamingColors.accent,
          ),
        ),
      ),
    );
  }

  // ==================== STACK TAB ====================
  Widget _buildStackTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GameCard(
            title: 'STACK DEFINITION',
            borderColor: GamingColors.primary,
            child: Text(
              'A Stack is a linear data structure that operates under the Last In, First Out (LIFO) protocol. The element placed last is processed first. Think of piling plates; you add to the top and retrieve from the top.',
              style: TextStyle(fontSize: 13, height: 1.4, color: GamingColors.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
          GameCard(
            title: 'INTERACTIVE VISUALIZER',
            child: Column(
              children: [
                Text(_stackFeedback, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: GamingColors.primary)),
                const SizedBox(height: 16),
                Container(
                  width: 120,
                  height: 160,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GamingColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GamingColors.primary.withValues(alpha: 0.5), width: 2),
                  ),
                  child: _simulatorStack.isEmpty
                      ? const Center(child: Text('Stack is empty', style: TextStyle(color: GamingColors.textMuted, fontSize: 11)))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: _simulatorStack.reversed.map((val) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              height: 20,
                              width: double.infinity,
                              decoration: BoxDecoration(color: GamingColors.primary, borderRadius: BorderRadius.circular(4)),
                              child: Center(
                                child: Text('$val', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GameButton(
                      height: 36,
                      label: 'PUSH VAL',
                      onPressed: _pushStack,
                      color: GamingColors.primary,
                    ),
                    const SizedBox(width: 12),
                    GameButton(
                      height: 36,
                      label: 'POP VAL',
                      onPressed: _popStack,
                      color: GamingColors.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const GameCard(
            title: 'REAL-WORLD ANALOGY',
            child: Text(
              '🥞 Stack of Pancakes: You prepare pancakes and pile them up on a plate. The very last pancake cooked goes on top. When eating, you eat the top one first. Trying to extract the bottom pancake results in syrup flying everywhere!',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          _buildCodeBlock('''// Dart Stack Implementation
class Stack<T> {
  final List<T> _storage = [];

  void push(T val) => _storage.add(val);

  T pop() {
    if (_storage.isEmpty) throw StateError('Stack Empty');
    return _storage.removeLast();
  }

  T get peek => _storage.last;
  bool get isEmpty => _storage.isEmpty;
}'''),
        ],
      ),
    );
  }

  // ==================== QUEUE TAB ====================
  Widget _buildQueueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GameCard(
            title: 'QUEUE DEFINITION',
            borderColor: GamingColors.secondary,
            child: Text(
              'A Queue is a linear data structure working on the First In, First Out (FIFO) protocol. The element added first is served first. Ideal for line flows and schedules.',
              style: TextStyle(fontSize: 13, height: 1.4, color: GamingColors.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
          GameCard(
            title: 'INTERACTIVE VISUALIZER',
            child: Column(
              children: [
                Text(_queueFeedback, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: GamingColors.secondary)),
                const SizedBox(height: 16),
                Container(
                  height: 60,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: GamingColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GamingColors.secondary.withValues(alpha: 0.5), width: 2),
                  ),
                  child: _simulatorQueue.isEmpty
                      ? const Center(child: Text('Queue is empty', style: TextStyle(color: GamingColors.textMuted, fontSize: 11)))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _simulatorQueue.length,
                          itemBuilder: (context, index) {
                            final val = _simulatorQueue[index];
                            final isFront = index == 0;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: GamingColors.secondary,
                                borderRadius: BorderRadius.circular(6),
                                border: isFront ? Border.all(color: Colors.white, width: 1.5) : null,
                              ),
                              child: Text(
                                '${isFront ? "FRONT: " : ""}$val',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GameButton(
                      height: 36,
                      label: 'ENQUEUE',
                      onPressed: _enqueueQueue,
                      color: GamingColors.secondary,
                    ),
                    const SizedBox(width: 12),
                    GameButton(
                      height: 36,
                      label: 'DEQUEUE',
                      onPressed: _dequeueQueue,
                      color: GamingColors.accent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const GameCard(
            title: 'REAL-WORLD ANALOGY',
            child: Text(
              '🎟️ Ticket Counter Line: People waiting for movie tickets stand in line. The person at the front gets their ticket first and leaves the queue. New arrivals stand at the back.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          _buildCodeBlock('''// Dart Queue Implementation
class Queue<T> {
  final List<T> _storage = [];

  void enqueue(T val) => _storage.add(val);

  T dequeue() {
    if (_storage.isEmpty) throw StateError('Queue Empty');
    return _storage.removeAt(0);
  }

  T get front => _storage.first;
  bool get isEmpty => _storage.isEmpty;
}'''),
        ],
      ),
    );
  }

  // ==================== BINARY SEARCH TAB ====================
  Widget _buildSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GameCard(
            title: 'BINARY SEARCH DEFINITION',
            borderColor: GamingColors.accent,
            child: Text(
              'Binary Search is a logarithmic division algorithm to locate a value in a sorted array. By comparing the target with the midpoint, it discards half the array at each step.',
              style: TextStyle(fontSize: 13, height: 1.4, color: GamingColors.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
          GameCard(
            title: 'INTERACTIVE VISUALIZER',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Target: $_searchTarget', style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.accent)),
                    Text('Low: $_searchLow | High: $_searchHigh', style: const TextStyle(color: GamingColors.textMuted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_searchFeedback, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: GamingColors.accent)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: List.generate(_searchArray.length, (index) {
                    final val = _searchArray[index];
                    final isMid = index == _searchMid;
                    final isExcluded = index < _searchLow || index > _searchHigh;
                    final isFound = _searchCompleted && val == _searchTarget && isMid;

                    Color cellColor = GamingColors.surfaceLight;
                    Color textColor = GamingColors.textPrimary;

                    if (isExcluded) {
                      cellColor = Colors.grey.shade100;
                      textColor = Colors.grey;
                    } else if (isFound) {
                      cellColor = GamingColors.accent;
                      textColor = Colors.white;
                    } else if (isMid) {
                      cellColor = GamingColors.primary;
                      textColor = Colors.white;
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(4),
                        border: isMid ? Border.all(color: Colors.white, width: 1.5) : null,
                      ),
                      child: Center(
                        child: Text(
                          '$val',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GameButton(
                      height: 36,
                      label: 'STEP SEARCH',
                      onPressed: _searchCompleted ? null : _stepSearch,
                      color: GamingColors.accent,
                    ),
                    const SizedBox(width: 12),
                    GameButton(
                      height: 36,
                      label: 'REBOOT',
                      onPressed: _resetSearch,
                      color: GamingColors.surfaceLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const GameCard(
            title: 'REAL-WORLD ANALOGY',
            child: Text(
              '📖 Dictionary Search: You search for "Llama". You open the middle page: "Monkey". L comes before M, so you immediately discard the entire second half of the dictionary. Repeat!',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          _buildCodeBlock('''// Dart Binary Search Implementation
int binarySearch(List<int> sorted, int target) {
  int low = 0;
  int high = sorted.length - 1;

  while (low <= high) {
    int mid = low + (high - low) ~/ 2;
    int guess = sorted[mid];

    if (guess == target) return mid; // Found!
    if (guess > target) {
      high = mid - 1; // Left half
    } else {
      low = mid + 1;  // Right half
    }
  }
  return -1; // Not found
}'''),
        ],
      ),
    );
  }

  // ==================== SYSTEM DESIGN TAB ====================
  Widget _buildSystemDesignTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Definition Header
          const GameCard(
            title: 'MOBILE SYSTEM DESIGN',
            borderColor: GamingColors.primary,
            child: Text(
              'System design for mobile focus on architectural choices under resource constraints (low battery, weak 3G signals, memory, and lifecycle kills). Here is how a production app is built.',
              style: TextStyle(fontSize: 13, height: 1.4, color: GamingColors.textPrimary),
            ),
          ),
          const SizedBox(height: 16),

          // 1. High-Level Design (HLD) Layers Explorer
          GameCard(
            title: '1. INTERACTIVE HLD ARCHITECTURE MAP',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHldLayerButton('UI Layer', GamingColors.primary),
                const Icon(Icons.arrow_downward, color: Colors.white24, size: 16),
                _buildHldLayerButton('Business Layer', GamingColors.secondary),
                const Icon(Icons.arrow_downward, color: Colors.white24, size: 16),
                _buildHldLayerButton('Data Layer', GamingColors.warning),
                const Icon(Icons.arrow_downward, color: Colors.white24, size: 16),
                _buildHldLayerButton('Network/DB Engine', GamingColors.accent),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    _hldLayerDetails,
                    style: const TextStyle(fontSize: 11, height: 1.5, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Real-Time Protocol Matrix Selector
          GameCard(
            title: '2. REAL-TIME PROTOCOL DECISION MATRIX',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a real-time scenario to choose the correct connection protocol:',
                  style: TextStyle(fontSize: 11, color: Colors.white54),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScenarioChip('Chat App'),
                    _buildScenarioChip('Live Scores'),
                    _buildScenarioChip('News Feed'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProtocolDecisionDetails(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Offline-First Optimistic Sync Simulator
          GameCard(
            title: '3. OFFLINE-FIRST OPTIMISTIC SYNC SIMULATOR',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isOfflineMode ? Icons.cloud_off : Icons.cloud_done,
                          color: _isOfflineMode ? GamingColors.error : GamingColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isOfflineMode ? 'NETWORK: OFFLINE' : 'NETWORK: ONLINE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _isOfflineMode ? GamingColors.error : GamingColors.accent,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: !_isOfflineMode,
                      activeThumbColor: GamingColors.accent,
                      inactiveThumbColor: GamingColors.error,
                      onChanged: (val) {
                        _toggleNetworkMode();
                        if (val) {
                          _triggerSyncQueue();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('LOCAL DATABASE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white54)),
                          const SizedBox(height: 6),
                          Container(
                            height: 100,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                            child: ListView(
                              children: _localDatabase.map((post) {
                                return Text(post, style: const TextStyle(fontSize: 10, color: Colors.white70));
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('OFFLINE SYNC QUEUE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white54)),
                          const SizedBox(height: 6),
                          Container(
                            height: 100,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                            child: _syncQueue.isEmpty
                                ? const Center(child: Text('Queue empty', style: TextStyle(fontSize: 9, color: Colors.white24)))
                                : ListView(
                                    children: _syncQueue.map((post) {
                                      return Text(post, style: const TextStyle(fontSize: 10, color: GamingColors.warning));
                                    }).toList(),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GameButton(
                        height: 36,
                        label: 'ADD POST',
                        onPressed: _addPostOffline,
                        color: GamingColors.primary,
                      ),
                    ),
                    if (!_isOfflineMode && _syncQueue.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: GameButton(
                          height: 36,
                          label: _isSyncing ? 'SYNCING...' : 'SYNC QUEUE',
                          onPressed: _isSyncing ? null : _triggerSyncQueue,
                          color: GamingColors.accent,
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHldLayerButton(String label, Color color) {
    final isSelected = _selectedHldLayer == label;
    return GestureDetector(
      onTap: () => _selectHldLayer(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : GamingColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8)] : null,
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScenarioChip(String label) {
    final isSelected = _selectedRealtimeScenario == label;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.white70)),
      selected: isSelected,
      selectedColor: GamingColors.accent,
      backgroundColor: GamingColors.surfaceLight,
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedRealtimeScenario = label;
          });
        }
      },
    );
  }

  Widget _buildProtocolDecisionDetails() {
    String recommendation = '';
    String why = '';
    switch (_selectedRealtimeScenario) {
      case 'Chat App':
        recommendation = 'Protocol Recommended: WebSockets';
        why = '• Bi-directional real-time communication: Users must push messages and receive updates concurrently.\n• Minimal connection handshakes: Connection stays open continually.';
        break;
      case 'Live Scores':
        recommendation = 'Protocol Recommended: Server-Sent Events (SSE)';
        why = '• Uni-directional flow: Client only receives score updates. No push events required.\n• Saves battery compared to polling since the radio stays warm only during active frame updates.';
        break;
      case 'News Feed':
      default:
        recommendation = 'Protocol Recommended: HTTP Polling (or Pull-to-Refresh)';
        why = '• Low real-time dependency: Algorithmic ranking loads feed posts once. Updates do not change second-to-second.\n• Most efficient battery saver: Cuts radio usage entirely between fetches.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recommendation,
            style: const TextStyle(fontWeight: FontWeight.bold, color: GamingColors.accent, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            why,
            style: const TextStyle(fontSize: 10, height: 1.4, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(String code) {
    return GameCard(
      title: 'DART REFERENCE CODE',
      child: Container(
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
            code,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Colors.blueGrey.shade800,
            ),
          ),
        ),
      ),
    );
  }
}
