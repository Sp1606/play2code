class World {
  final String id;
  final String title;
  final String description;
  final int totalChallenges;
  final int completedChallenges;
  final bool isUnlocked;
  final String colorHex;

  const World({
    required this.id,
    required this.title,
    required this.description,
    required this.totalChallenges,
    required this.completedChallenges,
    required this.isUnlocked,
    required this.colorHex,
  });

  double get progress => totalChallenges == 0 ? 0.0 : completedChallenges / totalChallenges;
}
