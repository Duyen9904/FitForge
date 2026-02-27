import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../shared/enums/meal_type.dart';
import '../models/nutrition_models.dart';

class PlanMealTemplateCard extends StatelessWidget {
  final MealTemplate template;
  final VoidCallback? onTap;

  const PlanMealTemplateCard({
    super.key,
    required this.template,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: meal type badge + calories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MealTypeBadge(mealType: template.mealType),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${template.calories} kcal',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacing8),

              // Meal name
              Text(
                template.mealName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Description
              if (template.description != null &&
                  template.description!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacing4),
                Text(
                  template.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: AppDimensions.spacing8),

              // Macros row
              Row(
                children: [
                  _MacroChip(
                    label: 'P',
                    value: '${(template.proteinG ?? 0).toStringAsFixed(0)}g',
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  _MacroChip(
                    label: 'C',
                    value: '${(template.carbsG ?? 0).toStringAsFixed(0)}g',
                    color: Colors.amber.shade600,
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  _MacroChip(
                    label: 'F',
                    value: '${(template.fatsG ?? 0).toStringAsFixed(0)}g',
                    color: Colors.blue.shade400,
                  ),
                ],
              ),

              // Recipe instructions snippet
              if (template.recipeInstructions != null &&
                  template.recipeInstructions!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  template.recipeInstructions!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MealTypeBadge extends StatelessWidget {
  final MealType mealType;

  const _MealTypeBadge({required this.mealType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getMealTypeColor(mealType);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing8,
        vertical: AppDimensions.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getMealTypeIcon(mealType),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
          Text(
            mealType.displayName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMealTypeColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.indigo;
      case MealType.snack:
        return Colors.purple;
    }
  }

  String _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing8,
        vertical: AppDimensions.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

