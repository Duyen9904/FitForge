import 'package:mobile/features/exercises/models/exercise_models.dart';

const mockExerciseSummary = ExerciseSummary(
  exerciseId: 'ex-1',
  exerciseName: 'Bench Press',
  difficultyLevel: 'INTERMEDIATE',
  exerciseType: 'STRENGTH',
  imageUrl: 'https://example.com/bench.jpg',
  caloriesBurnedPerMin: 8,
);

const mockExerciseWithoutImage = ExerciseSummary(
  exerciseId: 'ex-2',
  exerciseName: 'Bodyweight Squat',
  difficultyLevel: 'BEGINNER',
  exerciseType: 'BODYWEIGHT',
);

const mockExerciseAdvanced = ExerciseSummary(
  exerciseId: 'ex-3',
  exerciseName: 'Deadlift',
  difficultyLevel: 'ADVANCED',
  exerciseType: 'STRENGTH',
  caloriesBurnedPerMin: 12,
);
