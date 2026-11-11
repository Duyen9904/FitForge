import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../viewmodels/create_workout_plan_state.dart';
import '../../viewmodels/create_workout_plan_viewmodel.dart';
import 'exercise_picker_sheet.dart';
import '../../../../ui/core/states/empty_screen.dart';

/// Step 3: Add exercises to each session
class ExercisesStep extends ConsumerWidget {
  const ExercisesStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(activeWorkoutPlanViewModelProvider);
    final vm = ref.read(activeWorkoutPlanViewModelProvider.notifier);

    if (state is! CreateWorkoutPlanEditing) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Exercises',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            'Add exercises to each session',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),

          ...state.sessions.asMap().entries.map((entry) {
            final sessionIndex = entry.key;
            final session = entry.value;

            if (session.isRestDay) {
              final dateStr = session.scheduledDate != null
                  ? ' · ${DateFormat('EEE, MMM d').format(session.scheduledDate!)}'
                  : '';
              return Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusXLarge),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hotel, color: AppColors.grey400, size: 20),
                    const SizedBox(width: AppDimensions.spacing8),
                    Text(
                      'Day ${session.dayNumber}$dateStr — Rest Day',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }

            return _SessionExerciseCard(
              sessionIndex: sessionIndex,
              session: session,
              vm: vm,
            );
          }),
        ],
      ),
    );
  }
}

class _SessionExerciseCard extends StatelessWidget {
  final int sessionIndex;
  final SessionDraft session;
  final CreateWorkoutPlanViewModel vm;

  const _SessionExerciseCard({
    required this.sessionIndex,
    required this.session,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session header
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusXLarge),
                topRight: Radius.circular(AppDimensions.radiusXLarge),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day info row
                if (session.scheduledDate != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Day ${session.dayNumber} · ${DateFormat('EEE, MMM d').format(session.scheduledDate!)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Day ${session.dayNumber}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                // Session name + focus area
                Row(
                  children: [
                    Icon(Icons.fitness_center, color: AppColors.white, size: 20),
                    const SizedBox(width: AppDimensions.spacing8),
                    Expanded(
                      child: Text(
                        session.sessionName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (session.focusArea != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing8,
                          vertical: AppDimensions.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusRound),
                        ),
                        child: Text(
                          session.focusArea!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Exercise list
          if (session.exercises.isEmpty)
            const EmptyScreen(
              illustrationHeight: 120,
              title: 'No exercises yet',
              description: 'Add exercises to this session to build your routine',
            )
          else
            ...session.exercises.asMap().entries.map((entry) {
              final exIndex = entry.key;
              final exercise = entry.value;
              return _ExerciseTile(
                exercise: exercise,
                onRemove: () => vm.removeExercise(sessionIndex, exIndex),
                onSetsChanged: (v) =>
                    vm.updateExerciseSets(sessionIndex, exIndex, v),
                onRepsChanged: (v) =>
                    vm.updateExerciseReps(sessionIndex, exIndex, v),
                onWeightChanged: (v) =>
                    vm.updateExerciseWeight(sessionIndex, exIndex, v),
                onRestChanged: (v) =>
                    vm.updateExerciseRest(sessionIndex, exIndex, v),
              );
            }),

          // Add exercise button
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showExercisePicker(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Exercise'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacing12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExercisePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExercisePickerSheet(
        onExerciseSelected: (exercise) {
          vm.addExercise(sessionIndex, exercise);
        },
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final ExerciseDraft exercise;
  final VoidCallback onRemove;
  final ValueChanged<int> onSetsChanged;
  final ValueChanged<int> onRepsChanged;
  final ValueChanged<double?> onWeightChanged;
  final ValueChanged<int?> onRestChanged;

  const _ExerciseTile({
    required this.exercise,
    required this.onRemove,
    required this.onSetsChanged,
    required this.onRepsChanged,
    required this.onWeightChanged,
    required this.onRestChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing12,
        vertical: AppDimensions.spacing4,
      ),
      padding: const EdgeInsets.all(AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name & delete
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.exerciseName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 18, color: AppColors.error),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),

          // Sets / Reps / Weight / Rest
          Row(
            children: [
              _MiniField(
                label: 'Sets',
                value: exercise.sets.toString(),
                onChanged: (v) {
                  final val = int.tryParse(v);
                  if (val != null && val > 0) onSetsChanged(val);
                },
              ),
              const SizedBox(width: AppDimensions.spacing8),
              _MiniField(
                label: 'Reps',
                value: exercise.repetitions.toString(),
                onChanged: (v) {
                  final val = int.tryParse(v);
                  if (val != null && val > 0) onRepsChanged(val);
                },
              ),
              const SizedBox(width: AppDimensions.spacing8),
              _MiniField(
                label: 'kg',
                value: exercise.weightKg?.toString() ?? '',
                onChanged: (v) {
                  onWeightChanged(double.tryParse(v));
                },
              ),
              const SizedBox(width: AppDimensions.spacing8),
              _MiniField(
                label: 'Rest(s)',
                value: exercise.restTimeSeconds?.toString() ?? '',
                onChanged: (v) {
                  onRestChanged(int.tryParse(v));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _MiniField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.grey500,
                ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 36,
            child: TextField(
              controller: TextEditingController(text: value),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSmall),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSmall),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
