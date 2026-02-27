import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../viewmodels/workout_execution_viewmodel.dart';
import '../viewmodels/workout_execution_state.dart';
import '../widgets/exercise_image_card.dart';
import '../widgets/circular_progress_timer.dart';
import '../widgets/exercise_control_buttons.dart';

/// Exercise Execution Screen — performs a single exercise.
/// Reads current exercise/set from the viewmodel and logs sets via API.
class ExerciseExecutionScreen extends ConsumerStatefulWidget {
  const ExerciseExecutionScreen({super.key});

  @override
  ConsumerState<ExerciseExecutionScreen> createState() =>
      _ExerciseExecutionScreenState();
}

class _ExerciseExecutionScreenState
    extends ConsumerState<ExerciseExecutionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPaused = false;
  bool _isLogging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // default, will be overridden
    );
    // Duration will be set after the first build with real data.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetTimerForCurrentExercise();
    });
  }

  void _resetTimerForCurrentExercise() {
    final vm = ref.read(workoutExecutionViewModelProvider.notifier);
    final exercise = vm.currentExercise;
    // Estimate duration: sets × reps × 2 seconds per rep (rough)
    final sets = exercise?.sets ?? 3;
    final reps = exercise?.repetitions ?? 10;
    final durationSeconds = sets * reps * 2;

    _controller.duration = Duration(seconds: durationSeconds.clamp(10, 300));
    _controller.reset();
    _controller.forward();
    _isPaused = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePause() {
    setState(() {
      if (_isPaused) {
        _controller.forward();
      } else {
        _controller.stop();
      }
      _isPaused = !_isPaused;
    });
  }

  Future<void> _onSetComplete() async {
    if (_isLogging) return;
    setState(() => _isLogging = true);

    final vm = ref.read(workoutExecutionViewModelProvider.notifier);
    await vm.logCurrentSet();

    if (!mounted) return;
    setState(() => _isLogging = false);

    final state = ref.read(workoutExecutionViewModelProvider);
    state.when(
      exerciseInProgress: (_, __, ___, ____, _____) {
        // Still on same exercise (more sets) — reset timer
        _resetTimerForCurrentExercise();
      },
      resting: (_, __, ___, ____) {
        // Go to rest screen
        context.pushReplacement(Routes.restTimer);
      },
      completing: (_) {
        // Last exercise done, go to congratulations
        context.pushReplacement(Routes.workoutCongratulations);
      },
      error: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $message'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      initial: () {},
      starting: () {},
      completed: (_, __, ___, ____) {},
    );
  }

  Future<void> _onSkip() async {
    if (_isLogging) return;
    setState(() => _isLogging = true);

    final vm = ref.read(workoutExecutionViewModelProvider.notifier);
    await vm.skipExercise();

    if (!mounted) return;
    setState(() => _isLogging = false);

    final state = ref.read(workoutExecutionViewModelProvider);
    if (state is WorkoutExerciseResting) {
      context.pushReplacement(Routes.restTimer);
    } else if (state is WorkoutExecutionCompleting) {
      context.pushReplacement(Routes.workoutCongratulations);
    }
  }

  void _onPrevious() {
    final vm = ref.read(workoutExecutionViewModelProvider.notifier);
    vm.goToPreviousExercise();
    _resetTimerForCurrentExercise();
  }

  Future<void> _onStop() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Workout?'),
        content: const Text('Your progress so far will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Stop'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final vm = ref.read(workoutExecutionViewModelProvider.notifier);
      await vm.cancelWorkout();
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutExecutionViewModelProvider);

    return state.maybeWhen(
      exerciseInProgress:
          (progressId, exercises, currentIndex, setNumber, totalSets) {
        final exercise = exercises[currentIndex];
        final exerciseName =
            exercise.exercise?.exerciseName ?? 'Exercise ${currentIndex + 1}';
        final imageUrl = exercise.exercise?.imageUrl;

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
            child: SafeArea(
              child: Column(
                children: [
                  // Progress indicator
                  _buildProgressIndicator(
                      context, currentIndex + 1, exercises.length),

                  const SizedBox(height: AppDimensions.spacing16),

                  // Exercise image
                  ExerciseImageCard(
                    exerciseName: exerciseName,
                    imageUrl: imageUrl,
                  ),

                  const SizedBox(height: AppDimensions.spacing16),

                  // Set info
                  Text(
                    'Set $setNumber / $totalSets',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),

                  if (exercise.repetitions != null) ...[
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      '${exercise.repetitions} reps${exercise.weightKg != null ? " · ${exercise.weightKg!.toStringAsFixed(1)} kg" : ""}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                    ),
                  ],

                  const Spacer(),

                  // Timer / "Done" button
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final totalSec =
                          _controller.duration?.inSeconds ?? 30;
                      final remaining =
                          (totalSec * (1.0 - _controller.value)).ceil();
                      return CircularProgressTimer(
                        progress: 1.0 - _controller.value,
                        displayValue: remaining,
                        isPaused: _isPaused,
                        onTogglePause: _togglePause,
                      );
                    },
                  ),

                  const Spacer(),

                  // "Set Complete" button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing24,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeightLarge,
                      child: ElevatedButton(
                        onPressed: _isLogging ? null : _onSetComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusLarge),
                          ),
                          elevation: 0,
                        ),
                        child: _isLogging
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : Text(
                                setNumber >= totalSets
                                    ? 'EXERCISE COMPLETE'
                                    : 'SET COMPLETE',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing16),

                  // Control buttons
                  ExerciseControlButtons(
                    onPrevious: currentIndex > 0 ? _onPrevious : null,
                    onStop: _onStop,
                    onSkip: _onSkip,
                  ),

                  const SizedBox(height: AppDimensions.spacing24),
                ],
              ),
            ),
          ),
        );
      },
      orElse: () {
        // Fallback if state is not exerciseInProgress
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: AppDimensions.spacing16),
                Text(
                  'Loading exercise...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(
      BuildContext context, int current, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing20,
        vertical: AppDimensions.spacing8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: _onStop,
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: current / total,
                backgroundColor: AppColors.white.withValues(alpha: 0.3),
                color: AppColors.white,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Text(
            '$current/$total',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
