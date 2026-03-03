import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

/// App settings screen: Units, Theme, Notifications.
class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  bool _loading = true;
  String _measurementUnit = 'METRIC';
  bool _notificationEnabled = true;

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
          _measurementUnit =
              (prefs['measurementUnit'] as String?) ?? 'METRIC';
          _notificationEnabled =
              (prefs['notificationEnabled'] as bool?) ?? true;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updatePreference(String key, dynamic value) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.put(
        ApiConstants.userPreferences,
        data: {key: value},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Units
                ListTile(
                  leading: const Icon(Icons.straighten),
                  title: const Text('Measurement Units'),
                  subtitle: Text(_measurementUnit == 'METRIC'
                      ? 'Metric (kg, cm)'
                      : 'Imperial (lbs, ft)'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'METRIC', label: Text('Metric')),
                      ButtonSegment(
                          value: 'IMPERIAL', label: Text('Imperial')),
                    ],
                    selected: {_measurementUnit},
                    onSelectionChanged: (selected) {
                      final unit = selected.first;
                      setState(() => _measurementUnit = unit);
                      _updatePreference('measurementUnit', unit);
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      textStyle: WidgetStatePropertyAll(
                        theme.textTheme.labelSmall,
                      ),
                    ),
                  ),
                ),
                const Divider(indent: 72),

                // Theme (client-only)
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Theme'),
                  subtitle: const Text('System default'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implement theme selection dialog (SharedPreferences)
                  },
                ),
                const Divider(indent: 72),

                // Notifications
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  subtitle: const Text('Workout reminders & alerts'),
                  value: _notificationEnabled,
                  onChanged: (value) {
                    setState(() => _notificationEnabled = value);
                    _updatePreference('notificationEnabled', value);
                  },
                ),
              ],
            ),
    );
  }
}
