import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/onboarding_response.dart';

/// Body metrics step - collects weight, height, target weight
class BodyMetricsStep extends StatefulWidget {
  final OnboardingStepResponse step;
  final Function(Map<String, dynamic>) onSubmit;
  final String? existingData;

  const BodyMetricsStep({
    super.key,
    required this.step,
    required this.onSubmit,
    this.existingData,
  });

  @override
  State<BodyMetricsStep> createState() => _BodyMetricsStepState();
}

class _BodyMetricsStepState extends State<BodyMetricsStep> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData != null && widget.existingData!.isNotEmpty) {
      // TODO: Parse JSON and pre-fill fields
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit({
      'weight': double.tryParse(_weightController.text) ?? 0,
      'height': double.tryParse(_heightController.text) ?? 0,
      'targetWeight': double.tryParse(_targetWeightController.text),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              widget.step.title ?? 'Body Metrics',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.step.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.step.subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Current weight
            _buildMetricCard(
              theme: theme,
              icon: Icons.monitor_weight_outlined,
              title: 'Current Weight',
              controller: _weightController,
              suffix: 'kg',
              hint: '70',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight < 20 || weight > 300) {
                  return 'Enter valid weight (20-300 kg)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Height
            _buildMetricCard(
              theme: theme,
              icon: Icons.height,
              title: 'Height',
              controller: _heightController,
              suffix: 'cm',
              hint: '175',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                final height = double.tryParse(value);
                if (height == null || height < 100 || height > 250) {
                  return 'Enter valid height (100-250 cm)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Target weight (optional)
            _buildMetricCard(
              theme: theme,
              icon: Icons.track_changes,
              title: 'Target Weight (Optional)',
              controller: _targetWeightController,
              suffix: 'kg',
              hint: '68',
              isOptional: true,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 20 || weight > 300) {
                    return 'Enter valid weight (20-300 kg)';
                  }
                }
                return null;
              },
            ),

            if (widget.step.helpText != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.step.helpText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Submit button
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
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String suffix,
    required String hint,
    bool isOptional = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    hintText: hint,
                    suffixText: suffix,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  validator: validator,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
