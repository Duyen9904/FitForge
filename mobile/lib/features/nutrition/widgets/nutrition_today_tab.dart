import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/routes.dart';
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

    // Generate Mon–Sun week containing the selected date
    final sel = data.selectedDate;
    final weekStart = sel.subtract(Duration(days: sel.weekday - 1));
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

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
            onWeekChanged: (delta) {
              final newDate = data.selectedDate.add(Duration(days: 7 * delta));
              ref
                  .read(nutritionTabViewModelProvider.notifier)
                  .selectTodayDate(newDate);
            },
          ),
          const SizedBox(height: AppDimensions.spacing20),

          // ── No-plan banner ──
          if (data.caloriesTarget == 0)
            GestureDetector(
              onTap: () => context.push(Routes.nutritionPlanDetail),
              child: Container(
                margin:
                    const EdgeInsets.only(bottom: AppDimensions.spacing16),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing16,
                  vertical: AppDimensions.spacing12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withAlpha(80),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 20, color: AppColors.warning),
                    const SizedBox(width: AppDimensions.spacing8),
                    Expanded(
                      child: Text(
                        'No active plan — Tap to generate one',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 20, color: AppColors.warning),
                  ],
                ),
              ),
            ),

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

          // ── Planned Meals from active plan's day ──
          if (data.plannedDay != null &&
              data.plannedDay!.meals.isNotEmpty) ...[
            Text(
              "Today's Plan${data.plannedDay!.dayName != null ? ' — ${data.plannedDay!.dayName}' : ''}",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.grey900,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            ...data.plannedDay!.meals.map(
              (dayMeal) {
                final template = dayMeal.mealTemplate;
                final isCompleted = dayMeal.completedAt != null;

                return GestureDetector(
                  onTap: template != null
                      ? () => context.push(
                            Routes.templateMealDetail,
                            extra: template,
                          )
                      : null,
                  child: Container(
                    margin: const EdgeInsets.only(
                        bottom: AppDimensions.spacing8),
                    padding:
                        const EdgeInsets.all(AppDimensions.spacing12),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withAlpha(12)
                          : AppColors.primary.withAlpha(12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.success.withAlpha(40)
                            : AppColors.primary.withAlpha(40),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.success.withAlpha(25)
                                : AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _mealTypeIcon(dayMeal.mealType.name),
                            size: 20,
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                template?.mealName ?? dayMeal.mealType.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isCompleted
                                      ? AppColors.grey400
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${dayMeal.calories ?? template?.calories ?? 0} kcal · P ${(dayMeal.proteinG ?? template?.proteinG)?.toStringAsFixed(0) ?? '-'}g · C ${(dayMeal.carbsG ?? template?.carbsG)?.toStringAsFixed(0) ?? '-'}g · F ${(dayMeal.fatsG ?? template?.fatsG)?.toStringAsFixed(0) ?? '-'}g',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ── Complete button or completed checkmark ──
                        if (isCompleted)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            ),
                          )
                        else
                          IconButton(
                            onPressed: () async {
                              final success = await ref
                                  .read(nutritionTabViewModelProvider
                                      .notifier)
                                  .completeDayMeal(
                                      dayMeal.dayMealId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(success
                                        ? '${template?.mealName ?? dayMeal.mealType.name} completed!'
                                        : 'Failed to complete meal'),
                                    duration:
                                        const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              Icons.check_circle_outline,
                              color: AppColors.primary,
                            ),
                            tooltip: 'Complete this meal',
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.spacing16),
          ],

          // ── Recently logged header + Log Meal button ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently logged',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.push(Routes.logMeal),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Log Meal'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                ),
              ),
            ],
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

          const SizedBox(height: AppDimensions.spacing16),
        ],
      ),
    );
  }
}

/// Horizontal day selector strip (Mon..Sun) with week navigation arrows.
class _DayStrip extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<int> onWeekChanged;

  const _DayStrip({
    required this.days,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Week label (e.g. "Mar 3 – 9, 2026")
    final weekStart = days.first;
    final weekEnd = days.last;
    final sameMonth = weekStart.month == weekEnd.month;
    final weekLabel = sameMonth
        ? '${DateFormat('MMM d').format(weekStart)} – ${weekEnd.day}, ${weekEnd.year}'
        : '${DateFormat('MMM d').format(weekStart)} – ${DateFormat('MMM d').format(weekEnd)}, ${weekEnd.year}';

    return Column(
      children: [
        // ── Week header with arrows ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => onWeekChanged(-1),
              icon: const Icon(Icons.chevron_left_rounded, size: 24),
              color: AppColors.grey600,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            Text(
              weekLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
              ),
            ),
            IconButton(
              onPressed: () => onWeekChanged(1),
              icon: const Icon(Icons.chevron_right_rounded, size: 24),
              color: AppColors.grey600,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ── Day pills ──
        SizedBox(
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
        ),
      ],
    );
  }
}

IconData _mealTypeIcon(String mealType) {
  switch (mealType.toUpperCase()) {
    case 'BREAKFAST':
      return Icons.wb_sunny_outlined;
    case 'LUNCH':
      return Icons.restaurant_outlined;
    case 'DINNER':
      return Icons.nightlight_outlined;
    case 'SNACK':
      return Icons.cookie_outlined;
    default:
      return Icons.restaurant;
  }
}
