import '../../domain/entities/world.dart';

class WorldModel extends World {
  const WorldModel({
    required super.id,
    required super.title,
    required super.description,
    required super.totalChallenges,
    required super.completedChallenges,
    required super.isUnlocked,
    required super.colorHex,
  });

  factory WorldModel.fromJson(Map<String, dynamic> json) {
    return WorldModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      totalChallenges: json['totalChallenges'] as int,
      completedChallenges: json['completedChallenges'] as int,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      colorHex: json['color'] as String? ?? '0xFF00F0FF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'totalChallenges': totalChallenges,
      'completedChallenges': completedChallenges,
      'isUnlocked': isUnlocked,
      'color': colorHex,
    };
  }
}
