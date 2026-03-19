import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../../workouts/models/workout_plan_models.dart';
import '../widgets/workout_exercise_tile.dart';

/// Workout Activity Screen
/// Displays the list of exercises for a session with exercise numbering,
/// session summary header, and an animated gradient START button.
class WorkoutActivityScreen extends StatefulWidget {
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
  State<WorkoutActivityScreen> createState() => _WorkoutActivityScreenState();
}

class _WorkoutActivityScreenState extends State<WorkoutActivityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedExercises = List<SessionExerciseResponse>.from(widget.exercises)
      ..sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Session summary header
          _buildSessionSummary(context, sortedExercises),

          // Exercise list
          Expanded(
            child: sortedExercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center_rounded,
                          size: 48,
                          color: AppColors.grey300,
                        ),
                        const SizedBox(height: AppDimensions.spacing12),
                        Text(
                          'No exercises in this session',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.grey500,
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacing8,
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
                        exerciseNumber: index + 1,
                      );
                    },
                  ),
          ),

          // START button with glow
          _buildStartButton(context),
        ],
      ),
    );
  }

  Widget _buildSessionSummary(
      BuildContext context, List<SessionExerciseResponse> exercises) {
    if (exercises.isEmpty) return const SizedBox.shrink();

    final totalSets = exercises.fold<int>(0, (sum, e) => sum + (e.sets ?? 0));
    final estimatedMinutes = (totalSets * 1.5).ceil(); // rough estimate

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.spacing16,
        AppDimensions.spacing8,
        AppDimensions.spacing16,
        AppDimensions.spacing8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing12,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          _SummaryChip(
            icon: Icons.fitness_center_rounded,
            value: '${exercises.length}',
            label: 'exercises',
          ),
          const SizedBox(width: AppDimensions.spacing16),
          _SummaryChip(
            icon: Icons.repeat_rounded,
            value: '$totalSets',
            label: 'total sets',
          ),
          const SizedBox(width: AppDimensions.spacing16),
          _SummaryChip(
            icon: Icons.timer_outlined,
            value: '~$estimatedMinutes',
            label: 'min',
          ),
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
        widget.sessionName ?? 'Workout Activity',
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
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary
                        .withValues(alpha: 0.3 + _glowController.value * 0.2),
                    blurRadius: 12 + _glowController.value * 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeightLarge,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  Routes.workoutCountdown,
                  extra: {
                    'sessionId': widget.sessionId,
                    'exercises': widget.exercises,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 24),
                  const SizedBox(width: AppDimensions.spacing8),
                  Text(
                    'START WORKOUT',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey700,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
