import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nutrition_models.dart';
import '../models/nutrition_requests.dart';
import '../repositories/nutrition_repository.dart';
import 'nutrition_plan_state.dart';

final nutritionPlanViewModelProvider =
    StateNotifierProvider<NutritionPlanViewModel, NutritionPlanState>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return NutritionPlanViewModel(repository: repository);
});

class NutritionPlanViewModel extends StateNotifier<NutritionPlanState> {
  final NutritionRepository _repository;

  NutritionPlanViewModel({required NutritionRepository repository})
      : _repository = repository,
        super(const NutritionPlanState.initial());

  Future<void> loadActivePlan() async {
    state = const NutritionPlanState.loading();
    try {
      final plan = await _repository.getActivePlan();
      if (plan == null) {
        state = const NutritionPlanState.initial();
      } else {
        state = NutritionPlanState.loaded(plan: plan);
      }
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load active nutrition plan',
        name: 'NutritionPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionPlanState.error(e.toString());
    }
  }

  Future<void> createPlan(CreateNutritionPlanRequestDto dto) async {
    state = const NutritionPlanState.generating();
    try {
      final plan = await _repository.createNutritionPlan(dto);
      state = NutritionPlanState.loaded(plan: plan);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to create nutrition plan',
        name: 'NutritionPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionPlanState.error(e.toString());
    }
  }

  Future<void> updatePlan(
    int planId,
    UpdateNutritionPlanRequestDto dto,
  ) async {
    final currentState = state;
    if (currentState is! NutritionPlanLoaded) return;

    state = NutritionPlanState.updating(currentPlan: currentState.plan);
    try {
      final plan = await _repository.updateNutritionPlan(planId, dto);
      state = NutritionPlanState.loaded(plan: plan);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update nutrition plan',
        name: 'NutritionPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionPlanState.error(e.toString());
    }
  }

  Future<void> loadActivePlanIfExists() async {
    final planId = await _repository.getActiveNutritionPlanId();
    if (planId != null) {
      await loadActivePlan();
    }
  }

  void reset() {
    state = const NutritionPlanState.initial();
  }
}

