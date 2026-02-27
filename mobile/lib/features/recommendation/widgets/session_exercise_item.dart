import 'package:flutter/material.dart';
import '../models/recommendation_models.dart';

/// List item widget displaying session exercise details
class SessionExerciseItem extends StatelessWidget {
  final SessionExerciseResponse sessionExercise;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onSwapPressed;

  const SessionExerciseItem({
    super.key,
    required this.sessionExercise,
    required this.index,
    this.onTap,
    this.onSwapPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final exercise = sessionExercise.exercise;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Order index
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: sessionExercise.isSuperset
                      ? colorScheme.tertiaryContainer
                      : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: sessionExercise.isSuperset
                          ? colorScheme.onTertiaryContainer
                          : colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Exercise info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise?.exerciseName ?? 'Unknown Exercise',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (sessionExercise.isSuperset)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Superset',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onTertiary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Sets x Reps info
                    Row(
                      children: [
                        _ExerciseDetailChip(
                          icon: Icons.repeat,
                          label: '${sessionExercise.sets ?? 0} sets',
                        ),
                        const SizedBox(width: 8),
                        _ExerciseDetailChip(
                          icon: Icons.fitness_center,
                          label: '${sessionExercise.repetitions ?? 0} reps',
                        ),
                        if (sessionExercise.weightKg != null && sessionExercise.weightKg! > 0) ...[
                          const SizedBox(width: 8),
                          _ExerciseDetailChip(
                            icon: Icons.scale,
                            label: '${sessionExercise.weightKg} kg',
                          ),
                        ],
                      ],
                    ),

                    // Rest time
                    if (sessionExercise.restTimeSeconds != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Rest: ${sessionExercise.restTimeSeconds}s',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ),

                    // Notes
                    if (sessionExercise.notes != null && sessionExercise.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          sessionExercise.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              // Swap button
              if (onSwapPressed != null)
                IconButton(
                  onPressed: onSwapPressed,
                  icon: Icon(Icons.swap_horiz, color: colorScheme.primary),
                  tooltip: 'Swap exercise',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseDetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ExerciseDetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: theme.colorScheme.outline),
        const SizedBox(width: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
