import 'package:flutter/material.dart';
import '../../models/onboarding_response.dart';
import '../onboarding_option_card.dart';

/// Equipment step - multi-select from admin-configured equipment options
class EquipmentStep extends StatefulWidget {
  final OnboardingStepResponse step;
  final Function(Map<String, dynamic>) onSubmit;
  final String? existingData;

  const EquipmentStep({
    super.key,
    required this.step,
    required this.onSubmit,
    this.existingData,
  });

  @override
  State<EquipmentStep> createState() => _EquipmentStepState();
}

class _EquipmentStepState extends State<EquipmentStep> {
  final Set<String> _selectedEquipment = {};

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData != null && widget.existingData!.isNotEmpty) {
      // TODO: Parse JSON and pre-select equipment
    }
  }

  void _toggleEquipment(String equipmentKey) {
    setState(() {
      if (_selectedEquipment.contains(equipmentKey)) {
        _selectedEquipment.remove(equipmentKey);
      } else {
        _selectedEquipment.add(equipmentKey);
      }
    });
  }

  void _submit() {
    widget.onSubmit({
      'selectedOptions': _selectedEquipment.toList(),
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
            widget.step.title ?? 'Available Equipment',
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
          const SizedBox(height: 4),
          Text(
            'Select all equipment you have access to',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Quick presets
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Select',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPresetChip(
                      theme: theme,
                      label: 'Home Gym',
                      icon: Icons.home,
                      onTap: () {
                        setState(() {
                          _selectedEquipment.clear();
                          // Select common home gym equipment
                          for (final opt in options) {
                            if (['DUMBBELLS', 'RESISTANCE_BANDS', 'PULL_UP_BAR', 'YOGA_MAT']
                                .contains(opt.optionKey?.toUpperCase())) {
                              _selectedEquipment.add(opt.optionKey ?? '');
                            }
                          }
                        });
                      },
                    ),
                    _buildPresetChip(
                      theme: theme,
                      label: 'Full Gym',
                      icon: Icons.fitness_center,
                      onTap: () {
                        setState(() {
                          _selectedEquipment.clear();
                          for (final opt in options) {
                            _selectedEquipment.add(opt.optionKey ?? '');
                          }
                        });
                      },
                    ),
                    _buildPresetChip(
                      theme: theme,
                      label: 'Bodyweight Only',
                      icon: Icons.self_improvement,
                      onTap: () {
                        setState(() {
                          _selectedEquipment.clear();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Equipment options
          ...options.map((option) {
            final isSelected = _selectedEquipment.contains(option.optionKey);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OnboardingOptionCard(
                label: option.label ?? option.optionKey ?? '',
                description: option.description,
                iconUrl: option.iconUrl,
                isSelected: isSelected,
                onTap: () => _toggleEquipment(option.optionKey ?? ''),
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

  Widget _buildPresetChip({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
