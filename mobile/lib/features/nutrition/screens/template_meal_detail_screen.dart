import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../shared/enums/enums.dart';
import '../models/nutrition_models.dart';
import '../widgets/meal_detail_widgets.dart';

/// Detailed view of a meal template, showing image, description,
/// nutrition stats, ingredients, and an "Add Meal Plan" CTA.
class TemplateMealDetailScreen extends StatelessWidget {
  final MealTemplate template;

  const TemplateMealDetailScreen({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    final tagColor = _tagColor(template.mealType);
    final prepTime = _estimatedPrepTime(template.calories);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Hero image area with SliverAppBar ──
                SliverAppBar(
                  expandedHeight: 260,
                  pinned: true,
                  backgroundColor: tagColor,
                  foregroundColor: Colors.white,
                  actions: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        // placeholders for Edit / Delete actions
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      template.mealName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [
                          Shadow(blurRadius: 6, color: Colors.black38),
                        ],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient background
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                tagColor,
                                tagColor.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _mealIcon(template.mealType),
                              size: 80,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                        // Tag overlay (top-left)
                        Positioned(
                          left: 16,
                          bottom: 56,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              template.mealType.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: tagColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Content ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meal name
                        Text(
                          template.mealName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        if (template.description != null &&
                            template.description!.isNotEmpty) ...[
                          Text(
                            template.description!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.grey600,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Stats row
                        MealDetailStatsRow(
                          calories: template.calories,
                          proteinG: template.proteinG,
                          estimatedPrepTime: prepTime,
                        ),

                        const SizedBox(height: AppDimensions.spacing24),

                        // Ingredients card
                        IngredientsCard(
                          recipeInstructions: template.recipeInstructions,
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom CTA button ──
          _buildAddMealPlanButton(context),
        ],
      ),
    );
  }

  // ───────── Bottom button ─────────

  Widget _buildAddMealPlanButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacing16,
          AppDimensions.spacing8,
          AppDimensions.spacing16,
          AppDimensions.spacing16,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.push(
              Routes.addMealPlan,
              extra: template,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Add Meal Plan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── Helpers ─────────

  int _estimatedPrepTime(int calories) {
    if (calories < 300) return 10;
    if (calories < 500) return 20;
    return 30;
  }

  Color _tagColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return const Color(0xFF4CAF50);
      case MealType.lunch:
        return const Color(0xFFFF9800);
      case MealType.dinner:
        return const Color(0xFF5C6BC0);
      case MealType.snack:
        return const Color(0xFFAB47BC);
    }
  }

  IconData _mealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }
}
