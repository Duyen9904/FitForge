import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../shared/enums/difficulty_level.dart';
import '../../../shared/enums/exercise_type.dart';
import '../../../ui/core/buttons/app_buttons.dart';
import '../models/exercise_filter.dart';

/// Bottom sheet widget for exercise filtering
class ExerciseFilterBottomSheet extends StatefulWidget {
  final ExerciseFilter currentFilter;
  final Function(ExerciseFilter) onApply;

  const ExerciseFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<ExerciseFilterBottomSheet> createState() =>
      _ExerciseFilterBottomSheetState();
}

class _ExerciseFilterBottomSheetState
    extends State<ExerciseFilterBottomSheet> {
  late DifficultyLevel? _selectedDifficulty;
  late ExerciseCategory? _selectedCategory;
  late bool _requiresSpotter;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty =
        DifficultyLevel.fromString(widget.currentFilter.difficultyLevel);
    _selectedCategory =
        ExerciseCategory.fromString(widget.currentFilter.exerciseType);
    _requiresSpotter = widget.currentFilter.requiresSpotter ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppDimensions.spacing24,
        left: AppDimensions.spacing24,
        right: AppDimensions.spacing24,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            AppDimensions.spacing24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadius20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Exercises',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing24),

            // Difficulty Level
            Text(
              'Difficulty Level',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            Wrap(
              spacing: AppDimensions.spacing8,
              children: [
                _buildDifficultyChip(null, 'All'),
                ...DifficultyLevel.values
                    .where((d) => d != DifficultyLevel.expert)
                    .map((difficulty) =>
                        _buildDifficultyChip(difficulty, difficulty.displayName)),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing24),

            // Exercise Category
            Text(
              'Exercise Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            Wrap(
              spacing: AppDimensions.spacing8,
              children: [
                _buildCategoryChip(null, 'All'),
                ...ExerciseCategory.values.map((category) =>
                    _buildCategoryChip(category, category.displayName)),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing24),

            // Requires Spotter
            CheckboxListTile(
              title: const Text('Requires Spotter'),
              subtitle: const Text('Show only exercises that need a spotter'),
              value: _requiresSpotter,
              onChanged: (value) {
                setState(() {
                  _requiresSpotter = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: AppDimensions.spacing24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Reset',
                    onPressed: () {
                      setState(() {
                        _selectedDifficulty = null;
                        _selectedCategory = null;
                        _requiresSpotter = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing12),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    text: 'Apply Filters',
                    onPressed: () {
                      final filter = ExerciseFilter(
                        difficultyLevel: _selectedDifficulty?.apiValue,
                        exerciseType: _selectedCategory?.apiValue,
                        requiresSpotter:
                            _requiresSpotter ? _requiresSpotter : null,
                      );
                      widget.onApply(filter);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(DifficultyLevel? difficulty, String label) {
    final isSelected = _selectedDifficulty == difficulty;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDifficulty = selected ? difficulty : null;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.grey700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildCategoryChip(ExerciseCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.grey700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
