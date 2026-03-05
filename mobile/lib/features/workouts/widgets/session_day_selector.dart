import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/workout_plan_models.dart';

/// Approximate width of each day chip including padding.
const double _kChipWidth = 92;

/// Day selector for workout plan sessions with week navigation.
class SessionDaySelector extends StatefulWidget {
  final List<WorkoutSessionResponse> weekSessions;
  final String weekLabel;
  final int currentWeekNumber;
  final int totalWeeks;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;

  const SessionDaySelector({
    super.key,
    required this.weekSessions,
    required this.weekLabel,
    required this.currentWeekNumber,
    required this.totalWeeks,
    required this.selectedIndex,
    required this.onDaySelected,
    required this.onPrevWeek,
    required this.onNextWeek,
  });

  @override
  State<SessionDaySelector> createState() => _SessionDaySelectorState();
}

class _SessionDaySelectorState extends State<SessionDaySelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedIndex > 0 && widget.weekSessions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final offset = (widget.selectedIndex * (_kChipWidth + AppDimensions.spacing8))
          .toDouble();
      final maxOffset = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(offset.clamp(0.0, maxOffset));
    });
  }

  @override
  void didUpdateWidget(covariant SessionDaySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.weekSessions != widget.weekSessions) {
      _scrollToSelected();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final canGoPrev = widget.currentWeekNumber > 1;
    final canGoNext = widget.currentWeekNumber < widget.totalWeeks;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Week header with arrows
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
              vertical: AppDimensions.spacing8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: canGoPrev ? widget.onPrevWeek : null,
                  style: IconButton.styleFrom(
                    foregroundColor: canGoPrev
                        ? AppColors.grey700
                        : AppColors.grey400,
                  ),
                ),
                Text(
                  widget.weekLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.grey800,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: canGoNext ? widget.onNextWeek : null,
                  style: IconButton.styleFrom(
                    foregroundColor: canGoNext
                        ? AppColors.grey700
                        : AppColors.grey400,
                  ),
                ),
              ],
            ),
          ),
          // Row 2: Day chips
          SizedBox(
            height: 52,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing16,
              ),
              itemCount: widget.weekSessions.length,
              itemBuilder: (context, index) {
                final session = widget.weekSessions[index];
                final isSelected = index == widget.selectedIndex;
                final isRestDay = session.isRestDay;
                final isMissed = session.isMissed && !isRestDay;
                final dateStr = session.scheduledDate != null
                    ? _formatDate(session.scheduledDate!)
                    : null;

                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.spacing8),
                  child: ChoiceChip(
                    avatar: isMissed && !isSelected
                        ? Icon(
                            Icons.warning_rounded,
                            size: 16,
                            color: isSelected ? AppColors.white : AppColors.error,
                          )
                        : isRestDay
                            ? Icon(
                                Icons.hotel_rounded,
                                size: 16,
                                color:
                                    isSelected ? AppColors.white : AppColors.grey600,
                              )
                            : null,
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isRestDay
                              ? 'Day ${session.dayNumber} · Rest'
                              : isMissed
                                  ? 'Day ${session.dayNumber} · Missed'
                                  : 'Day ${session.dayNumber}',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: isSelected
                                        ? AppColors.white
                                        : isMissed
                                            ? AppColors.error
                                            : isRestDay
                                                ? AppColors.grey600
                                                : AppColors.grey700,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontStyle: isRestDay
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                        ),
                        if (dateStr != null)
                          Text(
                            dateStr,
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: isSelected
                                          ? AppColors.white
                                              .withValues(alpha: 0.8)
                                          : isMissed
                                              ? AppColors.error.withOpacity(0.7)
                                              : AppColors.grey500,
                                      fontSize: 10,
                                    ),
                          ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) => widget.onDaySelected(index),
                    backgroundColor: isMissed
                        ? AppColors.error.withOpacity(0.08)
                        : isRestDay
                            ? AppColors.grey100
                            : AppColors.grey200,
                    selectedColor: isMissed
                        ? AppColors.error
                        : isRestDay
                            ? AppColors.grey600
                            : AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusRound),
                      side: BorderSide(
                        color: isSelected
                            ? (isMissed
                                ? AppColors.error
                                : isRestDay
                                    ? AppColors.grey600
                                    : AppColors.primary)
                            : isMissed
                                ? AppColors.error.withOpacity(0.4)
                                : AppColors.grey300,
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing12,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
