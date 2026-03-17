import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/profile_models.dart';

/// GitHub-style activity heatmap designed for mobile.
///
/// Shows **~3 months** (a quarter) at a time with left/right arrow
/// navigation. Grid: 7 rows (Mon–Sun) × N week-columns, with cells
/// sized dynamically to fill the card width.
class ProfileActivityGrid extends StatefulWidget {
  final ActivityHeatmapData? heatmapData;
  final int totalWorkoutsCompleted;

  const ProfileActivityGrid({
    super.key,
    this.heatmapData,
    this.totalWorkoutsCompleted = 0,
  });

  @override
  State<ProfileActivityGrid> createState() => _ProfileActivityGridState();
}

class _ProfileActivityGridState extends State<ProfileActivityGrid> {
  /// How many weeks to display per page (~13 weeks ≈ 3 months).
  static const int _weeksPerPage = 13;
  static const double _cellGap = 4.0;
  static const double _dayLabelWidth = 30.0;

  /// Current page index (0 = most recent, grows backward in time).
  int _pageIndex = 0;

  /// Full grid data: all weeks from the activity data (oldest-first).
  List<List<_CellData?>> _allWeeks = [];

  /// Parsed lookup: date → DailyActivity.
  Map<DateTime, DailyActivity> _activityMap = {};

  /// Date range for month labels.
  DateTime? _mondayStart;

  @override
  void initState() {
    super.initState();
    _buildGridData();
  }

  @override
  void didUpdateWidget(covariant ProfileActivityGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.heatmapData != widget.heatmapData) {
      _buildGridData();
      _pageIndex = 0;
    }
  }

  void _buildGridData() {
    _activityMap = {};
    _allWeeks = [];
    _mondayStart = null;

    final activities = widget.heatmapData?.dailyActivities ?? [];
    if (activities.isEmpty) return;

    // Parse all dates
    for (final a in activities) {
      final d = DateTime.tryParse(a.date);
      if (d != null) {
        _activityMap[DateTime(d.year, d.month, d.day)] = a;
      }
    }
    if (_activityMap.isEmpty) return;

    final sortedDates = _activityMap.keys.toList()..sort();
    final startDate = sortedDates.first;
    final endDate = sortedDates.last;

    // Align to Monday of start week
    _mondayStart = startDate.subtract(Duration(days: (startDate.weekday - 1)));
    final totalDays = endDate.difference(_mondayStart!).inDays + 1;
    final totalWeeks = (totalDays / 7).ceil();

    for (int w = 0; w < totalWeeks; w++) {
      final week = <_CellData?>[];
      for (int d = 0; d < 7; d++) {
        final date = _mondayStart!.add(Duration(days: w * 7 + d));
        final key = DateTime(date.year, date.month, date.day);
        final activity = _activityMap[key];
        if (date.isAfter(endDate.add(const Duration(days: 1)))) {
          week.add(null);
        } else {
          week.add(_CellData(
            date: date,
            count: activity?.workoutsCompleted ?? 0,
          ));
        }
      }
      _allWeeks.add(week);
    }
  }

  /// Total number of navigable pages.
  int get _totalPages =>
      _allWeeks.isEmpty ? 1 : (_allWeeks.length / _weeksPerPage).ceil();

  bool get _canGoBack => _pageIndex < _totalPages - 1;
  bool get _canGoForward => _pageIndex > 0;

  /// Get the weeks for the current page (most recent = page 0).
  List<List<_CellData?>> get _currentWeeks {
    if (_allWeeks.isEmpty) return [];
    // Page 0 = rightmost (most recent) weeks
    final endIdx = _allWeeks.length - (_pageIndex * _weeksPerPage);
    final startIdx = (endIdx - _weeksPerPage).clamp(0, _allWeeks.length);
    return _allWeeks.sublist(startIdx, endIdx.clamp(0, _allWeeks.length));
  }

  void _goBack() {
    if (!_canGoBack) return;
    setState(() => _pageIndex++);
  }

  void _goForward() {
    if (!_canGoForward) return;
    setState(() => _pageIndex--);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.spacing24),

          // ── Section header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing12,
                  vertical: AppDimensions.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusRound),
                ),
                child: Text(
                  '${widget.totalWorkoutsCompleted} workouts',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacing16),

          // ── Heatmap Card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.grey300)
                      .withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _allWeeks.isNotEmpty
                ? _buildHeatmap(theme, isDark)
                : _buildEmptyState(theme),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // Heatmap content
  // ───────────────────────────────────────────────────────────────────

  Widget _buildHeatmap(ThemeData theme, bool isDark) {
    final weeks = _currentWeeks;
    if (weeks.isEmpty) return _buildEmptyState(theme);

    // Determine the displayed date range for month labels
    final monthLabels = _buildMonthLabels(weeks);

    // Page stats
    int pageWorkouts = 0;
    int pageActiveDays = 0;
    for (final week in weeks) {
      for (final cell in week) {
        if (cell != null && cell.count > 0) {
          pageWorkouts += cell.count;
          pageActiveDays++;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Navigation row ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navButton(
              icon: Icons.chevron_left_rounded,
              enabled: _canGoBack,
              onTap: _goBack,
              theme: theme,
            ),
            // Month range label
            Text(
              _pageRangeLabel(weeks),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            _navButton(
              icon: Icons.chevron_right_rounded,
              enabled: _canGoForward,
              onTap: _goForward,
              theme: theme,
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spacing8),

        // ── Month labels above grid ──
        Padding(
          padding: const EdgeInsets.only(left: _dayLabelWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = _cellSizeFor(constraints.maxWidth, weeks.length);
              final labels = monthLabels.toList();
              return Row(
                children: [
                  for (int i = 0; i < labels.length; i++)
                    SizedBox(
                      width: labels[i].weekCount * (cellSize + _cellGap) -
                          (i == labels.length - 1 ? _cellGap : 0),
                      child: Text(
                        labels[i].label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: AppDimensions.spacing4),

        // ── Grid ──
        LayoutBuilder(
          builder: (context, constraints) {
            final gridWidth = constraints.maxWidth - _dayLabelWidth;
            final cellSize = _cellSizeFor(gridWidth, weeks.length);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day labels
                Column(
                  children: List.generate(7, (i) {
                    return SizedBox(
                      height: cellSize + _cellGap,
                      width: _dayLabelWidth,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _shortDayLabels[i],
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                // Cell grid — Row of week-columns for compact height
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int wIdx = 0; wIdx < weeks.length; wIdx++)
                        Padding(
                          padding: EdgeInsets.only(
                            right: wIdx < weeks.length - 1 ? _cellGap : 0,
                          ),
                          child: Column(
                            children: [
                              for (int dIdx = 0; dIdx < 7; dIdx++)
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: dIdx < 6 ? _cellGap : 0,
                                  ),
                                  child: _buildCell(
                                    weeks[wIdx][dIdx],
                                    cellSize,
                                    isDark,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: AppDimensions.spacing12),

        // ── Footer: summary + legend ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '$pageActiveDays active days · $pageWorkouts workouts',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Less',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                ...List.generate(5, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _cellColor(i, isDark),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                )),
                const SizedBox(width: 4),
                Text(
                  'More',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // Helpers
  // ───────────────────────────────────────────────────────────────────

  Widget _buildCell(_CellData? cell, double size, bool isDark) {
    if (cell == null) {
      return SizedBox(width: size, height: size);
    }
    return Tooltip(
      message:
          '${_fmtDate(cell.date)}\n${cell.count} workout${cell.count != 1 ? 's' : ''}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _cellColor(cell.count, isDark),
          borderRadius: BorderRadius.circular(size * 0.22),
        ),
      ),
    );
  }

  Widget _navButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing4),
          child: Icon(
            icon,
            size: 24,
            color: enabled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.grid_on_rounded,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'No workout activity yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing4),
            Text(
              'Complete workouts to see your activity here',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Compute cell size to fill available width given number of weeks.
  double _cellSizeFor(double availableWidth, int weekCount) {
    if (weekCount <= 0) return 12.0;
    return ((availableWidth - (weekCount - 1) * _cellGap) / weekCount)
        .clamp(10.0, 22.0);
  }

  /// Build month labels with their column spans.
  List<_MonthLabel> _buildMonthLabels(List<List<_CellData?>> weeks) {
    final labels = <_MonthLabel>[];
    int currentMonth = -1;
    int count = 0;

    for (final week in weeks) {
      // Use the first non-null cell's month to represent the week
      final firstCell = week.firstWhere((c) => c != null, orElse: () => null);
      final month = firstCell?.date.month ?? currentMonth;

      if (month != currentMonth) {
        if (currentMonth != -1 && count > 0) {
          labels.add(_MonthLabel(label: _monthShort(currentMonth), weekCount: count));
        }
        currentMonth = month;
        count = 1;
      } else {
        count++;
      }
    }
    if (count > 0 && currentMonth != -1) {
      labels.add(_MonthLabel(label: _monthShort(currentMonth), weekCount: count));
    }
    return labels;
  }

  /// Range label for current page, e.g. "Jan – Mar 2026".
  String _pageRangeLabel(List<List<_CellData?>> weeks) {
    DateTime? first;
    DateTime? last;
    for (final week in weeks) {
      for (final cell in week) {
        if (cell != null) {
          first ??= cell.date;
          last = cell.date;
        }
      }
    }
    if (first == null || last == null) return '';
    final startLabel = '${_monthShort(first.month)}';
    final endLabel = '${_monthShort(last.month)} ${last.year}';
    return first.month == last.month ? endLabel : '$startLabel – $endLabel';
  }

  Color _cellColor(int count, bool isDark) {
    if (count <= 0) return isDark ? AppColors.grey700 : AppColors.grey200;
    if (count == 1) return AppColors.primary.withOpacity(0.30);
    if (count == 2) return AppColors.primary.withOpacity(0.55);
    if (count == 3) return AppColors.primary.withOpacity(0.80);
    return AppColors.primary;
  }

  static String _monthShort(int m) {
    const n = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return m >= 1 && m <= 12 ? n[m] : '';
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static const List<String> _shortDayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];
}

class _MonthLabel {
  final String label;
  final int weekCount;
  const _MonthLabel({required this.label, required this.weekCount});
}

class _CellData {
  final DateTime date;
  final int count;
  const _CellData({required this.date, required this.count});
}
