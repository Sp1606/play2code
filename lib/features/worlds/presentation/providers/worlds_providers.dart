import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../../data/datasources/worlds_remote_datasource.dart';
import '../../data/repositories/worlds_repository_impl.dart';
import '../../domain/entities/world.dart';
import '../../domain/repositories/worlds_repository.dart';

final worldsRemoteDataSourceProvider = Provider<WorldsRemoteDataSource>((ref) {
  return WorldsRemoteDataSourceImpl(FirebaseService.instance);
});

final worldsRepositoryProvider = Provider<WorldsRepository>((ref) {
  final remoteDataSource = ref.watch(worldsRemoteDataSourceProvider);
  return WorldsRepositoryImpl(remoteDataSource: remoteDataSource);
});

final worldsStreamProvider = StreamProvider<List<World>>((ref) {
  final repository = ref.watch(worldsRepositoryProvider);
  return repository.watchWorlds();
});
