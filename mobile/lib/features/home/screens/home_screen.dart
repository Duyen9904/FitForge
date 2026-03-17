import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../recommendation/viewmodels/workout_plan_viewmodel.dart';
import '../../workouts/viewmodels/workout_plans_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/home_state.dart';
import '../widgets/welcome_header.dart';

import '../widgets/todays_workout_card.dart';
import '../widgets/home_categories_section.dart';
import '../widgets/active_plans_section.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/plan_generation_options_sheet.dart';
import '../models/plan_generation_option.dart';
import '../models/home_dashboard_models.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).loadDashboard();
      ref.read(workoutPlansViewModelProvider.notifier).loadPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final homeState = ref.watch(homeViewModelProvider);
    final workoutPlansState = ref.watch(workoutPlansViewModelProvider);

    final userName = authState.maybeWhen(
      authenticated: (user) => user.username,
      orElse: () => 'User',
    );

    final hasPlans = workoutPlansState.maybeWhen(
      loaded: (plans, _, __, ___, ____, _____) => plans.isNotEmpty,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(homeViewModelProvider.notifier).refresh();
            ref.read(workoutPlansViewModelProvider.notifier).loadPlans();
          },
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
                WelcomeHeader(
                  userName: userName,
                  onAvatarTap: () => context.go(Routes.profile),
                ),
                const SizedBox(height: AppDimensions.spacing24),

                // 2. Today's Workout Hero Card
                _buildTodaysWorkout(homeState, hasPlans),
                const SizedBox(height: AppDimensions.spacing20),

                // 3. Categories
                const HomeCategoriesSection(),
                const SizedBox(height: AppDimensions.spacing24),


                // 5. Active Plans Section
                _buildActivePlans(homeState),

                // 6. Quick Actions Grid
                QuickActionsGrid(
                  onBrowseExercises: () => context.push(Routes.exercises),
                  onLogMeasurement: () => context.push(Routes.recordMeasurement),
                  onNutrition: () => context.push(Routes.nutrition),
                  onWorkoutHistory: () => context.push(Routes.workouts),
                ),
                const SizedBox(height: AppDimensions.spacing24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Compute overall progress from active plans (0.0 – 1.0).
  double _computeProgress(List<ActivePlanInfo>? activePlans) {
    if (activePlans == null || activePlans.isEmpty) return 0.0;
    final plan = activePlans.first;
    final total = plan.totalSessions;
    if (total == 0) return 0.0;
    return (plan.sessionsCompleted / total).clamp(0.0, 1.0);
  }

  /// Today's workout hero card
  Widget _buildTodaysWorkout(HomeState homeState, bool hasPlans) {
    return homeState.when(
      initial: () => TodaysWorkoutCard(
        hasPlans: hasPlans,
        onGeneratePlan: _showPlanGenerationOptionsSheet,
      ),
      loading: () => Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      loaded: (_, __, dashboard) {
        final plans = dashboard?.activePlans ?? [];
        return TodaysWorkoutCard(
          session: dashboard?.todaySession,
          hasPlans: hasPlans || plans.isNotEmpty,
          progress: _computeProgress(plans),
          onStartWorkout: () {
            final session = dashboard?.todaySession;
            if (session != null && session.planId != null) {
              context.push(Routes.workoutPlanDetail(session.planId!));
            }
          },
          onGeneratePlan: _showPlanGenerationOptionsSheet,
        );
      },
      error: (_) => TodaysWorkoutCard(
        hasPlans: hasPlans,
        onGeneratePlan: _showPlanGenerationOptionsSheet,
      ),
    );
  }





  /// Active plans section
  Widget _buildActivePlans(HomeState homeState) {
    return homeState.maybeWhen(
      loaded: (_, __, dashboard) {
        final plans = dashboard?.activePlans ?? [];
        if (plans.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacing24),
          child: ActivePlansSection(
            plans: plans,
            onSeeAll: () => context.push(Routes.workouts),
            onPlanTap: (planId) => context.push(Routes.workoutPlanDetail(planId)),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
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
          } else if (option == PlanGenerationOption.customAI) {
            context.push(Routes.generateAIPlan);
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
