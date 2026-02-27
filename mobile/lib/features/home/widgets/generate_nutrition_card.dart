import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';

/// Card widget prompting user to generate their nutrition plan
class GenerateNutritionCard extends StatelessWidget {
  const GenerateNutritionCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => GoRouter.of(context).go(Routes.nutrition),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacing12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: AppColors.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Nutrition Plan',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      'Get calorie & macro recommendations',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
              Icon(Icons.auto_awesome, color: AppColors.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
