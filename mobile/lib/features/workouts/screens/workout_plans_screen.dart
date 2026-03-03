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
import '../viewmodels/workout_plans_state.dart';
import '../viewmodels/workout_plans_viewmodel.dart';
import '../widgets/workout_plans_header.dart';
import '../widgets/workout_plans_filter_bar.dart';
import '../widgets/workout_plans_difficulty_chips.dart';
import '../widgets/workout_plans_empty_state.dart';
import '../widgets/workout_plans_list.dart';
import '../widgets/workout_plan_filter_sheet.dart';

/// Workout Plans Screen
/// Premium paginated list of user workout plans with a gradient collapsing
/// header, difficulty chips, shimmer loading, and entrance animations.
class WorkoutPlansScreen extends ConsumerStatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  ConsumerState<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends ConsumerState<WorkoutPlansScreen> {
  final _scrollController = ScrollController();

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

  // ─── Scroll & Data Handlers ───────────────────────────────────

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(workoutPlansViewModelProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(workoutPlansViewModelProvider.notifier).refresh();
  }

  Future<void> _handleToggleActive(int planId) async {
    try {
      await ref
          .read(workoutPlansViewModelProvider.notifier)
          .togglePlanActive(planId);
    } catch (e) {
      if (mounted) _showErrorSnackbar('Failed to toggle active status: $e');
    }
  }

  Future<void> _handleDuplicate(int planId, String newName) async {
    try {
      await ref
          .read(workoutPlansViewModelProvider.notifier)
          .duplicatePlan(planId, newName);
      if (mounted) _showSuccessSnackbar('Workout plan duplicated successfully');
    } catch (e) {
      if (mounted) _showErrorSnackbar('Failed to duplicate plan: $e');
    }
  }

  Future<void> _handleDelete(int planId) async {
    try {
      await ref
          .read(workoutPlansViewModelProvider.notifier)
          .deletePlan(planId);
      if (mounted) _showSuccessSnackbar('Workout plan deleted successfully');
    } catch (e) {
      if (mounted) _showErrorSnackbar('Failed to delete plan: $e');
    }
  }

  // ─── Snackbar Helpers ─────────────────────────────────────────

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Bottom Sheet & Dialog Handlers ───────────────────────────

  void _showFilterSheet() {
    final currentState = ref.read(workoutPlansViewModelProvider);
    final currentFilter =
        currentState is WorkoutPlansLoaded ? currentState.appliedFilter : null;

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
            ref
                .read(workoutPlansViewModelProvider.notifier)
                .applyFilters(filter);
          },
          onClear: () {
            ref.read(workoutPlansViewModelProvider.notifier).clearFilters();
          },
        ),
      ),
    );
  }

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
          } else if (option == PlanGenerationOption.customAI) {
            context.push(Routes.generateAIPlan);
          } else {
            _showComingSoonSnackbar(option);
          }
        },
      ),
    );
  }

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
    ref.read(workoutPlanViewModelProvider.notifier).generatePlan(startDate);
    context.push(Routes.workoutRecommendation);
  }

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutPlansViewModelProvider);

    return Scaffold(
      body: _buildBody(state),
    );
  }

  Widget _buildBody(WorkoutPlansState state) {
    final loadedState = state is WorkoutPlansLoaded ? state : null;
    final selectedDifficulty = loadedState?.selectedDifficulty;
    final appliedFilter = loadedState?.appliedFilter;

    Widget content = state.when(
      initial: () => const WorkoutPlansShimmer(),
      loading: () => const WorkoutPlansShimmer(),
      loaded: (plans, currentPage, totalPages, hasMore, selectedDifficulty,
          appliedFilter) {
        final hasActivePlans = plans.any((p) => p.isActive);

        if (!hasActivePlans) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: WorkoutPlansEmptyState(
              hasPlans: plans.isNotEmpty,
              onGeneratePlan: _showPlanGenerationOptionsSheet,
            ),
          );
        }

        return WorkoutPlansList(
          plans: plans,
          hasMore: hasMore,
          selectedDifficulty: selectedDifficulty,
          scrollController: _scrollController,
          onRefresh: _onRefresh,
          onToggleActive: () {},
          onToggleActivePlan: _handleToggleActive,
          onDuplicatePlan: _handleDuplicate,
          onDeletePlan: _handleDelete,
        );
      },
      error: (message) => SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          message: message,
          onRetry: () =>
              ref.read(workoutPlansViewModelProvider.notifier).loadPlans(),
        ),
      ),
    );

    Widget body = CustomScrollView(
      controller: _scrollController,
      slivers: [
        WorkoutPlansHeader(
          onAddPressed: _showPlanGenerationOptionsSheet,
        ),
        SliverToBoxAdapter(
          child: WorkoutPlansFilterBar(
            isVisible: appliedFilter != null,
            onClear: () {
              ref.read(workoutPlansViewModelProvider.notifier).clearFilters();
            },
          ),
        ),
        SliverToBoxAdapter(
          child: WorkoutPlansDifficultyChips(
            selectedDifficulty: selectedDifficulty,
            hasActiveFilter: appliedFilter != null,
            onDifficultySelected: (difficulty) {
              ref
                  .read(workoutPlansViewModelProvider.notifier)
                  .selectDifficulty(difficulty);
            },
            onFilterTap: _showFilterSheet,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppDimensions.spacing8),
        ),
        content,
        const SliverToBoxAdapter(
          child: SizedBox(height: AppDimensions.screenPaddingVertical),
        ),
      ],
    );

    if (loadedState != null && loadedState.plans.any((p) => p.isActive)) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _onRefresh,
        child: body,
      );
    }

    return body;
  }
}
