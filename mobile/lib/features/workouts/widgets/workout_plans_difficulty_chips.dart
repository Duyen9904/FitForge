import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Horizontal difficulty filter chips row for the Workout Plans screen.
/// Includes "All", "Beginner", "Intermediate", "Advanced" chips and
/// a filter icon button that highlights when server-side filters are active.
class WorkoutPlansDifficultyChips extends StatelessWidget {
  final String? selectedDifficulty;
  final bool hasActiveFilter;
  final ValueChanged<String?> onDifficultySelected;
  final VoidCallback onFilterTap;

  const WorkoutPlansDifficultyChips({
    super.key,
    this.selectedDifficulty,
    this.hasActiveFilter = false,
    required this.onDifficultySelected,
    required this.onFilterTap,
  });

  static const _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
        vertical: AppDimensions.spacing4,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // "All" chip
                  _buildChip(
                    context,
                    theme: theme,
                    label: 'All',
                    isSelected: selectedDifficulty == null,
                    onTap: () => onDifficultySelected(null),
                  ),
                  const SizedBox(width: AppDimensions.spacing6),
                  // Difficulty chips
                  ..._difficulties.map((difficulty) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(right: AppDimensions.spacing6),
                      child: _buildChip(
                        context,
                        theme: theme,
                        label: difficulty,
                        isSelected: selectedDifficulty == difficulty,
                        onTap: () => onDifficultySelected(difficulty),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Filter button
          Container(
            decoration: BoxDecoration(
              color: hasActiveFilter
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune_rounded,
                color: hasActiveFilter ? AppColors.primary : AppColors.grey500,
                size: 22,
              ),
              onPressed: onFilterTap,
              tooltip: 'Advanced Filters',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required ThemeData theme,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: FilterChip(
        label: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? AppColors.white : AppColors.grey700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: AppColors.white,
        selectedColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.grey300,
          ),
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing8,
          vertical: AppDimensions.spacing6,
        ),
      ),
    );
  }
}
