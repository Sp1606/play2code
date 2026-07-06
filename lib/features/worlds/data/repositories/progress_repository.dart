import 'package:shared_preferences/shared_preferences.dart';

class ProgressRepository {
  ProgressRepository._();

  static final ProgressRepository instance = ProgressRepository._();

  static String _levelPrefix(String uid) => 'play2code_user_${uid}_level_';

  // Valid statuses: 'Not Started', 'In Progress', 'Completed'
  static const String statusNotStarted = 'Not Started';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';

  /// Get status of a specific level. Defaults to 'In Progress' for level 1, and 'Not Started' for others.
  Future<String> getLevelStatus(String uid, int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('${_levelPrefix(uid)}$levelIndex');

    if (status != null) return status;

    // Default states
    if (levelIndex == 1) {
      return statusInProgress; // Level 1 starts unlocked and ready
    }
    return statusNotStarted;
  }

  /// Update status of a specific level
  Future<void> updateLevelStatus(String uid, int levelIndex, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_levelPrefix(uid)}$levelIndex', status);
  }

  /// Mark a level as completed, and unlock the next level
  Future<void> completeLevel(String uid, int levelIndex) async {
    await updateLevelStatus(uid, levelIndex, statusCompleted);
    
    // Unlock the next level
    if (levelIndex < 4) {
      final nextLevelStatus = await getLevelStatus(uid, levelIndex + 1);
      if (nextLevelStatus == statusNotStarted) {
        await updateLevelStatus(uid, levelIndex + 1, statusInProgress);
      }
    }
  }

  /// Clear all progress for this user
  Future<void> resetProgress(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _levelPrefix(uid);
    await prefs.remove('${prefix}1');
    await prefs.remove('${prefix}2');
    await prefs.remove('${prefix}3');
    await prefs.remove('${prefix}4');
  }
}
