import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nutrition_models.dart';
import '../models/nutrition_requests.dart';
import '../repositories/nutrition_repository.dart';
import 'nutrition_cheat_meals_state.dart';

final nutritionCheatMealsViewModelProvider = StateNotifierProvider<
    NutritionCheatMealsViewModel, NutritionCheatMealsState>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return NutritionCheatMealsViewModel(repository: repository);
});

class NutritionCheatMealsViewModel
    extends StateNotifier<NutritionCheatMealsState> {
  final NutritionRepository _repository;

  NutritionCheatMealsViewModel({required NutritionRepository repository})
      : _repository = repository,
        super(const NutritionCheatMealsState.initial());

  Future<void> loadCheatMeals() async {
    state = const NutritionCheatMealsState.loading();
    try {
      final cheatMeals = await _repository.getUncompensatedCheatMeals();
      state = NutritionCheatMealsState.loaded(
        cheatMeals: cheatMeals,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load cheat meals',
        name: 'NutritionCheatMealsViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionCheatMealsState.error(e.toString());
    }
  }

  Future<void> loadCompensationOptions(int cheatMealLogId) async {
    final currentState = state;
    if (currentState is! NutritionCheatMealsLoaded) return;

    try {
      final options = await _repository.getCompensationOptions(cheatMealLogId);
      state = currentState.copyWith(compensationOptions: options);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load compensation options',
        name: 'NutritionCheatMealsViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionCheatMealsState.error(e.toString());
    }
  }

  Future<void> selectCompensation(
    int cheatMealLogId,
    SelectCompensationRequestDto dto,
  ) async {
    final currentState = state;
    if (currentState is! NutritionCheatMealsLoaded) return;

    try {
      await _repository.selectCompensation(cheatMealLogId, dto);
      // Reload cheat meals to reflect the change
      await loadCheatMeals();
    } catch (e, stackTrace) {
      developer.log(
        'Failed to select compensation',
        name: 'NutritionCheatMealsViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionCheatMealsState.error(e.toString());
    }
  }
}

