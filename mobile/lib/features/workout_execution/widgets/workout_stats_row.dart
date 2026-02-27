import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// A row of 3 stat items showing workout summary (exercises, calories, minutes).
class WorkoutStatsRow extends StatelessWidget {
  final int exercises;
  final int calories;
  final int minutes;

  const WorkoutStatsRow({
    super.key,
    required this.exercises,
    required this.calories,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing24,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacing20,
        horizontal: AppDimensions.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: AppColors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(value: '$exercises', label: 'Exercises'),
          _buildDivider(),
          _StatItem(value: '$calories', label: 'Calories'),
          _buildDivider(),
          _StatItem(value: '$minutes', label: 'Minutes'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.white.withOpacity(0.2),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
        ),
        const SizedBox(height: AppDimensions.spacing4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withOpacity(0.7),
                fontSize: 13,
              ),
        ),
      ],
    );
  }
}
