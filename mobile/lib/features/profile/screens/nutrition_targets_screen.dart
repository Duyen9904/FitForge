import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/network/api_client.dart';

/// Nutrition targets screen: daily calories, protein, carbs, fats.
class NutritionTargetsScreen extends ConsumerStatefulWidget {
  const NutritionTargetsScreen({super.key});

  @override
  ConsumerState<NutritionTargetsScreen> createState() =>
      _NutritionTargetsScreenState();
}

class _NutritionTargetsScreenState
    extends ConsumerState<NutritionTargetsScreen> {
  bool _loading = true;
  bool _saving = false;

  final _calorieController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiConstants.userPreferences);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final prefs = data['data'] as Map<String, dynamic>;
        setState(() {
          _calorieController.text =
              (prefs['dailyCalorieTarget'] ?? '').toString();
          _proteinController.text =
              (prefs['dailyProteinTargetG'] ?? '').toString();
          _carbsController.text =
              (prefs['dailyCarbsTargetG'] ?? '').toString();
          _fatsController.text =
              (prefs['dailyFatsTargetG'] ?? '').toString();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.put(
        ApiConstants.userPreferences,
        data: {
          'dailyCalorieTarget':
              int.tryParse(_calorieController.text.trim()),
          'dailyProteinTargetG':
              double.tryParse(_proteinController.text.trim()),
          'dailyCarbsTargetG':
              double.tryParse(_carbsController.text.trim()),
          'dailyFatsTargetG':
              double.tryParse(_fatsController.text.trim()),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nutrition targets saved!'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Targets'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
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
                Text(
                  'Set your daily nutrition targets to track your intake.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing24),
                _NutrientField(
                  controller: _calorieController,
                  label: 'Daily Calories',
                  unit: 'kcal',
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                ),
                const SizedBox(height: AppDimensions.spacing16),
                _NutrientField(
                  controller: _proteinController,
                  label: 'Protein',
                  unit: 'g',
                  icon: Icons.egg_alt,
                  iconColor: Colors.redAccent,
                ),
                const SizedBox(height: AppDimensions.spacing16),
                _NutrientField(
                  controller: _carbsController,
                  label: 'Carbohydrates',
                  unit: 'g',
                  icon: Icons.grain,
                  iconColor: Colors.amber,
                ),
                const SizedBox(height: AppDimensions.spacing16),
                _NutrientField(
                  controller: _fatsController,
                  label: 'Fats',
                  unit: 'g',
                  icon: Icons.water_drop,
                  iconColor: Colors.teal,
                ),
              ],
            ),
    );
  }
}

class _NutrientField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String unit;
  final IconData icon;
  final Color iconColor;

  const _NutrientField({
    required this.controller,
    required this.label,
    required this.unit,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        prefixIcon: Icon(icon, color: iconColor),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
