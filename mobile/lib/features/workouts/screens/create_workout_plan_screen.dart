import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../viewmodels/create_workout_plan_viewmodel.dart';
import '../widgets/create_plan_steps/plan_details_step.dart';
import '../widgets/create_plan_steps/sessions_step.dart';
import '../widgets/create_plan_steps/exercises_step.dart';

/// Multi-step screen for manually creating a workout plan
class CreateWorkoutPlanScreen extends ConsumerWidget {
  const CreateWorkoutPlanScreen({super.key});

  static const _stepTitles = [
    'Plan Details',
    'Sessions',
    'Exercises',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(createWorkoutPlanViewModelProvider);
    final vm = ref.read(createWorkoutPlanViewModelProvider.notifier);

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
              // Step indicator
              _StepIndicator(
                currentStep: currentStep,
                stepTitles: _stepTitles,
              ),

              // Step content
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

              // Bottom navigation buttons
              _BottomButtons(
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
        success: (planId) {
          // Navigate after build completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Workout plan created successfully! 🎉'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/workouts/$planId');
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

/// Step indicator dots/labels at the top
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;

  const _StepIndicator({
    required this.currentStep,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing24,
        vertical: AppDimensions.spacing16,
      ),
      child: Row(
        children: List.generate(stepTitles.length, (index) {
          final isActive = index <= currentStep;
          final isCurrent = index == currentStep;

          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isActive ? AppColors.primary : AppColors.grey200,
                    ),
                  ),
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: isActive ? AppColors.primaryGradient : null,
                        color: isActive ? null : AppColors.grey200,
                        shape: BoxShape.circle,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isActive
                                ? AppColors.white
                                : AppColors.grey500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stepTitles[index],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            isCurrent ? AppColors.primary : AppColors.grey500,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                if (index < stepTitles.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index < currentStep
                          ? AppColors.primary
                          : AppColors.grey200,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Bottom navigation buttons (Back / Next / Create)
class _BottomButtons extends ConsumerWidget {
  final int currentStep;
  final CreateWorkoutPlanViewModel vm;

  const _BottomButtons({
    required this.currentStep,
    required this.vm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            if (currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: vm.previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.grey700,
                    side: BorderSide(color: AppColors.grey300),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacing16),
                  ),
                  child: const Text('Back'),
                ),
              ),
            if (currentStep > 0)
              const SizedBox(width: AppDimensions.spacing12),

            // Next / Create button
            Expanded(
              flex: currentStep == 0 ? 1 : 1,
              child: currentStep < 2
                  ? ElevatedButton(
                      onPressed: _canProceed(ref)
                          ? vm.nextStep
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.grey200,
                        disabledForegroundColor: AppColors.grey400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLarge),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.spacing16),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: _canProceed(ref)
                                  ? AppColors.white
                                  : AppColors.grey400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: _canProceed(ref)
                                ? AppColors.white
                                : AppColors.grey400,
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => vm.submitAll(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLarge),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.spacing16),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            'Create Plan',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed(WidgetRef ref) {
    if (currentStep == 0) {
      return vm.isStep1Valid();
    } else if (currentStep == 1) {
      return vm.isStep2Valid();
    }
    return true;
  }
}
