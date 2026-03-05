import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Circular calorie gauge with remaining calories in the center.
class CalorieRingCard extends StatelessWidget {
  final int caloriesConsumed;
  final int caloriesTarget;

  const CalorieRingCard({
    super.key,
    required this.caloriesConsumed,
    required this.caloriesTarget,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (caloriesTarget - caloriesConsumed).clamp(0, caloriesTarget);
    final progress = caloriesTarget > 0
        ? (caloriesConsumed / caloriesTarget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor:
                        AlwaysStoppedAnimation(AppColors.grey200),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Progress ring
                SizedBox(
                  width: 160,
                  height: 160,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          _progressColor(progress),
                        ),
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$remaining',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.grey900,
                          ),
                    ),
                    Text(
                      'Calories left',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _progressColor(double progress) {
    if (progress < 0.5) return AppColors.success;
    if (progress < 0.8) return AppColors.warning;
    return AppColors.error;
  }
}
