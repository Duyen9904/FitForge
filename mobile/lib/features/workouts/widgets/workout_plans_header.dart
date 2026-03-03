import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Header for the Workout Plans screen.
/// Displays the title and an add button.
class WorkoutPlansHeader extends StatelessWidget {
  final VoidCallback onAddPressed;

  const WorkoutPlansHeader({
    super.key,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      floating: false,
      pinned: true,
      surfaceTintColor: Colors.transparent,
      title: Text(
        'My Plans',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppDimensions.spacing8),
          child: IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: onAddPressed,
            tooltip: 'Create New Plan',
          ),
        ),
      ],
    );
  }
}
