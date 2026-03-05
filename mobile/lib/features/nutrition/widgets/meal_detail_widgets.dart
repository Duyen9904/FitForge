import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Ingredient row item parsed from recipe instructions text.
class IngredientItem {
  final String name;
  final String quantity;

  const IngredientItem({required this.name, required this.quantity});
}

/// Displays a list of ingredients in a card, matching the reference UI.
class IngredientsCard extends StatelessWidget {
  final String? recipeInstructions;

  const IngredientsCard({super.key, this.recipeInstructions});

  @override
  Widget build(BuildContext context) {
    final ingredients = _parseIngredients(recipeInstructions);

    if (ingredients.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text(
            'Ingredients',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          ...ingredients.map((item) => _IngredientRow(item: item)),
        ],
      ),
    );
  }

  /// Try to parse ingredients from recipe text.
  /// Supports formats like "• Chickpeas 1½ cups" or "- Chickpeas: 1½ cups"
  /// Falls back to line-by-line display.
  List<IngredientItem> _parseIngredients(String? text) {
    if (text == null || text.trim().isEmpty) return [];

    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return lines.map((line) {
      // Strip leading bullet/dash
      var cleaned = line.replaceAll(RegExp(r'^[•\-\*]\s*'), '');

      // Try to split on last number/fraction pattern
      final match = RegExp(r'^(.+?)\s+([\d½¼¾⅓⅔]+\s*.*)$').firstMatch(cleaned);
      if (match != null) {
        return IngredientItem(
          name: match.group(1)!.trim(),
          quantity: match.group(2)!.trim(),
        );
      }

      // Try colon separator
      if (cleaned.contains(':')) {
        final parts = cleaned.split(':');
        return IngredientItem(
          name: parts[0].trim(),
          quantity: parts.sublist(1).join(':').trim(),
        );
      }

      return IngredientItem(name: cleaned, quantity: '');
    }).toList();
  }
}

class _IngredientRow extends StatelessWidget {
  final IngredientItem item;

  const _IngredientRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          if (item.quantity.isNotEmpty)
            Text(
              item.quantity,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey600,
              ),
            ),
        ],
      ),
    );
  }
}

/// Stats row showing calories, prep time, and protein.
class MealDetailStatsRow extends StatelessWidget {
  final int calories;
  final double? proteinG;
  final int estimatedPrepTime;

  const MealDetailStatsRow({
    super.key,
    required this.calories,
    this.proteinG,
    required this.estimatedPrepTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.local_fire_department,
          iconColor: Colors.orange.shade600,
          value: '$calories',
          label: 'Kcals',
        ),
        const SizedBox(width: 16),
        _StatChip(
          icon: Icons.access_time,
          iconColor: AppColors.grey500,
          value: '$estimatedPrepTime',
          label: 'min.',
        ),
        const SizedBox(width: 16),
        _StatChip(
          icon: Icons.fitness_center,
          iconColor: const Color(0xFF4CAF50),
          value: '${proteinG?.toInt() ?? 0}g',
          label: 'Protein',
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.grey500,
          ),
        ),
      ],
    );
  }
}
