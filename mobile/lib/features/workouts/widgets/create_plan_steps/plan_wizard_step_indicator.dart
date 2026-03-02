import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Step indicator dots/labels at the top of the plan wizard
class PlanWizardStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;

  const PlanWizardStepIndicator({
    super.key,
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
