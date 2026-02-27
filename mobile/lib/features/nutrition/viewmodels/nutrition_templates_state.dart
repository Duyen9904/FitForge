import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/nutrition_models.dart';

part 'nutrition_templates_state.freezed.dart';

@freezed
class NutritionTemplatesState with _$NutritionTemplatesState {
  const factory NutritionTemplatesState.initial() = NutritionTemplatesInitial;

  const factory NutritionTemplatesState.loading() = NutritionTemplatesLoading;

  const factory NutritionTemplatesState.loaded({
    @Default(<MealTemplate>[]) List<MealTemplate> templates,
    @Default(false) bool isSubmitting,
  }) = NutritionTemplatesLoaded;

  const factory NutritionTemplatesState.error(String message) =
      NutritionTemplatesError;
}

