import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Expandable weekly calendar widget using app resource system colors:
/// - Compact header showing the selected date and a calendar icon button
/// - Tapping the calendar icon smoothly expands/collapses the 7-day calendar strip
/// - Selected day is highlighted in AppColors.primary pill with white text
/// - Workout dots use AppColors.secondary
class HomeWeeklyCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Set<String> workoutDates; // Dates in 'yyyy-MM-dd' format
  final bool initialExpanded;

  const HomeWeeklyCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.workoutDates = const {},
    this.initialExpanded = false,
  });

  @override
  State<HomeWeeklyCalendar> createState() => _HomeWeeklyCalendarState();
}

class _HomeWeeklyCalendarState extends State<HomeWeeklyCalendar> {
  late bool _isExpanded;
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
    _weekStart = _calculateWeekStart(widget.selectedDate);
  }

  @override
  void didUpdateWidget(covariant HomeWeeklyCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DateUtils.isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      _weekStart = _calculateWeekStart(widget.selectedDate);
    }
  }

  /// Start the week on Sunday (Dart weekday 7 % 7 = 0)
  DateTime _calculateWeekStart(DateTime date) {
    final diff = date.weekday % 7;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: diff));
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = DateUtils.isSameDay(widget.selectedDate, DateTime.now());
    final dateDisplay = isToday
        ? 'Today, ${DateFormat('d MMMM').format(widget.selectedDate)}'
        : DateFormat('EEEE, d MMMM').format(widget.selectedDate);

    final monthYearFormat = DateFormat('MMMM yyyy');
    final formattedMonthYear = monthYearFormat.format(_weekStart.add(const Duration(days: 3)));
    final days = List.generate(7, (index) => _weekStart.add(Duration(days: index)));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
        border: Border.all(
          color: AppColors.grey200.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact Header Bar with Calendar Icon
          Row(
            children: [
              // Calendar Icon Button to toggle expansion
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.spacing8),
                  decoration: BoxDecoration(
                    color: _isExpanded
                        ? AppColors.primary
                        : AppColors.primaryLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 20,
                    color: _isExpanded ? AppColors.white : AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(width: AppDimensions.spacing12),

              // Date Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateDisplay,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _isExpanded ? formattedMonthYear : 'Tap calendar icon to expand week',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Expand / Collapse Chevron Icon Button
              IconButton(
                icon: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grey600,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                tooltip: _isExpanded ? 'Collapse calendar' : 'Expand calendar',
              ),
            ],
          ),

          // Animated Expanded 7-Day Calendar Strip
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spacing12),
                const Divider(height: 1, color: AppColors.grey200),
                const SizedBox(height: AppDimensions.spacing12),

                // Week Navigation Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedMonthYear,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.grey600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.grey600, size: 20),
                          onPressed: _previousWeek,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: AppDimensions.spacing12),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: AppColors.grey600, size: 20),
                          onPressed: _nextWeek,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing12),

                // 7-Day Horizontal Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.map((day) {
                    final isSelected = DateUtils.isSameDay(day, widget.selectedDate);
                    final dayKey = DateFormat('yyyy-MM-dd').format(day);
                    final hasWorkout = widget.workoutDates.contains(dayKey);
                    final dayInitial = DateFormat('E').format(day).substring(0, 1).toUpperCase();

                    return _buildDayItem(
                      theme: theme,
                      dayInitial: dayInitial,
                      dayNumber: day.day.toString(),
                      isSelected: isSelected,
                      hasWorkout: hasWorkout,
                      onTap: () {
                        widget.onDateSelected(day);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppDimensions.spacing4),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem({
    required ThemeData theme,
    required String dayInitial,
    required String dayNumber,
    required bool isSelected,
    required bool hasWorkout,
    required VoidCallback onTap,
  }) {
    if (isSelected) {
      // Selected day in AppColors.primary
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppDimensions.radius20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dayInitial,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dayNumber,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Unselected day
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radius20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayInitial,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.grey400,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNumber,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.grey800,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            // Workout dot indicator
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasWorkout ? AppColors.secondary : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
