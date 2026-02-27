import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/states/state_widgets.dart';
import '../../home/widgets/plan_generation_options_sheet.dart';
import '../../home/models/plan_generation_option.dart';
import '../../recommendation/viewmodels/workout_plan_viewmodel.dart';
import '../models/workout_plan_models.dart';
import '../viewmodels/workout_plans_state.dart';
import '../viewmodels/workout_plans_viewmodel.dart';
import '../widgets/workout_plan_card.dart';
import '../widgets/workout_plan_filter_sheet.dart';

/// Workout Plans Screen
/// Shows paginated list of user workout plans with difficulty filter chips.
class WorkoutPlansScreen extends ConsumerStatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  ConsumerState<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends ConsumerState<WorkoutPlansScreen> {
  final _scrollController = ScrollController();

  static const _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutPlansViewModelProvider.notifier).loadPlans();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(workoutPlansViewModelProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(workoutPlansViewModelProvider.notifier).refresh();
  }

  void _showFilterSheet() {
    final currentState = ref.read(workoutPlansViewModelProvider);
    final currentFilter = currentState is WorkoutPlansLoaded 
        ? currentState.appliedFilter 
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => WorkoutPlanFilterSheet(
          initialFilter: currentFilter,
          onApply: (filter) {
            ref.read(workoutPlansViewModelProvider.notifier).applyFilters(filter);
          },
          onClear: () {
            ref.read(workoutPlansViewModelProvider.notifier).clearFilters();
          },
        ),
      ),
    );
  }

  Future<void> _handleDuplicate(int planId, String newName) async {
    try {
      await ref.read(workoutPlansViewModelProvider.notifier).duplicatePlan(planId, newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Workout plan duplicated successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to duplicate plan: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(int planId) async {
    try {
      await ref.read(workoutPlansViewModelProvider.notifier).deletePlan(planId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Workout plan deleted successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete plan: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleToggleActive(int planId) async {
    try {
      await ref.read(workoutPlansViewModelProvider.notifier).togglePlanActive(planId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle active status: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(workoutPlansViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Workout Levels',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.grey700),
            onPressed: _showPlanGenerationOptionsSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter indicator
          if (state is WorkoutPlansLoaded && state.appliedFilter != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingHorizontal,
                vertical: AppDimensions.spacing8,
              ),
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.filter_alt, size: AppDimensions.iconSmall, color: AppColors.primary),
                  const SizedBox(width: AppDimensions.spacing8),
                  Text(
                    'Filters applied',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.read(workoutPlansViewModelProvider.notifier).clearFilters();
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),

          // Difficulty filter chips
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingHorizontal,
              vertical: AppDimensions.spacing2,
            ),
            child: state.maybeWhen(
              loaded: (plans, currentPage, totalPages, hasMore,
                      selectedDifficulty, appliedFilter) =>
                  _buildDifficultyChips(
                      context, theme, colorScheme, selectedDifficulty),
              orElse: () =>
                  _buildDifficultyChips(context, theme, colorScheme, null),
            ),
          ),

          const SizedBox(height: AppDimensions.spacing8),

          // Content
          Expanded(
            child: state.when(
              initial: () => Center(
                child: Text(
                  'Loading workout plans...',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              loading: () => Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              ),
              loaded:
                  (plans, currentPage, totalPages, hasMore, selectedDifficulty, appliedFilter) {
                // Check if there are any active plans
                final hasActivePlans = plans.any((p) => p.isActive);

                // If no active plans, show generate button
                if (!hasActivePlans) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.screenPaddingHorizontal,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 80,
                            color: AppColors.grey300,
                          ),
                          const SizedBox(height: AppDimensions.spacing24),
                          Text(
                            'No Active Workout Plan',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacing8),
                          Text(
                            'Generate your first workout plan to get started',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.spacing32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _showPlanGenerationOptionsSheet,
                              icon: Icon(Icons.auto_awesome),
                              label: Text(
                                'Generate Your First Workout',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Client-side filter by difficulty
                final filteredPlans = selectedDifficulty == null
                    ? plans
                    : plans
                        .where((p) =>
                            p.difficultyLevel?.toUpperCase() ==
                            selectedDifficulty.toUpperCase())
                        .toList();

                if (filteredPlans.isEmpty) {
                  return EmptyState(
                    icon: Icons.fitness_center,
                    title: 'No workout plans found',
                    description: selectedDifficulty != null
                        ? 'No $selectedDifficulty plans available'
                        : 'Create your first workout plan to get started',
                  );
                }

                return RefreshIndicator(
                  color: colorScheme.primary,
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.screenPaddingVertical,
                    ),
                    itemCount: filteredPlans.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= filteredPlans.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(
                                AppDimensions.spacing16),
                            child: CircularProgressIndicator(
                                color: colorScheme.primary),
                          ),
                        );
                      }

                      final plan = filteredPlans[index];
                      return WorkoutPlanCard(
                        plan: plan,
                        onTap: () {
                          context.push(
                              Routes.workoutPlanDetail(plan.planId));
                        },
                        onToggleActive: () => _handleToggleActive(plan.planId),
                        onDuplicate: (newName) => _handleDuplicate(plan.planId, newName),
                        onDelete: () => _handleDelete(plan.planId),
                      );
                    },
                  ),
                );
              },
              error: (message) => ErrorState(
                message: message,
                onRetry: () => ref
                    .read(workoutPlansViewModelProvider.notifier)
                    .loadPlans(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChips(BuildContext context, ThemeData theme,
      ColorScheme colorScheme, String? selectedDifficulty) {
    final state = ref.watch(workoutPlansViewModelProvider);
    final hasFilter = state is WorkoutPlansLoaded && state.appliedFilter != null;

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _difficulties.map((difficulty) {
                final isSelected = selectedDifficulty == difficulty;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.spacing6),
                  child: FilterChip(
                    label: Text(
                      difficulty,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.grey700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      ref
                          .read(workoutPlansViewModelProvider.notifier)
                          .selectDifficulty(difficulty);
                    },
                    backgroundColor: AppColors.white,
                    selectedColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.grey300,
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing6,
                      vertical: AppDimensions.spacing6,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: hasFilter ? AppColors.primary : AppColors.grey700,
          ),
          onPressed: _showFilterSheet,
        ),
      ],
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
          if (option == PlanGenerationOption.createOwn) {
            context.push(Routes.createWorkoutPlan);
          } else if (option == PlanGenerationOption.fromOnboarding) {
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
