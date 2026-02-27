import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../widgets/active_nutrition_plan_banner.dart';
import '../widgets/active_plan_templates_section.dart';
import '../viewmodels/nutrition_dashboard_viewmodel.dart';
import '../viewmodels/nutrition_dashboard_state.dart';
import '../viewmodels/nutrition_cheat_meals_viewmodel.dart';
import '../viewmodels/nutrition_cheat_meals_state.dart';
import '../viewmodels/nutrition_plan_viewmodel.dart';
import '../viewmodels/nutrition_plan_state.dart';
import '../widgets/nutrition_cheat_meals_section.dart';
import '../widgets/nutrition_meal_list.dart';
import '../widgets/nutrition_summary_card.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(nutritionDashboardViewModelProvider.notifier)
          .loadDashboard();
      ref.read(nutritionPlanViewModelProvider.notifier).loadActivePlan();
      ref.read(nutritionCheatMealsViewModelProvider.notifier).loadCheatMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(nutritionDashboardViewModelProvider);
    final cheatMealsState = ref.watch(nutritionCheatMealsViewModelProvider);
    final planState = ref.watch(nutritionPlanViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlanBanner(planState),
              const SizedBox(height: AppDimensions.spacing16),
              _buildTemplatesSection(planState),
              const SizedBox(height: AppDimensions.spacing16),
              _buildDashboardSection(dashboardState),
              const SizedBox(height: AppDimensions.spacing16),
              _buildMealsSection(dashboardState),
              const SizedBox(height: AppDimensions.spacing16),
              _buildCheatMealsSection(cheatMealsState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanBanner(NutritionPlanState state) {
    return state.maybeWhen(
      loaded: (plan) => ActiveNutritionPlanBanner(plan: plan),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildTemplatesSection(NutritionPlanState state) {
    return state.maybeWhen(
      loaded: (plan) => ActivePlanTemplatesSection(
        templates: plan.mealTemplates,
        onManageTemplates: () {
          // TODO: Wire to meal template management screen
        },
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildDashboardSection(NutritionDashboardState state) {
    return state.when(
      initial: () => const Center(child: CircularProgressIndicator()),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (message) => Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.red,
          ),
        ),
      ),
      loaded: (dashboard, selectedDaySummary, selectedDayMeals) {
        final summary = selectedDaySummary ?? dashboard.todaySummary;
        return NutritionSummaryCard(summary: summary);
      },
    );
  }

  Widget _buildMealsSection(NutritionDashboardState state) {
    return state.maybeWhen(
      loaded: (dashboard, selectedDaySummary, selectedDayMeals) {
        final meals =
            selectedDayMeals.isNotEmpty ? selectedDayMeals : dashboard.recentMeals;
        return NutritionMealList(
          meals: meals,
          onAddMeal: () {
            // Will be wired to log meal screen in later steps
          },
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildCheatMealsSection(NutritionCheatMealsState state) {
    return state.maybeWhen(
      loaded: (cheatMeals, compensationOptions) {
        return NutritionCheatMealsSection(
          cheatMeals: cheatMeals,
          onViewAll: () {
            // Will be wired to cheat meal management screen later
          },
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

