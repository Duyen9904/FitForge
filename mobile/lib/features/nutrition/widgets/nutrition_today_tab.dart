import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../viewmodels/nutrition_tab_state.dart';
import '../viewmodels/nutrition_tab_viewmodel.dart';
import 'calorie_ring_card.dart';
import 'macro_summary_bar.dart';
import 'recent_meal_card.dart';

/// Today tab content — calorie ring, macros, recently logged meals.
class NutritionTodayTab extends ConsumerWidget {
  const NutritionTodayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionTabViewModelProvider);

    return state.maybeWhen(
      loaded: (todayData, _) => _buildContent(context, ref, todayData),
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
    NutritionTodayData data,
  ) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Generate day strip from today - 3 to today + 3
    final days = List.generate(7, (i) {
      return DateTime(now.year, now.month, now.day).subtract(
        Duration(days: 3 - i),
      );
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Day selector strip ──
          _DayStrip(
            days: days,
            selectedDate: data.selectedDate,
            onDateSelected: (date) {
              ref
                  .read(nutritionTabViewModelProvider.notifier)
                  .selectTodayDate(date);
            },
          ),
          const SizedBox(height: AppDimensions.spacing20),

          // ── Calorie ring ──
          CalorieRingCard(
            caloriesConsumed: data.caloriesConsumed,
            caloriesTarget: data.caloriesTarget,
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // ── Macro summary ──
          MacroSummaryBar(
            proteinConsumed: data.proteinConsumed,
            proteinTarget: data.proteinTarget,
            carbsConsumed: data.carbsConsumed,
            carbsTarget: data.carbsTarget,
            fatConsumed: data.fatConsumed,
            fatTarget: data.fatTarget,
          ),
          const SizedBox(height: AppDimensions.spacing24),

          // ── Recently logged header ──
          Text(
            'Recently logged',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // ── Meal cards ──
          if (data.recentMeals.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing20),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'No meals logged yet today',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey400,
                  ),
                ),
              ),
            )
          else
            ...data.recentMeals.map(
              (meal) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacing8),
                child: RecentMealCard(meal: meal),
              ),
            ),

          // Extra bottom spacing for FAB clearance
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

/// Horizontal day selector strip (Mon..Sun around today).
class _DayStrip extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DayStrip({
    required this.days,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return SizedBox(
      height: 68,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((date) {
          final isToday = date == today;
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : isToday
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).substring(0, 3),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.grey400,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.grey800,
                    ),
                  ),
                  if (isToday && !isSelected) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Today',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 8,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
