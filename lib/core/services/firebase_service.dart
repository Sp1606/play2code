import 'dart:async';
import 'package:flutter/material.dart';

/// A service that acts as a placeholder for Firebase Integration.
/// It outlines where to put real Firebase initialization, Authentication,
/// and Firestore calls.
class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  bool _isInitialized = false;

  /// Placeholder for Firebase initialization
  Future<void> initializeApp() async {
    if (_isInitialized) return;

    debugPrint('--- FIREBASE INTEGRATION PLACEHOLDER ---');
    debugPrint('Initializing Firebase SDK...');
    
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
    debugPrint('Firebase initialized successfully (Mock mode).');
  }

  // ==========================================
  // Authentication Placeholders
  // ==========================================
  
  /// ValueNotifier holding the current active user authentication state
  final ValueNotifier<Map<String, dynamic>?> authStateNotifier = ValueNotifier<Map<String, dynamic>?>(null);

  /// Stream of Auth State changes
  Stream<Map<String, dynamic>?> get authStateChanges {
    final controller = StreamController<Map<String, dynamic>?>.broadcast();
    void listener() {
      if (!controller.isClosed) {
        controller.add(authStateNotifier.value);
      }
    }
    authStateNotifier.addListener(listener);
    // Yield current auth value immediately on listen
    Timer.run(() {
      if (!controller.isClosed) {
        controller.add(authStateNotifier.value);
      }
    });
    return controller.stream;
  }

  /// Sign In with Email & Password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    debugPrint('Firebase Auth: Signing in with $email...');
    await Future.delayed(const Duration(milliseconds: 600));
    
    final cleanEmail = email.toLowerCase().trim();
    // Simulate user creation by deriving a unique UID hash
    final uid = 'user_${cleanEmail.hashCode}';
    final username = cleanEmail.split('@').first;
    
    final user = {
      'uid': uid,
      'email': email,
      'displayName': username,
      'photoUrl': 'https://api.dicebear.com/7.x/pixel-art/svg?seed=$username',
    };

    if (!_userDocs.containsKey(uid)) {
      _userDocs[uid] = {
        'uid': uid,
        'username': username,
        'email': email,
        'level': 1,
        'xp': 0,
        'rank': 'Novice Coder',
        'completedWorldsCount': 0,
        'achievements': <String>[],
      };
    }

    authStateNotifier.value = user;
    return user;
  }

  /// Sign Out
  Future<void> signOut() async {
    debugPrint('Firebase Auth: Signing out user...');
    await Future.delayed(const Duration(milliseconds: 300));
    authStateNotifier.value = null;
  }

  // ==========================================
  // Firestore Database Placeholders
  // ==========================================

  // In-memory collection simulation to store profiles separately by dynamic UID
  final Map<String, Map<String, dynamic>> _userDocs = {};

  /// Fetch a document from a collection
  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    debugPrint('Firestore: Fetching document $docId from collection $collection...');
    await Future.delayed(const Duration(milliseconds: 200));

    if (collection == 'users') {
      if (!_userDocs.containsKey(docId)) {
        _userDocs[docId] = {
          'uid': docId,
          'username': 'WarriorOne',
          'email': 'player@play2code.edu',
          'level': 1,
          'xp': 0,
          'rank': 'Novice Coder',
          'completedWorldsCount': 0,
          'achievements': <String>[],
        };
      }
      return _userDocs[docId];
    }
    return null;
  }

  /// Stream updates for a collection
  Stream<List<Map<String, dynamic>>> collectionStream(String collection) {
    debugPrint('Firestore: Listening to collection $collection...');
    
    if (collection == 'worlds') {
      return Stream.value([
        {
          'id': 'stack_temple',
          'title': 'Stack Temple',
          'description': 'Master LIFO order in block assembly tasks.',
          'totalChallenges': 4,
          'completedChallenges': 2,
          'isUnlocked': true,
          'color': '0xFF0284C7',
        },
        {
          'id': 'queue_station',
          'title': 'Queue Station',
          'description': 'Solve ticket routing using FIFO processing.',
          'totalChallenges': 4,
          'completedChallenges': 1,
          'isUnlocked': true,
          'color': '0xFF7C3AED',
        },
        {
          'id': 'treasure_hunt',
          'title': 'Treasure Hunt',
          'description': 'Search sorted chests efficiently using Binary Search division.',
          'totalChallenges': 4,
          'completedChallenges': 0,
          'isUnlocked': true,
          'color': '0xFF059669',
        },
      ]);
    }
    return Stream.value([]);
  }

  /// Update user progress data
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    debugPrint('Firestore: Updating document $docId in $collection with data: $data');
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (collection == 'users') {
      if (!_userDocs.containsKey(docId)) {
        _userDocs[docId] = {
          'uid': docId,
          'level': 1,
          'xp': 0,
          'rank': 'Novice Coder',
          'completedWorldsCount': 0,
          'achievements': <String>[],
        };
      }
      _userDocs[docId] = {
        ..._userDocs[docId]!,
        ...data,
      };
    }
  }

  // ==========================================
  // Play2Code Custom Progression & Analytics
  // ==========================================

  // Mock Database State for games in World 1
  final List<Map<String, dynamic>> _mockGameProgress = [
    {
      'gameId': 'stack_temple',
      'title': 'Stack Temple',
      'description': 'Master LIFO order in block assembly tasks.',
      'currentDifficulty': 1,
      'completedLevels': <int>[],
      'isBossUnlocked': false,
      'isCompleted': false,
    },
    {
      'gameId': 'queue_station',
      'title': 'Queue Station',
      'description': 'Solve ticket routing using FIFO processing.',
      'currentDifficulty': 1,
      'completedLevels': <int>[],
      'isBossUnlocked': false,
      'isCompleted': false,
    },
    {
      'gameId': 'treasure_hunt',
      'title': 'Treasure Hunt',
      'description': 'Search sorted chests efficiently using Binary Search division.',
      'currentDifficulty': 1,
      'completedLevels': <int>[],
      'isBossUnlocked': false,
      'isCompleted': false,
    },
  ];

  final List<Map<String, dynamic>> _mockAnalyticsLogs = [];

  /// Stream of World 1 games progress
  Stream<List<Map<String, dynamic>>> watchGameProgress() {
    return Stream.value(_mockGameProgress);
  }

  /// Update level completion in Firestore
  Future<void> updateGameProgress(String gameId, int levelIndex, bool isCompleted) async {
    debugPrint('Firebase Firestore: Updating progress for game $gameId, completed level: $levelIndex, isCompleted: $isCompleted');
    await Future.delayed(const Duration(milliseconds: 300));

    final gameIndex = _mockGameProgress.indexWhere((g) => g['gameId'] == gameId);
    if (gameIndex != -1) {
      final game = _mockGameProgress[gameIndex];
      final List<int> completed = List<int>.from(game['completedLevels'] as List);
      
      if (!completed.contains(levelIndex)) {
        completed.add(levelIndex);
      }

      final isBossUnlocked = completed.contains(1) && completed.contains(2) && completed.contains(3);
      final nextDifficulty = levelIndex < 4 ? levelIndex + 1 : 4;

      _mockGameProgress[gameIndex] = {
        ...game,
        'completedLevels': completed,
        'isBossUnlocked': isBossUnlocked,
        'currentDifficulty': nextDifficulty,
        'isCompleted': isCompleted || completed.contains(4),
      };
    }
  }

  /// Submit Post-Game Analytics to Firestore
  Future<void> submitGameAnalytics(Map<String, dynamic> analytics) async {
    debugPrint('Firebase Analytics: Logging user learning data: $analytics');
    await Future.delayed(const Duration(milliseconds: 500));
    _mockAnalyticsLogs.add(analytics);
  }

  /// Get mock analytics logs
  List<Map<String, dynamic>> get mockAnalyticsLogs => _mockAnalyticsLogs;
}
