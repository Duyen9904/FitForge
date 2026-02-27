import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/recommendation_repository.dart';
import 'nutrition_plan_state.dart';

/// Provider for NutritionPlanViewModel
final nutritionPlanViewModelProvider =
    StateNotifierProvider<NutritionPlanViewModel, NutritionPlanState>((ref) {
  final repository = ref.watch(recommendationRepositoryProvider);
  return NutritionPlanViewModel(repository: repository);
});

/// ViewModel for managing nutrition plan recommendation state
class NutritionPlanViewModel extends StateNotifier<NutritionPlanState> {
  final RecommendationRepository _repository;

  NutritionPlanViewModel({required RecommendationRepository repository})
      : _repository = repository,
        super(const NutritionPlanState.initial());

  /// Generate initial nutrition plan
  Future<void> generatePlan() async {
    state = const NutritionPlanState.generating();

    try {
      final plan = await _repository.generateNutritionPlan();
      state = NutritionPlanState.loaded(plan: plan);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to generate nutrition plan',
        name: 'NutritionPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionPlanState.error(e.toString());
    }
  }

  /// Adjust nutrition plan based on behavior
  Future<void> adjustPlan(int planId) async {
    final currentState = state;
    if (currentState is! NutritionPlanLoaded) return;

    state = NutritionPlanState.adjusting(currentPlan: currentState.plan);

    try {
      final adjustedPlan = await _repository.adjustNutritionPlan(planId);
      state = NutritionPlanState.loaded(plan: adjustedPlan);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to regenerate nutrition day',
        name: 'NutritionPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      // Restore previous state on error
      state = NutritionPlanState.loaded(plan: currentState.plan);
      rethrow;
    }
  }

  /// Load meals for specific day
  Future<void> loadMealsForDay(int planId, int dayNumber) async {
    final currentState = state;
    if (currentState is! NutritionPlanLoaded) return;

    state = NutritionPlanState.loadingMeals(
      plan: currentState.plan,
      dayNumber: dayNumber,
    );

    try {
      final meals = await _repository.getMealsForDay(planId, dayNumber);
      state = NutritionPlanState.loaded(
        plan: currentState.plan,
        currentDayMeals: meals,
        currentDay: dayNumber,
      );
    } catch (e) {
      state = NutritionPlanState.loaded(
        plan: currentState.plan,
        currentDay: dayNumber,
      );
      rethrow;
    }
  }

  /// Check if we have an active plan cached
  Future<void> loadActivePlanIfExists() async {
    final planId = await _repository.getActiveNutritionPlanId();
    if (planId != null) {
      // For now, we just know we had a plan but need to refresh from server
      // Could add an endpoint to fetch existing plan by ID
      state = const NutritionPlanState.initial();
    }
  }

  /// Reset to initial state
  void reset() {
    state = const NutritionPlanState.initial();
  }
}
