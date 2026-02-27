import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nutrition_models.dart';
import '../repositories/nutrition_repository.dart';
import 'nutrition_dashboard_state.dart';

final nutritionDashboardViewModelProvider = StateNotifierProvider<
    NutritionDashboardViewModel, NutritionDashboardState>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return NutritionDashboardViewModel(repository: repository);
});

class NutritionDashboardViewModel
    extends StateNotifier<NutritionDashboardState> {
  final NutritionRepository _repository;

  NutritionDashboardViewModel({required NutritionRepository repository})
      : _repository = repository,
        super(const NutritionDashboardState.initial());

  Future<void> loadDashboard() async {
    state = const NutritionDashboardState.loading();
    try {
      final dashboard = await _repository.getDashboard();
      state = NutritionDashboardState.loaded(dashboard: dashboard);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load nutrition dashboard',
        name: 'NutritionDashboardViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionDashboardState.error(e.toString());
    }
  }

  Future<void> loadDayDetails(DateTime date) async {
    final currentState = state;
    if (currentState is! NutritionDashboardLoaded) return;

    try {
      final summary = await _repository.getDailySummary(date);
      final meals = await _repository.getDailyMeals(date);
      state = currentState.copyWith(
        selectedDaySummary: summary,
        selectedDayMeals: meals,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load day details',
        name: 'NutritionDashboardViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionDashboardState.error(e.toString());
    }
  }
}

