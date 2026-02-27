import 'package:flutter/material.dart';
import '../../models/onboarding_response.dart';

/// Schedule step - workout days, duration, and preferred time
class ScheduleStep extends StatefulWidget {
  final OnboardingStepResponse step;
  final Function(Map<String, dynamic>) onSubmit;
  final String? existingData;

  const ScheduleStep({
    super.key,
    required this.step,
    required this.onSubmit,
    this.existingData,
  });

  @override
  State<ScheduleStep> createState() => _ScheduleStepState();
}

class _ScheduleStepState extends State<ScheduleStep> {
  final Set<String> _selectedDays = {};
  int _selectedDuration = 60; // minutes
  String _selectedTimeOfDay = 'MORNING';

  final List<Map<String, dynamic>> _days = [
    {'key': 'MON', 'label': 'Mon'},
    {'key': 'TUE', 'label': 'Tue'},
    {'key': 'WED', 'label': 'Wed'},
    {'key': 'THU', 'label': 'Thu'},
    {'key': 'FRI', 'label': 'Fri'},
    {'key': 'SAT', 'label': 'Sat'},
    {'key': 'SUN', 'label': 'Sun'},
  ];

  final List<int> _durationOptions = [30, 45, 60, 90, 120];

  final List<Map<String, dynamic>> _timeOfDayOptions = [
    {'key': 'MORNING', 'label': 'Morning', 'subtitle': '6 AM - 12 PM', 'icon': Icons.wb_sunny_outlined},
    {'key': 'AFTERNOON', 'label': 'Afternoon', 'subtitle': '12 PM - 5 PM', 'icon': Icons.wb_cloudy_outlined},
    {'key': 'EVENING', 'label': 'Evening', 'subtitle': '5 PM - 10 PM', 'icon': Icons.nightlight_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData != null && widget.existingData!.isNotEmpty) {
      // TODO: Parse JSON and pre-fill
    }
  }

  void _submit() {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one workout day')),
      );
      return;
    }

    widget.onSubmit({
      'days': _selectedDays.toList(),
      'duration': _selectedDuration,
      'timeOfDay': _selectedTimeOfDay,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            widget.step.title ?? 'Workout Schedule',
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

          // Day selection
          Text(
            'Workout Days',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Which days can you work out?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _days.map((day) {
              final isSelected = _selectedDays.contains(day['key']);
              return _buildDayChip(
                theme: theme,
                label: day['label'],
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDays.remove(day['key']);
                    } else {
                      _selectedDays.add(day['key']);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Duration selection
          Text(
            'Workout Duration',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'How long can you work out?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _durationOptions.map((duration) {
              final isSelected = _selectedDuration == duration;
              return ChoiceChip(
                label: Text('$duration min'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedDuration = duration);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Time of day selection
          Text(
            'Preferred Time',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'When do you prefer to work out?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ..._timeOfDayOptions.map((timeOption) {
            final isSelected = _selectedTimeOfDay == timeOption['key'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildTimeCard(
                theme: theme,
                label: timeOption['label'],
                subtitle: timeOption['subtitle'],
                icon: timeOption['icon'],
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selectedTimeOfDay = timeOption['key']);
                },
              ),
            );
          }),

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
    );
  }

  Widget _buildDayChip({
    required ThemeData theme,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard({
    required ThemeData theme,
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
