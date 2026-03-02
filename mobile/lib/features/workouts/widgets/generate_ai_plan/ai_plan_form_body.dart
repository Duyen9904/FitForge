import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/enums/target_muscle_group.dart';
import '../../viewmodels/generate_ai_plan_viewmodel.dart';

/// Form body for the AI plan generation screen
class AIPlanFormBody extends StatelessWidget {
  final GenerateAIPlanViewModel viewModel;
  final Set<TargetMuscleGroup> selectedMuscleGroups;
  final int durationWeeks;
  final DateTime? startDate;
  final String additionalInfo;
  final TextEditingController additionalInfoController;

  const AIPlanFormBody({
    super.key,
    required this.viewModel,
    required this.selectedMuscleGroups,
    required this.durationWeeks,
    required this.startDate,
    required this.additionalInfo,
    required this.additionalInfoController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Target Muscle Groups
        _SectionTitle(title: 'Target Muscle Groups', subtitle: 'Select one or more'),
        const SizedBox(height: AppDimensions.spacing12),
        _MuscleGroupChips(
          selected: selectedMuscleGroups,
          onToggle: viewModel.toggleMuscleGroup,
        ),
        if (selectedMuscleGroups.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'At least one muscle group is required',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
        const SizedBox(height: AppDimensions.spacing24),

        // 2. Duration
        _SectionTitle(
          title: 'Duration',
          subtitle: '$durationWeeks week${durationWeeks == 1 ? '' : 's'}',
        ),
        const SizedBox(height: AppDimensions.spacing12),
        _DurationSlider(
          durationWeeks: durationWeeks,
          onChanged: viewModel.updateDurationWeeks,
        ),
        const SizedBox(height: AppDimensions.spacing24),

        // 3. Start Date
        const _SectionTitle(title: 'Start Date'),
        const SizedBox(height: AppDimensions.spacing12),
        _DatePickerField(
          startDate: startDate,
          onDatePicked: viewModel.updateStartDate,
        ),
        const SizedBox(height: AppDimensions.spacing24),

        // 4. Additional Info
        const _SectionTitle(title: 'Additional Information', subtitle: 'Optional'),
        const SizedBox(height: AppDimensions.spacing12),
        _AdditionalInfoField(
          controller: additionalInfoController,
          onChanged: viewModel.updateAdditionalInfo,
        ),
        const SizedBox(height: AppDimensions.spacing32),

        // Generate Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: viewModel.isFormValid ? () => viewModel.submit() : null,
            icon: const Icon(Icons.auto_awesome),
            label: const Text(
              'Generate Plan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.grey300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacing24),
      ],
    );
  }
}

// ======================== PRIVATE SUB-WIDGETS ========================

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionTitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                ),
          ),
        ],
      ],
    );
  }
}

class _MuscleGroupChips extends StatelessWidget {
  final Set<TargetMuscleGroup> selected;
  final ValueChanged<TargetMuscleGroup> onToggle;

  const _MuscleGroupChips({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TargetMuscleGroup.values.map((group) {
        final isSelected = selected.contains(group);
        return FilterChip(
          label: Text(group.displayName),
          selected: isSelected,
          onSelected: (_) => onToggle(group),
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.grey700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.grey300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }
}

class _DurationSlider extends StatelessWidget {
  final int durationWeeks;
  final ValueChanged<int> onChanged;

  const _DurationSlider({required this.durationWeeks, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 week',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.grey500)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$durationWeeks week${durationWeeks == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Text('52 weeks',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.grey500)),
            ],
          ),
          Slider(
            value: durationWeeks.toDouble(),
            min: 1,
            max: 52,
            divisions: 51,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.grey200,
            onChanged: (val) => onChanged(val.round()),
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? startDate;
  final ValueChanged<DateTime?> onDatePicked;

  const _DatePickerField({required this.startDate, required this.onDatePicked});

  @override
  Widget build(BuildContext context) {
    final displayDate = startDate != null
        ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
        : 'Select a start date';

    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: startDate ?? now,
          firstDate: now,
          lastDate: now.add(const Duration(days: 365)),
          helpText: 'Select start date for your plan',
        );
        if (picked != null) {
          onDatePicked(picked);
        }
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16,
            vertical: AppDimensions.spacing16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: startDate != null ? AppColors.primary : AppColors.grey300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: startDate != null ? AppColors.primary : AppColors.grey500,
            ),
            const SizedBox(width: 12),
            Text(
              displayDate,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        startDate != null ? AppColors.grey900 : AppColors.grey500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdditionalInfoField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _AdditionalInfoField(
      {required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      maxLength: 1000,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText:
            'E.g., "Focus on hypertrophy for upper body" or "I have a shoulder injury"',
        hintStyle: const TextStyle(color: AppColors.grey400, fontSize: 14),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
