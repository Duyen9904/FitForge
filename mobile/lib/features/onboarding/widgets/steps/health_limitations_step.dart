import 'package:flutter/material.dart';
import '../../models/onboarding_response.dart';
import '../onboarding_option_card.dart';

/// Health limitations step - optional multi-select for injuries/conditions
class HealthLimitationsStep extends StatefulWidget {
  final OnboardingStepResponse step;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onSkip;
  final String? existingData;

  const HealthLimitationsStep({
    super.key,
    required this.step,
    required this.onSubmit,
    this.onSkip,
    this.existingData,
  });

  @override
  State<HealthLimitationsStep> createState() => _HealthLimitationsStepState();
}

class _HealthLimitationsStepState extends State<HealthLimitationsStep> {
  final Set<String> _selectedLimitations = {};
  bool _hasNoLimitations = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData != null && widget.existingData!.isNotEmpty) {
      // TODO: Parse JSON and pre-select limitations
    }
  }

  void _toggleLimitation(String key) {
    setState(() {
      _hasNoLimitations = false;
      if (_selectedLimitations.contains(key)) {
        _selectedLimitations.remove(key);
      } else {
        _selectedLimitations.add(key);
      }
    });
  }

  void _selectNone() {
    setState(() {
      _hasNoLimitations = true;
      _selectedLimitations.clear();
    });
  }

  void _submit() {
    if (_hasNoLimitations) {
      widget.onSubmit({
        'selectedOptions': <String>[],
        'noLimitations': true,
      });
    } else {
      widget.onSubmit({
        'selectedOptions': _selectedLimitations.toList(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = widget.step.options;
    final isOptional = widget.step.isRequired != true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            widget.step.title ?? 'Health Limitations',
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
          if (isOptional) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Optional',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // No limitations option
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OnboardingOptionCard(
              label: 'No limitations',
              description: 'I don\'t have any injuries or health conditions',
              isSelected: _hasNoLimitations,
              onTap: _selectNone,
            ),
          ),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR SELECT ANY THAT APPLY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3))),
            ],
          ),
          const SizedBox(height: 12),

          // Limitation options
          ...options.map((option) {
            final isSelected = _selectedLimitations.contains(option.optionKey);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OnboardingOptionCard(
                label: option.label ?? option.optionKey ?? '',
                description: option.description,
                iconUrl: option.iconUrl,
                isSelected: isSelected,
                onTap: () => _toggleLimitation(option.optionKey ?? ''),
              ),
            );
          }),

          if (widget.step.helpText != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.step.helpText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Buttons
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
          if (isOptional && widget.onSkip != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: widget.onSkip,
                child: const Text('Skip for now'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
