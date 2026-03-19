import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../../workouts/models/workout_plan_models.dart';
import '../viewmodels/workout_execution_viewmodel.dart';
import '../widgets/countdown_timer_ring.dart';

/// Workout Countdown Screen — immersive dark gradient "Get Ready!" countdown
/// with first exercise preview and motivational text.
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

    final viewModel = ref.read(workoutExecutionViewModelProvider.notifier);
    await viewModel.startWorkout(widget.sessionId!, widget.exercises);

    if (!mounted) return;

    final state = ref.read(workoutExecutionViewModelProvider);
    state.when(
      exerciseInProgress: (progressId, exercises, currentIndex, setNumber, totalSets) {
        context.pushReplacement(Routes.exerciseExecution);
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
      resting: (_, __, ___, ____, _____, ______) {},
      completing: (_) {},
      completed: (_, __, ___, ____) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get first exercise info for preview
    final firstExercise = widget.exercises.isNotEmpty
        ? widget.exercises.first
        : null;
    final firstExerciseName =
        firstExercise?.exercise?.exerciseName ?? 'Get Started';

    return Scaffold(
      body: Container(
        color: AppColors.grey900,
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacing8),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: AppDimensions.iconSmall,
                      color: AppColors.white,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // "Get Ready!" text with motivational subtitle
              Text(
                _isStarting ? 'Starting...' : 'GET READY!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      fontSize: 36,
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                'Your workout is about to begin',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
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
                          color: AppColors.white,
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

              const Spacer(flex: 1),

              // First exercise preview
              if (firstExercise != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing32,
                  ),
                  padding: const EdgeInsets.all(AppDimensions.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusXLarge),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Exercise thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium),
                        child: Container(
                          width: 48,
                          height: 48,
                          color: AppColors.white.withValues(alpha: 0.15),
                          child: firstExercise.exercise?.imageUrl != null
                              ? Image.network(
                                  firstExercise.exercise!.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.fitness_center,
                                    color: AppColors.white,
                                    size: 24,
                                  ),
                                )
                              : const Icon(
                                  Icons.fitness_center,
                                  color: AppColors.white,
                                  size: 24,
                                ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FIRST EXERCISE',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.white.withValues(alpha: 0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              firstExerciseName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppDimensions.spacing24),

              // Restart Timer button
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
                      backgroundColor: AppColors.white.withValues(alpha: 0.15),
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusRound),
                        side: BorderSide(
                          color: AppColors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'RESTART TIMER',
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
      ),
    );
  }
}
