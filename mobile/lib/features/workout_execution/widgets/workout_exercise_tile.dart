import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Reusable exercise tile widget for the Workout Activity screen.
/// Shows exercise number badge, image, name, subtitle, and chevron indicator.
class WorkoutExerciseTile extends StatelessWidget {
  final String exerciseName;
  final String duration;
  final String? imageUrl;
  final int? exerciseNumber;
  final VoidCallback? onTap;

  const WorkoutExerciseTile({
    super.key,
    required this.exerciseName,
    required this.duration,
    this.imageUrl,
    this.exerciseNumber,
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
          vertical: AppDimensions.spacing12,
        ),
        child: Row(
          children: [
            // Exercise number badge
            if (exerciseNumber != null) ...[
              _buildNumberBadge(context),
              const SizedBox(width: AppDimensions.spacing12),
            ],

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

            // Chevron
            const SizedBox(width: AppDimensions.spacing8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.grey400,
              size: AppDimensions.iconMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberBadge(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
      ),
      child: Center(
        child: Text(
          '$exerciseNumber',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        width: 64,
        height: 64,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primaryLight.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.fitness_center,
          color: AppColors.primary,
          size: 22,
        ),
      ),
    );
  }
}
