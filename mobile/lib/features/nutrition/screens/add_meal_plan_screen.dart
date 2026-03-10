import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../shared/enums/enums.dart';
import '../models/nutrition_models.dart';
import '../models/nutrition_requests.dart';
import '../repositories/nutrition_repository.dart';
import '../widgets/meal_plan_checkbox.dart';

/// Screen for adding a meal template to the meal plan.
/// User picks meal type(s), a date, and a time, then submits.
class AddMealPlanScreen extends ConsumerStatefulWidget {
  final MealTemplate template;

  const AddMealPlanScreen({super.key, required this.template});

  @override
  ConsumerState<AddMealPlanScreen> createState() => _AddMealPlanScreenState();
}

class _AddMealPlanScreenState extends ConsumerState<AddMealPlanScreen> {
  final Set<MealType> _selectedTypes = {};
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _selectedTime = TimeOfDay.now();
    // Pre-select the template's own meal type
    _selectedTypes.add(widget.template.mealType);
  }

  // ───────────────── Build ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Add Meal Plan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add another',
            onPressed: () {
              // placeholder for future multi-add
            },
          ),
        ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMealTypeSection(),
                  const SizedBox(height: AppDimensions.spacing24),
                  _buildDateSection(),
                ],
              ),
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  // ───────────── Meal Type Section ─────────────

  Widget _buildMealTypeSection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add to Meal Plan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '${_selectedTypes.length} Selected',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // Checkbox grid (2 columns)
          _buildCheckboxGrid(),
        ],
      ),
    );
  }

  Widget _buildCheckboxGrid() {
    final types = MealType.values;
    return Wrap(
      spacing: 0,
      runSpacing: 0,
      children: types.map((type) {
        final isSelected = _selectedTypes.contains(type);
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.38,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedTypes.remove(type);
                } else {
                  _selectedTypes.add(type);
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
                  Text(
                    type.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
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
    );
  }

  // ───────────── Date Section ─────────────

  Widget _buildDateSection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Date',
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
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),

          // Calendar
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: const Color(0xFFFF8C00),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: const Color(0xFF1A1A2E),
                  ),
            ),
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate:
                  DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (date) {
                setState(() => _selectedDate = date);
              },
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: AppDimensions.spacing12),

          // Time row
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _pickTime,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    _selectedTime.format(context),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFFFF8C00),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // ───────────── Submit Button ─────────────

  Widget _buildSubmitButton() {
    final canSubmit = _selectedTypes.isNotEmpty && !_isSubmitting;

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
                    'Add Meal Plan',
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
    if (_selectedTypes.isEmpty) return;

    setState(() => _isSubmitting = true);

    final mealDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    ).toUtc();

    try {
      final repo = ref.read(nutritionRepositoryProvider);

      // Check for existing meals on the selected date
      final existingMeals = await repo.getDailyMeals(_selectedDate);
      final existingTypes = existingMeals
          .map((m) => m.mealType)
          .toSet();

      // Find which selected types conflict with existing meals
      final conflictingTypes = _selectedTypes
          .where((type) => existingTypes.contains(type))
          .toList();

      bool replaceExisting = false;

      if (conflictingTypes.isNotEmpty && mounted) {
        final typeNames =
            conflictingTypes.map((t) => t.displayName).join(', ');
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Meal Already Exists'),
            content: Text(
              '$typeNames already exists for this date. '
              'Do you want to replace the existing meal(s)?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Replace'),
              ),
            ],
          ),
        );

        if (confirmed != true) {
          setState(() => _isSubmitting = false);
          return;
        }
        replaceExisting = true;
      }

      // Log one entry per selected meal type
      for (final type in _selectedTypes) {
        final dto = LogMealRequestDto(
          templateId: widget.template.mealTemplateId,
          quantityMultiplier: 1.0,
          mealType: type,
          logDate: _selectedDate,
          mealTime: mealDateTime,
          replaceExisting: replaceExisting,
        );
        await repo.logMeal(dto);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal plan added successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add: $e'),
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
