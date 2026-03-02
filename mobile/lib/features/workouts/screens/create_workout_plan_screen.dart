import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../viewmodels/create_workout_plan_viewmodel.dart';
import '../viewmodels/create_workout_plan_state.dart';
import '../widgets/create_plan_steps/plan_details_step.dart';
import '../widgets/create_plan_steps/sessions_step.dart';
import '../widgets/create_plan_steps/exercises_step.dart';
import '../widgets/create_plan_steps/plan_wizard_step_indicator.dart';
import '../widgets/create_plan_steps/plan_wizard_bottom_buttons.dart';

/// Multi-step screen for manually creating a workout plan.
class CreateWorkoutPlanScreen extends StatelessWidget {
  const CreateWorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WizardBody();
  }
}

/// The actual wizard body — reads from activeWorkoutPlanViewModelProvider
class _WizardBody extends ConsumerWidget {
  const _WizardBody();

  static const _stepTitles = [
    'Plan Details',
    'Sessions',
    'Exercises',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(activeWorkoutPlanViewModelProvider);
    final vm = ref.read(activeWorkoutPlanViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.grey700),
          onPressed: () => _showDiscardDialog(context),
        ),
        title: Text(
          'Create Workout Plan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: state.when(
        editing: (currentStep, planName, description, goalId,
            targetMuscleGroup, difficultyLevel, frequencyPerWeek,
            durationWeeks, startDate, sessions) {
          return Column(
            children: [
              PlanWizardStepIndicator(
                currentStep: currentStep,
                stepTitles: _stepTitles,
              ),
              Expanded(
                child: IndexedStack(
                  index: currentStep,
                  children: const [
                    PlanDetailsStep(),
                    SessionsStep(),
                    ExercisesStep(),
                  ],
                ),
              ),
              PlanWizardBottomButtons(
                currentStep: currentStep,
                vm: vm,
              ),
            ],
          );
        },
        submitting: (message) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
        success: (resultPlanId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Workout plan created successfully! 🎉'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/workouts/$resultPlanId');
          });
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 64),
                const SizedBox(height: AppDimensions.spacing16),
                Text(
                  'Plan Created!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
        error: (message) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 64),
                const SizedBox(height: AppDimensions.spacing16),
                Text(
                  'Failed to Create Plan',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacing24),
                ElevatedButton.icon(
                  onPressed: vm.retryFromError,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing24,
                      vertical: AppDimensions.spacing12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Discard Plan?'),
        content: const Text(
          'Are you sure you want to discard this workout plan? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}
