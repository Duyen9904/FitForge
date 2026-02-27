import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nutrition_models.dart';
import '../models/nutrition_requests.dart';
import '../repositories/nutrition_repository.dart';
import 'nutrition_templates_state.dart';

final nutritionTemplatesViewModelProvider =
    StateNotifierProvider<NutritionTemplatesViewModel, NutritionTemplatesState>(
        (ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return NutritionTemplatesViewModel(repository: repository);
});

class NutritionTemplatesViewModel
    extends StateNotifier<NutritionTemplatesState> {
  final NutritionRepository _repository;

  NutritionTemplatesViewModel({required NutritionRepository repository})
      : _repository = repository,
        super(const NutritionTemplatesState.initial());

  Future<void> loadTemplates() async {
    state = const NutritionTemplatesState.loading();
    try {
      final templates = await _repository.getMealTemplates();
      state = NutritionTemplatesState.loaded(templates: templates);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load templates',
        name: 'NutritionTemplatesViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionTemplatesState.error(e.toString());
    }
  }

  Future<void> createTemplate(CreateMealTemplateRequestDto dto) async {
    final currentState = state;
    if (currentState is! NutritionTemplatesLoaded) return;

    state = currentState.copyWith(isSubmitting: true);
    try {
      final template = await _repository.createMealTemplate(dto);
      final updated = [...currentState.templates, template];
      state = currentState.copyWith(
        templates: updated,
        isSubmitting: false,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to create template',
        name: 'NutritionTemplatesViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionTemplatesState.error(e.toString());
    }
  }

  Future<void> deleteTemplate(int templateId) async {
    final currentState = state;
    if (currentState is! NutritionTemplatesLoaded) return;

    try {
      await _repository.deleteMealTemplate(templateId);
      final updated = currentState.templates
          .where((t) => t.mealTemplateId != templateId)
          .toList();
      state = currentState.copyWith(templates: updated);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete template',
        name: 'NutritionTemplatesViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionTemplatesState.error(e.toString());
    }
  }
}

