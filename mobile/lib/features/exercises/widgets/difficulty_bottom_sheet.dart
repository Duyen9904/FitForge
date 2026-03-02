import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Bottom sheet for selecting exercise difficulty level.
class DifficultyBottomSheet extends StatelessWidget {
  final String? selectedDifficulty;
  final ValueChanged<String?> onSelected;

  const DifficultyBottomSheet({
    super.key,
    required this.selectedDifficulty,
    required this.onSelected,
  });

  static const _difficulties = ['Beginner', 'Intermediate', 'Expert'];

  static Future<String?> show(
    BuildContext context, {
    String? currentDifficulty,
  }) async {
    return showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => DifficultyBottomSheet(
        selectedDifficulty: currentDifficulty,
        onSelected: (value) => Navigator.pop(context, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadius20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Text(
              'Select Difficulty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.grey100),

          // "All" option
          _buildOption(
            context,
            label: 'All Difficulties',
            value: null,
            isSelected: selectedDifficulty == null,
          ),

          // Difficulty options
          ..._difficulties.map(
            (d) => _buildOption(
              context,
              label: d,
              value: d,
              isSelected: selectedDifficulty == d,
            ),
          ),

          SizedBox(
            height: MediaQuery.of(context).padding.bottom +
                AppDimensions.spacing16,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required String? value,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing24,
          vertical: AppDimensions.spacing16,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.grey800,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
