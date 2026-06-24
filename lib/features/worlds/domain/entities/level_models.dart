class GameProgress {
  final String gameId;
  final String title;
  final String description;
  final int currentDifficulty; // 1: Easy, 2: Medium, 3: Hard, 4: Boss
  final List<int> completedLevels; // List of level indices completed (e.g. [1, 2])
  final bool isBossUnlocked;
  final bool isCompleted;

  const GameProgress({
    required this.gameId,
    required this.title,
    required this.description,
    this.currentDifficulty = 1,
    this.completedLevels = const [],
    this.isBossUnlocked = false,
    this.isCompleted = false,
  });

  double get percentComplete {
    if (completedLevels.isEmpty) return 0.0;
    return completedLevels.length / 4.0; // 3 standard levels + 1 boss = 4 total levels
  }

  GameProgress copyWith({
    String? gameId,
    String? title,
    String? description,
    int? currentDifficulty,
    List<int>? completedLevels,
    bool? isBossUnlocked,
    bool? isCompleted,
  }) {
    return GameProgress(
      gameId: gameId ?? this.gameId,
      title: title ?? this.title,
      description: description ?? this.description,
      currentDifficulty: currentDifficulty ?? this.currentDifficulty,
      completedLevels: completedLevels ?? this.completedLevels,
      isBossUnlocked: isBossUnlocked ?? this.isBossUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class GameAnalytics {
  final String gameId;
  final double completionRate;
  final int confidenceScore; // 1 to 5
  final String reflectionResponse;
  final bool discoveredPattern;
  final DateTime timestamp;

  const GameAnalytics({
    required this.gameId,
    required this.completionRate,
    required this.confidenceScore,
    required this.reflectionResponse,
    required this.discoveredPattern,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'completionRate': completionRate,
      'confidenceScore': confidenceScore,
      'reflectionResponse': reflectionResponse,
      'discoveredPattern': discoveredPattern,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
