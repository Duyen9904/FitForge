import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Reusable exercise tile widget for the Workout Activity screen.
/// Shows an image, exercise name, and duration in a horizontal layout.
class WorkoutExerciseTile extends StatelessWidget {
  final String exerciseName;
  final String duration;
  final String? imageUrl;
  final VoidCallback? onTap;

  const WorkoutExerciseTile({
    super.key,
    required this.exerciseName,
    required this.duration,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing8,
        ),
        child: Row(
          children: [
            // Exercise image
            _buildImage(),
            const SizedBox(width: AppDimensions.spacing16),

            // Exercise name & duration
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacing4),
                  Text(
                    duration,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        width: 72,
        height: 72,
        color: AppColors.grey200,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.grey200,
      child: const Center(
        child: Icon(
          Icons.fitness_center,
          color: AppColors.grey400,
          size: AppDimensions.iconMedium,
        ),
      ),
    );
  }
}
