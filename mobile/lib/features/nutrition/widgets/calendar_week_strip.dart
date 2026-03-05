import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Horizontal calendar showing one week with month header and navigation arrows.
class CalendarWeekStrip extends StatelessWidget {
  final DateTime weekStartDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const CalendarWeekStrip({
    super.key,
    required this.weekStartDate,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = List.generate(
      7,
      (i) => weekStartDate.add(Duration(days: i)),
    );
    final monthLabel = DateFormat('MMMM yyyy').format(weekStartDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month header with arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
              Row(
                children: [
                  _ArrowButton(
                    icon: Icons.chevron_left,
                    onTap: onPreviousWeek,
                  ),
                  const SizedBox(width: 4),
                  _ArrowButton(
                    icon: Icons.chevron_right,
                    onTap: onNextWeek,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _DayLabel('S'),
              _DayLabel('M'),
              _DayLabel('T'),
              _DayLabel('W'),
              _DayLabel('T'),
              _DayLabel('F'),
              _DayLabel('S'),
            ],
          ),
          const SizedBox(height: 8),
          // Day numbers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((date) {
              // Adjust days: the generated list starts from Monday (weekday 1),
              // but the labels above start from Sunday. Re-map:
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;

              return _DayCell(
                day: date.day,
                isToday: isToday,
                isSelected: isSelected,
                onTap: () => onDateSelected(date),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.grey700),
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;

  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.grey400,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = isToday || isSelected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: highlighted ? AppColors.success : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$day',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      highlighted ? FontWeight.w700 : FontWeight.normal,
                  color: highlighted ? Colors.white : AppColors.grey700,
                ),
          ),
        ),
      ),
    );
  }
}
