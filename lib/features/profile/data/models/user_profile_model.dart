import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.username,
    required super.email,
    required super.level,
    required super.xp,
    required super.rank,
    required super.achievements,
    required super.avatarUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json, {String? email, String? username}) {
    return UserProfileModel(
      uid: json['uid'] as String,
      username: username ?? json['username'] as String? ?? 'PlayerOne',
      email: email ?? json['email'] as String? ?? 'player@play2code.edu',
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      rank: json['rank'] as String? ?? 'Novice Coder',
      achievements: List<String>.from(json['achievements'] as List? ?? []),
      avatarUrl: json['avatarUrl'] as String? ?? 
          'https://api.dicebear.com/7.x/pixel-art/svg?seed=${username ?? json['uid'] ?? 'player'}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'level': level,
      'xp': xp,
      'rank': rank,
      'achievements': achievements,
      'avatarUrl': avatarUrl,
    };
  }
}
