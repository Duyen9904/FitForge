import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/onboarding_response.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';

/// Generic NUMBER input step - numeric fields driven by step.options or defaults.
/// Calls the ViewModel directly via Riverpod on user interaction.
class NumberInputStep extends ConsumerStatefulWidget {
  final OnboardingStepResponse step;
  final String? existingData;

  const NumberInputStep({
    super.key,
    required this.step,
    this.existingData,
  });

  @override
  ConsumerState<NumberInputStep> createState() => _NumberInputStepState();
}

class _NumberInputStepState extends ConsumerState<NumberInputStep> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initFields();
    _loadExistingData();
    // Add listeners AFTER loading existing data to avoid triggering
    // provider updates during the build phase.
    for (final c in _controllers.values) {
      c.addListener(_reportData);
    }
    // Defer initial report to after the widget tree is done building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reportData();
    });
  }

  /// Key used when the step has no options – derived from stepKey or title.
  String get _fallbackKey =>
      widget.step.stepKey?.toLowerCase() ??
      widget.step.title?.toLowerCase() ??
      'value';

  void _initFields() {
    final options = widget.step.options;
    if (options.isNotEmpty) {
      for (final opt in options) {
        final key = opt.optionKey ?? opt.label ?? 'field_${opt.optionId}';
        _controllers[key] = TextEditingController();
      }
    } else {
      _controllers[_fallbackKey] = TextEditingController();
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
      c.removeListener(_reportData);
      c.dispose();
    }
    super.dispose();
  }

  void _reportData() {
    final Map<String, dynamic> data = {};
    bool allValid = true;
    for (final entry in _controllers.entries) {
      final text = entry.value.text.trim();
      if (text.isEmpty) {
        allValid = false;
        break;
      }
      final numValue = num.tryParse(text);
      if (numValue == null) {
        allValid = false;
        break;
      }
      data[entry.key] = numValue;
    }
    ref.read(onboardingViewModelProvider.notifier)
        .updateStepData(allValid ? data : null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = widget.step.options;
    final hasOptions = options.isNotEmpty;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
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
                key: _fallbackKey,
                label: widget.step.title ?? 'Value',
                hint: '',
                suffix: '',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (num.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
            ],
            if (widget.step.helpText != null) ...[
              const SizedBox(height: 24),
              _buildHelpText(theme, widget.step.helpText!),
            ],
            const SizedBox(height: 24),
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

  Widget _buildHelpText(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
