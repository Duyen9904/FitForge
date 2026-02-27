import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/exercise_models.dart';
import 'difficulty_badge.dart';

/// Card widget to display alternative exercise
class AlternativeExerciseCard extends StatelessWidget {
  final ExerciseAlternative alternative;
  final VoidCallback onTap;

  const AlternativeExerciseCard({
    super.key,
    required this.alternative,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: AppDimensions.spacing12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius12),
        child: SizedBox(
          width: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.borderRadius12),
                ),
                child: alternative.alternativeExercise.imageUrl != null
                    ? Image.network(
                        alternative.alternativeExercise.imageUrl!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise name
                    Text(
                      alternative.alternativeExercise.exerciseName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacing8),

                    // Difficulty
                    DifficultyBadge(
                      difficultyLevel:
                          alternative.alternativeExercise.difficultyLevel,
                      compact: true,
                    ),

                    // Reason/substitution type
                    if (alternative.reason != null ||
                        alternative.substitutionType != null) ...[
                      const SizedBox(height: AppDimensions.spacing8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing8,
                          vertical: AppDimensions.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadius8),
                        ),
                        child: Text(
                          alternative.substitutionType ?? alternative.reason!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 100,
      width: double.infinity,
      color: AppColors.grey200,
      child: Icon(
        Icons.fitness_center,
        size: 40,
        color: AppColors.grey400,
      ),
    );
  }
}
