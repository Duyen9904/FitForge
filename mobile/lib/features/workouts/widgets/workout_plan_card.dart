import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/workout_plan_models.dart';
import 'workout_plan_menu.dart';

/// Card widget for displaying a workout plan summary
/// Premium gradient card with white-background badges
class WorkoutPlanCard extends StatelessWidget {
  final WorkoutPlanSummaryResponse plan;
  final VoidCallback onTap;
  final VoidCallback? onToggleActive;
  final Function(String)? onDuplicate;
  final VoidCallback? onDelete;

  const WorkoutPlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    this.onToggleActive,
    this.onDuplicate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;


    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
        vertical: AppDimensions.spacing6,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shadowColor: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: AppDimensions.spacing64 * 2.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
              color: colorScheme.surface,
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: Stack(
              children: [
                // Background pattern icon
                Positioned(
                  right: -AppDimensions.spacing20,
                  bottom: -AppDimensions.spacing20,
                  child: Icon(
                    _getMuscleGroupIcon(),
                    size: AppDimensions.iconXLarge * 2.5,
                    color: colorScheme.primary.withValues(alpha: 0.05),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacing20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: badges and menu
                      Row(
                        children: [
                          if (plan.aiGenerated) ...[
                            _buildBadge(
                              context,
                              icon: Icons.auto_awesome,
                              label: 'AI',
                              color: colorScheme.tertiary,
                            ),
                            const SizedBox(width: AppDimensions.spacing8),
                          ],
                          if (plan.difficultyLevel != null)
                            _buildBadge(
                              context,
                              label: _formatDifficulty(plan.difficultyLevel!),
                              color: _getDifficultyColor(plan.difficultyLevel!),
                            ),
                          const Spacer(),
                          // Active status badge
                          if (onToggleActive != null)
                            InkWell(
                              onTap: onToggleActive,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusRound),
                              child: _buildBadge(
                                context,
                                icon: plan.isActive
                                    ? Icons.check_circle_outline
                                    : Icons.radio_button_unchecked,
                                label: plan.isActive ? 'Active' : 'Inactive',
                                color: plan.isActive
                                    ? AppColors.success
                                    : AppColors.grey400,
                              ),
                            )
                          else if (plan.isActive)
                            _buildBadge(
                              context,
                              icon: Icons.check_circle_outline,
                              label: 'Active',
                              color: AppColors.success,
                            ),
                          // Menu button
                          if (onDuplicate != null && onDelete != null) ...[
                            const SizedBox(width: AppDimensions.spacing4),
                            WorkoutPlanMenu(
                              plan: plan,
                              onDuplicate: onDuplicate!,
                              onDelete: onDelete!,

                            ),
                          ],
                        ],
                      ),

                      const Spacer(),

                      // Plan name
                      Text(
                        plan.planName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: AppDimensions.spacing8),

                      // Bottom info row
                      Row(
                        children: [
                          if (plan.muscleGroup != null) ...[
                            Icon(
                              _getMuscleGroupIcon(),
                              size: AppDimensions.iconSmall,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: AppDimensions.spacing4),
                            Text(
                              _formatMuscleGroup(plan.muscleGroup!.groupName),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacing12),
                          ],
                          if (plan.frequencyPerWeek != null) ...[
                            Icon(
                              Icons.calendar_today,
                              size: AppDimensions.iconSmall,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: AppDimensions.spacing4),
                            Text(
                              '${plan.frequencyPerWeek}x/week',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacing12),
                          ],
                          if (plan.durationWeeks != null) ...[
                            Icon(
                              Icons.timer_outlined,
                              size: AppDimensions.iconSmall,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: AppDimensions.spacing4),
                            Text(
                              '${plan.durationWeeks} weeks',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    IconData? icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing8,
        vertical: AppDimensions.spacing4,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppDimensions.iconSmall * 0.75, color: color),
            const SizedBox(width: AppDimensions.spacing4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMuscleGroupIcon() {
    switch (plan.muscleGroup!.groupName) {
      case 'CHEST':
        return Icons.fitness_center;
      case 'BACK':
        return Icons.accessibility_new;
      case 'LEGS':
        return Icons.directions_run;
      case 'ARMS':
        return Icons.sports_martial_arts;
      case 'SHOULDERS':
        return Icons.sports_gymnastics;
      case 'CORE':
        return Icons.self_improvement;
      case 'GLUTES':
        return Icons.directions_walk;
      case 'FULL_BODY':
        return Icons.sports;
      default:
        return Icons.fitness_center;
    }
  }

  String _formatMuscleGroup(String muscleGroup) {
    return muscleGroup
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty
            ? ''
            : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatDifficulty(String difficulty) {
    if (difficulty.isEmpty) return difficulty;
    return difficulty[0].toUpperCase() + difficulty.substring(1).toLowerCase();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'BEGINNER':
        return AppColors.success;
      case 'INTERMEDIATE':
        return AppColors.warning;
      case 'ADVANCED':
        return AppColors.error;
      default:
        return AppColors.grey400;
    }
  }
}
