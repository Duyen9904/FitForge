import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/state/app_flow_state.dart';
import '../models/measurement_models.dart';
import '../repositories/measurement_repository.dart';
import '../widgets/measurement_date_card.dart';

/// Manual entry form for body measurement.
class ManualMeasurementFormScreen extends ConsumerStatefulWidget {
  /// When true (first measurement after onboarding), weight/height fields are
  /// hidden since they were already captured during onboarding.
  final bool isFirstMeasurement;

  const ManualMeasurementFormScreen({
    super.key,
    this.isFirstMeasurement = false,
  });

  @override
  ConsumerState<ManualMeasurementFormScreen> createState() =>
      _ManualMeasurementFormScreenState();
}

class _ManualMeasurementFormScreenState
    extends ConsumerState<ManualMeasurementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _measurementDate = DateTime.now();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _bicepsController = TextEditingController();
  final _thighsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _bodyFatController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _bicepsController.dispose();
    _thighsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _measurementDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _measurementDate = picked);
  }

  Future<void> _submit() async {
    _error = null;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final request = RecordMeasurementRequest(
        measurementDate: _measurementDate,
        weightKg: widget.isFirstMeasurement
            ? null
            : _parseOptDouble(_weightController.text),
        bodyFatPercentage: _parseOptDouble(_bodyFatController.text),
        chestCm: _parseOptDouble(_chestController.text),
        waistCm: _parseOptDouble(_waistController.text),
        hipsCm: _parseOptDouble(_hipsController.text),
        bicepsCm: _parseOptDouble(_bicepsController.text),
        thighsCm: _parseOptDouble(_thighsController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      await ref.read(measurementRepositoryProvider).recordMeasurement(request);
      
      // Update flow state to reflect measurement completion
      await ref.read(appFlowStateProvider.notifier).checkFlowStatus();
      
      if (mounted) context.go(Routes.home);
    } on MeasurementException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  double? _parseOptDouble(String s) {
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  /// Builds a simple underline-style numeric input field.
  Widget _buildMetricField({
    required TextEditingController controller,
    required String label,
    required String helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter measurements'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MeasurementDateCard(
                      date: _measurementDate,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: AppDimensions.spacing24),
                    // Weight & Height: shown only for subsequent measurements
                    // (first measurement gets weight/height from onboarding)
                    if (!widget.isFirstMeasurement) ...[
                      _buildMetricField(
                        controller: _weightController,
                        label: 'Weight',
                        helperText: 'In kilograms (kg)',
                      ),
                      const SizedBox(height: AppDimensions.spacing16),
                      _buildMetricField(
                        controller: _heightController,
                        label: 'Height',
                        helperText: 'In centimeters (cm)',
                      ),
                      const SizedBox(height: AppDimensions.spacing16),
                    ],
                    _buildMetricField(
                      controller: _bodyFatController,
                      label: 'Body fat',
                      helperText: 'Percentage (0–100)',
                      validator: (v) {
                        if (v != null && v.isNotEmpty) {
                          final n = double.tryParse(v);
                          if (n == null || n < 0 || n > 100) {
                            return 'Enter 0–100';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    _buildMetricField(
                      controller: _chestController,
                      label: 'Chest',
                      helperText: 'In centimeters (cm)',
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    _buildMetricField(
                      controller: _waistController,
                      label: 'Waist',
                      helperText: 'In centimeters (cm)',
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    _buildMetricField(
                      controller: _hipsController,
                      label: 'Hips',
                      helperText: 'In centimeters (cm)',
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    _buildMetricField(
                      controller: _bicepsController,
                      label: 'Biceps',
                      helperText: 'In centimeters (cm)',
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    _buildMetricField(
                      controller: _thighsController,
                      label: 'Thighs',
                      helperText: 'In centimeters (cm)',
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        helperText: 'Optional',
                      ),
                      maxLines: 2,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppDimensions.spacing12),
                      Text(
                        _error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.spacing24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save measurement'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
