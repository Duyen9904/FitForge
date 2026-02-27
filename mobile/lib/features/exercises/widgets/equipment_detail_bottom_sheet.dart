import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/buttons/app_buttons.dart';
import '../models/exercise_models.dart';

/// Bottom sheet widget to display equipment details
class EquipmentDetailBottomSheet extends StatelessWidget {
  final Equipment equipment;

  const EquipmentDetailBottomSheet({
    super.key,
    required this.equipment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppDimensions.spacing24,
        left: AppDimensions.spacing24,
        right: AppDimensions.spacing24,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            AppDimensions.spacing24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadius20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with icon and close button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacing12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getEquipmentIcon(equipment.equipmentType),
                  size: 32,
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      equipment.equipmentType,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey600,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),
          
          const Divider(),
          const SizedBox(height: AppDimensions.spacing16),

          // Description
          if (equipment.description != null && equipment.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacing16),
              child: Text(
                equipment.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

          // View Exercises button
          PrimaryButton(
            text: 'View Exercises Using This Equipment',
            icon: Icons.fitness_center,
            onPressed: () {
              Navigator.pop(context);
              // Navigate to equipment exercises screen
              context.push(
                '/equipment/${equipment.equipmentId}/exercises',
                extra: equipment.equipmentName,
              );
            },
          ),
        ],
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
