import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'log_meal_name_section.dart';

/// Reusable macro slider (calories, protein, carbs, fats).
class LogMealMacroSlider extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final String unit;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const LogMealMacroSlider({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.unit,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LogMealCard(
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
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 8),
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
}
