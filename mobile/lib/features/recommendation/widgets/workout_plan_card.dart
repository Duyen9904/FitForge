import 'package:flutter/material.dart';
import '../../../shared/enums/enums.dart';
import '../models/recommendation_models.dart';

/// Card widget displaying workout plan summary
class WorkoutPlanCard extends StatelessWidget {
  final WorkoutPlanResponse plan;
  final VoidCallback? onTap;
  final VoidCallback? onAdjustPressed;

  const WorkoutPlanCard({
    super.key,
    required this.plan,
    this.onTap,
    this.onAdjustPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer,
                colorScheme.primaryContainer.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      plan.planName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  if (plan.aiGenerated)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 14, color: colorScheme.onSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'AI',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Goal badge
              if (plan.goal != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    plan.goal!.goalName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Info row
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: '${plan.frequencyPerWeek ?? 0}x/week',
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.timer,
                    label: '${plan.durationWeeks ?? 0} weeks',
                  ),
                  const SizedBox(width: 12),
                  if (plan.difficultyLevel != null)
                    _InfoChip(
                      icon: Icons.fitness_center,
                      label: plan.difficultyLevel!.displayName,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              if (plan.description != null)
                Text(
                  plan.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 16),

              // Action buttons
              if (onTap != null || onAdjustPressed != null)
                Row(
                  children: [
                    if (onTap != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('View Detail'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary),
                          ),
                        ),
                      ),
                    if (onTap != null && onAdjustPressed != null)
                      const SizedBox(width: 12),
                    if (onAdjustPressed != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onAdjustPressed,
                          icon: const Icon(Icons.tune, size: 18),
                          label: const Text('Adjust Plan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onPrimaryContainer),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}
