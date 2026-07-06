import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../../data/repositories/progress_repository.dart';
import 'game_state_provider.dart';

// Central provider mapping Firebase auth state notifier to Riverpod state
final authStateProvider = StateProvider<Map<String, dynamic>?>((ref) {
  final notifier = FirebaseService.instance.authStateNotifier;
  void listener() {
    ref.controller.state = notifier.value;
  }
  notifier.addListener(listener);
  ref.onDispose(() => notifier.removeListener(listener));
  return notifier.value;
});

class LevelProgressNotifier extends StateNotifier<Map<int, String>> {
  final Ref _ref;
  final String _uid;

  LevelProgressNotifier(this._ref, this._uid) : super({
    1: ProgressRepository.statusInProgress,
    2: ProgressRepository.statusNotStarted,
    3: ProgressRepository.statusNotStarted,
    4: ProgressRepository.statusNotStarted,
  }) {
    loadProgress();
  }

  Future<void> loadProgress() async {
    final status1 = await ProgressRepository.instance.getLevelStatus(_uid, 1);
    final status2 = await ProgressRepository.instance.getLevelStatus(_uid, 2);
    final status3 = await ProgressRepository.instance.getLevelStatus(_uid, 3);
    final status4 = await ProgressRepository.instance.getLevelStatus(_uid, 4);

    state = {
      1: status1,
      2: status2,
      3: status3,
      4: status4,
    };
  }

  Future<void> completeLevel(int levelIndex) async {
    final previousStatus = state[levelIndex];
    await ProgressRepository.instance.completeLevel(_uid, levelIndex);
    await loadProgress();

    if (previousStatus != ProgressRepository.statusCompleted) {
      await _ref.read(gameStateProvider.notifier).awardLevelCompletion(levelIndex);
    }
  }

  Future<void> setLevelInProgress(int levelIndex) async {
    final currentStatus = state[levelIndex];
    if (currentStatus == ProgressRepository.statusNotStarted) {
      await ProgressRepository.instance.updateLevelStatus(_uid, levelIndex, ProgressRepository.statusInProgress);
      await loadProgress();
    }
  }

  Future<void> resetProgress() async {
    await ProgressRepository.instance.resetProgress(_uid);
    await _ref.read(gameStateProvider.notifier).resetState();
    await loadProgress();
  }
}

final levelProgressProvider = StateNotifierProvider<LevelProgressNotifier, Map<int, String>>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState?['uid'] ?? 'guest_user';
  return LevelProgressNotifier(ref, uid);
});
