import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/nutrition_tab_repository.dart';
import 'nutrition_tab_state.dart';

final nutritionTabViewModelProvider =
    StateNotifierProvider<NutritionTabViewModel, NutritionTabState>((ref) {
  final repository = ref.watch(nutritionTabRepositoryProvider);
  return NutritionTabViewModel(repository: repository);
});

class NutritionTabViewModel extends StateNotifier<NutritionTabState> {
  final NutritionTabRepository _repository;

  NutritionTabViewModel({required NutritionTabRepository repository})
      : _repository = repository,
        super(const NutritionTabState.initial());

  /// Load both today + history data
  Future<void> loadAll() async {
    state = const NutritionTabState.loading();
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Calculate start of the current week (Monday)
      final weekStart = today.subtract(Duration(days: today.weekday - 1));

      final results = await Future.wait([
        _repository.getTodayData(today),
        _repository.getHistoryData(weekStart),
      ]);

      state = NutritionTabState.loaded(
        todayData: results[0] as NutritionTodayData,
        historyData: results[1] as NutritionHistoryData,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load nutrition tab data',
        name: 'NutritionTabViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = NutritionTabState.error(e.toString());
    }
  }

  /// Select a different day on the Today tab
  Future<void> selectTodayDate(DateTime date) async {
    final current = state;
    if (current is! NutritionTabLoaded) return;

    try {
      final todayData = await _repository.getTodayData(date);
      state = current.copyWith(todayData: todayData);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load day data',
        name: 'NutritionTabViewModel',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Select a different day on the History tab
  Future<void> selectHistoryDate(DateTime date) async {
    final current = state;
    if (current is! NutritionTabLoaded) return;

    final historyData = current.historyData;
    final dayMeals = historyData.weekDays
        .where((d) =>
            d.date.year == date.year &&
            d.date.month == date.month &&
            d.date.day == date.day)
        .expand((d) => d.meals)
        .toList();

    state = current.copyWith(
      historyData: historyData.copyWith(
        selectedDate: date,
        selectedDayMeals: dayMeals,
      ),
    );
  }

  /// Navigate history week forward / backward
  Future<void> changeHistoryWeek(int weekDelta) async {
    final current = state;
    if (current is! NutritionTabLoaded) return;

    try {
      final newWeekStart =
          current.historyData.weekStartDate.add(Duration(days: 7 * weekDelta));
      final historyData = await _repository.getHistoryData(newWeekStart);
      state = current.copyWith(historyData: historyData);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to change history week',
        name: 'NutritionTabViewModel',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Complete a day meal (one-tap from planned meal card)
  Future<bool> completeDayMeal(int dayMealId, {String? proofPhotoUrl}) async {
    try {
      await _repository.completeDayMeal(
        dayMealId,
        proofPhotoUrl: proofPhotoUrl,
      );
      await loadAll();
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to complete day meal',
        name: 'NutritionTabViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
