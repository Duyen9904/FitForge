import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/exercise_category_response.dart';

/// Card widget for displaying an exercise category (muscle group)
class ExerciseCategoryCard extends StatelessWidget {
  final ExerciseCategoryResponse category;
  final VoidCallback onTap;

  const ExerciseCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visualData = _getCategoryVisualData(category.categoryName);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing6,
      ),
      child: Material(
        color: visualData.backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          child: Container(
            height: 100,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing20,
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: visualData.iconBackgroundColor,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusLarge),
                  ),
                  child: Icon(
                    visualData.icon,
                    size: 28,
                    color: visualData.iconColor,
                  ),
                ),

                const SizedBox(width: AppDimensions.spacing16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatCategoryName(category.categoryName),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.grey900,
                                ),
                      ),
                      const SizedBox(height: AppDimensions.spacing4),
                      Text(
                        '${category.exerciseCount} Exercises',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.grey500,
                                ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: AppColors.grey400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCategoryName(String name) {
    if (name.isEmpty) return name;
    // Handle names like "UPPER_BODY" → "Upper Body"
    return name
        .split(RegExp(r'[_\s]+'))
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  _CategoryVisualData _getCategoryVisualData(String categoryName) {
    switch (categoryName.toUpperCase()) {
      case 'CHEST':
        return _CategoryVisualData(
          backgroundColor: const Color(0xFFFFE4EC),
          iconBackgroundColor: const Color(0xFFFFCDD9),
          iconColor: const Color(0xFFC62828),
          icon: Icons.fitness_center,
        );
      case 'BACK':
        return _CategoryVisualData(
          backgroundColor: const Color(0xFFE8E4F8),
          iconBackgroundColor: const Color(0xFFD3CCF0),
          iconColor: AppColors.primaryDark,
          icon: Icons.straighten,
        );
      case 'SHOULDERS':
        return _CategoryVisualData(
          backgroundColor: const Color(0xFFFFF3E0),
          iconBackgroundColor: const Color(0xFFFFE0B2),
          iconColor: const Color(0xFFE65100),
          icon: Icons.accessibility_new,
        );
      case 'LEGS':
        return _CategoryVisualData(
          backgroundColor: const Color(0xFFE0F7FA),
          iconBackgroundColor: const Color(0xFFB2EBF2),
          iconColor: const Color(0xFF00838F),
          icon: Icons.directions_walk,
        );
      case 'ARMS':
      case 'BICEPS':
      case 'TRICEPS':
        return _CategoryVisualData(
          backgroundColor: const Color(0xFFE8F5E9),
          iconBackgroundColor: const Color(0xFFC8E6C9),
          iconColor: const Color(0xFF2E7D32),
          icon: Icons.sports_gymnastics,
        );
      case 'CORE':
      case 'ABS':
      case 'ABDOMINALS':
        return _CategoryVisualData(
          backgroundColor: const Color(0xFFFCE4EC),
          iconBackgroundColor: const Color(0xFFF8BBD0),
          iconColor: const Color(0xFFAD1457),
          icon: Icons.view_stream,
        );
      case 'GLUTES':
        return _CategoryVisualData(
          backgroundColor: const Color(0xFFF3E5F5),
          iconBackgroundColor: const Color(0xFFE1BEE7),
          iconColor: const Color(0xFF6A1B9A),
          icon: Icons.airline_seat_recline_extra,
        );
      case 'FULL_BODY':
      case 'FULL BODY':
        return _CategoryVisualData(
          backgroundColor: const Color(0xFFE3F2FD),
          iconBackgroundColor: const Color(0xFFBBDEFB),
          iconColor: const Color(0xFF1565C0),
          icon: Icons.person,
        );
      default:
        return _CategoryVisualData(
          backgroundColor: AppColors.grey100,
          iconBackgroundColor: AppColors.grey200,
          iconColor: AppColors.grey600,
          icon: Icons.sports,
        );
    }
  }
}

class _CategoryVisualData {
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final IconData icon;

  _CategoryVisualData({
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.icon,
  });
}
