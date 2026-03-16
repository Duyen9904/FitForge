import 'package:mobile/features/workouts/models/workout_plan_models.dart';
import 'package:mobile/features/exercises/models/exercise_models.dart';

// ================== Workout Plan Summaries ==================

final mockWorkoutPlanSummary = WorkoutPlanSummaryResponse(
  planId: 1,
  planName: 'Full Body Blast',
  description: 'A complete full body workout plan',
  muscleGroup: const MuscleGroup(muscleGroupId: 8, groupName: 'Full Body', category: 'COMPOUND'),
  frequencyPerWeek: 3,
  durationWeeks: 4,
  difficultyLevel: 'BEGINNER',
  aiGenerated: false,
  isActive: true,
  sessionCount: 12,
);

final mockAiGeneratedPlan = WorkoutPlanSummaryResponse(
  planId: 2,
  planName: 'AI Muscle Builder',
  description: 'AI generated muscle building plan',
  muscleGroup: const MuscleGroup(muscleGroupId: 1, groupName: 'Chest', category: 'UPPER_BODY'),
  frequencyPerWeek: 4,
  durationWeeks: 8,
  difficultyLevel: 'INTERMEDIATE',
  aiGenerated: true,
  isActive: true,
  sessionCount: 32,
);

final mockInactivePlan = WorkoutPlanSummaryResponse(
  planId: 3,
  planName: 'Old Plan',
  difficultyLevel: 'ADVANCED',
  aiGenerated: false,
  isActive: false,
);

// ================== Workout Sessions ==================

const mockWorkoutSession = WorkoutSessionResponse(
  sessionId: 1,
  sessionName: 'Push Day',
  dayNumber: 1,
  isRestDay: false,
  isMissed: false,
  exerciseCount: 5,
  exercises: [],
);

const mockRestDaySession = WorkoutSessionResponse(
  sessionId: 2,
  sessionName: 'Rest',
  dayNumber: 2,
  isRestDay: true,
  isMissed: false,
  exerciseCount: 0,
  exercises: [],
);

const mockMissedSession = WorkoutSessionResponse(
  sessionId: 3,
  sessionName: 'Leg Day',
  dayNumber: 3,
  isRestDay: false,
  isMissed: true,
  exerciseCount: 4,
  exercises: [],
);

// ================== Session Exercises ==================

const mockSessionExercise = SessionExerciseResponse(
  sessionExerciseId: 1,
  exercise: WorkoutExerciseSummary(
    exerciseId: 'ex-1',
    exerciseName: 'Bench Press',
    difficultyLevel: 'INTERMEDIATE',
    imageUrl: 'https://example.com/bench.jpg',
    caloriesBurnedPerMin: 8,
  ),
  sets: 3,
  repetitions: 12,
  weightKg: 60.0,
  restTimeSeconds: 90,
  orderIndex: 0,
);

const mockSessionExercise2 = SessionExerciseResponse(
  sessionExerciseId: 2,
  exercise: WorkoutExerciseSummary(
    exerciseId: 'ex-2',
    exerciseName: 'Squat',
    difficultyLevel: 'BEGINNER',
  ),
  sets: 4,
  repetitions: 10,
  weightKg: 80.0,
  restTimeSeconds: 120,
  orderIndex: 1,
);

const mockSessionExercise3 = SessionExerciseResponse(
  sessionExerciseId: 3,
  exercise: WorkoutExerciseSummary(
    exerciseId: 'ex-3',
    exerciseName: 'Deadlift',
    difficultyLevel: 'ADVANCED',
  ),
  sets: 3,
  repetitions: 8,
  weightKg: 100.0,
  restTimeSeconds: 120,
  orderIndex: 2,
);

const mockSessionWithExercises = WorkoutSessionResponse(
  sessionId: 10,
  sessionName: 'Full Body A',
  dayNumber: 1,
  isRestDay: false,
  isMissed: false,
  exerciseCount: 3,
  exercises: [
    mockSessionExercise,
    mockSessionExercise2,
    mockSessionExercise3,
  ],
);
