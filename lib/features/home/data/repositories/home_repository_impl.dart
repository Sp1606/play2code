import '../../domain/entities/challenge.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Challenge>> getDailyChallenges() async {
    return await remoteDataSource.getDailyChallenges();
  }

  @override
  Future<void> completeChallenge(String id) async {
    await remoteDataSource.completeChallenge(id);
  }
}
