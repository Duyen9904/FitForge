import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/nutrition_models.dart';
import '../viewmodels/meal_templates_viewmodel.dart';
import '../widgets/meal_template_list_card.dart';

/// Screen displaying a list of meal template cards
class MealTemplatesScreen extends ConsumerStatefulWidget {
  const MealTemplatesScreen({super.key});

  @override
  ConsumerState<MealTemplatesScreen> createState() =>
      _MealTemplatesScreenState();
}

class _MealTemplatesScreenState extends ConsumerState<MealTemplatesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mealTemplatesViewModelProvider.notifier).loadTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealTemplatesViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Meal Templates',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(error.toString()),
        data: (templates) =>
            templates.isEmpty ? _buildEmpty() : _buildList(templates),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.grey400),
            const SizedBox(height: AppDimensions.spacing12),
            Text(
              'Failed to load templates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.grey500),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            TextButton.icon(
              onPressed: () {
                ref
                    .read(mealTemplatesViewModelProvider.notifier)
                    .loadTemplates();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu, size: 56, color: AppColors.grey300),
            const SizedBox(height: AppDimensions.spacing12),
            Text(
              'No Meal Templates',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Your meal templates will appear here once created.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<MealTemplate> templates) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing12,
      ),
      itemCount: templates.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spacing12),
      itemBuilder: (context, index) =>
          MealTemplateCard(template: templates[index]),
    );
  }
}
