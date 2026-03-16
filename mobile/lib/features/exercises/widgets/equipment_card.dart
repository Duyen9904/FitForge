import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/exercise_models.dart';

/// Card widget to display equipment in list
class EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback onTap;

  const EquipmentCard({
    super.key,
    required this.equipment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Row(
            children: [
              // Icon based on equipment type
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacing12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getEquipmentIcon(equipment.equipmentType),
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.equipmentName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              const SizedBox(width: AppDimensions.spacing8),
              Image.network(
                equipment.imageUrl,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 40,
                  height: 40,
                  color: AppColors.grey200,
                  child: const Icon(
                    Icons.fitness_center,
                    size: 24,
                    color: AppColors.grey400,
                  ),
                ),
              ),
            ],
          ),
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
