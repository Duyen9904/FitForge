import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/workout_plan_models.dart';

/// Bottom sheet for editing a single session's metadata
/// (session name, focus area, estimated duration, rest-day toggle).
class EditSessionMetadataSheet extends StatefulWidget {
  final WorkoutSessionResponse session;
  final Future<void> Function(UpdateWorkoutSessionRequest request) onSave;

  const EditSessionMetadataSheet({
    super.key,
    required this.session,
    required this.onSave,
  });

  @override
  State<EditSessionMetadataSheet> createState() =>
      _EditSessionMetadataSheetState();
}

class _EditSessionMetadataSheetState extends State<EditSessionMetadataSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _focusAreaController;
  late TextEditingController _durationController;
  late TextEditingController _warmUpController;
  late TextEditingController _coolDownController;
  late bool _isRestDay;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    _nameController = TextEditingController(text: s.sessionName);
    _focusAreaController = TextEditingController(text: s.focusArea ?? '');
    _durationController =
        TextEditingController(text: s.estimatedDuration?.toString() ?? '');
    _warmUpController = TextEditingController(text: s.warmUpNotes ?? '');
    _coolDownController = TextEditingController(text: s.coolDownNotes ?? '');
    _isRestDay = s.isRestDay;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusAreaController.dispose();
    _durationController.dispose();
    _warmUpController.dispose();
    _coolDownController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final request = UpdateWorkoutSessionRequest(
      sessionName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      focusArea: _focusAreaController.text.trim().isNotEmpty
          ? _focusAreaController.text.trim()
          : null,
      estimatedDuration: _durationController.text.isNotEmpty
          ? int.tryParse(_durationController.text)
          : null,
      warmUpNotes: _warmUpController.text.trim().isNotEmpty
          ? _warmUpController.text.trim()
          : null,
      coolDownNotes: _coolDownController.text.trim().isNotEmpty
          ? _coolDownController.text.trim()
          : null,
      isRestDay: _isRestDay,
    );

    await widget.onSave(request);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    'Edit Session',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing4),
                  Text(
                    'Day ${widget.session.dayNumber}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing20),

                  // Session Name
                  _buildLabel(theme, 'Session Name'),
                  const SizedBox(height: AppDimensions.spacing4),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('e.g., Upper Body Push'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Focus Area
                  _buildLabel(theme, 'Focus Area'),
                  const SizedBox(height: AppDimensions.spacing4),
                  TextFormField(
                    controller: _focusAreaController,
                    decoration: _inputDecoration('e.g., Chest & Triceps'),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Estimated Duration
                  _buildLabel(theme, 'Estimated Duration (minutes)'),
                  const SizedBox(height: AppDimensions.spacing4),
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('e.g., 60'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final parsed = int.tryParse(value);
                      if (parsed == null) return 'Invalid number';
                      if (parsed < 1) return 'Min: 1';
                      if (parsed > 300) return 'Max: 300';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Warm-up Notes
                  _buildLabel(theme, 'Warm-up Notes'),
                  const SizedBox(height: AppDimensions.spacing4),
                  TextFormField(
                    controller: _warmUpController,
                    maxLines: 2,
                    maxLength: 500,
                    decoration: _inputDecoration('Optional warm-up notes...'),
                  ),
                  const SizedBox(height: AppDimensions.spacing12),

                  // Cool-down Notes
                  _buildLabel(theme, 'Cool-down Notes'),
                  const SizedBox(height: AppDimensions.spacing4),
                  TextFormField(
                    controller: _coolDownController,
                    maxLines: 2,
                    maxLength: 500,
                    decoration: _inputDecoration('Optional cool-down notes...'),
                  ),
                  const SizedBox(height: AppDimensions.spacing12),

                  // Rest Day toggle
                  SwitchListTile(
                    title: Text(
                      'Rest Day',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    subtitle: Text(
                      'Mark this session as a rest day',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                    value: _isRestDay,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) =>
                        setState(() => _isRestDay = value),
                  ),
                  const SizedBox(height: AppDimensions.spacing20),

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
}
