import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_response.dart';
import '../models/nutrition_models.dart';
import '../services/nutrition_service.dart';
import '../viewmodels/nutrition_tab_state.dart';

final nutritionTabRepositoryProvider =
    Provider<NutritionTabRepository>((ref) {
  final service = ref.watch(nutritionServiceProvider);
  return NutritionTabRepository(service: service);
});

/// Repository for the new nutrition tab screens.
/// Uses real API for supported features, hardcoded values for steps/water.
class NutritionTabRepository {
  final NutritionService _service;

  NutritionTabRepository({required NutritionService service})
      : _service = service;

  /// Unwrap API response or throw
  T _unwrap<T>(ApiResponse<T> response) {
    if (!response.success) {
      throw Exception(response.error?.message ?? response.message ?? 'Request failed');
    }
    return response.data as T;
  }

  /// Get today tab data from real API
  Future<NutritionTodayData> getTodayData(DateTime date) async {
    // Fetch daily summary (calories + macros + targets)
    final summaryResponse = await _service.getDailySummary(date);
    final summary = _unwrap(summaryResponse);

    // Fetch daily meals
    final mealsResponse = await _service.getDailyMeals(date);
    final meals = _unwrap(mealsResponse);

    // Fetch active plan's specific day (based on weekday: Mon=1, Sun=7)
    NutritionDay? plannedDay;
    try {
      final planResponse = await _service.getActivePlan();
      final plan = _unwrap(planResponse);
      final dayNumber = date.weekday; // 1=Mon, 7=Sun
      final dayResponse = await _service.getPlanDay(
        plan.nutritionPlanId,
        dayNumber,
      );
      plannedDay = _unwrap(dayResponse);
    } catch (_) {
      // No active plan or no day data — leave null
    }

    return NutritionTodayData(
      caloriesConsumed: summary.totalCalories,
      caloriesTarget: summary.targetCalories,
      proteinConsumed: summary.totalProteinG,
      proteinTarget: summary.targetProteinG,
      carbsConsumed: summary.totalCarbsG,
      carbsTarget: summary.targetCarbsG,
      fatConsumed: summary.totalFatsG,
      fatTarget: summary.targetFatsG,
      selectedDate: date,
      recentMeals: meals,
      plannedDay: plannedDay,
    );
  }

  /// Get history tab data from real API + hardcoded steps/water
  Future<NutritionHistoryData> getHistoryData(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Fetch weekly totals from API
    final weeklyResponse = await _service.getWeeklyTotals(weekStart);
    final weeklySummaries = _unwrap(weeklyResponse);

    // Fetch meals for each day in the week
    final weekDays = <NutritionHistoryDay>[];
    for (final summary in weeklySummaries) {
      final mealsResponse = await _service.getDailyMeals(summary.date);
      final meals = _unwrap(mealsResponse);

      weekDays.add(NutritionHistoryDay(
        date: summary.date,
        totalCalories: summary.totalCalories,
        meals: meals,
      ));
    }

    // Use current date or closest date in the week as selected
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = weekDays.any((d) =>
            d.date.year == today.year &&
            d.date.month == today.month &&
            d.date.day == today.day)
        ? today
        : weekStart;

    final selectedDayMeals = weekDays
        .where((d) =>
            d.date.year == selectedDate.year &&
            d.date.month == selectedDate.month &&
            d.date.day == selectedDate.day)
        .expand((d) => d.meals)
        .toList();

    return NutritionHistoryData(
      weekStartDate: weekStart,
      weekDays: weekDays,
      selectedDate: selectedDate,
      selectedDayMeals: selectedDayMeals,
    );
  }

  /// Complete a day meal (one-tap from planned meal card)
  Future<DayMeal> completeDayMeal(int dayMealId, {String? proofPhotoUrl}) async {
    final response = await _service.completeDayMeal(
      dayMealId,
      proofPhotoUrl: proofPhotoUrl,
    );
    return _unwrap(response);
  }
}
