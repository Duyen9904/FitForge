import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// 2×2 grid of quick action navigation cards
class QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onBrowseExercises;
  final VoidCallback? onLogMeasurement;
  final VoidCallback? onNutrition;
  final VoidCallback? onWorkoutHistory;

  const QuickActionsGrid({
    super.key,
    this.onBrowseExercises,
    this.onLogMeasurement,
    this.onNutrition,
    this.onWorkoutHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
        ),
        const SizedBox(height: AppDimensions.spacing12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppDimensions.spacing12,
          crossAxisSpacing: AppDimensions.spacing12,
          childAspectRatio: 1.6,
          children: [
            _QuickActionCard(
              icon: Icons.fitness_center_rounded,
              title: 'Exercises',
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primary.withOpacity(0.1),
              onTap: onBrowseExercises,
            ),
            _QuickActionCard(
              icon: Icons.straighten_rounded,
              title: 'Measurement',
              iconColor: AppColors.success,
              iconBgColor: AppColors.success.withOpacity(0.1),
              onTap: onLogMeasurement,
            ),
            _QuickActionCard(
              icon: Icons.restaurant_rounded,
              title: 'Nutrition',
              iconColor: AppColors.warning,
              iconBgColor: AppColors.warning.withOpacity(0.1),
              onTap: onNutrition,
            ),
            _QuickActionCard(
              icon: Icons.history_rounded,
              title: 'History',
              iconColor: AppColors.info,
              iconBgColor: AppColors.info.withOpacity(0.1),
              onTap: onWorkoutHistory,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.iconBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.grey100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
