import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import 'log_meal_name_section.dart';

/// Extras section: cheat-meal toggle + notes text field.
class LogMealExtrasSection extends StatelessWidget {
  final bool isCheatMeal;
  final ValueChanged<bool> onCheatMealChanged;
  final String notes;
  final ValueChanged<String> onNotesChanged;

  const LogMealExtrasSection({
    super.key,
    required this.isCheatMeal,
    required this.onCheatMealChanged,
    required this.notes,
    required this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LogMealCard(
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
                value: isCheatMeal,
                activeColor: const Color(0xFFFF8C00),
                onChanged: onCheatMealChanged,
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
            initialValue: notes,
            maxLines: 3,
            onChanged: onNotesChanged,
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
}
