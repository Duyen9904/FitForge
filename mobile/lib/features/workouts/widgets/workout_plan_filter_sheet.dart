import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/workout_plan_models.dart';
import '../viewmodels/create_workout_plan_viewmodel.dart';

/// Bottom sheet for filtering workout plans
class WorkoutPlanFilterSheet extends ConsumerStatefulWidget {
  final WorkoutPlanFilterRequest? initialFilter;
  final Function(WorkoutPlanFilterRequest) onApply;
  final VoidCallback onClear;

  const WorkoutPlanFilterSheet({
    super.key,
    this.initialFilter,
    required this.onApply,
    required this.onClear,
  });

  @override
  ConsumerState<WorkoutPlanFilterSheet> createState() =>
      _WorkoutPlanFilterSheetState();
}

class _WorkoutPlanFilterSheetState
    extends ConsumerState<WorkoutPlanFilterSheet> {
  late bool? _isActive;
  late int? _targetMuscleGroup;
  late bool? _aiGenerated;
  late DateTime? _createdAfter;
  late DateTime? _createdBefore;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialFilter?.isActive;
    _targetMuscleGroup = widget.initialFilter?.muscleGroupId;
    _aiGenerated = widget.initialFilter?.aiGenerated;
    _createdAfter = widget.initialFilter?.startDate != null
        ? DateTime.tryParse(widget.initialFilter!.startDate!)
        : null;
    _createdBefore = widget.initialFilter?.endDate != null
        ? DateTime.tryParse(widget.initialFilter!.endDate!)
        : null;
    _searchController = TextEditingController(
      text: widget.initialFilter?.fitnessGoal ?? '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muscleGroupsAsync = ref.watch(muscleGroupsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.spacing12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Row(
              children: [
                Text(
                  'Filter Workout Plans',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search query
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      hintText: 'Search plan names...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing24),

                  // Active status
                  Text(
                    'Active Status',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterChip(
                          label: 'All',
                          selected: _isActive == null,
                          onTap: () => setState(() => _isActive = null),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing8),
                      Expanded(
                        child: _buildFilterChip(
                          label: 'Active',
                          selected: _isActive == true,
                          onTap: () => setState(() => _isActive = true),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing8),
                      Expanded(
                        child: _buildFilterChip(
                          label: 'Inactive',
                          selected: _isActive == false,
                          onTap: () => setState(() => _isActive = false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacing24),

                  // Target muscle group
                  Text(
                    'Target Muscle Group',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  muscleGroupsAsync.when(
                    data: (groups) {
                      if (groups.isEmpty) {
                        return DropdownButtonFormField<int?>(
                          value: _targetMuscleGroup,
                          decoration: InputDecoration(
                            hintText: 'No muscle groups available',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMedium),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text('No muscle groups available'),
                            ),
                          ],
                          onChanged: null,
                        );
                      }

                      return DropdownButtonFormField<int?>(
                        value: _targetMuscleGroup,
                        decoration: InputDecoration(
                          hintText: 'Select muscle group',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMedium),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All muscle groups'),
                          ),
                          ...groups.map(
                            (muscle) => DropdownMenuItem<int?>(
                              value: muscle.muscleGroupId,
                              child: Text(muscle.groupName),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _targetMuscleGroup = value),
                      );
                    },
                    loading: () => DropdownButtonFormField<int?>(
                      value: _targetMuscleGroup,
                      decoration: InputDecoration(
                        hintText: 'Loading muscle groups...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Loading muscle groups...'),
                        ),
                      ],
                      onChanged: null,
                    ),
                    error: (error, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Failed to load muscle groups',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.error),
                        ),
                        const SizedBox(height: AppDimensions.spacing8),
                        DropdownButtonFormField<int?>(
                          value: _targetMuscleGroup,
                          decoration: InputDecoration(
                            hintText: 'Select muscle group',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMedium),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All muscle groups'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _targetMuscleGroup = value),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing24),

                  // AI Generated
                  Row(
                    children: [
                      Text(
                        'AI Generated',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _buildFilterChip(
                            label: 'All',
                            selected: _aiGenerated == null,
                            onTap: () => setState(() => _aiGenerated = null),
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          _buildFilterChip(
                            label: 'Yes',
                            selected: _aiGenerated == true,
                            onTap: () => setState(() => _aiGenerated = true),
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          _buildFilterChip(
                            label: 'No',
                            selected: _aiGenerated == false,
                            onTap: () => setState(() => _aiGenerated = false),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacing24),

                  // Date range
                  Text(
                    'Created Date Range',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          context: context,
                          label: 'From',
                          date: _createdAfter,
                          onSelect: (date) => setState(() => _createdAfter = date),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                      Expanded(
                        child: _buildDateField(
                          context: context,
                          label: 'To',
                          date: _createdBefore,
                          onSelect: (date) => setState(() => _createdBefore = date),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacing24),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey900.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing12),
                    ),
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final filter = WorkoutPlanFilterRequest(
                        isActive: _isActive,
                        muscleGroupId: _targetMuscleGroup,
                        aiGenerated: _aiGenerated,
                        startDate: _createdAfter != null
                            ? DateFormat('yyyy-MM-dd').format(_createdAfter!)
                            : null,
                        endDate: _createdBefore != null
                            ? DateFormat('yyyy-MM-dd').format(_createdBefore!)
                            : null,
                        fitnessGoal: _searchController.text.trim().isEmpty
                            ? null
                            : _searchController.text.trim(),
                      );
                      widget.onApply(filter);
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing12),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing12,
          vertical: AppDimensions.spacing8,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.grey200,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.white : AppColors.grey700,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required Function(DateTime?) onSelect,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onSelect(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: date != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onSelect(null),
                )
              : const Icon(Icons.calendar_today, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
        child: Text(
          date != null ? DateFormat('MMM d, yyyy').format(date) : 'Select date',
          style: TextStyle(
            color: date != null ? AppColors.grey900 : AppColors.grey500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

}
