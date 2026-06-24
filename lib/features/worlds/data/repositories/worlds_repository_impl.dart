import '../../domain/entities/world.dart';
import '../../domain/repositories/worlds_repository.dart';
import '../datasources/worlds_remote_datasource.dart';

class WorldsRepositoryImpl implements WorldsRepository {
  final WorldsRemoteDataSource remoteDataSource;

  WorldsRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<World>> watchWorlds() {
    return remoteDataSource.watchWorlds();
  }
}
