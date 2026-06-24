import '../../domain/entities/challenge.dart';

class ChallengeModel extends Challenge {
  const ChallengeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.difficulty,
    required super.points,
    required super.isCompleted,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String,
      points: json['points'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'points': points,
      'isCompleted': isCompleted,
    };
  }

  factory ChallengeModel.fromEntity(Challenge entity) {
    return ChallengeModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      difficulty: entity.difficulty,
      points: entity.points,
      isCompleted: entity.isCompleted,
    );
  }
}
