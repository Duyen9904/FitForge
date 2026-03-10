import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../shared/enums/enums.dart';
import '../models/nutrition_models.dart';

/// Meal type group section (e.g. "Breakfast") with calorie range,
/// meal thumbnails row, and a "+" add button.
class MealGroupSection extends StatelessWidget {
  final MealType mealType;
  final List<PlanMeal> meals;
  final VoidCallback? onAddMeal;

  const MealGroupSection({
    super.key,
    required this.mealType,
    required this.meals,
    this.onAddMeal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calorie range
    String calorieRange = '0 kcal';
    if (meals.isNotEmpty) {
      final calories = meals.map((m) => m.calories).toList()..sort();
      if (calories.length == 1) {
        calorieRange = '${calories.first} kcal';
      } else {
        calorieRange = '${calories.first} - ${calories.last} kcal';
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Meal type icon + name
              Expanded(
                child: Row(
                  children: [
                    Text(
                      mealType.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bookmark icon (decorative)
                    Icon(
                      Icons.bookmark_outline,
                      size: 18,
                      color: AppColors.grey400,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onAddMeal,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 18,
                    color: AppColors.grey700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Calorie range
          Row(
            children: [
              Icon(Icons.local_fire_department,
                  size: 14, color: Colors.orange.shade400),
              const SizedBox(width: 4),
              Text(
                calorieRange,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          // Meal thumbnail row
          if (meals.isEmpty)
            Text(
              'No meals logged',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.grey400,
              ),
            )
          else
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: meals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return _MealThumbnail(meal: meals[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MealThumbnail extends StatelessWidget {
  final PlanMeal meal;

  const _MealThumbnail({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _thumbnailColor(meal.mealType),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          meal.mealType.icon,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }

  Color _thumbnailColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Colors.orange.withOpacity(0.12);
      case MealType.lunch:
        return Colors.green.withOpacity(0.12);
      case MealType.dinner:
        return Colors.indigo.withOpacity(0.12);
      case MealType.snack:
        return Colors.purple.withOpacity(0.12);
    }
  }
}
