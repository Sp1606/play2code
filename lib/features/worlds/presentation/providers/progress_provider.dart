import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/progress_repository.dart';
import 'game_state_provider.dart';

class LevelProgressNotifier extends StateNotifier<Map<int, String>> {
  final Ref _ref;

  LevelProgressNotifier(this._ref) : super({
    1: ProgressRepository.statusInProgress,
    2: ProgressRepository.statusNotStarted,
    3: ProgressRepository.statusNotStarted,
    4: ProgressRepository.statusNotStarted,
  }) {
    loadProgress();
  }

  Future<void> loadProgress() async {
    final status1 = await ProgressRepository.instance.getLevelStatus(1);
    final status2 = await ProgressRepository.instance.getLevelStatus(2);
    final status3 = await ProgressRepository.instance.getLevelStatus(3);
    final status4 = await ProgressRepository.instance.getLevelStatus(4);

    state = {
      1: status1,
      2: status2,
      3: status3,
      4: status4,
    };
  }

  Future<void> completeLevel(int levelIndex) async {
    final previousStatus = state[levelIndex];
    await ProgressRepository.instance.completeLevel(levelIndex);
    await loadProgress();

    if (previousStatus != ProgressRepository.statusCompleted) {
      await _ref.read(gameStateProvider.notifier).awardLevelCompletion(levelIndex);
    }
  }

  Future<void> setLevelInProgress(int levelIndex) async {
    final currentStatus = state[levelIndex];
    if (currentStatus == ProgressRepository.statusNotStarted) {
      await ProgressRepository.instance.updateLevelStatus(levelIndex, ProgressRepository.statusInProgress);
      await loadProgress();
    }
  }

  Future<void> resetProgress() async {
    await ProgressRepository.instance.resetProgress();
    await _ref.read(gameStateProvider.notifier).resetState();
    await loadProgress();
  }
}

final levelProgressProvider = StateNotifierProvider<LevelProgressNotifier, Map<int, String>>((ref) {
  return LevelProgressNotifier(ref);
});
