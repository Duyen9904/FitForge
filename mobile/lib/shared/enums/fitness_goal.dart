/// User fitness goal
enum FitnessGoal {
  loseWeight,
  buildMuscle,
  improveEndurance,
  maintainFitness,
  increaseFlexibility;

  String get displayName {
    switch (this) {
      case FitnessGoal.loseWeight:
        return 'Lose Weight';
      case FitnessGoal.buildMuscle:
        return 'Build Muscle';
      case FitnessGoal.improveEndurance:
        return 'Improve Endurance';
      case FitnessGoal.maintainFitness:
        return 'Maintain Fitness';
      case FitnessGoal.increaseFlexibility:
        return 'Increase Flexibility';
    }
  }
}
