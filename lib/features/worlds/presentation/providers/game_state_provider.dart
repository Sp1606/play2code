import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState {
  final int coins;
  final int gems;
  final int energy;
  final int xp;
  final int level;

  const GameState({
    required this.coins,
    required this.gems,
    required this.energy,
    required this.xp,
    required this.level,
  });

  GameState copyWith({
    int? coins,
    int? gems,
    int? energy,
    int? xp,
    int? level,
  }) {
    return GameState(
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      energy: energy ?? this.energy,
      xp: xp ?? this.xp,
      level: level ?? this.level,
    );
  }
}

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier()
      : super(const GameState(
          coins: 100,
          gems: 20,
          energy: 5,
          xp: 0,
          level: 1,
        )) {
    loadState();
  }

  static const String _keyCoins = 'play2code_coins';
  static const String _keyGems = 'play2code_gems';
  static const String _keyEnergy = 'play2code_energy';
  static const String _keyXp = 'play2code_xp';
  static const String _keyLevel = 'play2code_level';

  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final coins = prefs.getInt(_keyCoins) ?? 100;
    final gems = prefs.getInt(_keyGems) ?? 20;
    final energy = prefs.getInt(_keyEnergy) ?? 5;
    final xp = prefs.getInt(_keyXp) ?? 0;
    final level = prefs.getInt(_keyLevel) ?? 1;

    state = GameState(
      coins: coins,
      gems: gems,
      energy: energy,
      xp: xp,
      level: level,
    );
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCoins, state.coins);
    await prefs.setInt(_keyGems, state.gems);
    await prefs.setInt(_keyEnergy, state.energy);
    await prefs.setInt(_keyXp, state.xp);
    await prefs.setInt(_keyLevel, state.level);
  }

  Future<void> awardLevelCompletion(int levelIndex) async {
    // Award 100 XP, 50 coins, 10 gems
    int newXp = state.xp + 100;
    int newLevel = state.level;
    int coinsAwarded = 50;
    int gemsAwarded = 10;

    // Check level up (every 100 XP is a level)
    if (newXp >= 100) {
      newXp = newXp - 100;
      newLevel += 1;
      gemsAwarded += 20; // Level up bonus!
    }

    state = state.copyWith(
      xp: newXp,
      level: newLevel,
      coins: state.coins + coinsAwarded,
      gems: state.gems + gemsAwarded,
    );
    await _saveState();
  }

  Future<bool> spendCoins(int amount) async {
    if (state.coins >= amount) {
      state = state.copyWith(coins: state.coins - amount);
      await _saveState();
      return true;
    }
    return false;
  }

  Future<bool> spendGems(int amount) async {
    if (state.gems >= amount) {
      state = state.copyWith(gems: state.gems - amount);
      await _saveState();
      return true;
    }
    return false;
  }

  Future<bool> useEnergy() async {
    if (state.energy > 0) {
      state = state.copyWith(energy: state.energy - 1);
      await _saveState();
      return true;
    }
    return false;
  }

  Future<void> refillEnergy() async {
    state = state.copyWith(energy: 5);
    await _saveState();
  }

  Future<void> addGems(int amount) async {
    state = state.copyWith(gems: state.gems + amount);
    await _saveState();
  }

  Future<void> addCoins(int amount) async {
    state = state.copyWith(coins: state.coins + amount);
    await _saveState();
  }

  Future<void> resetState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCoins);
    await prefs.remove(_keyGems);
    await prefs.remove(_keyEnergy);
    await prefs.remove(_keyXp);
    await prefs.remove(_keyLevel);
    
    state = const GameState(
      coins: 100,
      gems: 20,
      energy: 5,
      xp: 0,
      level: 1,
    );
  }
}

final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});
