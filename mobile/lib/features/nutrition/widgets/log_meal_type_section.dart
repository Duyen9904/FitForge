import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../shared/enums/meal_type.dart';
import 'log_meal_name_section.dart';
import 'meal_plan_checkbox.dart';

/// Meal-type checkbox grid section.
class LogMealTypeSection extends StatelessWidget {
  final MealType selectedType;
  final ValueChanged<MealType> onChanged;

  const LogMealTypeSection({
    super.key,
    required this.selectedType,
    required this.onChanged,
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
                'Meal Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '1 Selected',
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
            children: MealType.values.map((type) {
              final isSelected = selectedType == type;
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.38,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onChanged(type),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MealPlanCheckbox(checked: isSelected),
                        const SizedBox(width: 8),
                        Text(
                          type.displayName,
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
