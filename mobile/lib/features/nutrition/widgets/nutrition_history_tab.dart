import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../shared/enums/enums.dart';
import '../viewmodels/nutrition_tab_state.dart';
import '../viewmodels/nutrition_tab_viewmodel.dart';
import 'calendar_week_strip.dart';
import 'meal_group_section.dart';

/// History tab content — calendar and meal groups.
class NutritionHistoryTab extends ConsumerWidget {
  const NutritionHistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionTabViewModelProvider);

    return state.maybeWhen(
      loaded: (_, historyData) =>
          _buildContent(context, ref, historyData),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (msg) => Center(
        child: Text(
          msg,
          style: TextStyle(color: AppColors.error),
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    NutritionHistoryData data,
  ) {
    final viewModel = ref.read(nutritionTabViewModelProvider.notifier);

    // Group meals by type for the selected day
    final mealsByType = <MealType, List<dynamic>>{};
    for (final type in MealType.values) {
      final meals = data.selectedDayMeals
          .where((m) => m.mealType == type)
          .toList();
      mealsByType[type] = meals;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Calendar week strip ──
          CalendarWeekStrip(
            weekStartDate: data.weekStartDate,
            selectedDate: data.selectedDate,
            onDateSelected: (date) => viewModel.selectHistoryDate(date),
            onPreviousWeek: () => viewModel.changeHistoryWeek(-1),
            onNextWeek: () => viewModel.changeHistoryWeek(1),
          ),
          const SizedBox(height: AppDimensions.spacing20),

          // ── Meal group sections ──
          ...MealType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
              child: MealGroupSection(
                mealType: type,
                meals: (mealsByType[type] ?? []).cast(),
                onAddMeal: () {
                  // TODO: wire to add meal for this type
                },
              ),
            );
          }),

          // Extra bottom spacing
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
