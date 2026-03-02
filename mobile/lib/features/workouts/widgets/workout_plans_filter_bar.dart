import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Active filter indicator bar for the Workout Plans screen.
/// Shows a subtle banner when server-side filters are applied,
/// with a smooth animated show/hide transition.
class WorkoutPlansFilterBar extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onClear;

  const WorkoutPlansFilterBar({
    super.key,
    required this.isVisible,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1,
          child: child,
        );
      },
      child: isVisible
          ? Container(
              key: const ValueKey('filter-bar-visible'),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingHorizontal,
                vertical: AppDimensions.spacing8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacing4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Icon(
                      Icons.filter_alt_rounded,
                      size: AppDimensions.iconSmall,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  Expanded(
                    child: Text(
                      'Filters applied',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onClear,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      'Clear',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('filter-bar-hidden')),
    );
  }
}
