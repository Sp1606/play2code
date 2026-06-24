import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getUserProfile(String uid);
  Future<void> updateXP(String uid, int xpGained);
}
