import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../models/nutrition_models.dart';

class NutritionTemplatesSection extends StatelessWidget {
  final List<MealTemplate> templates;
  final VoidCallback onManageTemplates;

  const NutritionTemplatesSection({
    super.key,
    required this.templates,
    required this.onManageTemplates,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meal templates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: onManageTemplates,
              child: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing8),
        if (templates.isEmpty)
          Text(
            'No templates yet. Create one from a logged meal.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          Wrap(
            spacing: AppDimensions.spacing8,
            runSpacing: AppDimensions.spacing8,
            children: templates
                .take(6)
                .map(
                  (template) => Chip(
                    label: Text(template.mealName),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

