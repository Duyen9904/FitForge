import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../recommendation/viewmodels/workout_plan_viewmodel.dart';
import '../../recommendation/viewmodels/workout_plan_state.dart';
import '../../workouts/viewmodels/workout_plans_viewmodel.dart';
import '../../workouts/viewmodels/workout_plans_state.dart';
import '../../workouts/viewmodels/recommended_templates_viewmodel.dart';
import '../../recommendation/viewmodels/nutrition_plan_viewmodel.dart';
import '../../recommendation/viewmodels/nutrition_plan_state.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/home_state.dart';
import '../models/home_models.dart';
import '../widgets/welcome_header.dart';
import '../widgets/weekly_progress_chart.dart';
import '../widgets/featured_plan_card.dart';
import '../widgets/trending_workout_card.dart';
import '../widgets/workout_filter_chips.dart';
import '../widgets/generate_workout_card.dart';
import '../widgets/plan_generation_options_sheet.dart';
import '../models/plan_generation_option.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All Type';

  static const List<String> _categories = [
    'All Type',
    'Chest',
    'Cardio',
    'Lower',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).loadDashboard();
      ref.read(workoutPlansViewModelProvider.notifier).loadPlans();
      ref.read(nutritionPlanViewModelProvider.notifier).loadActivePlanIfExists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final homeState = ref.watch(homeViewModelProvider);
    final workoutPlanState = ref.watch(workoutPlanViewModelProvider);
    final workoutPlansState = ref.watch(workoutPlansViewModelProvider);
    final nutritionPlanState = ref.watch(nutritionPlanViewModelProvider);

    final userName = authState.maybeWhen(
      authenticated: (user) => user.username,
      orElse: () => 'User',
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(homeViewModelProvider.notifier).refresh(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
              vertical: AppDimensions.spacing16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Greeting Header
                WelcomeHeader(userName: userName),
                const SizedBox(height: AppDimensions.spacing24),

                // 2. Weekly Progress Chart or Generate Workout Button
                _buildWeeklyChartOrGenerate(homeState, workoutPlansState),
                const SizedBox(height: AppDimensions.spacing24),

                // 3. Featured Plan Section
                _buildSectionHeader(context, 'Featured plan', onSeeAll: () {
                  context.push(Routes.workoutRecommendation);
                }),
                const SizedBox(height: AppDimensions.spacing12),
                _buildFeaturedPlans(workoutPlanState, nutritionPlanState),
                const SizedBox(height: AppDimensions.spacing24),

                // 4. Trending Workouts Section
                _buildSectionHeader(context, 'Trending workouts', onSeeAll: () {
                  context.push(Routes.workoutRecommendation);
                }),
                const SizedBox(height: AppDimensions.spacing12),
                WorkoutFilterChips(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onSelected: (category) {
                    setState(() => _selectedCategory = category);
                  },
                ),
                const SizedBox(height: AppDimensions.spacing12),
                _buildTrendingWorkoutsGrid(),
                const SizedBox(height: AppDimensions.spacing24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section header with title and "See all" link
  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See all',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
      ],
    );
  }

  /// Weekly progress bar chart section or generate workout button
  Widget _buildWeeklyChartOrGenerate(HomeState homeState, WorkoutPlansState workoutPlansState) {
    // Check if user has any workout plans
    final hasPlans = workoutPlansState.maybeWhen(
      loaded: (plans, _, __, ___, ____, _____) => plans.isNotEmpty,
      orElse: () => false,
    );

    // If no plans, show generate button instead of chart
    if (!hasPlans) {
      return GenerateWorkoutCard(
        onTap: _showPlanGenerationOptionsSheet,
      );
    }

    // Otherwise show the weekly progress chart
    return _buildWeeklyChart(homeState);
  }

  /// Weekly progress bar chart section
  Widget _buildWeeklyChart(HomeState homeState) {
    return homeState.when(
      initial: () => _buildEmptyChart(),
      loading: () => Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      loaded: (weeklyProgress, _) => WeeklyProgressChart(
        weeklyProgress: weeklyProgress,
      ),
      error: (_) => _buildEmptyChart(),
    );
  }

  /// Empty chart placeholder
  Widget _buildEmptyChart() {
    return WeeklyProgressChart(
      weeklyProgress: WeeklyWorkoutProgressResponse(
        weekLabel: 'This Week',
        dailyData: List.generate(
          7,
          (i) => DailyWorkoutData(
            dayOfWeek: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][i],
            isToday: i == DateTime.now().weekday % 7,
          ),
        ),
      ),
    );
  }

  /// Featured plans horizontal list
  Widget _buildFeaturedPlans(
    WorkoutPlanState workoutState,
    NutritionPlanState nutritionState,
  ) {
    final cards = <Widget>[];

    // Workout plan or recommended templates cards
    workoutState.maybeWhen(
      loaded: (plan, _, __) {
        // If there is an active/generated workout plan, keep existing behavior
        cards.add(
          FeaturedPlanCard(
            title: plan.planName,
            subtitle:
                '${plan.durationWeeks ?? 0} weeks • ${plan.frequencyPerWeek ?? 0}x/week',
            onTap: () => context.push(Routes.workoutRecommendation),
            onStartPressed: () => context.push(Routes.workoutRecommendation),
          ),
        );
      },
      orElse: () {
        // If no active plan, show recommended templates from backend
        final templatesAsync =
            ref.watch(recommendedWorkoutTemplatesProvider);

        templatesAsync.when(
          data: (templates) {
            if (templates.isEmpty) {
              cards.add(
                FeaturedPlanCard(
                  title: 'No recommended plans yet',
                  subtitle: 'Complete onboarding to get suggestions',
                  onTap: () => context.push(Routes.workoutRecommendation),
                ),
              );
            } else {
              for (final template in templates) {
                final days = template.daysPerWeek;
                final subtitleParts = <String>[];
                if (template.goalType != null &&
                    template.goalType!.trim().isNotEmpty) {
                  subtitleParts.add(template.goalType!);
                }
                if (template.experienceLevel != null &&
                    template.experienceLevel!.trim().isNotEmpty) {
                  subtitleParts.add(template.experienceLevel!);
                }
                if (days != null && days > 0) {
                  subtitleParts.add('$days days/week');
                }

                cards.add(
                  FeaturedPlanCard(
                    title: template.name,
                    subtitle:
                        subtitleParts.isNotEmpty ? subtitleParts.join(' • ') : null,
                    onTap: () => context.push(Routes.workoutRecommendation),
                    onStartPressed: () =>
                        context.push(Routes.workoutRecommendation),
                  ),
                );
              }
            }
          },
          loading: () {
            cards.add(
              const FeaturedPlanCard(
                title: 'Loading recommendations...',
                subtitle: 'Fetching your best plans',
              ),
            );
          },
          error: (_, __) {
            cards.add(
              FeaturedPlanCard(
                title: 'Recommended plans unavailable',
                subtitle: 'Please try again later',
                onTap: () => context.push(Routes.workoutRecommendation),
              ),
            );
          },
        );
      },
    );

    // Nutrition plan card
    nutritionState.maybeWhen(
      loaded: (plan, _, __) {
        cards.add(FeaturedPlanCard(
          title: plan.planName,
          subtitle: '${plan.dailyCalorieTarget ?? 0} cal/day',
          onTap: () => context.push(Routes.nutritionRecommendation),
          onStartPressed: () => context.push(Routes.nutritionRecommendation),
        ));
      },
      orElse: () {
        cards.add(FeaturedPlanCard(
          title: 'Smart\nNutrition',
          subtitle: 'Personalized meals',
          onTap: () => context.push(Routes.nutritionRecommendation),
        ));
      },
    );

    return SizedBox(
      height: 170,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }

  /// Trending workouts grid
  Widget _buildTrendingWorkoutsGrid() {
    // Static trending workouts for now — will be dynamic when backend supports it
    final trendingWorkouts = [
      {'title': 'Full Body Burn', 'category': 'All Type'},
      {'title': 'Chest Press', 'category': 'Chest'},
      {'title': 'HIIT Cardio', 'category': 'Cardio'},
      {'title': 'Leg Day', 'category': 'Lower'},
      {'title': 'Push Up Challenge', 'category': 'Chest'},
      {'title': 'Sprint Training', 'category': 'Cardio'},
    ];

    final filtered = _selectedCategory == 'All Type'
        ? trendingWorkouts
        : trendingWorkouts
            .where((w) => w['category'] == _selectedCategory)
            .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.spacing12,
        crossAxisSpacing: AppDimensions.spacing12,
        childAspectRatio: 1.1,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final workout = filtered[index];
        return TrendingWorkoutCard(
          title: workout['title']!,
          onTap: () => context.push(Routes.workoutRecommendation),
        );
      },
    );
  }

  /// Show plan generation options bottom sheet
  void _showPlanGenerationOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlanGenerationOptionsSheet(
        onOptionSelected: (option) {
          if (option == PlanGenerationOption.fromOnboarding) {
            _showOnboardingConfirmation();
          } else {
            _showComingSoonSnackbar(option);
          }
        },
      ),
    );
  }

  /// Show confirmation dialog for onboarding-based generation
  void _showOnboardingConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Plan from Profile?'),
        content: const Text(
          'We\'ll use your onboarding answers to create a personalized workout plan.\n\nDo you want to revise any of your answers first?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(Routes.onboarding);
            },
            child: const Text('Revise Answers'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _generateWorkoutPlan();
            },
            child: const Text('Generate Now'),
          ),
        ],
      ),
    );
  }

  /// Show coming soon snackbar for unavailable options
  void _showComingSoonSnackbar(PlanGenerationOption option) {
    final optionName = option == PlanGenerationOption.createOwn
        ? 'Manual plan creation'
        : 'Custom AI generation';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$optionName is coming soon!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Generate workout plan from onboarding data
  void _generateWorkoutPlan() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select start date for your plan',
    );
    if (picked == null || !mounted) return;
    final startDate =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

    // Call the API to generate the plan
    ref.read(workoutPlanViewModelProvider.notifier).generatePlan(startDate);

    // Navigate to workout recommendation screen to show the generated plan
    context.push(Routes.workoutRecommendation);
  }
}
