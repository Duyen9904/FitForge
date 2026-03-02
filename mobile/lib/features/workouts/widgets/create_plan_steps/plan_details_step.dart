import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../viewmodels/create_workout_plan_state.dart';
import '../../viewmodels/create_workout_plan_viewmodel.dart';
import 'form_text_field.dart';
import 'form_dropdown_field.dart';
import 'form_number_field.dart';
import 'form_date_picker.dart';
import 'form_async_fields.dart';

/// Step 1: Plan Details form
class PlanDetailsStep extends ConsumerStatefulWidget {
  const PlanDetailsStep({super.key});

  @override
  ConsumerState<PlanDetailsStep> createState() => _PlanDetailsStepState();
}

class _PlanDetailsStepState extends ConsumerState<PlanDetailsStep> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  static const _difficulties = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

  @override
  void initState() {
    super.initState();
    final state = ref.read(activeWorkoutPlanViewModelProvider);
    if (state is CreateWorkoutPlanEditing) {
      _nameController.text = state.planName;
      _descController.text = state.description;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(activeWorkoutPlanViewModelProvider);
    final vm = ref.read(activeWorkoutPlanViewModelProvider.notifier);
    final goalsAsync = ref.watch(goalsProvider);
    final muscleGroupsAsync = ref.watch(muscleGroupsProvider);

    if (state is! CreateWorkoutPlanEditing) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Text(
            'Plan Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            'Set up the basics of your workout plan',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),

          // Plan Name
          FormTextField(
            label: 'Plan Name *',
            controller: _nameController,
            hint: 'e.g., My Muscle Building Plan',
            onChanged: vm.updatePlanName,
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // Description
          FormTextField(
            label: 'Description',
            controller: _descController,
            hint: 'Describe your workout plan goals...',
            maxLines: 3,
            onChanged: vm.updateDescription,
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // Goal (from API)
          goalsAsync.when(
            data: (goals) => FormDropdownField<int>(
              label: 'Fitness Goal *',
              value: state.goalId,
              items: goals
                  .map((g) => DropdownMenuItem<int>(
                        value: g.goalId,
                        child: Text(g.goalName),
                      ))
                  .toList(),
              onChanged: (v) => vm.updateGoalId(v),
            ),
            loading: () => const FormLoadingField(label: 'Fitness Goal *'),
            error: (e, _) => FormErrorField(
              label: 'Fitness Goal',
              error: e.toString(),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // Target Muscle Group (from API)
          muscleGroupsAsync.when(
            data: (groups) => FormDropdownField<int>(
              label: 'Target Muscle Group *',
              value: state.muscleGroupId,
              items: groups
                  .map((g) => DropdownMenuItem<int>(
                        value: g.muscleGroupId,
                        child: Text(g.groupName),
                      ))
                  .toList(),
              onChanged: (v) => vm.updateMuscleGroupId(v),
            ),
            loading: () => const FormLoadingField(
                label: 'Target Muscle Group *'),
            error: (e, _) => FormErrorField(
              label: 'Target Muscle Group',
              error: e.toString(),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // Difficulty Level
          FormDropdownField<String>(
            label: 'Difficulty Level',
            value: state.difficultyLevel,
            items: _difficulties
                .map((d) => DropdownMenuItem<String>(
                      value: d,
                      child: Text(_formatEnum(d)),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) vm.updateDifficultyLevel(v);
            },
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // Frequency & Duration row
          Row(
            children: [
              Expanded(
                child: FormNumberField(
                  label: 'Days/Week',
                  value: state.frequencyPerWeek,
                  min: 1,
                  max: 7,
                  onChanged: vm.updateFrequencyPerWeek,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: FormNumberField(
                  label: 'Duration (weeks)',
                  value: state.durationWeeks,
                  min: 1,
                  max: 52,
                  onChanged: vm.updateDurationWeeks,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // Start Date
          FormDatePicker(
            label: 'Start Date *',
            value: state.startDate,
            onChanged: vm.updateStartDate,
          ),
          const SizedBox(height: AppDimensions.spacing32),
        ],
      ),
    );
  }

  String _formatEnum(String value) {
    return value
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}
