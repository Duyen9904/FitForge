import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Displays the "Next Movement" label with current/total count
/// and the upcoming exercise name.
class RestNextMovementInfo extends StatelessWidget {
  final String nextExerciseName;
  final int currentIndex;
  final int totalExercises;

  const RestNextMovementInfo({
    super.key,
    required this.nextExerciseName,
    required this.currentIndex,
    required this.totalExercises,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Next Movement ($currentIndex/$totalExercises)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppDimensions.spacing8),
        Text(
          nextExerciseName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
