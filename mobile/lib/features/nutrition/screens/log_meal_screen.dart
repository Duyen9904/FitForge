import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../shared/enums/meal_type.dart';
import '../models/nutrition_requests.dart';
import '../repositories/nutrition_repository.dart';
import '../viewmodels/nutrition_tab_viewmodel.dart';
import '../widgets/meal_plan_checkbox.dart';

/// Common ingredients the user can quickly select.
const _commonIngredients = [
  'Wheat Bread',
  'Egg',
  'Tomato',
  'Broccoli',
  'Cheese',
  'Corn',
  'Carrot',
  'Sweet Potato',
  'Lettuce',
  'Cabbage',
  'Chicken',
  'Rice',
];

class LogMealScreen extends ConsumerStatefulWidget {
  const LogMealScreen({super.key});

  @override
  ConsumerState<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends ConsumerState<LogMealScreen> {
  final _foodNameController = TextEditingController();
  final _notesController = TextEditingController();
  MealType _selectedMealType = MealType.lunch;
  final Set<String> _selectedIngredients = {};

  // Macro sliders
  double _calories = 300;
  double _proteinG = 25;
  double _carbsG = 40;
  double _fatsG = 15;

  bool _isCheatMeal = false;
  bool _isSubmitting = false;

  // Targets (hard-coded upper bounds for sliders)
  static const double _maxCalories = 2000;
  static const double _maxProtein = 150;
  static const double _maxCarbs = 300;
  static const double _maxFats = 100;

  @override
  void dispose() {
    _foodNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ───────────── Build ─────────────
  @override
  Widget build(BuildContext context) {
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
                  _buildMealNameSection(),
                  const SizedBox(height: AppDimensions.spacing16),
                  _buildMealTypeSection(),
                  const SizedBox(height: AppDimensions.spacing16),
                  _buildIngredientsSection(),
                  const SizedBox(height: AppDimensions.spacing16),
                  _buildMacroSection('Calories', _calories, _maxCalories,
                      'kcal', const Color(0xFFFF8C00), (v) {
                    setState(() => _calories = v);
                  }),
                  const SizedBox(height: AppDimensions.spacing12),
                  _buildMacroSection('Total Protein', _proteinG, _maxProtein,
                      'g', const Color(0xFFFF8C00), (v) {
                    setState(() => _proteinG = v);
                  }),
                  const SizedBox(height: AppDimensions.spacing12),
                  _buildMacroSection('Total Carbs', _carbsG, _maxCarbs, 'g',
                      const Color(0xFF22C55E), (v) {
                    setState(() => _carbsG = v);
                  }),
                  const SizedBox(height: AppDimensions.spacing12),
                  _buildMacroSection('Total Fats', _fatsG, _maxFats, 'g',
                      const Color(0xFF3B82F6), (v) {
                    setState(() => _fatsG = v);
                  }),
                  const SizedBox(height: AppDimensions.spacing16),
                  _buildExtrasSection(),
                  const SizedBox(height: AppDimensions.spacing8),
                ],
              ),
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  // ───────────── Meal Name ─────────────
  Widget _buildMealNameSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meal Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          TextFormField(
            controller: _foodNameController,
            decoration: InputDecoration(
              hintText: 'Enter your meal name',
              hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
              filled: true,
              fillColor: AppColors.grey50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFFF8C00), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Meal Type ─────────────
  Widget _buildMealTypeSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Meal Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '1 Selected',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFF8C00),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Wrap(
            spacing: 0,
            runSpacing: 0,
            children: MealType.values.map((type) {
              final isSelected = _selectedMealType == type;
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.38,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => setState(() => _selectedMealType = type),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MealPlanCheckbox(checked: isSelected),
                        const SizedBox(width: 8),
                        Text(
                          type.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFF1A1A2E)
                                : AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ───────────── Ingredients ─────────────
  Widget _buildIngredientsSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '${_selectedIngredients.length} Selected',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFF8C00),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Wrap(
            spacing: 0,
            runSpacing: 0,
            children: _commonIngredients.map((ingredient) {
              final isSelected = _selectedIngredients.contains(ingredient);
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.38,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedIngredients.remove(ingredient);
                      } else {
                        _selectedIngredients.add(ingredient);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MealPlanCheckbox(checked: isSelected),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            ingredient,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFF1A1A2E)
                                  : AppColors.grey500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ───────────── Macro Slider ─────────────
  Widget _buildMacroSection(
    String label,
    double value,
    double max,
    String unit,
    Color activeColor,
    ValueChanged<double> onChanged,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeColor,
              inactiveTrackColor: activeColor.withValues(alpha: 0.15),
              thumbColor: activeColor,
              overlayColor: activeColor.withValues(alpha: 0.12),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: max,
              onChanged: onChanged,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '${value.round()}$unit / ${max.round()}$unit',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Extras (cheat meal + notes) ─────────────
  Widget _buildExtrasSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cheat meal toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cheat Meal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Switch.adaptive(
                value: _isCheatMeal,
                activeColor: const Color(0xFFFF8C00),
                onChanged: (v) => setState(() => _isCheatMeal = v),
              ),
            ],
          ),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.spacing12),
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add notes (optional)',
              hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
              filled: true,
              fillColor: AppColors.grey50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFFF8C00), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Submit Button ─────────────
  Widget _buildSubmitButton() {
    final canSubmit =
        _foodNameController.text.trim().isNotEmpty && !_isSubmitting;

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
            onPressed: canSubmit ? _submit : null,
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
            child: _isSubmitting
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

  // ───────────── Submission ─────────────
  Future<void> _submit() async {
    final foodName = _foodNameController.text.trim();
    if (foodName.isEmpty) return;

    setState(() => _isSubmitting = true);

    // Build food name including selected ingredients
    final fullFoodName = _selectedIngredients.isEmpty
        ? foodName
        : '$foodName (${_selectedIngredients.join(', ')})';

    final dto = LogMealRequestDto(
      mealType: _selectedMealType,
      foodName: fullFoodName,
      calories: _calories.round(),
      proteinG: _proteinG,
      carbsG: _carbsG,
      fatsG: _fatsG,
      isCheatMeal: _isCheatMeal,
      logDate: DateTime.now(),
      mealTime: DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      final repo = ref.read(nutritionRepositoryProvider);
      await repo.logMeal(dto);

      // Refresh nutrition tab data after logging
      ref.read(nutritionTabViewModelProvider.notifier).loadAll();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal logged successfully!'),
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

  // ───────────── Reusable Card ─────────────
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
