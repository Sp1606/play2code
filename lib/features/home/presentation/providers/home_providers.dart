import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/repositories/home_repository.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return HomeRemoteDataSourceImpl(FirebaseService.instance);
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remoteDataSource: remoteDataSource);
});

// A StateNotifier to manage the challenges list
class DailyChallengesNotifier extends StateNotifier<AsyncValue<List<Challenge>>> {
  final HomeRepository _repository;

  DailyChallengesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadChallenges();
  }

  Future<void> loadChallenges() async {
    state = const AsyncValue.loading();
    try {
      final challenges = await _repository.getDailyChallenges();
      state = AsyncValue.data(challenges);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeChallenge(String id) async {
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    try {
      // Optimistic update
      state = AsyncValue.data([
        for (final challenge in currentList)
          if (challenge.id == id)
            challenge.copyWith(isCompleted: true)
          else
            challenge
      ]);

      await _repository.completeChallenge(id);
    } catch (e) {
      // Revert in case of error
      state = AsyncValue.data(currentList);
    }
  }
}

final dailyChallengesProvider =
    StateNotifierProvider<DailyChallengesNotifier, AsyncValue<List<Challenge>>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return DailyChallengesNotifier(repository);
});
