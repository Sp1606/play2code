import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'progress_provider.dart';

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
  final String _uid;

  GameStateNotifier(this._uid)
      : super(const GameState(
          coins: 0,
          gems: 0,
          energy: 5,
          xp: 0,
          level: 1,
        )) {
    loadState();
  }

  String get _keyCoins => 'play2code_${_uid}_coins';
  String get _keyGems => 'play2code_${_uid}_gems';
  String get _keyEnergy => 'play2code_${_uid}_energy';
  String get _keyXp => 'play2code_${_uid}_xp';
  String get _keyLevel => 'play2code_${_uid}_level';

  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final coins = prefs.getInt(_keyCoins) ?? 0;
    final gems = prefs.getInt(_keyGems) ?? 0;
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
    int newXp = state.xp + 100;
    int newLevel = state.level;
    int coinsAwarded = 50;
    int gemsAwarded = 10;

    // Check level up (100 XP per level)
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

  Future<void> addXp(int amount) async {
    int newXp = state.xp + amount;
    int newLevel = state.level;
    while (newXp >= 100) {
      newXp -= 100;
      newLevel += 1;
    }
    state = state.copyWith(xp: newXp, level: newLevel);
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
      coins: 0,
      gems: 0,
      energy: 5,
      xp: 0,
      level: 1,
    );
  }
}

final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState?['uid'] ?? 'guest_user';
  return GameStateNotifier(uid);
});
