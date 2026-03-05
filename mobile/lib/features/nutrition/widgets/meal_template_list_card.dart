import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/enums/enums.dart';
import '../models/nutrition_models.dart';

/// Card widget displaying a meal template summary.
/// Shows category tag, meal name, calories, estimated prep time, and a food icon.
class MealTemplateCard extends StatelessWidget {
  final MealTemplate template;

  const MealTemplateCard({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    final tagColor = _tagColor(template.mealType);

    return GestureDetector(
      onTap: () => context.push(
        Routes.templateMealDetail,
        extra: template,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ── Left content ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        template.mealType.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: tagColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Meal name
                    Text(
                      template.mealName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Calories + prep time row
                    Row(
                      children: [
                        // Calories
                        Icon(Icons.local_fire_department,
                            size: 14, color: Colors.orange.shade600),
                        const SizedBox(width: 3),
                        Text(
                          '${template.calories}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Kcals',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey500,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Prep time (estimated from calories)
                        Icon(Icons.access_time,
                            size: 14, color: AppColors.grey400),
                        const SizedBox(width: 3),
                        Text(
                          '${_estimatedPrepTime(template.calories)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'min.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── Right: food image placeholder ──
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    _mealIcon(template.mealType),
                    size: 36,
                    color: tagColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Rough prep-time estimate (since model has no prep field)
  int _estimatedPrepTime(int calories) {
    if (calories < 300) return 10;
    if (calories < 500) return 20;
    return 30;
  }

  Color _tagColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return const Color(0xFF4CAF50);
      case MealType.lunch:
        return const Color(0xFFFF9800);
      case MealType.dinner:
        return const Color(0xFF5C6BC0);
      case MealType.snack:
        return const Color(0xFFAB47BC);
    }
  }

  IconData _mealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }
}
