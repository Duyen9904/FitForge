import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../viewmodels/workout_execution_viewmodel.dart';
import '../viewmodels/workout_execution_state.dart';
import '../widgets/circular_progress_timer.dart';
import '../widgets/rest_next_movement_info.dart';
import '../widgets/skip_rest_button.dart';

/// Rest Timer Screen — countdown between exercises.
/// Shows next exercise info, breathing guide, skip and +15s extend buttons.
class RestTimerScreen extends ConsumerStatefulWidget {
  const RestTimerScreen({super.key});

  @override
  ConsumerState<RestTimerScreen> createState() => _RestTimerScreenState();
}

class _RestTimerScreenState extends ConsumerState<RestTimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _breathingController;
  bool _isPaused = false;
  int _restSeconds = 30;

  @override
  void initState() {
    super.initState();
    _restSeconds = _getRestSeconds();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _restSeconds),
    );
    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _onRestComplete();
      }
    });

    // Breathing animation (4s cycle)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  int _getRestSeconds() {
    final state = ref.read(workoutExecutionViewModelProvider);
    if (state is WorkoutExerciseResting) {
      return state.restTimeSeconds;
    }
    return 30;
  }

  @override
  void dispose() {
    _controller.dispose();
    _breathingController.dispose();
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

  void _onRestComplete() {
    final vm = ref.read(workoutExecutionViewModelProvider.notifier);
    final currentState = ref.read(workoutExecutionViewModelProvider);

    if (currentState is WorkoutExerciseResting &&
        currentState.nextSetNumber <= currentState.totalSets) {
      vm.goToNextSet(
        currentState.currentExerciseIndex,
        currentState.nextSetNumber,
        currentState.totalSets,
      );
      context.pushReplacement(Routes.exerciseExecution);
      return;
    }

    if (vm.isLastExercise) {
      context.pushReplacement(Routes.workoutCongratulations);
    } else {
      vm.goToNextExercise();
      context.pushReplacement(Routes.exerciseExecution);
    }
  }

  void _onSkipRest() {
    _controller.stop();
    _onRestComplete();
  }

  void _onExtend15s() {
    setState(() {
      _restSeconds += 15;
      final currentProgress = _controller.value;
      _controller.duration = Duration(seconds: _restSeconds);
      // Recalculate the progress to keep remaining time consistent
      final remainingRatio = 1.0 - currentProgress;
      final newProgress = 1.0 - (remainingRatio * (_restSeconds - 15) / _restSeconds + 15 / _restSeconds);
      _controller.value = newProgress.clamp(0.0, 1.0);
      if (!_isPaused) {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutExecutionViewModelProvider);

    return state.maybeWhen(
      resting: (progressId, exercises, currentIndex, restTimeSeconds,
          nextSetNumber, totalSets) {
        final vm = ref.read(workoutExecutionViewModelProvider.notifier);
        final isBetweenSets = nextSetNumber <= totalSets;
        final nextName = isBetweenSets
            ? 'Set $nextSetNumber / $totalSets'
            : vm.nextExerciseName;
        final title = isBetweenSets ? 'REST BETWEEN SETS' : 'TAKE A REST';
        final nextIndex = currentIndex + 1;
        final nextImageUrl = nextIndex < exercises.length
            ? exercises[nextIndex].exercise?.imageUrl
            : null;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.95),
                  AppColors.primaryDark.withValues(alpha: 0.8),
                  AppColors.backgroundLight,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.spacing24),

                  // Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 2,
                        ),
                  ),

                  // Breathing guide
                  const SizedBox(height: AppDimensions.spacing8),
                  AnimatedBuilder(
                    animation: _breathingController,
                    builder: (context, _) {
                      final phase = _breathingController.value;
                      final text = phase < 0.5
                          ? 'Breathe in...'
                          : 'Breathe out...';
                      final opacity = phase < 0.5
                          ? (phase * 2).clamp(0.3, 0.8)
                          : ((1.0 - phase) * 2).clamp(0.3, 0.8);
                      return Opacity(
                        opacity: opacity,
                        child: Text(
                          text,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.white.withValues(alpha: 0.6),
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 1),

                  // Timer
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final remaining =
                          (_restSeconds * (1.0 - _controller.value)).ceil();
                      return CircularProgressTimer(
                        progress: 1.0 - _controller.value,
                        displayValue: remaining,
                        isPaused: _isPaused,
                        onTogglePause: _togglePause,
                        size: 200,
                      );
                    },
                  ),

                  const SizedBox(height: AppDimensions.spacing16),

                  // +15s extend button
                  TextButton.icon(
                    onPressed: _onExtend15s,
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                    label: Text(
                      '+15s',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Next movement info
                  RestNextMovementInfo(
                    nextExerciseName: nextName,
                    currentIndex: currentIndex + 1,
                    totalExercises: exercises.length,
                    nextImageUrl: isBetweenSets ? null : nextImageUrl,
                  ),

                  const SizedBox(height: AppDimensions.spacing24),

                  // Skip button
                  SkipRestButton(onPressed: _onSkipRest),

                  const SizedBox(height: AppDimensions.spacing48),
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
                Text('Preparing...',
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        );
      },
    );
  }
}
