import 'package:flutter/material.dart';

/// Visual indicator for macro distribution (protein/carbs/fats)
class MacroProgressIndicator extends StatelessWidget {
  final double proteinPercentage;
  final double carbsPercentage;
  final double fatsPercentage;
  final double height;
  final bool showLabels;

  const MacroProgressIndicator({
    super.key,
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatsPercentage,
    this.height = 20,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Normalize to 100% if needed
    final total = proteinPercentage + carbsPercentage + fatsPercentage;
    final normalizedProtein = total > 0 ? proteinPercentage / total : 0.33;
    final normalizedCarbs = total > 0 ? carbsPercentage / total : 0.34;
    final normalizedFats = total > 0 ? fatsPercentage / total : 0.33;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                // Protein
                Expanded(
                  flex: (normalizedProtein * 100).toInt(),
                  child: Container(
                    color: Colors.red.shade400,
                    child: showLabels && normalizedProtein > 0.15
                        ? Center(
                            child: Text(
                              '${proteinPercentage.toInt()}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                // Carbs
                Expanded(
                  flex: (normalizedCarbs * 100).toInt(),
                  child: Container(
                    color: Colors.amber.shade600,
                    child: showLabels && normalizedCarbs > 0.15
                        ? Center(
                            child: Text(
                              '${carbsPercentage.toInt()}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                // Fats
                Expanded(
                  flex: (normalizedFats * 100).toInt(),
                  child: Container(
                    color: Colors.blue.shade400,
                    child: showLabels && normalizedFats > 0.15
                        ? Center(
                            child: Text(
                              '${fatsPercentage.toInt()}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Legend
        if (showLabels) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(color: Colors.red.shade400, label: 'Protein'),
              _LegendItem(color: Colors.amber.shade600, label: 'Carbs'),
              _LegendItem(color: Colors.blue.shade400, label: 'Fats'),
            ],
          ),
        ],
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}
