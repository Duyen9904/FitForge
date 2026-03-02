import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/workout_plan_models.dart';
import '../viewmodels/create_workout_plan_viewmodel.dart';

/// Bottom sheet for editing workout plan metadata (name, description,
/// goal, muscle group, difficulty, frequency, duration).
class EditPlanMetadataSheet extends ConsumerStatefulWidget {
  final WorkoutPlanResponse plan;
  final Future<void> Function(UpdateWorkoutPlanRequest request) onSave;

  const EditPlanMetadataSheet({
    super.key,
    required this.plan,
    required this.onSave,
  });

  @override
  ConsumerState<EditPlanMetadataSheet> createState() =>
      _EditPlanMetadataSheetState();
}

class _EditPlanMetadataSheetState extends ConsumerState<EditPlanMetadataSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _freqController;
  late TextEditingController _durationController;

  int? _selectedGoalId;
  int? _selectedMuscleGroupId;
  String _selectedDifficulty = 'INTERMEDIATE';

  bool _saving = false;

  static const _difficulties = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    _nameController = TextEditingController(text: p.planName);
    _descController = TextEditingController(text: p.description ?? '');
    _freqController =
        TextEditingController(text: p.frequencyPerWeek?.toString() ?? '3');
    _durationController =
        TextEditingController(text: p.durationWeeks?.toString() ?? '4');
    _selectedGoalId = p.goal?.goalId;
    _selectedMuscleGroupId = p.muscleGroup?.muscleGroupId;
    _selectedDifficulty = p.difficultyLevel ?? 'INTERMEDIATE';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _freqController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final request = UpdateWorkoutPlanRequest(
      planName:
          _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      description:
          _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      goalId: _selectedGoalId,
      muscleGroupId: _selectedMuscleGroupId ?? 1,
      frequencyPerWeek: int.tryParse(_freqController.text),
      durationWeeks: int.tryParse(_durationController.text),
      difficultyLevel: _selectedDifficulty,
    );

    await widget.onSave(request);
    if (mounted) Navigator.pop(context);
  }

  String _formatEnum(String value) {
    return value
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalsAsync = ref.watch(goalsProvider);
    final muscleGroupsAsync = ref.watch(muscleGroupsProvider);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Title
                  Text(
                    'Edit Plan Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing20),

                  // Plan Name
                  _buildLabel(theme, 'Plan Name'),
                  const SizedBox(height: AppDimensions.spacing4),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('e.g., My Muscle Plan'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Description
                  _buildLabel(theme, 'Description'),
                  const SizedBox(height: AppDimensions.spacing4),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration:
                        _inputDecoration('Describe your workout plan...'),
                  ),
                  const SizedBox(height: AppDimensions.spacing12),

                  // Goal dropdown
                  goalsAsync.when(
                    data: (goals) {
                      return _buildDropdown<int>(
                        theme: theme,
                        label: 'Fitness Goal',
                        value: _selectedGoalId,
                        items: goals
                            .map((g) => DropdownMenuItem<int>(
                                  value: g.goalId,
                                  child: Text(g.goalName),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedGoalId = v),
                      );
                    },
                    loading: () => _buildLoadingField(theme, 'Fitness Goal'),
                    error: (_, __) =>
                        _buildErrorField(theme, 'Fitness Goal'),
                  ),
                  const SizedBox(height: AppDimensions.spacing12),

                  // Muscle Group dropdown
                  muscleGroupsAsync.when(
                    data: (groups) {
                      return _buildDropdown<int>(
                        theme: theme,
                        label: 'Target Muscle Group',
                        value: _selectedMuscleGroupId,
                        items: groups
                            .map((g) => DropdownMenuItem<int>(
                                  value: g.muscleGroupId,
                                  child: Text(g.groupName),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedMuscleGroupId = v),
                      );
                    },
                    loading: () =>
                        _buildLoadingField(theme, 'Target Muscle Group'),
                    error: (_, __) =>
                        _buildErrorField(theme, 'Target Muscle Group'),
                  ),
                  const SizedBox(height: AppDimensions.spacing12),

                  // Difficulty
                  _buildDropdown<String>(
                    theme: theme,
                    label: 'Difficulty Level',
                    value: _selectedDifficulty,
                    items: _difficulties
                        .map((d) => DropdownMenuItem<String>(
                              value: d,
                              child: Text(_formatEnum(d)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedDifficulty = v);
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacing12),

                  // Frequency & Duration row
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          theme: theme,
                          controller: _freqController,
                          label: 'Days/Week',
                          hint: '3',
                          min: 1,
                          max: 7,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                      Expanded(
                        child: _buildNumberField(
                          theme: theme,
                          controller: _durationController,
                          label: 'Duration (weeks)',
                          hint: '4',
                          min: 1,
                          max: 52,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _onSave,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.spacing12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.white),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper builders ──

  Widget _buildLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.grey700,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing12,
        vertical: AppDimensions.spacing8,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required ThemeData theme,
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(theme, label),
        const SizedBox(height: AppDimensions.spacing4),
        DropdownButtonFormField<T>(
          value: items.any((i) => i.value == value) ? value : null,
          items: items,
          onChanged: onChanged,
          decoration: _inputDecoration('Select...'),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required String hint,
    int? min,
    int? max,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(theme, label),
        const SizedBox(height: AppDimensions.spacing4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(hint),
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            final parsed = int.tryParse(value);
            if (parsed == null) return 'Invalid';
            if (min != null && parsed < min) return 'Min: $min';
            if (max != null && parsed > max) return 'Max: $max';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoadingField(ThemeData theme, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(theme, label),
        const SizedBox(height: AppDimensions.spacing4),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.grey200),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorField(ThemeData theme, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(theme, label),
        const SizedBox(height: AppDimensions.spacing4),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              'Failed to load',
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
