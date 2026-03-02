import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../viewmodels/create_workout_plan_viewmodel.dart';

/// Bottom navigation buttons (Back / Next / Create) for the plan wizard
class PlanWizardBottomButtons extends ConsumerWidget {
  final int currentStep;
  final CreateWorkoutPlanViewModel vm;

  const PlanWizardBottomButtons({
    super.key,
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

            // Next / Create / Save button
            Expanded(
              flex: 1,
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
                          const Icon(Icons.check, size: 20),
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
