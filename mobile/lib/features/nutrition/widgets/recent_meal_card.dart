import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/nutrition_models.dart';

/// Individual meal log card with food icon, name, calories, and macro pills.
class RecentMealCard extends StatelessWidget {
  final PlanMeal meal;
  final VoidCallback? onTap;

  const RecentMealCard({
    super.key,
    required this.meal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Food icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _mealColor(meal.mealType).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  meal.mealType.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacing12),
            // Name + calories
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.foodName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          size: 14, color: Colors.orange.shade400),
                      const SizedBox(width: 2),
                      Text(
                        '${meal.calories} calories',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Macro pills column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _MacroPill(
                  label: '${(meal.proteinG ?? 0).toStringAsFixed(0)}g',
                  color: const Color(0xFFFF6B6B),
                ),
                const SizedBox(height: 3),
                _MacroPill(
                  label: '${(meal.carbsG ?? 0).toStringAsFixed(0)}g',
                  color: const Color(0xFFFFA726),
                ),
                const SizedBox(height: 3),
                _MacroPill(
                  label: '${(meal.fatsG ?? 0).toStringAsFixed(0)}g',
                  color: const Color(0xFF42A5F5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _mealColor(dynamic mealType) {
    final name = mealType.toString().split('.').last;
    switch (name) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.indigo;
      default:
        return Colors.purple;
    }
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MacroPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }
}
