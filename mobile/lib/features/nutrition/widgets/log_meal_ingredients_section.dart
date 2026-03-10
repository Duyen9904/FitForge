import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import 'log_meal_name_section.dart';
import 'meal_plan_checkbox.dart';

/// Common ingredients the user can quickly select.
const commonIngredients = [
  'Wheat Bread',
  'Egg',
  'Tomato',
  'Broccoli',
  'Cheese',
  'Corn',
  'Carrot',
  'Sweet Potato',
  'Lettuce',
  'Cabbage',
  'Chicken',
  'Rice',
];

/// Ingredients checkbox grid section.
class LogMealIngredientsSection extends StatelessWidget {
  final Set<String> selectedIngredients;
  final ValueChanged<String> onToggle;

  const LogMealIngredientsSection({
    super.key,
    required this.selectedIngredients,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LogMealCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '${selectedIngredients.length} Selected',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFF8C00),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Wrap(
            spacing: 0,
            runSpacing: 0,
            children: commonIngredients.map((ingredient) {
              final isSelected = selectedIngredients.contains(ingredient);
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.38,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onToggle(ingredient),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MealPlanCheckbox(checked: isSelected),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            ingredient,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFF1A1A2E)
                                  : AppColors.grey500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
