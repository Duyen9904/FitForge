import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/state/app_flow_state.dart';
import '../models/measurement_models.dart';
import '../repositories/measurement_repository.dart';
import '../widgets/measurement_date_card.dart';
import '../widgets/measurement_metric_card.dart';

/// Manual entry form for body measurement.
class ManualMeasurementFormScreen extends ConsumerStatefulWidget {
  const ManualMeasurementFormScreen({super.key});

  @override
  ConsumerState<ManualMeasurementFormScreen> createState() =>
      _ManualMeasurementFormScreenState();
}

class _ManualMeasurementFormScreenState
    extends ConsumerState<ManualMeasurementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _measurementDate = DateTime.now();
  final _weightController = TextEditingController();
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

    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) return;

    setState(() => _loading = true);
    try {
      final request = RecordMeasurementRequest(
        measurementDate: _measurementDate,
        weightKg: weight,
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
                    const SizedBox(height: AppDimensions.spacing16),
                    MeasurementMetricCard(
                      icon: Icons.monitor_weight_outlined,
                      title: 'Weight',
                      controller: _weightController,
                      suffix: 'kg',
                      hint: '70',
                      required: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null || n < 20 || n > 300) {
                          return 'Enter 20–300 kg';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    MeasurementMetricCard(
                      icon: Icons.pie_chart_outline,
                      title: 'Body fat %',
                      controller: _bodyFatController,
                      suffix: '%',
                      hint: '20',
                      required: false,
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
                    MeasurementMetricCard(
                      icon: Icons.straighten,
                      title: 'Chest (cm)',
                      controller: _chestController,
                      suffix: 'cm',
                      hint: '100',
                      required: false,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    MeasurementMetricCard(
                      icon: Icons.straighten,
                      title: 'Waist (cm)',
                      controller: _waistController,
                      suffix: 'cm',
                      hint: '80',
                      required: false,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    MeasurementMetricCard(
                      icon: Icons.straighten,
                      title: 'Hips (cm)',
                      controller: _hipsController,
                      suffix: 'cm',
                      hint: '95',
                      required: false,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    MeasurementMetricCard(
                      icon: Icons.straighten,
                      title: 'Biceps (cm)',
                      controller: _bicepsController,
                      suffix: 'cm',
                      hint: '35',
                      required: false,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    MeasurementMetricCard(
                      icon: Icons.straighten,
                      title: 'Thighs (cm)',
                      controller: _thighsController,
                      suffix: 'cm',
                      hint: '55',
                      required: false,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
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
