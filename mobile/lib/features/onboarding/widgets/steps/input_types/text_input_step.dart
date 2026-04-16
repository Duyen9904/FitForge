import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/onboarding_response.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';

/// Generic TEXT input step - one or more text fields driven by step.options or default.
/// Calls the ViewModel directly via Riverpod on user interaction.
class TextInputStep extends ConsumerStatefulWidget {
  final OnboardingStepResponse step;
  final String? existingData;

  const TextInputStep({
    super.key,
    required this.step,
    this.existingData,
  });

  @override
  ConsumerState<TextInputStep> createState() => _TextInputStepState();
}

class _TextInputStepState extends ConsumerState<TextInputStep> {
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
      c.removeListener(_reportData);
      c.dispose();
    }
    super.dispose();
  }

  void _reportData() {
    final allFilled = _controllers.values.every(
      (c) => c.text.trim().isNotEmpty,
    );
    if (allFilled) {
      final Map<String, dynamic> data = {};
      for (final entry in _controllers.entries) {
        data[entry.key] = entry.value.text.trim();
      }
      ref.read(onboardingViewModelProvider.notifier).updateStepData(data);
    } else {
      ref.read(onboardingViewModelProvider.notifier).updateStepData(null);
    }
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
              _buildHelpText(theme, widget.step.helpText!),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
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
