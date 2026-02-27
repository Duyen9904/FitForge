import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../shared/enums/difficulty_level_converter.dart';
import '../../../shared/enums/enums.dart';
import '../../exercises/models/exercise_models.dart';

part 'recommendation_models.freezed.dart';
part 'recommendation_models.g.dart';

/// Goal response from recommendation endpoints
@freezed
class GoalResponse with _$GoalResponse {
  const factory GoalResponse({
    required int goalId,
    required String goalName,
    String? description,
    String? recommendedRepRange,
    String? recommendedRestTime,
    String? recommendedFrequency,
    int? targetCalorieAdjustment,
  }) = _GoalResponse;

  factory GoalResponse.fromJson(Map<String, dynamic> json) =>
      _$GoalResponseFromJson(json);
}

/// Workout plan response from recommendation endpoints
@freezed
class WorkoutPlanResponse with _$WorkoutPlanResponse {
  const factory WorkoutPlanResponse({
    required int planId,
    required String planName,
    String? description,
    GoalResponse? goal,
    TargetMuscleGroup? targetMuscleGroup,
    int? frequencyPerWeek,
    int? durationWeeks,
    @DifficultyLevelConverter() DifficultyLevel? difficultyLevel,
    // Recommendation metadata
    String? algorithmVersion,
    String? generatedFrom,
    int? version,
    String? recommendationReason,
    @Default(false) bool aiGenerated,
    @Default(true) bool allowWorkoutSwaps,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<WorkoutSessionResponse> sessions,
  }) = _WorkoutPlanResponse;

  factory WorkoutPlanResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutPlanResponseFromJson(json);
}

/// Workout session response
@freezed
class WorkoutSessionResponse with _$WorkoutSessionResponse {
  const factory WorkoutSessionResponse({
    required int sessionId,
    required String sessionName,
    required int dayNumber,
    String? focusArea,
    int? estimatedDuration,
    String? warmUpNotes,
    String? coolDownNotes,
    @Default(false) bool isRestDay,
    int? exerciseCount,
    @Default([]) List<SessionExerciseResponse> exercises,
  }) = _WorkoutSessionResponse;

  factory WorkoutSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionResponseFromJson(json);
}

/// Session exercise response
@freezed
class SessionExerciseResponse with _$SessionExerciseResponse {
  const factory SessionExerciseResponse({
    required int sessionExerciseId,
    ExerciseSummary? exercise,
    int? sets,
    int? repetitions,
    double? weightKg,
    int? restTimeSeconds,
    int? orderIndex,
    String? notes,
    @Default(false) bool isSuperset,
  }) = _SessionExerciseResponse;

  factory SessionExerciseResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionExerciseResponseFromJson(json);
}

/// Nutrition plan response from recommendation endpoints
@freezed
class NutritionPlanResponse with _$NutritionPlanResponse {
  const factory NutritionPlanResponse({
    required int nutritionPlanId,
    required String planName,
    int? goalId,
    String? goalName,
    int? dailyCalorieTarget,
    // Recommendation metadata
    String? algorithmVersion,
    int? version,
    String? recommendationReason,
    // Macro percentages
    double? proteinPercentage,
    double? carbsPercentage,
    double? fatsPercentage,
    // Calculated grams
    double? proteinGrams,
    double? carbsGrams,
    double? fatsGrams,
    int? cheatMealsPerWeek,
    @Default(true) bool autoAdjustEnabled,
    @Default(true) bool isActive,
    @Default([]) List<MealTemplateResponse> mealTemplates,
  }) = _NutritionPlanResponse;

  factory NutritionPlanResponse.fromJson(Map<String, dynamic> json) =>
      _$NutritionPlanResponseFromJson(json);
}

/// Meal template response
@freezed
class MealTemplateResponse with _$MealTemplateResponse {
  const factory MealTemplateResponse({
    required int mealTemplateId,
    required String mealName,
    MealType? mealType,
    String? description,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatsG,
    String? recipeInstructions,
  }) = _MealTemplateResponse;

  factory MealTemplateResponse.fromJson(Map<String, dynamic> json) =>
      _$MealTemplateResponseFromJson(json);
}
