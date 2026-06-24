import '../../../../core/services/firebase_service.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String uid);
  Future<void> updateXP(String uid, int xpGained);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseService _firebaseService;

  ProfileRemoteDataSourceImpl(this._firebaseService);

  @override
  Future<UserProfileModel> getUserProfile(String uid) async {
    final data = await _firebaseService.getDocument('users', uid);
    if (data == null) {
      throw Exception('User profile not found in database');
    }
    return UserProfileModel.fromJson(data, email: 'player@play2code.edu', username: 'CodeWarrior');
  }

  @override
  Future<void> updateXP(String uid, int xpGained) async {
    // In production, update Firestore document
    await _firebaseService.updateDocument('users', uid, {
      'xpGained': xpGained,
    });
  }
}
