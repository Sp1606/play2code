class Challenge {
  final String id;
  final String title;
  final String description;
  final String difficulty; // e.g., 'Easy', 'Medium', 'Hard'
  final int points;
  final bool isCompleted;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.points,
    required this.isCompleted,
  });

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    int? points,
    bool? isCompleted,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
