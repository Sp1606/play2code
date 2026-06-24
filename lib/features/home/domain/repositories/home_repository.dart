import '../entities/challenge.dart';

abstract class HomeRepository {
  Future<List<Challenge>> getDailyChallenges();
  Future<void> completeChallenge(String id);
}
