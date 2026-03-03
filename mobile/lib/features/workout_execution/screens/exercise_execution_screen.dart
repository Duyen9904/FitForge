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
/// Features set progress dots, exercise name header, and improved stop dialog.
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
      duration: const Duration(seconds: 30),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetTimerForCurrentExercise();
    });
  }

  void _resetTimerForCurrentExercise() {
    final vm = ref.read(workoutExecutionViewModelProvider.notifier);
    final exercise = vm.currentExercise;
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
        _resetTimerForCurrentExercise();
      },
      resting: (_, __, ___, ____, _____, ______) {
        context.pushReplacement(Routes.restTimer);
      },
      completing: (_) {
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
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _StopWorkoutSheet(),
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
                  AppColors.primary.withValues(alpha: 0.95),
                  AppColors.primaryDark.withValues(alpha: 0.85),
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

                  const SizedBox(height: AppDimensions.spacing12),

                  // Exercise image
                  ExerciseImageCard(
                    exerciseName: exerciseName,
                    imageUrl: imageUrl,
                  ),

                  const SizedBox(height: AppDimensions.spacing16),

                  // Set info with progress dots
                  Text(
                    'Set $setNumber / $totalSets',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                  ),

                  const SizedBox(height: AppDimensions.spacing8),

                  // Set progress dots
                  _buildSetProgressDots(setNumber, totalSets),

                  if (exercise.repetitions != null) ...[
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(
                      '${exercise.repetitions} reps${exercise.weightKg != null ? " · ${exercise.weightKg!.toStringAsFixed(1)} kg" : ""}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.7),
                          ),
                    ),
                  ],

                  const Spacer(),

                  // Timer
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
                                AppDimensions.radiusRound),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black.withValues(alpha: 0.15),
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
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    setNumber >= totalSets
                                        ? Icons.check_circle_rounded
                                        : Icons.check_rounded,
                                    size: 22,
                                  ),
                                  const SizedBox(
                                      width: AppDimensions.spacing8),
                                  Text(
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
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing12),

                  // Control buttons
                  ExerciseControlButtons(
                    onPrevious: currentIndex > 0 ? _onPrevious : null,
                    onStop: _onStop,
                    onSkip: _onSkip,
                  ),

                  const SizedBox(height: AppDimensions.spacing16),
                ],
              ),
            ),
          ),
        );
      },
      orElse: () {
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

  Widget _buildSetProgressDots(int currentSet, int totalSets) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSets, (index) {
        final isCompleted = index < currentSet - 1;
        final isCurrent = index == currentSet - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isCurrent ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: isCompleted
                ? AppColors.success
                : isCurrent
                    ? AppColors.white
                    : AppColors.white.withValues(alpha: 0.3),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.white.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
        );
      }),
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
                backgroundColor: AppColors.white.withValues(alpha: 0.2),
                color: AppColors.white,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$current/$total',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom bottom sheet for the stop workout confirmation.
class _StopWorkoutSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(AppDimensions.spacing24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),

            // Warning icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),

            Text(
              'Stop Workout?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Your progress so far will be lost.\nAre you sure you want to stop?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey500,
                  ),
            ),

            const SizedBox(height: AppDimensions.spacing24),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightLarge,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusRound),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue Workout',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing12),

            // Stop button
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightLarge,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusRound),
                  ),
                ),
                child: Text(
                  'Stop Workout',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
          ],
        ),
      ),
    );
  }
}
