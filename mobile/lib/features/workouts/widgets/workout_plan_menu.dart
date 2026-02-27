import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/workout_plan_models.dart';

/// Reusable popup menu for workout plan actions
class WorkoutPlanMenu extends StatelessWidget {
  final WorkoutPlanSummaryResponse plan;
  final Function(String) onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const WorkoutPlanMenu({
    super.key,
    required this.plan,
    required this.onDuplicate,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppColors.grey700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      offset: const Offset(0, 40),
      onSelected: (value) async {
        switch (value) {
          case 'duplicate':
            await _showDuplicateDialog(context);
            break;
          case 'delete':
            await _showDeleteConfirmation(context);
            break;
          case 'edit':
            onEdit?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.copy, size: AppDimensions.iconSmall, color: AppColors.grey700),
              const SizedBox(width: AppDimensions.spacing12),
              const Text('Duplicate'),
            ],
          ),
        ),
        if (onEdit != null)
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: AppDimensions.iconSmall, color: AppColors.grey700),
                const SizedBox(width: AppDimensions.spacing12),
                const Text('Edit'),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: AppDimensions.iconSmall, color: AppColors.error),
              const SizedBox(width: AppDimensions.spacing12),
              Text('Delete', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showDuplicateDialog(BuildContext context) async {
    final controller = TextEditingController(text: '${plan.planName} Copy');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate Workout Plan'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'New Plan Name',
              hintText: 'Enter a name for the duplicated plan',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a plan name';
              }
              return null;
            },
            maxLength: 100,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      onDuplicate(result);
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this workout plan?'),
            const SizedBox(height: AppDimensions.spacing12),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing12),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, color: AppColors.primary, size: AppDimensions.iconSmall),
                  const SizedBox(width: AppDimensions.spacing8),
                  Expanded(
                    child: Text(
                      plan.planName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      onDelete();
    }
  }
}
