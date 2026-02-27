import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../models/nutrition_models.dart';
import '../models/nutrition_requests.dart';

class LogMealFromTemplateScreen extends StatefulWidget {
  final List<MealTemplate> templates;

  const LogMealFromTemplateScreen({
    super.key,
    required this.templates,
  });

  @override
  State<LogMealFromTemplateScreen> createState() =>
      _LogMealFromTemplateScreenState();
}

class _LogMealFromTemplateScreenState
    extends State<LogMealFromTemplateScreen> {
  MealTemplate? _selectedTemplate;
  final _quantityController = TextEditingController(text: '1');

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log from template'),
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
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Log meal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_selectedTemplate == null) return;

    final dto = LogMealFromTemplateRequestDto(
      templateId: _selectedTemplate!.mealTemplateId,
      quantityMultiplier:
          double.tryParse(_quantityController.text) ?? 1.0,
      logDate: DateTime.now(),
    );

    Navigator.of(context).pop(dto);
  }
}

