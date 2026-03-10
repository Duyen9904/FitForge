import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../viewmodels/log_meal_viewmodel.dart';
import '../widgets/log_meal_extras_section.dart';
import '../widgets/log_meal_ingredients_section.dart';
import '../widgets/log_meal_macro_slider.dart';
import '../widgets/log_meal_name_section.dart';
import '../widgets/log_meal_type_section.dart';

class LogMealScreen extends ConsumerWidget {
  const LogMealScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logMealViewModelProvider);
    final vm = ref.read(logMealViewModelProvider.notifier);

    // React to submission result
    ref.listen(logMealViewModelProvider, (prev, next) {
      if (next.isSubmitted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal logged successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
      if (next.errorMessage != null && prev?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log meal: ${next.errorMessage}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Log Meal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing16,
                vertical: AppDimensions.spacing8,
              ),
              child: Column(
                children: [
                  LogMealNameSection(
                    value: state.foodName,
                    onChanged: vm.setFoodName,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  LogMealTypeSection(
                    selectedType: state.mealType,
                    onChanged: vm.setMealType,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  LogMealIngredientsSection(
                    selectedIngredients: state.selectedIngredients,
                    onToggle: vm.toggleIngredient,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  LogMealMacroSlider(
                    label: 'Calories',
                    value: state.calories,
                    max: 2000,
                    unit: 'kcal',
                    activeColor: const Color(0xFFFF8C00),
                    onChanged: vm.setCalories,
                  ),
                  const SizedBox(height: AppDimensions.spacing12),
                  LogMealMacroSlider(
                    label: 'Total Protein',
                    value: state.proteinG,
                    max: 150,
                    unit: 'g',
                    activeColor: const Color(0xFFFF8C00),
                    onChanged: vm.setProtein,
                  ),
                  const SizedBox(height: AppDimensions.spacing12),
                  LogMealMacroSlider(
                    label: 'Total Carbs',
                    value: state.carbsG,
                    max: 300,
                    unit: 'g',
                    activeColor: const Color(0xFF22C55E),
                    onChanged: vm.setCarbs,
                  ),
                  const SizedBox(height: AppDimensions.spacing12),
                  LogMealMacroSlider(
                    label: 'Total Fats',
                    value: state.fatsG,
                    max: 100,
                    unit: 'g',
                    activeColor: const Color(0xFF3B82F6),
                    onChanged: vm.setFats,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  LogMealExtrasSection(
                    isCheatMeal: state.isCheatMeal,
                    onCheatMealChanged: vm.setCheatMeal,
                    notes: state.notes,
                    onNotesChanged: vm.setNotes,
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                ],
              ),
            ),
          ),
          _SubmitButton(
            isSubmitting: state.isSubmitting,
            canSubmit: vm.canSubmit,
            onPressed: vm.submit,
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final bool canSubmit;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isSubmitting,
    required this.canSubmit,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacing16,
          AppDimensions.spacing8,
          AppDimensions.spacing16,
          AppDimensions.spacing16,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: canSubmit ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              disabledBackgroundColor:
                  const Color(0xFFFF8C00).withValues(alpha: 0.4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Add Meal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
