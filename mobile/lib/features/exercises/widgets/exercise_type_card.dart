import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/exercise_type_response.dart';

/// Card widget for displaying an exercise type/category
/// Matches the design with a colored background, image area, and type info
class ExerciseTypeCard extends StatelessWidget {
  final ExerciseTypeResponse exerciseType;
  final VoidCallback onTap;

  const ExerciseTypeCard({
    super.key,
    required this.exerciseType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeData = _getTypeVisualData(exerciseType.typeName);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing6,
      ),
      child: Material(
        color: typeData.backgroundColor,
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
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTypeName(exerciseType.typeName),
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.grey900,
                                ),
                      ),
                    ],
                  ),
                ),

                // Icon placeholder
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: typeData.iconBackgroundColor,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusLarge),
                  ),
                  child: Icon(
                    typeData.icon,
                    size: 36,
                    color: typeData.iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTypeName(String typeName) {
    // Convert "STRENGTH" or "strength" → "Strength"
    if (typeName.isEmpty) return typeName;
    return typeName[0].toUpperCase() +
        typeName.substring(1).toLowerCase();
  }

  _TypeVisualData _getTypeVisualData(String typeName) {
    switch (typeName.toUpperCase()) {
      case 'STRENGTH':
        return _TypeVisualData(
          backgroundColor: const Color(0xFFE8E4F8),
          iconBackgroundColor: const Color(0xFFD3CCF0),
          iconColor: AppColors.primaryDark,
          icon: Icons.fitness_center,
        );
      case 'CARDIO':
        return _TypeVisualData(
          backgroundColor: const Color(0xFFFFE4EC),
          iconBackgroundColor: const Color(0xFFFFCDD9),
          iconColor: AppColors.accentDark,
          icon: Icons.directions_run,
        );
      case 'FLEXIBILITY':
        return _TypeVisualData(
          backgroundColor: const Color(0xFFE0F7FA),
          iconBackgroundColor: const Color(0xFFB2EBF2),
          iconColor: const Color(0xFF00838F),
          icon: Icons.self_improvement,
        );
      case 'BALANCE':
        return _TypeVisualData(
          backgroundColor: const Color(0xFFFFF3E0),
          iconBackgroundColor: const Color(0xFFFFE0B2),
          iconColor: const Color(0xFFE65100),
          icon: Icons.accessibility_new,
        );
      default:
        return _TypeVisualData(
          backgroundColor: AppColors.grey100,
          iconBackgroundColor: AppColors.grey200,
          iconColor: AppColors.grey600,
          icon: Icons.sports,
        );
    }
  }
}

class _TypeVisualData {
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final IconData icon;

  _TypeVisualData({
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.icon,
  });
}
