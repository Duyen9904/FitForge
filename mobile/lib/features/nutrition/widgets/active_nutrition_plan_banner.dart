import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../models/nutrition_models.dart';

class ActiveNutritionPlanBanner extends StatelessWidget {
  final NutritionPlan plan;

  const ActiveNutritionPlanBanner({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final totalMacroGrams =
        plan.proteinGrams + plan.carbsGrams + plan.fatsGrams;

    double _percentage(double grams) {
      if (totalMacroGrams <= 0) return 0;
      return (grams / totalMacroGrams) * 100;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan name and goal
            Text(
              plan.planName,
              style: textTheme.titleMedium,
            ),
            if (plan.goalName != null) ...[
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                plan.goalName!,
                style: textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: AppDimensions.spacing8),

            // Calories per day
            Text(
              '${plan.dailyCalorieTarget} kcal / day',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.spacing8),

            // Macros row
            _MacroRow(
              proteinGrams: plan.proteinGrams,
              carbsGrams: plan.carbsGrams,
              fatsGrams: plan.fatsGrams,
              proteinPercentage: _percentage(plan.proteinGrams),
              carbsPercentage: _percentage(plan.carbsGrams),
              fatsPercentage: _percentage(plan.fatsGrams),
            ),

            // Cheat meals & auto-adjust
            if (plan.cheatMealsPerWeek != null ||
                plan.autoAdjustEnabled != null) ...[
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                [
                  if (plan.cheatMealsPerWeek != null)
                    'Cheat meals/week: ${plan.cheatMealsPerWeek}',
                  if (plan.autoAdjustEnabled != null)
                    'Auto adjust: ${plan.autoAdjustEnabled! ? 'On' : 'Off'}',
                ].join(' \u00b7 '),
                style: textTheme.bodySmall,
              ),
            ],

            // Recommendation reason
            if (plan.recommendationReason != null &&
                plan.recommendationReason!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                plan.recommendationReason!,
                style: textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;
  final double proteinPercentage;
  final double carbsPercentage;
  final double fatsPercentage;

  const _MacroRow({
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatsPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    String _macroText(String label, double grams, double percentage) {
      return '$label: ${grams.toStringAsFixed(1)} g (${percentage.toStringAsFixed(0)}%)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Macros',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing4),
        Wrap(
          spacing: AppDimensions.spacing8,
          runSpacing: AppDimensions.spacing4,
          children: [
            Text(
              _macroText('Protein', proteinGrams, proteinPercentage),
              style: textTheme.bodySmall,
            ),
            Text(
              _macroText('Carbs', carbsGrams, carbsPercentage),
              style: textTheme.bodySmall,
            ),
            Text(
              _macroText('Fats', fatsGrams, fatsPercentage),
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

