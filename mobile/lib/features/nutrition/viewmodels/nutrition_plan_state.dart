import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/nutrition_models.dart';

part 'nutrition_plan_state.freezed.dart';

@freezed
class NutritionPlanState with _$NutritionPlanState {
  const factory NutritionPlanState.initial() = NutritionPlanInitial;

  const factory NutritionPlanState.loading() = NutritionPlanLoading;

  const factory NutritionPlanState.loaded({
    required NutritionPlan plan,
  }) = NutritionPlanLoaded;

  const factory NutritionPlanState.generating() = NutritionPlanGenerating;

  const factory NutritionPlanState.updating({
    required NutritionPlan currentPlan,
  }) = NutritionPlanUpdating;

  const factory NutritionPlanState.error(String message) = NutritionPlanError;
}

