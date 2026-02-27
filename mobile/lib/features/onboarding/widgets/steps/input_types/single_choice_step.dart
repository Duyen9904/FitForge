import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../models/onboarding_response.dart';
import '../../onboarding_option_card.dart';

/// Generic SINGLE_CHOICE step - one option selected from step.options.
class SingleChoiceStep extends StatefulWidget {
  final OnboardingStepResponse step;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onSkip;
  final String? existingData;

  const SingleChoiceStep({
    super.key,
    required this.step,
    required this.onSubmit,
    this.onSkip,
    this.existingData,
  });

  @override
  State<SingleChoiceStep> createState() => _SingleChoiceStepState();
}

class _SingleChoiceStepState extends State<SingleChoiceStep> {
  String? _selectedOptionKey;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final data = widget.existingData ?? widget.step.responseData;
    if (data == null || data.isEmpty) return;
    try {
      final map = jsonDecode(data) as Map<String, dynamic>?;
      if (map == null) return;
      final selected = map['selectedOption'];
      if (selected != null) _selectedOptionKey = selected.toString();
    } catch (_) {}
  }

  void _submit() {
    if (_selectedOptionKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option')),
      );
      return;
    }
    widget.onSubmit({'selectedOption': _selectedOptionKey});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = widget.step.options;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.step.title ?? 'Select one',
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
          const SizedBox(height: 24),
          ...options.map((option) {
            final key = option.optionKey ?? option.optionId?.toString() ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OnboardingOptionCard(
                label: option.label ?? option.optionKey ?? '',
                description: option.description,
                iconUrl: option.iconUrl,
                isSelected: _selectedOptionKey == key,
                onTap: () {
                  setState(() => _selectedOptionKey = key);
                },
              ),
            );
          }),
          if (widget.step.helpText != null) ...[
            const SizedBox(height: 16),
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
    );
  }
}
