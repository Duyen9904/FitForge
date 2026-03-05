import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        title: const Text('Nutrition plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: state.maybeWhen(
          loaded: (plan) => _PlanForm(planId: plan.nutritionPlanId),
          orElse: () => const Center(
            child: Text('No active nutrition plan'),
          ),
        ),
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
              child: const Text('Save changes'),
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

