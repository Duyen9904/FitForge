import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nutrition_models.dart';
import '../repositories/nutrition_repository.dart';

/// Provider for MealTemplatesViewModel
final mealTemplatesViewModelProvider =
    StateNotifierProvider<MealTemplatesViewModel, AsyncValue<List<MealTemplate>>>(
        (ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return MealTemplatesViewModel(repository: repository);
});

/// ViewModel for the meal templates list screen
class MealTemplatesViewModel
    extends StateNotifier<AsyncValue<List<MealTemplate>>> {
  final NutritionRepository _repository;

  MealTemplatesViewModel({required NutritionRepository repository})
      : _repository = repository,
        super(const AsyncValue.loading());

  /// Load all meal templates from API
  Future<void> loadTemplates() async {
    state = const AsyncValue.loading();
    try {
      final templates = await _repository.getMealTemplates();
      state = AsyncValue.data(templates);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load meal templates',
        name: 'MealTemplatesViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
