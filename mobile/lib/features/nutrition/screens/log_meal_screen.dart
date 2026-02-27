import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../shared/enums/meal_type.dart';
import '../models/nutrition_requests.dart';

class LogMealScreen extends ConsumerStatefulWidget {
  const LogMealScreen({super.key});

  @override
  ConsumerState<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends ConsumerState<LogMealScreen> {
  final _formKey = GlobalKey<FormState>();
  MealType _mealType = MealType.lunch;
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();
  bool _isCheatMeal = false;

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log meal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<MealType>(
                value: _mealType,
                decoration: const InputDecoration(labelText: 'Meal type'),
                items: MealType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _mealType = value);
                  }
                },
              ),
              const SizedBox(height: AppDimensions.spacing12),
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(labelText: 'Food name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppDimensions.spacing12),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppDimensions.spacing12),
              TextFormField(
                controller: _proteinController,
                decoration:
                    const InputDecoration(labelText: 'Protein (g, optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimensions.spacing12),
              TextFormField(
                controller: _carbsController,
                decoration:
                    const InputDecoration(labelText: 'Carbs (g, optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimensions.spacing12),
              TextFormField(
                controller: _fatsController,
                decoration:
                    const InputDecoration(labelText: 'Fats (g, optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimensions.spacing12),
              SwitchListTile(
                value: _isCheatMeal,
                onChanged: (value) {
                  setState(() => _isCheatMeal = value);
                },
                title: const Text('Mark as cheat meal'),
              ),
              const SizedBox(height: AppDimensions.spacing24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Log meal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final dto = LogMealRequestDto(
      mealType: _mealType,
      foodName: _foodNameController.text,
      calories: int.parse(_caloriesController.text),
      proteinG: _proteinController.text.isEmpty
          ? null
          : double.tryParse(_proteinController.text),
      carbsG: _carbsController.text.isEmpty
          ? null
          : double.tryParse(_carbsController.text),
      fatsG: _fatsController.text.isEmpty
          ? null
          : double.tryParse(_fatsController.text),
      isCheatMeal: _isCheatMeal,
      logDate: DateTime.now(),
    );

    // ViewModel call will be wired later; for now just pop with dto
    Navigator.of(context).pop(dto);
  }
}

