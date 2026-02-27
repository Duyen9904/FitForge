import 'package:flutter/material.dart';
import '../../../shared/enums/enums.dart';
import '../models/recommendation_models.dart';
import '../widgets/macro_progress_indicator.dart';

/// Screen for displaying meal template details with recipe
class MealDetailScreen extends StatelessWidget {
  final MealTemplateResponse meal;

  const MealDetailScreen({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with meal type gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                meal.mealName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(blurRadius: 4, color: Colors.black45),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getMealTypeColor(meal.mealType),
                      _getMealTypeColor(meal.mealType).withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getMealTypeIcon(meal.mealType),
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getMealTypeColor(meal.mealType).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getMealTypeIcon(meal.mealType),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          meal.mealType?.displayName ?? 'Meal',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: _getMealTypeColor(meal.mealType),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (meal.description != null) ...[
                    Text(
                      meal.description!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Nutrition card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nutrition Facts',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),

                          // Calories
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.orange,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${meal.calories ?? 0}',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'kcal',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Macro progress
                          MacroProgressIndicator(
                            proteinPercentage: _calculateMacroPercentage(
                              meal.proteinG ?? 0,
                              meal.carbsG ?? 0,
                              meal.fatsG ?? 0,
                              'protein',
                            ),
                            carbsPercentage: _calculateMacroPercentage(
                              meal.proteinG ?? 0,
                              meal.carbsG ?? 0,
                              meal.fatsG ?? 0,
                              'carbs',
                            ),
                            fatsPercentage: _calculateMacroPercentage(
                              meal.proteinG ?? 0,
                              meal.carbsG ?? 0,
                              meal.fatsG ?? 0,
                              'fats',
                            ),
                            height: 24,
                          ),
                          const SizedBox(height: 24),

                          // Macro details
                          Row(
                            children: [
                              Expanded(
                                child: _MacroDetail(
                                  label: 'Protein',
                                  grams: meal.proteinG ?? 0,
                                  color: Colors.red.shade400,
                                ),
                              ),
                              Expanded(
                                child: _MacroDetail(
                                  label: 'Carbs',
                                  grams: meal.carbsG ?? 0,
                                  color: Colors.amber.shade600,
                                ),
                              ),
                              Expanded(
                                child: _MacroDetail(
                                  label: 'Fats',
                                  grams: meal.fatsG ?? 0,
                                  color: Colors.blue.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recipe instructions
                  if (meal.recipeInstructions != null &&
                      meal.recipeInstructions!.isNotEmpty) ...[
                    Text(
                      'Recipe',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          meal.recipeInstructions!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Color _getMealTypeColor(MealType? type) {
    switch (type) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.indigo;
      case MealType.snack:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getMealTypeIcon(MealType? type) {
    switch (type) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
      default:
        return '🍽️';
    }
  }

  double _calculateMacroPercentage(
    double protein,
    double carbs,
    double fats,
    String macro,
  ) {
    // Calculate calories from macros (4 cal/g protein, 4 cal/g carbs, 9 cal/g fats)
    final proteinCal = protein * 4;
    final carbsCal = carbs * 4;
    final fatsCal = fats * 9;
    final totalCal = proteinCal + carbsCal + fatsCal;

    if (totalCal == 0) return 0;

    switch (macro) {
      case 'protein':
        return (proteinCal / totalCal) * 100;
      case 'carbs':
        return (carbsCal / totalCal) * 100;
      case 'fats':
        return (fatsCal / totalCal) * 100;
      default:
        return 0;
    }
  }
}

class _MacroDetail extends StatelessWidget {
  final String label;
  final double grams;
  final Color color;

  const _MacroDetail({
    required this.label,
    required this.grams,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${grams.toInt()}g',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
