import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/enums/enums.dart';

part 'log_meal_state.freezed.dart';

@freezed
class LogMealState with _$LogMealState {
  const factory LogMealState({
    @Default('') String foodName,
    @Default(MealType.lunch) MealType mealType,
    @Default(<String>{}) Set<String> selectedIngredients,
    @Default(300) double calories,
    @Default(25) double proteinG,
    @Default(40) double carbsG,
    @Default(15) double fatsG,
    @Default(false) bool isCheatMeal,
    @Default('') String notes,
    @Default(false) bool isSubmitting,
    @Default(false) bool isSubmitted,
    String? errorMessage,
  }) = _LogMealState;
}
