import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Orange-themed animated checkbox used in the Add Meal Plan screen.
class MealPlanCheckbox extends StatelessWidget {
  final bool checked;

  const MealPlanCheckbox({super.key, required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? const Color(0xFFFF8C00) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? const Color(0xFFFF8C00) : AppColors.grey300,
          width: 2,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
