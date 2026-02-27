import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/exercise_models.dart';

/// List item widget to display equipment
class EquipmentListItem extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback? onTap;

  const EquipmentListItem({
    super.key,
    required this.equipment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadius8),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacing8),
        padding: const EdgeInsets.all(AppDimensions.spacing12),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius8),
        ),
        child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacing8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getEquipmentIcon(equipment.equipmentType),
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipment.equipmentName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (equipment.description != null) ...[
                  const SizedBox(height: AppDimensions.spacing4),
                  Text(
                    equipment.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  IconData _getEquipmentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'barbell':
        return Icons.fitness_center;
      case 'dumbbell':
        return Icons.fitness_center;
      case 'machine':
        return Icons.sports_gymnastics;
      case 'bodyweight':
        return Icons.accessibility_new;
      case 'cable':
        return Icons.cable;
      case 'band':
        return Icons.sports_martial_arts;
      default:
        return Icons.fitness_center;
    }
  }
}
