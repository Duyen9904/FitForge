import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/nutrition_models.dart';

part 'nutrition_cheat_meals_state.freezed.dart';

@freezed
class NutritionCheatMealsState with _$NutritionCheatMealsState {
  const factory NutritionCheatMealsState.initial() =
      NutritionCheatMealsInitial;

  const factory NutritionCheatMealsState.loading() =
      NutritionCheatMealsLoading;

  const factory NutritionCheatMealsState.loaded({
    @Default(<CheatMealLog>[]) List<CheatMealLog> cheatMeals,
    @Default(<CompensationAction>[])
    List<CompensationAction> compensationOptions,
  }) = NutritionCheatMealsLoaded;

  const factory NutritionCheatMealsState.error(String message) =
      NutritionCheatMealsError;
}

