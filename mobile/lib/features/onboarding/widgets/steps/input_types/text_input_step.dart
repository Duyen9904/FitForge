import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../models/onboarding_response.dart';

/// Generic TEXT input step - one or more text fields driven by step.options or default.
class TextInputStep extends StatefulWidget {
  final OnboardingStepResponse step;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onSkip;
  final String? existingData;

  const TextInputStep({
    super.key,
    required this.step,
    required this.onSubmit,
    this.onSkip,
    this.existingData,
  });

  @override
  State<TextInputStep> createState() => _TextInputStepState();
}

class _TextInputStepState extends State<TextInputStep> {
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
      _controllers['value'] = TextEditingController();
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
      data[entry.key] = entry.value.text.trim();
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
              widget.step.title ?? 'Enter information',
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
                      return null;
                    },
                  ),
                );
              })
            else
              TextFormField(
                controller: _controllers['value'],
                decoration: InputDecoration(
                  labelText: 'Value',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
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
}
