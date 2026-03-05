import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/nutrition_requests.dart';
import '../viewmodels/nutrition_plan_viewmodel.dart';

class NutritionPlanDetailScreen extends ConsumerWidget {
  const NutritionPlanDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionPlanViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: state.when(
          initial: () => _buildNoPlan(context, ref),
          loading: () => const Center(child: CircularProgressIndicator()),
          generating: () => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppDimensions.spacing12),
                Text('Generating your plan...'),
              ],
            ),
          ),
          updating: (currentPlan) => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppDimensions.spacing12),
                Text('Adjusting your plan...'),
              ],
            ),
          ),
          loaded: (plan) => _PlanForm(planId: plan.nutritionPlanId),
          error: (message) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: AppDimensions.spacing12),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: AppDimensions.spacing16),
                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(nutritionPlanViewModelProvider.notifier)
                        .loadActivePlan();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoPlan(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant_menu, size: 56, color: AppColors.grey300),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            'No Active Nutrition Plan',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            'Generate a personalized plan based on your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.grey500),
          ),
          const SizedBox(height: AppDimensions.spacing24),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(nutritionPlanViewModelProvider.notifier)
                  .generateRecommendedPlan();
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Plan'),
          ),
        ],
      ),
    );
  }
}

class _PlanForm extends ConsumerStatefulWidget {
  final int planId;

  const _PlanForm({required this.planId});

  @override
  ConsumerState<_PlanForm> createState() => _PlanFormState();
}

class _PlanFormState extends ConsumerState<_PlanForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Plan name',
            ),
          ),
          const SizedBox(height: AppDimensions.spacing12),
          TextFormField(
            controller: _caloriesController,
            decoration: const InputDecoration(
              labelText: 'Daily calories',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          TextFormField(
            controller: _proteinController,
            decoration: const InputDecoration(
              labelText: 'Protein %',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          TextFormField(
            controller: _carbsController,
            decoration: const InputDecoration(
              labelText: 'Carbs %',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          TextFormField(
            controller: _fatsController,
            decoration: const InputDecoration(
              labelText: 'Fats %',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppDimensions.spacing24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(nutritionPlanViewModelProvider.notifier)
                    .adjustPlanBasedOnBehavior(widget.planId);
              },
              icon: const Icon(Icons.tune),
              label: const Text('Auto-Adjust Based on Behavior'),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final dto = UpdateNutritionPlanRequestDto(
      planName: _nameController.text.isEmpty ? null : _nameController.text,
      dailyCalorieTarget: _caloriesController.text.isEmpty
          ? null
          : int.tryParse(_caloriesController.text),
      proteinPercentage: _proteinController.text.isEmpty
          ? null
          : double.tryParse(_proteinController.text),
      carbsPercentage: _carbsController.text.isEmpty
          ? null
          : double.tryParse(_carbsController.text),
      fatsPercentage: _fatsController.text.isEmpty
          ? null
          : double.tryParse(_fatsController.text),
    );

    ref
        .read(nutritionPlanViewModelProvider.notifier)
        .updatePlan(widget.planId, dto);
    Navigator.of(context).pop();
  }
}
