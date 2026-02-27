import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../models/nutrition_models.dart';

class NutritionCheatMealsSection extends StatelessWidget {
  final List<CheatMealLog> cheatMeals;
  final VoidCallback onViewAll;

  const NutritionCheatMealsSection({
    super.key,
    required this.cheatMeals,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cheat meals & compensations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing8),
        if (cheatMeals.isEmpty)
          Text(
            'No cheat meals requiring compensation.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else ...[
          Text(
            'Uncompensated cheat meals',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Column(
            children: cheatMeals
                .take(3)
                .map(
                  (meal) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(meal.mealName),
                    subtitle: Text(
                      '${meal.cheatDate.toLocal().toIso8601String().split('T').first} • ${meal.excessCalories} kcal over',
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

