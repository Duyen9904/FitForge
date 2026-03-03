import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/network/api_client.dart';

/// Training preferences screen: workout duration, time, reminders, AI toggle.
class TrainingPreferencesScreen extends ConsumerStatefulWidget {
  const TrainingPreferencesScreen({super.key});

  @override
  ConsumerState<TrainingPreferencesScreen> createState() =>
      _TrainingPreferencesScreenState();
}

class _TrainingPreferencesScreenState
    extends ConsumerState<TrainingPreferencesScreen> {
  bool _loading = true;
  int _workoutDuration = 45;
  String _workoutTime = 'MORNING';
  String _reminderDays = 'MON,WED,FRI';
  bool _allowAiSuggestions = true;
  bool _saving = false;

  final _timeOptions = ['MORNING', 'AFTERNOON', 'EVENING'];
  final _dayOptions = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiConstants.userPreferences);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final prefs = data['data'] as Map<String, dynamic>;
        setState(() {
          _workoutDuration =
              (prefs['preferredWorkoutDuration'] as int?) ?? 45;
          _workoutTime =
              (prefs['preferredWorkoutTime'] as String?) ?? 'MORNING';
          _reminderDays =
              (prefs['workoutReminderDays'] as String?) ?? 'MON,WED,FRI';
          _allowAiSuggestions =
              (prefs['allowAiSuggestions'] as bool?) ?? true;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveAll() async {
    setState(() => _saving = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.put(
        ApiConstants.userPreferences,
        data: {
          'preferredWorkoutDuration': _workoutDuration,
          'preferredWorkoutTime': _workoutTime,
          'workoutReminderDays': _reminderDays,
          'allowAiSuggestions': _allowAiSuggestions,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferences saved!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  Set<String> get _selectedDays => _reminderDays.split(',').toSet();

  void _toggleDay(String day) {
    final days = _selectedDays;
    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
    }
    setState(() {
      _reminderDays = _dayOptions.where((d) => days.contains(d)).join(',');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Preferences'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveAll,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              children: [
                // Workout Duration
                Text('Workout Duration',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppDimensions.spacing8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _workoutDuration.toDouble(),
                        min: 15,
                        max: 120,
                        divisions: 21,
                        label: '$_workoutDuration min',
                        onChanged: (value) =>
                            setState(() => _workoutDuration = value.round()),
                      ),
                    ),
                    SizedBox(
                      width: 64,
                      child: Text(
                        '$_workoutDuration min',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // Preferred Time
                Text('Preferred Workout Time',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppDimensions.spacing8),
                SegmentedButton<String>(
                  segments: _timeOptions
                      .map((t) => ButtonSegment(
                            value: t,
                            label: Text(t[0] + t.substring(1).toLowerCase()),
                          ))
                      .toList(),
                  selected: {_workoutTime},
                  onSelectionChanged: (selected) =>
                      setState(() => _workoutTime = selected.first),
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // Reminder Days
                Text('Workout Reminder Days',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppDimensions.spacing8),
                Wrap(
                  spacing: AppDimensions.spacing8,
                  children: _dayOptions.map((day) {
                    final selected = _selectedDays.contains(day);
                    return FilterChip(
                      label: Text(day),
                      selected: selected,
                      onSelected: (_) => _toggleDay(day),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // AI Suggestions
                SwitchListTile(
                  title: const Text('AI Workout Suggestions'),
                  subtitle: const Text(
                      'Let AI suggest workout adjustments'),
                  value: _allowAiSuggestions,
                  onChanged: (value) =>
                      setState(() => _allowAiSuggestions = value),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
    );
  }
}
