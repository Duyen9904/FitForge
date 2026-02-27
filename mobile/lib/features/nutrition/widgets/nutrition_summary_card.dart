import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../recommendation/widgets/macro_progress_indicator.dart';
import '../models/nutrition_models.dart';

class NutritionSummaryCard extends StatelessWidget {
  final DailyNutritionSummary summary;

  const NutritionSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacing16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Nutrition',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              '${summary.totalCalories} / ${summary.targetCalories} kcal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Builder(
              builder: (context) {
                // Calculate percentages from grams
                final totalGrams = summary.totalProteinG + summary.totalCarbsG + summary.totalFatsG;
                final proteinPercentage = totalGrams > 0 ? (summary.totalProteinG / totalGrams) * 100 : 0.0;
                final carbsPercentage = totalGrams > 0 ? (summary.totalCarbsG / totalGrams) * 100 : 0.0;
                final fatsPercentage = totalGrams > 0 ? (summary.totalFatsG / totalGrams) * 100 : 0.0;

                return MacroProgressIndicator(
                  proteinPercentage: proteinPercentage,
                  carbsPercentage: carbsPercentage,
                  fatsPercentage: fatsPercentage,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

