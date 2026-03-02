import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../viewmodels/workout_execution_viewmodel.dart';
import '../viewmodels/workout_execution_state.dart';
import '../widgets/congratulations_trophy.dart';
import '../widgets/workout_stats_row.dart';
import '../widgets/next_workout_button.dart';

/// Workout Congratulations Screen — workout complete!
/// Calls completeWorkout API, then shows real stats.
class WorkoutCongratulationsScreen extends ConsumerStatefulWidget {
  const WorkoutCongratulationsScreen({super.key});

  @override
  ConsumerState<WorkoutCongratulationsScreen> createState() =>
      _WorkoutCongratulationsScreenState();
}

class _WorkoutCongratulationsScreenState
    extends ConsumerState<WorkoutCongratulationsScreen> {
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _completeIfNeeded();
    });
  }

  Future<void> _completeIfNeeded() async {
    if (_hasCompleted) return;
    _hasCompleted = true;

    final state = ref.read(workoutExecutionViewModelProvider);
    // Only call complete if we're in the completing state (not already completed)
    if (state is WorkoutExecutionCompleting) {
      final vm = ref.read(workoutExecutionViewModelProvider.notifier);
      await vm.completeWorkout(
        difficultyRating: 3,
        moodRating: 'GOOD',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutExecutionViewModelProvider);

    return state.maybeWhen(
      completed: (result, totalExercises, totalCalories, totalMinutes) {
        return _buildSuccessScreen(
          context,
          exercises: totalExercises,
          calories: totalCalories,
          minutes: totalMinutes,
        );
      },
      completing: (_) {
        return _buildLoadingScreen(context);
      },
      error: (message) {
        // Even on error, show a generic congratulations with fallback data
        final vm = ref.read(workoutExecutionViewModelProvider.notifier);
        return _buildSuccessScreen(
          context,
          exercises: vm.exercises.length,
          calories: 0, // unknown
          minutes: 0,
        );
      },
      orElse: () {
        // Fallback — show generic congratulations
        return _buildSuccessScreen(
          context,
          exercises: 0,
          calories: 0,
          minutes: 0,
        );
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.9),
              AppColors.primary.withValues(alpha: 0.6),
              AppColors.backgroundLight,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CongratulationsTrophy(),
              const SizedBox(height: AppDimensions.spacing24),
              Text(
                'Finishing up...',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              const CircularProgressIndicator(color: AppColors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(
    BuildContext context, {
    required int exercises,
    required int calories,
    required int minutes,
  }) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.95),
              AppColors.primary.withValues(alpha: 0.7),
              AppColors.backgroundLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Trophy
              const CongratulationsTrophy(),

              const SizedBox(height: AppDimensions.spacing24),

              // Title
              Text(
                'Congratulations!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
              ),

              const SizedBox(height: AppDimensions.spacing8),

              Text(
                'You have completed your workout',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
              ),

              const Spacer(flex: 1),

              // Stats
              WorkoutStatsRow(
                exercises: exercises,
                calories: calories,
                minutes: minutes,
              ),

              const Spacer(flex: 2),

              // "Back to Home" button
              NextWorkoutButton(
                label: 'BACK TO HOME',
                onPressed: () {
                  // Reset viewmodel state (don't cancel — workout is already completed)
                  ref
                      .read(workoutExecutionViewModelProvider.notifier)
                      .resetState();
                  context.go(Routes.home);
                },
              ),

              const SizedBox(height: AppDimensions.spacing48),
            ],
          ),
        ),
      ),
    );
  }
}
