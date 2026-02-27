import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../viewmodels/create_workout_plan_state.dart';
import '../../viewmodels/create_workout_plan_viewmodel.dart';

/// Step 2: Sessions builder
class SessionsStep extends ConsumerWidget {
  const SessionsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(createWorkoutPlanViewModelProvider);
    final vm = ref.read(createWorkoutPlanViewModelProvider.notifier);
    final muscleGroupsAsync = ref.watch(muscleGroupsProvider);

    if (state is! CreateWorkoutPlanEditing) return const SizedBox.shrink();

    // Extract focus area names from muscle groups API
    final focusAreas = muscleGroupsAsync.when(
      data: (groups) => groups.map((g) => g.groupName).toList(),
      loading: () => <String>[],
      error: (_, __) => <String>[],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout Sessions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            'Name your sessions and set focus areas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),

          // Session cards
          ...state.sessions.asMap().entries.map((entry) {
            final index = entry.key;
            final session = entry.value;
            return _SessionCard(
              index: index,
              session: session,
              focusAreas: focusAreas,
              isLoadingFocusAreas: muscleGroupsAsync.isLoading,
              onNameChanged: (name) => vm.updateSessionName(index, name),
              onFocusChanged: (focus) =>
                  vm.updateSessionFocusArea(index, focus),
              onDurationChanged: (dur) =>
                  vm.updateSessionDuration(index, dur),
              onToggleRest: () => vm.toggleRestDay(index),
            );
          }),
        ],
      ),
    );
  }
}

class _SessionCard extends StatefulWidget {
  final int index;
  final SessionDraft session;
  final List<String> focusAreas;
  final bool isLoadingFocusAreas;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String?> onFocusChanged;
  final ValueChanged<int?> onDurationChanged;
  final VoidCallback onToggleRest;

  const _SessionCard({
    required this.index,
    required this.session,
    required this.focusAreas,
    required this.isLoadingFocusAreas,
    required this.onNameChanged,
    required this.onFocusChanged,
    required this.onDurationChanged,
    required this.onToggleRest,
  });

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  late TextEditingController _nameController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.session.sessionName);
    _durationController = TextEditingController(
      text: widget.session.estimatedDuration?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: widget.session.isRestDay
            ? AppColors.grey50
            : AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: widget.session.isRestDay
              ? AppColors.grey300
              : AppColors.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: widget.session.isRestDay
                        ? null
                        : AppColors.primaryGradient,
                    color: widget.session.isRestDay
                        ? AppColors.grey300
                        : null,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index + 1}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing12),
                Expanded(
                  child: Text(
                    'Day ${widget.session.dayNumber}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Rest day toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rest',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                    Switch.adaptive(
                      value: widget.session.isRestDay,
                      onChanged: (_) => widget.onToggleRest(),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),

            if (!widget.session.isRestDay) ...[
              const SizedBox(height: AppDimensions.spacing12),
              // Session Name
              TextField(
                controller: _nameController,
                onChanged: widget.onNameChanged,
                decoration: InputDecoration(
                  labelText: 'Session Name',
                  hintText: 'e.g., Chest & Triceps',
                  filled: true,
                  fillColor: AppColors.grey50,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: BorderSide(color: AppColors.grey200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: BorderSide(color: AppColors.grey200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing12,
                    vertical: AppDimensions.spacing8,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing12),

              // Focus area & estimated duration row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing12),
                      child: widget.isLoadingFocusAreas
                          ? SizedBox(
                              height: 40,
                              child: Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            )
                          : DropdownButton<String>(
                              value: widget.focusAreas
                                      .contains(widget.session.focusArea)
                                  ? widget.session.focusArea
                                  : null,
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                              hint: Text('Focus Area',
                                  style: TextStyle(
                                      color: AppColors.grey400, fontSize: 14)),
                              items: widget.focusAreas
                                  .map((f) => DropdownMenuItem<String>(
                                        value: f,
                                        child: Text(f,
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ))
                                  .toList(),
                              onChanged: widget.onFocusChanged,
                              isDense: true,
                            ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final dur = int.tryParse(v);
                        widget.onDurationChanged(dur);
                      },
                      decoration: InputDecoration(
                        labelText: 'Min',
                        hintText: '45',
                        filled: true,
                        fillColor: AppColors.grey50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium),
                          borderSide: BorderSide(color: AppColors.grey200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium),
                          borderSide: BorderSide(color: AppColors.grey200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium),
                          borderSide: BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing12,
                          vertical: AppDimensions.spacing8,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: AppDimensions.spacing8),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hotel, color: AppColors.grey400, size: 20),
                    const SizedBox(width: AppDimensions.spacing8),
                    Text(
                      'Rest Day - Recovery & Stretch',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
