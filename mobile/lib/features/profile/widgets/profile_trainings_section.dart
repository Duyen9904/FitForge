import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../workouts/models/workout_plan_models.dart';

/// Horizontal scrollable trainings section for the profile screen.
/// Matches the "Trainings" section in the reference UI.
class ProfileTrainingsSection extends StatelessWidget {
  final List<WorkoutPlanSummaryResponse> plans;
  final VoidCallback? onShowAll;
  final void Function(int planId)? onPlanTap;

  const ProfileTrainingsSection({
    super.key,
    required this.plans,
    this.onShowAll,
    this.onPlanTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trainings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onShowAll != null)
                GestureDetector(
                  onTap: onShowAll,
                  child: Text(
                    'Show all',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacing12),

          if (plans.isEmpty)
            _EmptyTrainings(theme: theme)
          else
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: plans.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppDimensions.spacing12),
                itemBuilder: (context, index) {
                  return _TrainingCard(
                    plan: plans[index],
                    onTap: () =>
                        onPlanTap?.call(plans[index].planId),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// A single training plan card.
class _TrainingCard extends StatelessWidget {
  final WorkoutPlanSummaryResponse plan;
  final VoidCallback? onTap;

  const _TrainingCard({required this.plan, this.onTap});

  IconData get _planIcon {
    final difficulty = plan.difficultyLevel?.toLowerCase() ?? '';
    if (difficulty.contains('advanced')) return Icons.local_fire_department;
    if (difficulty.contains('intermediate')) return Icons.fitness_center;
    return Icons.directions_run;
  }

  Color get _planColor {
    final difficulty = plan.difficultyLevel?.toLowerCase() ?? '';
    if (difficulty.contains('advanced')) return AppColors.error;
    if (difficulty.contains('intermediate')) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final freq = plan.frequencyPerWeek;
    final weeks = plan.durationWeeks;
    final subtitle = [
      if (freq != null) '${freq}x/week',
      if (weeks != null) '$weeks weeks',
    ].join(' • ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(AppDimensions.spacing12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusXLarge),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _planColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: Icon(
                _planIcon,
                color: _planColor,
                size: 22,
              ),
            ),
            const SizedBox(width: AppDimensions.spacing12),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    plan.planName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacing2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when there are no active training plans.
class _EmptyTrainings extends StatelessWidget {
  final ThemeData theme;

  const _EmptyTrainings({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius:
            BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Center(
        child: Text(
          'No active training plans yet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
