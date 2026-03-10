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
class NutritionDay with _$NutritionDay {
  const factory NutritionDay({
    required int nutritionDayId,
    required int dayNumber,
    String? dayName,
    String? description,
    int? targetCalories,
    @Default(false) bool isRestDay,
    @Default(<DayMeal>[]) List<DayMeal> meals,
  }) = _NutritionDay;

  factory NutritionDay.fromJson(Map<String, dynamic> json) =>
      _$NutritionDayFromJson(json);
}

@freezed
class DayMeal with _$DayMeal {
  const factory DayMeal({
    required int dayMealId,
    required MealType mealType,
    int? orderIndex,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatsG,
    String? notes,
    DateTime? completedAt,
    MealTemplate? mealTemplate,
    String? proofPhotoUrl,
    String? proofPhotoSignedUrl,
  }) = _DayMeal;

  factory DayMeal.fromJson(Map<String, dynamic> json) =>
      _$DayMealFromJson(json);
}

@freezed
class PlanMeal with _$PlanMeal {
  const factory PlanMeal({
    required int planMealId,
    int? nutritionPlanId,
    int? mealTemplateId,
    required DateTime scheduledDate,
    required MealType mealType,
    required PlanMealStatus status,
    required PlanMealSource source,
    required String foodName,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatsG,
    DateTime? mealTime,
    DateTime? completedAt,
    @Default(false) bool isCheatMeal,
    String? notes,
  }) = _PlanMeal;

  factory PlanMeal.fromJson(Map<String, dynamic> json) =>
      _$PlanMealFromJson(json);
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
    required int planMealId,
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
    @Default(<PlanMeal>[]) List<PlanMeal> recentMeals,
    WeeklyCheatMealSummary? weeklyCheatMeals,
    @Default(<CompensationAction>[]) List<CompensationAction> activeCompensations,
    NutritionTrendSummary? trends,
  }) = _NutritionDashboard;

  factory NutritionDashboard.fromJson(Map<String, dynamic> json) =>
      _$NutritionDashboardFromJson(json);
}

