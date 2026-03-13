import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/exercise_models.dart';
import '../repositories/exercise_repository.dart';
import 'difficulty_badge.dart';

/// Card widget to display exercise summary in list/grid
class ExerciseCard extends ConsumerStatefulWidget {
  final ExerciseSummary exercise;
  final VoidCallback onTap;
  final bool showFavoriteButton;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
    this.showFavoriteButton = true,
  });

  @override
  ConsumerState<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<ExerciseCard> {
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    if (!widget.showFavoriteButton) return;
    
    try {
      final repository = ref.read(exerciseRepositoryProvider);
      final isFavorite =
          await repository.isFavorite(widget.exercise.exerciseId);
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    } catch (e) {
      // Ignore errors when loading favorite status
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(exerciseRepositoryProvider);
      if (_isFavorite) {
        await repository.removeFromFavorites(widget.exercise.exerciseId);
      } else {
        await repository.addToFavorites(widget.exercise.exerciseId);
      }

      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite
                  ? 'Added to favorites'
                  : 'Removed from favorites',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button
            Stack(
              children: [
                // Exercise image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.borderRadius12),
                  ),
                  child: widget.exercise.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.exercise.imageUrl!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 120,
                            width: double.infinity,
                            color: AppColors.grey200,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),

                // Favorite button
                if (widget.showFavoriteButton)
                  Positioned(
                    top: AppDimensions.spacing8,
                    right: AppDimensions.spacing8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorite
                                    ? Colors.red
                                    : AppColors.grey600,
                              ),
                              onPressed: _toggleFavorite,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                    ),
                  ),
              ],
            ),

            // Exercise details
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise name
                  Text(
                    widget.exercise.exerciseName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacing8),

                  // Difficulty badge
                  DifficultyBadge(
                    difficultyLevel: widget.exercise.difficultyLevel,
                    compact: true,
                  ),
                  const SizedBox(height: AppDimensions.spacing8),

                  // Calories info
                  if (widget.exercise.caloriesBurnedPerMin != null)
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: AppColors.grey600,
                        ),
                        const SizedBox(width: AppDimensions.spacing4),
                        Text(
                          '${widget.exercise.caloriesBurnedPerMin} cal/min',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.grey600,
                                  ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      color: AppColors.grey200,
      child: Icon(
        Icons.fitness_center,
        size: 48,
        color: AppColors.grey400,
      ),
    );
  }
}
