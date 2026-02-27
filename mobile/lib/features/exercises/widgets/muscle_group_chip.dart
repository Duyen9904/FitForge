import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Chip widget to display muscle group
class MuscleGroupChip extends StatelessWidget {
  final String groupName;
  final bool isPrimary;
  final bool compact;

  const MuscleGroupChip({
    super.key,
    required this.groupName,
    this.isPrimary = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing8,
              vertical: AppDimensions.spacing4,
            )
          : const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing12,
              vertical: AppDimensions.spacing6,
            ),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.grey200,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius16),
        border: isPrimary
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fitness_center,
            size: compact ? 12 : 14,
            color: isPrimary ? AppColors.primary : AppColors.grey600,
          ),
          const SizedBox(width: AppDimensions.spacing4),
          Text(
            groupName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isPrimary ? AppColors.primary : AppColors.grey700,
                  fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                  fontSize: compact ? 10 : 12,
                ),
          ),
        ],
      ),
    );
  }
}
