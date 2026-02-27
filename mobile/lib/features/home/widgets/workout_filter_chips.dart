import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class WorkoutFilterChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String>? onSelected;

  const WorkoutFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppDimensions.spacing8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () => onSelected?.call(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing16,
                vertical: AppDimensions.spacing6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.grey900 : Colors.transparent,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusRound),
                border: Border.all(
                  color: isSelected ? AppColors.grey900 : AppColors.grey300,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.grey600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
