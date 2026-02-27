import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/nutrition_models.dart';

part 'nutrition_dashboard_state.freezed.dart';

@freezed
class NutritionDashboardState with _$NutritionDashboardState {
  const factory NutritionDashboardState.initial() = NutritionDashboardInitial;

  const factory NutritionDashboardState.loading() = NutritionDashboardLoading;

  const factory NutritionDashboardState.loaded({
    required NutritionDashboard dashboard,
    DailyNutritionSummary? selectedDaySummary,
    @Default(<NutritionLog>[]) List<NutritionLog> selectedDayMeals,
  }) = NutritionDashboardLoaded;

  const factory NutritionDashboardState.error(String message) =
      NutritionDashboardError;
}

