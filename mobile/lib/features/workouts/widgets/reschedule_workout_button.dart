import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/workout_plan_models.dart';

/// Reschedule workout button widget.
/// Shows when the session is not completed and not a rest day.
class RescheduleWorkoutButton extends StatelessWidget {
  final WorkoutSessionResponse? loadedSession;
  final Future<void> Function(DateTime newDate)? onReschedule;

  const RescheduleWorkoutButton({
    super.key,
    this.loadedSession,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    if (loadedSession == null) return const SizedBox.shrink();
    if (loadedSession!.isRestDay) return const SizedBox.shrink();
    if (loadedSession!.isCompleted) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing20,
        vertical: AppDimensions.spacing8,
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppDimensions.buttonHeightLarge,
        child: OutlinedButton.icon(
          onPressed: () => _showDatePicker(context),
          icon: const Icon(Icons.calendar_month_outlined, size: 20),
          label: Text(
            loadedSession!.isMissed ? 'RESCHEDULE MISSED' : 'RESCHEDULE',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: loadedSession!.isMissed
                ? AppColors.warning
                : AppColors.primary,
            side: BorderSide(
              color: loadedSession!.isMissed
                  ? AppColors.warning
                  : AppColors.primary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Select new workout date',
    );

    if (pickedDate != null && onReschedule != null) {
      try {
        await onReschedule!(pickedDate);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Workout rescheduled successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reschedule: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
