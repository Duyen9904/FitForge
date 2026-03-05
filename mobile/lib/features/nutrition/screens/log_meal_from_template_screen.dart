import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/nutrition_models.dart';
import '../models/nutrition_requests.dart';
import '../repositories/nutrition_repository.dart';
import '../viewmodels/nutrition_tab_viewmodel.dart';

class LogMealFromTemplateScreen extends ConsumerStatefulWidget {
  final List<MealTemplate> templates;

  const LogMealFromTemplateScreen({
    super.key,
    required this.templates,
  });

  @override
  ConsumerState<LogMealFromTemplateScreen> createState() =>
      _LogMealFromTemplateScreenState();
}

class _LogMealFromTemplateScreenState
    extends ConsumerState<LogMealFromTemplateScreen> {
  MealTemplate? _selectedTemplate;
  final _quantityController = TextEditingController(text: '1');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log from Template'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          children: [
            DropdownButtonFormField<MealTemplate>(
              value: _selectedTemplate,
              decoration:
                  const InputDecoration(labelText: 'Meal template'),
              items: widget.templates
                  .map(
                    (template) => DropdownMenuItem(
                      value: template,
                      child: Text(template.mealName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedTemplate = value);
              },
            ),
            const SizedBox(height: AppDimensions.spacing12),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity multiplier',
              ),
              keyboardType: TextInputType.number,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Log Meal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedTemplate == null) return;

    setState(() => _isSubmitting = true);

    final dto = LogMealFromTemplateRequestDto(
      templateId: _selectedTemplate!.mealTemplateId,
      quantityMultiplier:
          double.tryParse(_quantityController.text) ?? 1.0,
      logDate: DateTime.now(),
    );

    try {
      final repo = ref.read(nutritionRepositoryProvider);
      await repo.logMealFromTemplate(dto);

      // Refresh nutrition tab data after logging
      ref.read(nutritionTabViewModelProvider.notifier).loadAll();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal logged from template!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log meal: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
