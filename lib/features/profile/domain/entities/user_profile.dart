class UserProfile {
  final String uid;
  final String username;
  final String email;
  final int level;
  final int xp;
  final String rank;
  final List<String> achievements;
  final String avatarUrl;

  const UserProfile({
    required this.uid,
    required this.username,
    required this.email,
    required this.level,
    required this.xp,
    required this.rank,
    required this.achievements,
    required this.avatarUrl,
  });

  UserProfile copyWith({
    String? uid,
    String? username,
    String? email,
    int? level,
    int? xp,
    String? rank,
    List<String>? achievements,
    String? avatarUrl,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      rank: rank ?? this.rank,
      achievements: achievements ?? this.achievements,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
