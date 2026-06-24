import '../entities/world.dart';

abstract class WorldsRepository {
  Stream<List<World>> watchWorlds();
}
