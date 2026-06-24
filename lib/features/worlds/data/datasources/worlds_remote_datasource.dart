import '../../../../core/services/firebase_service.dart';
import '../models/world_model.dart';

abstract class WorldsRemoteDataSource {
  Stream<List<WorldModel>> watchWorlds();
}

class WorldsRemoteDataSourceImpl implements WorldsRemoteDataSource {
  final FirebaseService _firebaseService;

  WorldsRemoteDataSourceImpl(this._firebaseService);

  @override
  Stream<List<WorldModel>> watchWorlds() {
    return _firebaseService.collectionStream('worlds').map((list) {
      return list.map((item) => WorldModel.fromJson(item)).toList();
    });
  }
}
