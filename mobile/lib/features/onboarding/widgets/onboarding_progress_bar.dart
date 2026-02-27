import 'package:flutter/material.dart';

/// Progress bar showing onboarding completion status
class OnboardingProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final int completedSteps;

  const OnboardingProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.completedSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalSteps > 0 ? (completedSteps / totalSteps) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${(progress * 100).round()}% Complete',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Step indicators
        Row(
          children: List.generate(totalSteps, (index) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < totalSteps - 1 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: index < completedSteps
                      ? theme.colorScheme.primary
                      : index == currentStep
                          ? theme.colorScheme.primary.withValues(alpha: 0.5)
                          : theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
