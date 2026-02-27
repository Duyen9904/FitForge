import 'package:flutter/material.dart';
import '../../models/onboarding_response.dart';

/// Notifications step - toggle switches for notification preferences
class NotificationsStep extends StatefulWidget {
  final OnboardingStepResponse step;
  final Function(Map<String, dynamic>) onSubmit;
  final String? existingData;

  const NotificationsStep({
    super.key,
    required this.step,
    required this.onSubmit,
    this.existingData,
  });

  @override
  State<NotificationsStep> createState() => _NotificationsStepState();
}

class _NotificationsStepState extends State<NotificationsStep> {
  bool _workoutReminders = true;
  bool _progressUpdates = true;
  bool _achievementAlerts = true;
  bool _streakAlerts = true;
  bool _recoveryAlerts = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData != null && widget.existingData!.isNotEmpty) {
      // TODO: Parse JSON and set toggles
    }
  }

  void _submit() {
    widget.onSubmit({
      'workoutReminders': _workoutReminders,
      'progressUpdates': _progressUpdates,
      'achievementAlerts': _achievementAlerts,
      'streakAlerts': _streakAlerts,
      'recoveryAlerts': _recoveryAlerts,
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
            widget.step.title ?? 'Notifications',
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

          // Notification toggles
          _buildNotificationTile(
            theme: theme,
            icon: Icons.fitness_center,
            title: 'Workout Reminders',
            subtitle: 'Get reminded when it\'s time to work out',
            value: _workoutReminders,
            onChanged: (value) => setState(() => _workoutReminders = value),
          ),
          _buildNotificationTile(
            theme: theme,
            icon: Icons.trending_up,
            title: 'Progress Updates',
            subtitle: 'Weekly summaries and milestone notifications',
            value: _progressUpdates,
            onChanged: (value) => setState(() => _progressUpdates = value),
          ),
          _buildNotificationTile(
            theme: theme,
            icon: Icons.emoji_events,
            title: 'Achievement Alerts',
            subtitle: 'Get notified when you earn new achievements',
            value: _achievementAlerts,
            onChanged: (value) => setState(() => _achievementAlerts = value),
          ),
          _buildNotificationTile(
            theme: theme,
            icon: Icons.local_fire_department,
            title: 'Streak Alerts',
            subtitle: 'Celebrate your workout streaks',
            value: _streakAlerts,
            onChanged: (value) => setState(() => _streakAlerts = value),
          ),
          _buildNotificationTile(
            theme: theme,
            icon: Icons.favorite_border,
            title: 'Recovery Alerts',
            subtitle: 'Get warned about overtraining',
            value: _recoveryAlerts,
            onChanged: (value) => setState(() => _recoveryAlerts = value),
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
              child: const Text('Finish Setup'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: value
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
