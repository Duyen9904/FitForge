import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/recommendation_models.dart';

part 'nutrition_plan_state.freezed.dart';

/// State for nutrition plan recommendation
@freezed
class NutritionPlanState with _$NutritionPlanState {
  /// Initial state - no plan loaded
  const factory NutritionPlanState.initial() = NutritionPlanInitial;

  /// Loading plan from server
  const factory NutritionPlanState.loading() = NutritionPlanLoading;

  /// Plan loaded successfully
  const factory NutritionPlanState.loaded({
    required NutritionPlanResponse plan,
    @Default([]) List<MealTemplateResponse> currentDayMeals,
    @Default(1) int currentDay,
  }) = NutritionPlanLoaded;

  /// Generating new plan
  const factory NutritionPlanState.generating() = NutritionPlanGenerating;

  /// Adjusting existing plan
  const factory NutritionPlanState.adjusting({
    required NutritionPlanResponse currentPlan,
  }) = NutritionPlanAdjusting;

  /// Loading meals for specific day
  const factory NutritionPlanState.loadingMeals({
    required NutritionPlanResponse plan,
    required int dayNumber,
  }) = NutritionPlanLoadingMeals;

  /// Error state
  const factory NutritionPlanState.error(String message) = NutritionPlanError;
}
