/// Exercise type classification
enum ExerciseType {
  strength,
  cardio,
  flexibility,
  balance;

  String get displayName {
    switch (this) {
      case ExerciseType.strength:
        return 'Strength';
      case ExerciseType.cardio:
        return 'Cardio';
      case ExerciseType.flexibility:
        return 'Flexibility';
      case ExerciseType.balance:
        return 'Balance';
    }
  }
}

/// Exercise category for backend API (COMPOUND/ISOLATION)
enum ExerciseCategory {
  compound,
  isolation;

  String get apiValue => name.toUpperCase();
  
  String get displayName {
    switch (this) {
      case ExerciseCategory.compound:
        return 'Compound';
      case ExerciseCategory.isolation:
        return 'Isolation';
    }
  }
  
  static ExerciseCategory? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase();
    return ExerciseCategory.values.firstWhere(
      (e) => e.name == normalized,
      orElse: () => ExerciseCategory.compound,
    );
  }
}
