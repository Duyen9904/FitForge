import 'package:flutter/material.dart';
import '../../models/onboarding_response.dart';
import '../onboarding_option_card.dart';

/// Fitness level step - single select from admin-configured options
class FitnessLevelStep extends StatefulWidget {
  final OnboardingStepResponse step;
  final Function(Map<String, dynamic>) onSubmit;
  final String? existingData;

  const FitnessLevelStep({
    super.key,
    required this.step,
    required this.onSubmit,
    this.existingData,
  });

  @override
  State<FitnessLevelStep> createState() => _FitnessLevelStepState();
}

class _FitnessLevelStepState extends State<FitnessLevelStep> {
  String? _selectedOptionKey;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData != null && widget.existingData!.isNotEmpty) {
      // TODO: Parse JSON and pre-select option
    }
  }

  void _submit() {
    if (_selectedOptionKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your fitness level')),
      );
      return;
    }

    widget.onSubmit({
      'selectedOption': _selectedOptionKey,
    });
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
          // Header
          Text(
            widget.step.title ?? 'Fitness Level',
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

          // Options list
          ...options.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OnboardingOptionCard(
                label: option.label ?? option.optionKey ?? '',
                description: option.description,
                iconUrl: option.iconUrl,
                isSelected: _selectedOptionKey == option.optionKey,
                onTap: () {
                  setState(() {
                    _selectedOptionKey = option.optionKey;
                  });
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
    );
  }
}
