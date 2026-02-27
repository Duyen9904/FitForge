import 'package:flutter/material.dart';
import '../../../shared/enums/enums.dart';
import '../models/recommendation_models.dart';

/// Card widget displaying meal template information
class MealTemplateCard extends StatelessWidget {
  final MealTemplateResponse meal;
  final VoidCallback? onTap;

  const MealTemplateCard({
    super.key,
    required this.meal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with meal type badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Meal type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMealTypeColor(meal.mealType).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getMealTypeIcon(meal.mealType),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          meal.mealType?.displayName ?? 'Meal',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _getMealTypeColor(meal.mealType),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Calories
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '${meal.calories ?? 0} kcal',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Meal name
              Text(
                meal.mealName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Description
              if (meal.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  meal.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),

              // Macros row
              Row(
                children: [
                  _MacroChip(
                    label: 'P',
                    value: '${meal.proteinG?.toInt() ?? 0}g',
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(width: 8),
                  _MacroChip(
                    label: 'C',
                    value: '${meal.carbsG?.toInt() ?? 0}g',
                    color: Colors.amber.shade600,
                  ),
                  const SizedBox(width: 8),
                  _MacroChip(
                    label: 'F',
                    value: '${meal.fatsG?.toInt() ?? 0}g',
                    color: Colors.blue.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMealTypeColor(MealType? type) {
    switch (type) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.indigo;
      case MealType.snack:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getMealTypeIcon(MealType? type) {
    switch (type) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
      default:
        return '🍽️';
    }
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
