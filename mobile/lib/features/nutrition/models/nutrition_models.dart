import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/enums/enums.dart';

part 'nutrition_models.freezed.dart';
part 'nutrition_models.g.dart';

@freezed
class NutritionPlan with _$NutritionPlan {
  const factory NutritionPlan({
    required int nutritionPlanId,
    required String planName,
    int? goalId,
    String? goalName,
    required int dailyCalorieTarget,
    String? algorithmVersion,
    int? version,
    String? recommendationReason,
    required double proteinPercentage,
    required double carbsPercentage,
    required double fatsPercentage,
    required double proteinGrams,
    required double carbsGrams,
    required double fatsGrams,
    int? cheatMealsPerWeek,
    bool? autoAdjustEnabled,
    @Default(false) bool isActive,
    @Default(<MealTemplate>[]) List<MealTemplate> mealTemplates,
  }) = _NutritionPlan;

  factory NutritionPlan.fromJson(Map<String, dynamic> json) =>
      _$NutritionPlanFromJson(json);
}

@freezed
class MealTemplate with _$MealTemplate {
  const factory MealTemplate({
    required int mealTemplateId,
    required String mealName,
    required MealType mealType,
    String? description,
    required int calories,
    double? proteinG,
    double? carbsG,
    double? fatsG,
    String? recipeInstructions,
  }) = _MealTemplate;

  factory MealTemplate.fromJson(Map<String, dynamic> json) =>
      _$MealTemplateFromJson(json);
}

@freezed
class NutritionLog with _$NutritionLog {
  const factory NutritionLog({
    required int nutritionId,
    required DateTime logDate,
    required MealType mealType,
    required String foodName,
    required int calories,
    double? proteinG,
    double? carbsG,
    double? fatsG,
    DateTime? mealTime,
    @Default(false) bool isCheatMeal,
    String? notes,
  }) = _NutritionLog;

  factory NutritionLog.fromJson(Map<String, dynamic> json) =>
      _$NutritionLogFromJson(json);
}

@freezed
class DailyNutritionSummary with _$DailyNutritionSummary {
  const factory DailyNutritionSummary({
    required DateTime date,
    @Default(0) int totalCalories,
    @Default(0) double totalProteinG,
    @Default(0) double totalCarbsG,
    @Default(0) double totalFatsG,
    @Default(0) int targetCalories,
    @Default(0) double targetProteinG,
    @Default(0) double targetCarbsG,
    @Default(0) double targetFatsG,
    @Default(0) int remainingCalories,
    @Default(0) double remainingProteinG,
    @Default(0) double remainingCarbsG,
    @Default(0) double remainingFatsG,
    @Default(0) double calorieProgress,
    @Default(0) double proteinProgress,
    @Default(0) double carbsProgress,
    @Default(0) double fatsProgress,
    @Default(0) int cheatMealCount,
  }) = _DailyNutritionSummary;

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> json) =>
      _$DailyNutritionSummaryFromJson(json);
}

@freezed
class WeeklyCheatMealSummary with _$WeeklyCheatMealSummary {
  const factory WeeklyCheatMealSummary({
    required int usedThisWeek,
    required int allowedPerWeek,
    required int remaining,
  }) = _WeeklyCheatMealSummary;

  factory WeeklyCheatMealSummary.fromJson(Map<String, dynamic> json) =>
      _$WeeklyCheatMealSummaryFromJson(json);
}

@freezed
class DailyTrendPoint with _$DailyTrendPoint {
  const factory DailyTrendPoint({
    required DateTime date,
    required int calories,
    required double proteinG,
    required double carbsG,
    required double fatsG,
  }) = _DailyTrendPoint;

  factory DailyTrendPoint.fromJson(Map<String, dynamic> json) =>
      _$DailyTrendPointFromJson(json);
}

@freezed
class NutritionTrendSummary with _$NutritionTrendSummary {
  const factory NutritionTrendSummary({
    @Default(<DailyTrendPoint>[]) List<DailyTrendPoint> last7Days,
    required double averageDailyCalories,
    required double averageDailyProtein,
    required String adherenceStatus,
  }) = _NutritionTrendSummary;

  factory NutritionTrendSummary.fromJson(Map<String, dynamic> json) =>
      _$NutritionTrendSummaryFromJson(json);
}

@freezed
class CheatMealLog with _$CheatMealLog {
  const factory CheatMealLog({
    required int cheatMealLogId,
    required int nutritionLogId,
    required DateTime cheatDate,
    required String mealName,
    required int mealCalories,
    required int excessCalories,
    String? compensationStrategy,
    @Default(false) bool isCompensated,
  }) = _CheatMealLog;

  factory CheatMealLog.fromJson(Map<String, dynamic> json) =>
      _$CheatMealLogFromJson(json);
}

@freezed
class CompensationAction with _$CompensationAction {
  const factory CompensationAction({
    required int compensationId,
    required String triggerType,
    required String status,
    required String statusDisplayName,
    required String actionType,
    required String actionDescription,
    DateTime? scheduledDate,
    DateTime? validUntilDate,
    @Default(false) bool isCompleted,
    int? calorieAdjustment,
    String? details,
    DateTime? createdAt,
    DateTime? completedAt,
    CompensationType? compensationType,
    int? daysRemaining,
    String? progressStatus,
  }) = _CompensationAction;

  factory CompensationAction.fromJson(Map<String, dynamic> json) =>
      _$CompensationActionFromJson(json);
}

@freezed
class NutritionDashboard with _$NutritionDashboard {
  const factory NutritionDashboard({
    required DailyNutritionSummary todaySummary,
    @Default(<NutritionLog>[]) List<NutritionLog> recentMeals,
    WeeklyCheatMealSummary? weeklyCheatMeals,
    @Default(<CompensationAction>[]) List<CompensationAction> activeCompensations,
    NutritionTrendSummary? trends,
  }) = _NutritionDashboard;

  factory NutritionDashboard.fromJson(Map<String, dynamic> json) =>
      _$NutritionDashboardFromJson(json);
}

