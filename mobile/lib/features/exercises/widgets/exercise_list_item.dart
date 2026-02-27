import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/exercise_models.dart';

/// List item widget for displaying an exercise in the list view.
/// Shows exercise image on the left, name in the middle, and chevron on the right.
class ExerciseListItem extends StatelessWidget {
  final ExerciseSummary exercise;
  final VoidCallback onTap;

  const ExerciseListItem({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.grey200,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Exercise image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius8),
              child: exercise.imageUrl != null
                  ? Image.network(
                      exercise.imageUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            const SizedBox(width: AppDimensions.spacing16),

            // Exercise name
            Expanded(
              child: Text(
                exercise.exerciseName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey900,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: AppDimensions.spacing8),

            // Chevron
            Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius8),
      ),
      child: Icon(
        Icons.fitness_center,
        size: 28,
        color: AppColors.grey400,
      ),
    );
  }
}
