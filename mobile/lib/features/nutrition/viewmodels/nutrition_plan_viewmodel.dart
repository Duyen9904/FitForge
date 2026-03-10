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
        // Auto-fetch all days for plan review
        await _fetchPlanDays(plan.nutritionPlanId);
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

  Future<void> generateRecommendedPlan() async {
    state = const NutritionPlanState.generating();
    try {
      final plan = await _repository.generateRecommendedPlan();
      state = NutritionPlanState.loaded(plan: plan);
      // Auto-fetch all days for plan review
      await _fetchPlanDays(plan.nutritionPlanId);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to generate recommended plan',
        name: 'NutritionPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionPlanState.error(e.toString());
    }
  }

  Future<void> adjustPlanBasedOnBehavior(int planId) async {
    final currentState = state;
    if (currentState is! NutritionPlanLoaded) return;

    state = NutritionPlanState.updating(currentPlan: currentState.plan);
    try {
      final plan = await _repository.adjustPlanBasedOnBehavior(planId);
      state = NutritionPlanState.loaded(plan: plan);
      await _fetchPlanDays(plan.nutritionPlanId);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to adjust plan based on behavior',
        name: 'NutritionPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionPlanState.error(e.toString());
    }
  }

  Future<void> generateAiPlan() async {
    state = const NutritionPlanState.generating();
    try {
      final plan = await _repository.generateAiPlan();
      state = NutritionPlanState.loaded(plan: plan);
      // Auto-fetch all days for plan review
      await _fetchPlanDays(plan.nutritionPlanId);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to generate AI plan',
        name: 'NutritionPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionPlanState.error(e.toString());
    }
  }

  Future<void> adjustPlanWithAi(int planId) async {
    final currentState = state;
    if (currentState is! NutritionPlanLoaded) return;

    state = NutritionPlanState.updating(currentPlan: currentState.plan);
    try {
      final plan = await _repository.adjustPlanWithAi(planId);
      state = NutritionPlanState.loaded(plan: plan);
      await _fetchPlanDays(plan.nutritionPlanId);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to adjust plan with AI',
        name: 'NutritionPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionPlanState.error(e.toString());
    }
  }

  /// Fetch all days in the plan and update the loaded state.
  Future<void> _fetchPlanDays(int planId) async {
    final currentState = state;
    if (currentState is! NutritionPlanLoaded) return;

    try {
      final days = await _repository.getPlanDays(planId);
      state = NutritionPlanState.loaded(
        plan: currentState.plan,
        days: days,
      );
    } catch (e) {
      developer.log(
        'Failed to fetch plan days (non-fatal)',
        name: 'NutritionPlanViewModel',
        error: e,
      );
      // Non-fatal — keep the plan loaded without days
    }
  }

  Future<void> deletePlan(int planId) async {
    final currentState = state;
    if (currentState is! NutritionPlanLoaded) return;

    state = NutritionPlanState.updating(currentPlan: currentState.plan);
    try {
      await _repository.deletePlan(planId);
      state = const NutritionPlanState.initial();
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete nutrition plan',
        name: 'NutritionPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionPlanState.error(e.toString());
    }
  }

  Future<void> deactivatePlan(int planId) async {
    final currentState = state;
    if (currentState is! NutritionPlanLoaded) return;

    state = NutritionPlanState.updating(currentPlan: currentState.plan);
    try {
      final plan = await _repository.deactivatePlan(planId);
      state = NutritionPlanState.loaded(plan: plan);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to deactivate nutrition plan',
        name: 'NutritionPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionPlanState.error(e.toString());
    }
  }

  Future<void> loadPlanDays(int planId) async {
    final currentState = state;
    if (currentState is! NutritionPlanLoaded) return;

    try {
      final days = await _repository.getPlanDays(planId);
      state = NutritionPlanState.loaded(
        plan: currentState.plan,
        days: days,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load plan days',
        name: 'NutritionPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      // Non-fatal — keep the plan loaded without days
    }
  }

  void reset() {
    state = const NutritionPlanState.initial();
  }
}
