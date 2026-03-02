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
/// Shows next exercise info and lets the user skip rest.
class RestTimerScreen extends ConsumerStatefulWidget {
  const RestTimerScreen({super.key});

  @override
  ConsumerState<RestTimerScreen> createState() => _RestTimerScreenState();
}

class _RestTimerScreenState extends ConsumerState<RestTimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    final restSeconds = _getRestSeconds();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: restSeconds),
    );
    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _onRestComplete();
      }
    });
  }

  int _getRestSeconds() {
    final state = ref.read(workoutExecutionViewModelProvider);
    if (state is WorkoutExerciseResting) {
      return state.restTimeSeconds;
    }
    return 30; // fallback
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

  void _onRestComplete() {
    final vm = ref.read(workoutExecutionViewModelProvider.notifier);
    final currentState = ref.read(workoutExecutionViewModelProvider);

    if (currentState is WorkoutExerciseResting &&
        currentState.nextSetNumber <= currentState.totalSets) {
      // Resting between sets — resume same exercise at next set
      vm.goToNextSet(
        currentState.currentExerciseIndex,
        currentState.nextSetNumber,
        currentState.totalSets,
      );
      context.pushReplacement(Routes.exerciseExecution);
      return;
    }

    if (vm.isLastExercise) {
      // Last exercise done — navigate to congratulations
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
        // Get next exercise image if available
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
                  AppColors.primary.withValues(alpha: 0.7),
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

                  const Spacer(flex: 1),

                  // Timer
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final remaining =
                          (restTimeSeconds * (1.0 - _controller.value)).ceil();
                      return CircularProgressTimer(
                        progress: 1.0 - _controller.value,
                        displayValue: remaining,
                        isPaused: _isPaused,
                        onTogglePause: _togglePause,
                      );
                    },
                  ),

                  const Spacer(flex: 1),

                  // Next movement info
                  RestNextMovementInfo(
                    nextExerciseName: nextName,
                    currentIndex: currentIndex + 1,
                    totalExercises: exercises.length,
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
                Text('Preparing...', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        );
      },
    );
  }
}
