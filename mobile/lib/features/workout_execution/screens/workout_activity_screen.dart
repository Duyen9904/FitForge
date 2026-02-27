import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../../workouts/models/workout_plan_models.dart';
import '../widgets/workout_exercise_tile.dart';

/// Workout Activity Screen
/// Displays the list of exercises for a session.
/// Receives sessionId and exercises from the workout plan detail screen.
class WorkoutActivityScreen extends StatelessWidget {
  final int? sessionId;
  final String? sessionName;
  final List<SessionExerciseResponse> exercises;

  const WorkoutActivityScreen({
    super.key,
    this.sessionId,
    this.sessionName,
    this.exercises = const [],
  });

  @override
  Widget build(BuildContext context) {
    final sortedExercises = List<SessionExerciseResponse>.from(exercises)
      ..sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Exercise list
          Expanded(
            child: sortedExercises.isEmpty
                ? Center(
                    child: Text(
                      'No exercises in this session',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.grey500,
                          ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacing16,
                    ),
                    itemCount: sortedExercises.length,
                    separatorBuilder: (_, __) => Divider(
                      color: AppColors.grey200,
                      height: 1,
                      indent: AppDimensions.spacing16,
                      endIndent: AppDimensions.spacing16,
                    ),
                    itemBuilder: (context, index) {
                      final sessionExercise = sortedExercises[index];
                      final exercise = sessionExercise.exercise;
                      final subtitle = _buildSubtitle(sessionExercise);
                      return WorkoutExerciseTile(
                        exerciseName:
                            exercise?.exerciseName ?? 'Exercise ${index + 1}',
                        duration: subtitle,
                        imageUrl: exercise?.imageUrl,
                      );
                    },
                  ),
          ),

          // START button
          _buildStartButton(context),
        ],
      ),
    );
  }

  String _buildSubtitle(SessionExerciseResponse ex) {
    final parts = <String>[];
    if (ex.sets != null) parts.add('${ex.sets} sets');
    if (ex.repetitions != null) parts.add('${ex.repetitions} reps');
    if (ex.restTimeSeconds != null) parts.add('${ex.restTimeSeconds}s rest');
    return parts.isEmpty ? 'View details' : parts.join(' · ');
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: AppDimensions.iconSmall,
          color: AppColors.grey900,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        sessionName ?? 'Workout Activity',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildStartButton(BuildContext context) {
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
          child: ElevatedButton(
            onPressed: () {
              context.push(
                Routes.workoutCountdown,
                extra: {
                  'sessionId': sessionId,
                  'exercises': exercises,
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
              'START',
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
