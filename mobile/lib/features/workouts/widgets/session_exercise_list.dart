import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/workout_plan_models.dart';
import '../viewmodels/workout_plan_detail_state.dart';

/// Exercise list widget that handles loading, error, and loaded states.
class SessionExerciseList extends StatelessWidget {
  final SessionLoadingState loadingState;
  final WorkoutSessionResponse? session;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final void Function(SessionExerciseResponse exercise)? onEditExercise;
  final void Function(SessionExerciseResponse exercise)? onDeleteExercise;

  const SessionExerciseList({
    super.key,
    required this.loadingState,
    this.session,
    this.errorMessage,
    this.onRetry,
    this.onEditExercise,
    this.onDeleteExercise,
  });

  @override
  Widget build(BuildContext context) {
    switch (loadingState) {
      case SessionLoadingState.idle:
        return const SizedBox.shrink();

      case SessionLoadingState.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing24),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );

      case SessionLoadingState.error:
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing20,
            vertical: AppDimensions.spacing24,
          ),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                errorMessage ?? 'Failed to load exercises',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey600,
                    ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppDimensions.spacing12),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        );

      case SessionLoadingState.loaded:
        if (session == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing20,
              vertical: AppDimensions.spacing24,
            ),
            child: Center(
              child: Text(
                session?.isRestDay == true
                    ? 'Rest Day — Take it easy!'
                    : 'No exercises for this session',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey500,
                    ),
              ),
            ),
          );
        }

        final exercises =
            List<SessionExerciseResponse>.from(session!.exercises)
              ..sort(
                  (a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16,
            vertical: AppDimensions.spacing8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing4,
                  vertical: AppDimensions.spacing8,
                ),
                child: Text(
                  '${exercises.length} Exercises',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                ),
              ),
              ...exercises
                  .map((exercise) => _buildExerciseTile(context, exercise)),
            ],
          ),
        );
    }
  }

  Widget _buildExerciseTile(
      BuildContext context, SessionExerciseResponse sessionExercise) {
    final exercise = sessionExercise.exercise;

    final tile = Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing12,
          vertical: AppDimensions.spacing4,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: SizedBox(
            width: 56,
            height: 56,
            child: exercise?.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: exercise!.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.grey200,
                      child: const Icon(Icons.fitness_center,
                          color: AppColors.grey400, size: 24),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.grey200,
                      child: const Icon(Icons.fitness_center,
                          color: AppColors.grey400, size: 24),
                    ),
                  )
                : Container(
                    color: AppColors.grey200,
                    child: const Icon(Icons.fitness_center,
                        color: AppColors.grey400, size: 24),
                  ),
          ),
        ),
        title: Text(
          exercise?.exerciseName ?? 'Exercise',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _buildExerciseSubtitle(sessionExercise),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey600,
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEditExercise != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.grey500, size: 20),
                onPressed: () => onEditExercise!(sessionExercise),
                tooltip: 'Edit exercise',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(AppDimensions.spacing4),
              ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
              size: 20,
            ),
          ],
        ),
        onTap: () {
          if (exercise != null) {
            context.push('/exercises/${exercise.exerciseId}');
          }
        },
      ),
    );

    // Wrap with Dismissible for swipe-to-delete if callback provided
    if (onDeleteExercise != null) {
      return Dismissible(
        key: ValueKey(sessionExercise.sessionExerciseId),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacing8),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppDimensions.spacing20),
          child: const Icon(Icons.delete, color: AppColors.white, size: 24),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Exercise'),
              content: Text(
                'Remove "${exercise?.exerciseName ?? 'this exercise'}" from this session?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style:
                      FilledButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) => onDeleteExercise!(sessionExercise),
        child: tile,
      );
    }

    return tile;
  }

  String _buildExerciseSubtitle(SessionExerciseResponse exercise) {
    final parts = <String>[];
    if (exercise.sets != null) parts.add('${exercise.sets} sets');
    if (exercise.repetitions != null) parts.add('${exercise.repetitions} reps');
    if (exercise.weightKg != null) {
      parts.add('${exercise.weightKg!.toStringAsFixed(1)} kg');
    }
    if (exercise.restTimeSeconds != null) {
      parts.add('${exercise.restTimeSeconds}s rest');
    }
    return parts.isEmpty ? 'View details' : parts.join(' · ');
  }
}
