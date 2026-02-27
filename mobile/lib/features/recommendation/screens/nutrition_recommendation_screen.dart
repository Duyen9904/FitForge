import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/nutrition_plan_viewmodel.dart';
import '../viewmodels/nutrition_plan_state.dart';
import '../widgets/nutrition_plan_card.dart';
import '../widgets/meal_template_card.dart';

/// Screen for displaying and managing nutrition recommendations
class NutritionRecommendationScreen extends ConsumerStatefulWidget {
  const NutritionRecommendationScreen({super.key});

  @override
  ConsumerState<NutritionRecommendationScreen> createState() =>
      _NutritionRecommendationScreenState();
}

class _NutritionRecommendationScreenState
    extends ConsumerState<NutritionRecommendationScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nutritionPlanViewModelProvider.notifier).loadActivePlanIfExists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionPlanViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Plan'),
        centerTitle: true,
        actions: [
          if (state is NutritionPlanLoaded)
            IconButton(
              onPressed: () => _showPlanInfo(context, state),
              icon: const Icon(Icons.info_outline),
              tooltip: 'Plan Info',
            ),
        ],
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(NutritionPlanState state, ThemeData theme) {
    return state.when(
      initial: () => _buildInitialState(theme),
      loading: () => const Center(child: CircularProgressIndicator()),
      generating: () => _buildGeneratingState(theme),
      adjusting: (currentPlan) => _buildAdjustingState(theme),
      loadingMeals: (plan, dayNumber) =>
          _buildLoadedState(plan, isLoadingMeals: true),
      loaded: (plan, currentDayMeals, currentDay) =>
          _buildLoadedState(plan, meals: currentDayMeals, currentDay: currentDay),
      error: (message) => _buildErrorState(message, theme),
    );
  }

  Widget _buildInitialState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: theme.colorScheme.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Nutrition Plan Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a personalized nutrition plan based on your profile and fitness goals',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _generatePlan,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Plan'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Generating your nutrition plan...',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Calculating your calorie needs and macros',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Adjusting your nutrition plan...',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing your recent eating habits',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
    dynamic plan, {
    List<dynamic>? meals,
    int currentDay = 1,
    bool isLoadingMeals = false,
  }) {
    final theme = Theme.of(context);
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(nutritionPlanViewModelProvider.notifier).reset();
      },
      child: CustomScrollView(
        slivers: [
          // Plan card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: NutritionPlanCard(
                plan: plan,
                onAdjustPressed: () => _adjustPlan(plan.nutritionPlanId),
              ),
            ),
          ),

          // Day selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Day $currentDay Meals',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: currentDay > 1
                            ? () => _loadMeals(plan.nutritionPlanId, currentDay - 1)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        onPressed: () => _loadMeals(plan.nutritionPlanId, currentDay + 1),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Meals list
          if (isLoadingMeals)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (meals != null && meals.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: MealTemplateCard(
                      meal: meals[index],
                      onTap: () => _navigateToMealDetail(meals[index]),
                    ),
                  ),
                  childCount: meals.length,
                ),
              ),
            )
          else if (plan.mealTemplates.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: MealTemplateCard(
                      meal: plan.mealTemplates[index],
                      onTap: () => _navigateToMealDetail(plan.mealTemplates[index]),
                    ),
                  ),
                  childCount: plan.mealTemplates.length,
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No meals for this day yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _loadMeals(plan.nutritionPlanId, currentDay),
                      child: const Text('Load Meals'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _generatePlan,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _generatePlan() {
    ref.read(nutritionPlanViewModelProvider.notifier).generatePlan();
  }

  void _adjustPlan(int planId) {
    ref.read(nutritionPlanViewModelProvider.notifier).adjustPlan(planId);
  }

  void _loadMeals(int planId, int dayNumber) {
    ref.read(nutritionPlanViewModelProvider.notifier)
        .loadMealsForDay(planId, dayNumber);
  }

  void _navigateToMealDetail(dynamic meal) {
    Navigator.pushNamed(
      context,
      '/recommendation/nutrition/meal',
      arguments: meal,
    );
  }

  void _showPlanInfo(BuildContext context, NutritionPlanLoaded state) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state.plan.algorithmVersion != null)
              _InfoRow('Algorithm', state.plan.algorithmVersion!),
            if (state.plan.version != null)
              _InfoRow('Version', 'v${state.plan.version}'),
            if (state.plan.recommendationReason != null)
              _InfoRow('Reason', state.plan.recommendationReason!),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
