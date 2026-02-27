import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../../workouts/models/workout_plan_models.dart';
import '../viewmodels/workout_execution_viewmodel.dart';
import '../viewmodels/workout_execution_state.dart';
import '../widgets/countdown_timer_ring.dart';

/// Workout Countdown Screen — "Get Ready!" countdown before workout begins.
/// On completion, calls startWorkout API then navigates to exercise execution.
class WorkoutCountdownScreen extends ConsumerStatefulWidget {
  final int? sessionId;
  final List<SessionExerciseResponse> exercises;

  const WorkoutCountdownScreen({
    super.key,
    this.sessionId,
    this.exercises = const [],
  });

  @override
  ConsumerState<WorkoutCountdownScreen> createState() =>
      _WorkoutCountdownScreenState();
}

class _WorkoutCountdownScreenState
    extends ConsumerState<WorkoutCountdownScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalSeconds = 10;

  late AnimationController _controller;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _totalSeconds),
    );
    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && !_isStarting) {
        _onCountdownComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startOver() {
    _controller.reset();
    _controller.forward();
  }

  Future<void> _onCountdownComplete() async {
    if (widget.sessionId == null) {
      // Fallback: no sessionId, just navigate with mock data
      if (mounted) {
        context.push(
          Routes.exerciseExecution,
          extra: {
            'exerciseName': 'Exercise',
            'durationSeconds': 15,
          },
        );
      }
      return;
    }

    setState(() => _isStarting = true);

    // Call the API to start the workout
    final viewModel = ref.read(workoutExecutionViewModelProvider.notifier);
    await viewModel.startWorkout(widget.sessionId!, widget.exercises);

    if (!mounted) return;

    final state = ref.read(workoutExecutionViewModelProvider);
    state.when(
      exerciseInProgress: (progressId, exercises, currentIndex, setNumber, totalSets) {
        final exercise = exercises[currentIndex];
        context.pushReplacement(
          Routes.exerciseExecution,
        );
      },
      error: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start workout: $message'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isStarting = false);
        _startOver();
      },
      initial: () {},
      starting: () {},
      resting: (_, __, ___, ____) {},
      completing: (_) {},
      completed: (_, __, ___, ____) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // "Get Ready!" text or "Starting..." text
            Text(
              _isStarting ? 'Starting...' : 'Get Ready!',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 36,
                  ),
            ),

            const Spacer(flex: 1),

            // Countdown Timer Ring or loading indicator
            _isStarting
                ? const SizedBox(
                    width: 240,
                    height: 240,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 4,
                      ),
                    ),
                  )
                : AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final remaining =
                          (_totalSeconds * (1.0 - _controller.value)).ceil();
                      final progress = 1.0 - _controller.value;
                      return CountdownTimerRing(
                        totalSeconds: _totalSeconds,
                        progress: progress,
                        displaySeconds: remaining,
                        size: 240,
                        strokeWidth: 14,
                      );
                    },
                  ),

            const Spacer(flex: 2),

            // Start Over button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing40,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: _isStarting ? null : _startOver,
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
                    'Start Over',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spacing48),
          ],
        ),
      ),
    );
  }
}
