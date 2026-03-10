import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/enums/enums.dart';
import '../models/nutrition_requests.dart';
import '../repositories/nutrition_repository.dart';
import '../viewmodels/nutrition_tab_viewmodel.dart';
import 'log_meal_state.dart';

final logMealViewModelProvider =
    StateNotifierProvider.autoDispose<LogMealViewModel, LogMealState>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return LogMealViewModel(repository: repository, ref: ref);
});

class LogMealViewModel extends StateNotifier<LogMealState> {
  final NutritionRepository _repository;
  final Ref _ref;

  LogMealViewModel({
    required NutritionRepository repository,
    required Ref ref,
  })  : _repository = repository,
        _ref = ref,
        super(const LogMealState());

  void setFoodName(String value) {
    state = state.copyWith(foodName: value);
  }

  void setMealType(MealType type) {
    state = state.copyWith(mealType: type);
  }

  void toggleIngredient(String ingredient) {
    final updated = Set<String>.from(state.selectedIngredients);
    if (updated.contains(ingredient)) {
      updated.remove(ingredient);
    } else {
      updated.add(ingredient);
    }
    state = state.copyWith(selectedIngredients: updated);
  }

  void setCalories(double value) {
    state = state.copyWith(calories: value);
  }

  void setProtein(double value) {
    state = state.copyWith(proteinG: value);
  }

  void setCarbs(double value) {
    state = state.copyWith(carbsG: value);
  }

  void setFats(double value) {
    state = state.copyWith(fatsG: value);
  }

  void setCheatMeal(bool value) {
    state = state.copyWith(isCheatMeal: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }

  bool get canSubmit => state.foodName.trim().isNotEmpty && !state.isSubmitting;

  Future<void> submit() async {
    if (!canSubmit) return;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    // Build food name including selected ingredients
    final foodName = state.foodName.trim();
    final fullFoodName = state.selectedIngredients.isEmpty
        ? foodName
        : '$foodName (${state.selectedIngredients.join(', ')})';

    final dto = LogMealRequestDto(
      mealType: state.mealType,
      foodName: fullFoodName,
      calories: state.calories.round(),
      proteinG: state.proteinG,
      carbsG: state.carbsG,
      fatsG: state.fatsG,
      isCheatMeal: state.isCheatMeal,
      logDate: DateTime.now().toUtc(),
      mealTime: DateTime.now().toUtc(),
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
    );

    try {
      await _repository.logMeal(dto);

      // Refresh nutrition tab data
      _ref.read(nutritionTabViewModelProvider.notifier).loadAll();

      state = state.copyWith(isSubmitting: false, isSubmitted: true);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to log meal',
        name: 'LogMealViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
    }
  }
}
