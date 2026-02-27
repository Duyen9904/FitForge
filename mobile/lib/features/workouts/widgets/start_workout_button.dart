import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/workout_plan_models.dart';

/// Start workout button widget.
class StartWorkoutButton extends StatelessWidget {
  final WorkoutSessionResponse? loadedSession;

  const StartWorkoutButton({
    super.key,
    this.loadedSession,
  });

  @override
  Widget build(BuildContext context) {
    if (loadedSession == null) {
      return const SizedBox.shrink();
    }

    if (loadedSession!.isRestDay) {
      return const SizedBox.shrink();
    }

    final isCompleted = loadedSession!.isCompleted;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing20,
        AppDimensions.spacing12,
        AppDimensions.spacing20,
        AppDimensions.spacing24,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.grey200,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeightLarge,
          child: isCompleted
              ? Center(
                  child: Text(
                    'Workout completed for today',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    context.push(
                      Routes.workoutActivity,
                      extra: {
                        'sessionId': loadedSession?.sessionId,
                        'sessionName': loadedSession?.sessionName,
                        'exercises': loadedSession?.exercises ?? [],
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'START WORKOUT',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                ),
        ),
      ),
    );
  }
}
