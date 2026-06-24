import 'dart:async';
import '../../../../core/services/firebase_service.dart';
import '../models/challenge_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<ChallengeModel>> getDailyChallenges();
  Future<void> completeChallenge(String id);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseService _firebaseService;

  HomeRemoteDataSourceImpl(this._firebaseService);

  @override
  Future<List<ChallengeModel>> getDailyChallenges() async {
    // In production, we'd query Firestore:
    // var snapshot = await _firebaseInstance.collection('daily_challenges').get();
    // return snapshot.docs.map((doc) => ChallengeModel.fromJson(doc.data())).toList();

    // Mock Firestore fetch through our FirebaseService
    await _firebaseService.getDocument('users', 'mock_user_123'); // trigger mock delay
    
    return [
      const ChallengeModel(
        id: 'challenge_1',
        title: 'Variable Declaration Master',
        description: 'Declare variables of types String, int, and double, and debug a syntax error.',
        difficulty: 'Easy',
        points: 50,
        isCompleted: true,
      ),
      const ChallengeModel(
        id: 'challenge_2',
        title: 'Recursive Factorial Quest',
        description: 'Implement a recursive function to compute the factorial of a given integer.',
        difficulty: 'Medium',
        points: 150,
        isCompleted: false,
      ),
      const ChallengeModel(
        id: 'challenge_3',
        title: 'Matrix Rotation Challenge',
        description: 'Rotate an NxN matrix 90 degrees clockwise in-place.',
        difficulty: 'Hard',
        points: 300,
        isCompleted: false,
      ),
    ];
  }

  @override
  Future<void> completeChallenge(String id) async {
    // In production:
    // await _firebaseInstance.collection('users').doc(userId).update({'completedChallenges': FieldValue.arrayUnion([id])});
    await _firebaseService.updateDocument('users', 'mock_user_123', {
      'completedChallengeId': id,
    });
  }
}
