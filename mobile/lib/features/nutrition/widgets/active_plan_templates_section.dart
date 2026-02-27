import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../models/nutrition_models.dart';
import 'plan_meal_template_card.dart';

class ActivePlanTemplatesSection extends StatelessWidget {
  final List<MealTemplate> templates;
  final VoidCallback onManageTemplates;

  const ActivePlanTemplatesSection({
    super.key,
    required this.templates,
    required this.onManageTemplates,
  });

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Plan meals',
              style: theme.textTheme.titleMedium,
            ),
            TextButton(
              onPressed: onManageTemplates,
              child: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: templates.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimensions.spacing8),
          itemBuilder: (context, index) {
            final template = templates[index];
            return PlanMealTemplateCard(template: template);
          },
        ),
      ],
    );
  }
}

