import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../models/nutrition_models.dart';

class NutritionMealList extends StatelessWidget {
  final List<NutritionLog> meals;
  final VoidCallback onAddMeal;

  const NutritionMealList({
    super.key,
    required this.meals,
    required this.onAddMeal,
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
              'Today\'s Meals',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: onAddMeal,
              child: const Text('Add meal'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing8),
        if (meals.isEmpty)
          Text(
            'No meals logged yet.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meals.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.spacing8),
            itemBuilder: (context, index) {
              final meal = meals[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(meal.foodName),
                subtitle: Text(
                  '${meal.mealType.displayName} • ${meal.calories} kcal',
                ),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          ),
      ],
    );
  }
}

