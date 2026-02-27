/// Difficulty level for exercises and workouts
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert;

  String get displayName {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }
  
  String get apiValue => name;
  
  static DifficultyLevel? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase();
    return DifficultyLevel.values.firstWhere(
      (e) => e.name == normalized,
      orElse: () => DifficultyLevel.beginner,
    );
  }
}
