import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfile> getUserProfile(String uid) async {
    return await remoteDataSource.getUserProfile(uid);
  }

  @override
  Future<void> updateXP(String uid, int xpGained) async {
    await remoteDataSource.updateXP(uid, xpGained);
  }
}
