import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/onboarding_response.dart';

/// Generic NUMBER input step - numeric fields driven by step.options or defaults.
class NumberInputStep extends StatefulWidget {
  final OnboardingStepResponse step;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onSkip;
  final String? existingData;

  const NumberInputStep({
    super.key,
    required this.step,
    required this.onSubmit,
    this.onSkip,
    this.existingData,
  });

  @override
  State<NumberInputStep> createState() => _NumberInputStepState();
}

class _NumberInputStepState extends State<NumberInputStep> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initFields();
    _loadExistingData();
  }

  void _initFields() {
    final options = widget.step.options;
    if (options.isNotEmpty) {
      for (final opt in options) {
        final key = opt.optionKey ?? opt.label ?? 'field_${opt.optionId}';
        _controllers[key] = TextEditingController();
      }
    } else {
      _controllers['weight'] = TextEditingController();
      _controllers['height'] = TextEditingController();
    }
  }

  void _loadExistingData() {
    final data = widget.existingData ?? widget.step.responseData;
    if (data == null || data.isEmpty) return;
    try {
      final map = jsonDecode(data) as Map<String, dynamic>?;
      if (map == null) return;
      for (final entry in map.entries) {
        final c = _controllers[entry.key];
        if (c != null && entry.value != null) {
          c.text = entry.value.toString();
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final Map<String, dynamic> data = {};
    for (final entry in _controllers.entries) {
      final numValue = num.tryParse(entry.value.text.trim());
      data[entry.key] = numValue;
    }
    widget.onSubmit(data);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = widget.step.options;
    final hasOptions = options.isNotEmpty;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.step.title ?? 'Enter numbers',
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
            if (hasOptions)
              ...options.map((opt) {
                final key = opt.optionKey ?? opt.label ?? 'field_${opt.optionId}';
                final controller = _controllers[key];
                if (controller == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: InputDecoration(
                      labelText: opt.label ?? key,
                      hintText: opt.description,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (num.tryParse(value.trim()) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                );
              })
            else ...[
              _buildNumberField(
                theme: theme,
                key: 'weight',
                label: 'Weight',
                hint: '70',
                suffix: 'kg',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final n = double.tryParse(v);
                  if (n == null || n < 20 || n > 300) return 'Enter 20-300 kg';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                theme: theme,
                key: 'height',
                label: 'Height',
                hint: '175',
                suffix: 'cm',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final n = double.tryParse(v);
                  if (n == null || n < 100 || n > 250) return 'Enter 100-250 cm';
                  return null;
                },
              ),
            ],
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
            if (widget.onSkip != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: widget.onSkip,
                  child: const Text('Skip'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required ThemeData theme,
    required String key,
    required String label,
    required String hint,
    required String suffix,
    required String? Function(String?) validator,
  }) {
    final controller = _controllers[key]!;
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }
}
