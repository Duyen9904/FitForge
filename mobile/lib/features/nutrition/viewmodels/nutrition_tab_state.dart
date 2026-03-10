import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/nutrition_models.dart';

part 'nutrition_tab_state.freezed.dart';

/// Data class for the "Today" tab
@freezed
class NutritionTodayData with _$NutritionTodayData {
  const factory NutritionTodayData({
    required int caloriesConsumed,
    required int caloriesTarget,
    required double proteinConsumed,
    required double proteinTarget,
    required double carbsConsumed,
    required double carbsTarget,
    required double fatConsumed,
    required double fatTarget,
    @Default(<PlanMeal>[]) List<PlanMeal> recentMeals,
    NutritionDay? plannedDay,
    required DateTime selectedDate,
  }) = _NutritionTodayData;
}

/// A single day entry in the history calendar
@freezed
class NutritionHistoryDay with _$NutritionHistoryDay {
  const factory NutritionHistoryDay({
    required DateTime date,
    @Default(0) int totalCalories,
    @Default(<PlanMeal>[]) List<PlanMeal> meals,
  }) = _NutritionHistoryDay;
}

/// Data class for the "History" tab
@freezed
class NutritionHistoryData with _$NutritionHistoryData {
  const factory NutritionHistoryData({
    required DateTime weekStartDate,
    @Default(<NutritionHistoryDay>[]) List<NutritionHistoryDay> weekDays,
    required DateTime selectedDate,
    @Default(<PlanMeal>[]) List<PlanMeal> selectedDayMeals,
  }) = _NutritionHistoryData;
}

/// Combined state for both nutrition tabs
@freezed
class NutritionTabState with _$NutritionTabState {
  const factory NutritionTabState.initial() = NutritionTabInitial;
  const factory NutritionTabState.loading() = NutritionTabLoading;
  const factory NutritionTabState.loaded({
    required NutritionTodayData todayData,
    required NutritionHistoryData historyData,
  }) = NutritionTabLoaded;
  const factory NutritionTabState.error(String message) = NutritionTabError;
}
