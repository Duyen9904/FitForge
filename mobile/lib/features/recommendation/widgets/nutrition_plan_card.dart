import 'package:flutter/material.dart';
import '../models/recommendation_models.dart';

/// Card widget displaying nutrition plan summary with macros
class NutritionPlanCard extends StatelessWidget {
  final NutritionPlanResponse plan;
  final VoidCallback? onTap;
  final VoidCallback? onAdjustPressed;

  const NutritionPlanCard({
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
                colorScheme.secondaryContainer,
                colorScheme.secondaryContainer.withOpacity(0.7),
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
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  if (plan.autoAdjustEnabled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_mode, size: 14, color: colorScheme.onTertiary),
                          const SizedBox(width: 4),
                          Text(
                            'Auto',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onTertiary,
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
              if (plan.goalName != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    plan.goalName!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Calorie target
              _CalorieDisplay(
                calories: plan.dailyCalorieTarget ?? 0,
                colorScheme: colorScheme,
                theme: theme,
              ),
              const SizedBox(height: 16),

              // Macro breakdown
              _MacroBreakdown(plan: plan, theme: theme, colorScheme: colorScheme),
              const SizedBox(height: 16),

              // Cheat meals info
              if (plan.cheatMealsPerWeek != null && plan.cheatMealsPerWeek! > 0)
                Row(
                  children: [
                    Icon(Icons.cake_outlined, size: 16, color: colorScheme.onSecondaryContainer),
                    const SizedBox(width: 4),
                    Text(
                      '${plan.cheatMealsPerWeek} cheat meal${plan.cheatMealsPerWeek! > 1 ? 's' : ''}/week',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),

              // Action buttons
              if (onTap != null || onAdjustPressed != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (onTap != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('View Detail'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.secondary,
                            side: BorderSide(color: colorScheme.secondary),
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
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CalorieDisplay extends StatelessWidget {
  final int calories;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _CalorieDisplay({
    required this.calories,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
          const SizedBox(width: 8),
          Text(
            '$calories',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'kcal/day',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondaryContainer.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroBreakdown extends StatelessWidget {
  final NutritionPlanResponse plan;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _MacroBreakdown({
    required this.plan,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MacroCard(
            label: 'Protein',
            grams: plan.proteinGrams ?? 0,
            percentage: plan.proteinPercentage ?? 0,
            color: Colors.red.shade400,
            theme: theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MacroCard(
            label: 'Carbs',
            grams: plan.carbsGrams ?? 0,
            percentage: plan.carbsPercentage ?? 0,
            color: Colors.amber.shade600,
            theme: theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MacroCard(
            label: 'Fats',
            grams: plan.fatsGrams ?? 0,
            percentage: plan.fatsPercentage ?? 0,
            color: Colors.blue.shade400,
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final double grams;
  final double percentage;
  final Color color;
  final ThemeData theme;

  const _MacroCard({
    required this.label,
    required this.grams,
    required this.percentage,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${grams.toInt()}g',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${percentage.toInt()}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
