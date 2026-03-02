import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../viewmodels/exercise_types_viewmodel.dart';

/// Dropdown widget for selecting exercise difficulty level.
class DifficultyDropdown extends ConsumerWidget {
  const DifficultyDropdown({super.key});

  static const _difficulties = ['Beginner', 'Intermediate', 'Expert'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDifficulty =
        ref.watch(exerciseTypesViewModelProvider).maybeWhen(
              loaded: (_, selectedDifficulty) => selectedDifficulty,
              orElse: () => null,
            );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing4,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: selectedDifficulty,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.grey500,
            ),
            hint: Text(
              'All Difficulties',
              style: TextStyle(
                color: AppColors.grey700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextStyle(
              color: AppColors.grey900,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius12),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  'All Difficulties',
                  style: TextStyle(
                    color: AppColors.grey700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ..._difficulties.map(
                (difficulty) => DropdownMenuItem<String?>(
                  value: difficulty,
                  child: Text(
                    difficulty,
                    style: TextStyle(
                      color: AppColors.grey900,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              ref
                  .read(exerciseTypesViewModelProvider.notifier)
                  .selectDifficulty(value);
            },
          ),
        ),
      ),
    );
  }
}
