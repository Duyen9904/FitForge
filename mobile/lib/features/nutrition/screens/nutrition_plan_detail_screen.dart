import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/nutrition_models.dart';
import '../models/nutrition_requests.dart';
import '../viewmodels/nutrition_plan_viewmodel.dart';

class NutritionPlanDetailScreen extends ConsumerStatefulWidget {
  const NutritionPlanDetailScreen({super.key});

  @override
  ConsumerState<NutritionPlanDetailScreen> createState() =>
      _NutritionPlanDetailScreenState();
}

class _NutritionPlanDetailScreenState
    extends ConsumerState<NutritionPlanDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(nutritionPlanViewModelProvider.notifier).loadActivePlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionPlanViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: state.when(
          initial: () => _buildNoPlan(),
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
          loaded: (plan, days) => _PlanView(plan: plan, days: days),
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

  Widget _buildNoPlan() {
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

          // RCM Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(nutritionPlanViewModelProvider.notifier)
                    .generateRecommendedPlan();
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Recommended Plan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // AI Generate button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(nutritionPlanViewModelProvider.notifier)
                    .generateAiPlan();
              },
              icon: const Icon(Icons.smart_toy_outlined),
              label: const Text('Generate with AI'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanView extends ConsumerStatefulWidget {
  final NutritionPlan plan;
  final List<NutritionDay> days;

  const _PlanView({required this.plan, required this.days});

  @override
  ConsumerState<_PlanView> createState() => _PlanViewState();
}

class _PlanViewState extends ConsumerState<_PlanView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatsController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.plan.planName);
    _caloriesController = TextEditingController(
        text: widget.plan.dailyCalorieTarget.toString());
    _proteinController = TextEditingController(
        text: widget.plan.proteinPercentage.toStringAsFixed(0));
    _carbsController = TextEditingController(
        text: widget.plan.carbsPercentage.toStringAsFixed(0));
    _fatsController = TextEditingController(
        text: widget.plan.fatsPercentage.toStringAsFixed(0));
  }

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
    final plan = widget.plan;

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          // ── Plan summary card ──
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withAlpha(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.planName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _SummaryChip(
                      label: '${plan.dailyCalorieTarget} kcal',
                      icon: Icons.local_fire_department_rounded,
                    ),
                    const SizedBox(width: 8),
                    _SummaryChip(
                      label: 'P ${plan.proteinGrams.toStringAsFixed(0)}g',
                      icon: Icons.fitness_center,
                    ),
                    const SizedBox(width: 8),
                    _SummaryChip(
                      label: 'C ${plan.carbsGrams.toStringAsFixed(0)}g',
                      icon: Icons.grain,
                    ),
                    const SizedBox(width: 8),
                    _SummaryChip(
                      label: 'F ${plan.fatsGrams.toStringAsFixed(0)}g',
                      icon: Icons.water_drop,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),

          // ── Edit form ──
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Plan name'),
          ),
          const SizedBox(height: AppDimensions.spacing12),
          TextFormField(
            controller: _caloriesController,
            decoration: const InputDecoration(labelText: 'Daily calories'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          TextFormField(
            controller: _proteinController,
            decoration: const InputDecoration(labelText: 'Protein %'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          TextFormField(
            controller: _carbsController,
            decoration: const InputDecoration(labelText: 'Carbs %'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          TextFormField(
            controller: _fatsController,
            decoration: const InputDecoration(labelText: 'Fats %'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppDimensions.spacing24),

          // ── Save button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // ── Auto-Adjust button ──
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(nutritionPlanViewModelProvider.notifier)
                    .adjustPlanBasedOnBehavior(plan.nutritionPlanId);
              },
              icon: const Icon(Icons.tune),
              label: const Text('Auto-Adjust Based on Behavior'),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),

          // ── AI Adjust button ──
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(nutritionPlanViewModelProvider.notifier)
                    .adjustPlanWithAi(plan.nutritionPlanId);
              },
              icon: const Icon(Icons.smart_toy_outlined),
              label: const Text('Adjust with AI'),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),

          // ── Plan Days & Meals ──
          if (widget.days.isNotEmpty) ...[
            Text(
              'Plan Days',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.grey900,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            ...widget.days.map((day) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing12,
                    vertical: AppDimensions.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Day ${day.dayNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (day.dayName != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          day.dayName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (day.targetCalories != null)
                        Text(
                          '${day.targetCalories} kcal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey500,
                          ),
                        ),
                      if (day.isRestDay)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Rest',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing8),
                // Day meals
                ...day.meals.map((dayMeal) {
                  final template = dayMeal.mealTemplate;
                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: AppDimensions.spacing8,
                      left: AppDimensions.spacing8,
                    ),
                    padding: const EdgeInsets.all(AppDimensions.spacing12),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _mealTypeIcon(dayMeal.mealType.name),
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                template?.mealName ?? dayMeal.mealType.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${dayMeal.calories ?? template?.calories ?? 0} kcal · P ${(dayMeal.proteinG ?? template?.proteinG)?.toStringAsFixed(0) ?? '-'}g · C ${(dayMeal.carbsG ?? template?.carbsG)?.toStringAsFixed(0) ?? '-'}g · F ${(dayMeal.fatsG ?? template?.fatsG)?.toStringAsFixed(0) ?? '-'}g',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppDimensions.spacing8),
              ],
            )),
          ],
          const SizedBox(height: AppDimensions.spacing24),
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
        .updatePlan(widget.plan.nutritionPlanId, dto);
    Navigator.of(context).pop();
  }

  IconData _mealTypeIcon(String mealType) {
    switch (mealType.toUpperCase()) {
      case 'BREAKFAST':
        return Icons.wb_sunny_outlined;
      case 'LUNCH':
        return Icons.restaurant_outlined;
      case 'DINNER':
        return Icons.nightlight_outlined;
      case 'SNACK':
        return Icons.cookie_outlined;
      default:
        return Icons.restaurant;
    }
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SummaryChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
