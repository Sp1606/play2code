import 'package:shared_preferences/shared_preferences.dart';

class ProgressRepository {
  ProgressRepository._();

  static final ProgressRepository instance = ProgressRepository._();

  static const String _levelPrefix = 'play2code_level_';

  // Valid statuses: 'Not Started', 'In Progress', 'Completed'
  static const String statusNotStarted = 'Not Started';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';

  /// Get status of a specific level. Defaults to 'In Progress' for level 1, and 'Not Started' for others.
  Future<String> getLevelStatus(int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('$_levelPrefix$levelIndex');

    if (status != null) return status;

    // Default states
    if (levelIndex == 1) {
      return statusInProgress; // Level 1 starts unlocked and ready
    }
    return statusNotStarted;
  }

  /// Update status of a specific level
  Future<void> updateLevelStatus(int levelIndex, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_levelPrefix$levelIndex', status);
  }

  /// Mark a level as completed, and unlock the next level
  Future<void> completeLevel(int levelIndex) async {
    await updateLevelStatus(levelIndex, statusCompleted);
    
    // Unlock the next level
    if (levelIndex < 4) {
      final nextLevelStatus = await getLevelStatus(levelIndex + 1);
      if (nextLevelStatus == statusNotStarted) {
        await updateLevelStatus(levelIndex + 1, statusInProgress);
      }
    }
  }

  /// Clear all progress (for debug or restart)
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_levelPrefix}1');
    await prefs.remove('${_levelPrefix}2');
    await prefs.remove('${_levelPrefix}3');
    await prefs.remove('${_levelPrefix}4');
  }
}
