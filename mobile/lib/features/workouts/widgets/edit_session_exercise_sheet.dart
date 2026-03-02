import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../exercises/models/exercise_models.dart';
import '../../exercises/repositories/exercise_repository.dart';
import '../models/workout_plan_models.dart';

/// Bottom sheet for editing a session exercise.
/// Prefills all editable fields and provides an exercise picker.
class EditSessionExerciseSheet extends ConsumerStatefulWidget {
  final SessionExerciseResponse sessionExercise;
  final void Function(UpdateSessionExerciseRequest request) onSave;

  const EditSessionExerciseSheet({
    super.key,
    required this.sessionExercise,
    required this.onSave,
  });

  @override
  ConsumerState<EditSessionExerciseSheet> createState() =>
      _EditSessionExerciseSheetState();
}

class _EditSessionExerciseSheetState
    extends ConsumerState<EditSessionExerciseSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _restController;
  late TextEditingController _orderController;
  late TextEditingController _notesController;
  late bool _isSuperset;

  // Exercise picker state
  int? _selectedExerciseId;
  String? _selectedExerciseName;
  String? _selectedExerciseImage;

  // Exercise search state
  List<ExerciseSummary> _exercises = [];
  bool _loadingExercises = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final ex = widget.sessionExercise;
    _setsController = TextEditingController(text: ex.sets?.toString() ?? '');
    _repsController =
        TextEditingController(text: ex.repetitions?.toString() ?? '');
    _weightController =
        TextEditingController(text: ex.weightKg?.toString() ?? '');
    _restController =
        TextEditingController(text: ex.restTimeSeconds?.toString() ?? '');
    _orderController =
        TextEditingController(text: ex.orderIndex?.toString() ?? '');
    _notesController = TextEditingController(text: ex.notes ?? '');
    _isSuperset = ex.isSuperset;

    _selectedExerciseId = ex.exercise?.exerciseId;
    _selectedExerciseName = ex.exercise?.exerciseName;
    _selectedExerciseImage = ex.exercise?.imageUrl;
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    _orderController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() => _loadingExercises = true);
    try {
      final result = await ref.read(exerciseRepositoryProvider).browseExercises(
            page: 0,
            size: 50,
            sort: 'exerciseName,asc',
          );
      if (mounted) {
        setState(() {
          _exercises = result.content;
          _loadingExercises = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingExercises = false);
      }
    }
  }

  void _showExercisePicker() async {
    await _loadExercises();

    if (!mounted) return;

    final selected = await showModalBottomSheet<ExerciseSummary>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXLarge)),
      ),
      builder: (context) => _ExercisePickerSheet(
        exercises: _exercises,
        loading: _loadingExercises,
        selectedExerciseId: _selectedExerciseId,
        searchQuery: _searchQuery,
        onSearch: (query) {
          _searchQuery = query;
        },
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedExerciseId = selected.exerciseId;
        _selectedExerciseName = selected.exerciseName;
        _selectedExerciseImage = selected.imageUrl;
      });
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final request = UpdateSessionExerciseRequest(
      exerciseId: _selectedExerciseId,
      sets: _setsController.text.isNotEmpty
          ? int.tryParse(_setsController.text)
          : null,
      repetitions: _repsController.text.isNotEmpty
          ? int.tryParse(_repsController.text)
          : null,
      weightKg: _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
      restTimeSeconds: _restController.text.isNotEmpty
          ? int.tryParse(_restController.text)
          : null,
      orderIndex: _orderController.text.isNotEmpty
          ? int.tryParse(_orderController.text)
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      isSuperset: _isSuperset,
    );

    widget.onSave(request);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Title
                  Text(
                    'Edit Exercise',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey900,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.spacing20),

                  // Exercise picker
                  Text(
                    'Exercise',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  InkWell(
                    onTap: _showExercisePicker,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.spacing12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      child: Row(
                        children: [
                          // Exercise image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSmall),
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: _selectedExerciseImage != null
                                  ? CachedNetworkImage(
                                      imageUrl: _selectedExerciseImage!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        color: AppColors.grey200,
                                        child: const Icon(
                                            Icons.fitness_center,
                                            color: AppColors.grey400,
                                            size: 20),
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        color: AppColors.grey200,
                                        child: const Icon(
                                            Icons.fitness_center,
                                            color: AppColors.grey400,
                                            size: 20),
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.grey200,
                                      child: const Icon(Icons.fitness_center,
                                          color: AppColors.grey400, size: 20),
                                    ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacing12),
                          Expanded(
                            child: Text(
                              _selectedExerciseName ?? 'Select Exercise',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: _selectedExerciseName != null
                                        ? AppColors.grey900
                                        : AppColors.grey500,
                                  ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.grey400, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Sets & Reps row
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          controller: _setsController,
                          label: 'Sets',
                          hint: '3',
                          min: 1,
                          max: 20,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                      Expanded(
                        child: _buildNumberField(
                          controller: _repsController,
                          label: 'Reps',
                          hint: '12',
                          min: 1,
                          max: 100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing12),

                  // Weight & Rest row
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          controller: _weightController,
                          label: 'Weight (kg)',
                          hint: '0.0',
                          isDecimal: true,
                          min: 0,
                          max: 1000,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                      Expanded(
                        child: _buildNumberField(
                          controller: _restController,
                          label: 'Rest (sec)',
                          hint: '60',
                          min: 0,
                          max: 600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing12),

                  // Order index
                  _buildNumberField(
                    controller: _orderController,
                    label: 'Order',
                    hint: '0',
                    min: 0,
                    max: 99,
                  ),
                  const SizedBox(height: AppDimensions.spacing12),

                  // Notes
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.spacing4),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Optional notes...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      contentPadding:
                          const EdgeInsets.all(AppDimensions.spacing12),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing12),

                  // Superset toggle
                  SwitchListTile(
                    title: Text(
                      'Superset',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                          ),
                    ),
                    subtitle: Text(
                      'Perform with the next exercise without rest',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                          ),
                    ),
                    value: _isSuperset,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) => setState(() => _isSuperset = value),
                  ),
                  const SizedBox(height: AppDimensions.spacing20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _onSave,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding:  EdgeInsets.symmetric(
                            vertical: AppDimensions.spacing12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isDecimal = false,
    int? min,
    int? max,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
        ),
        const SizedBox(height: AppDimensions.spacing4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing12,
              vertical: AppDimensions.spacing8,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            final num? parsed =
                isDecimal ? double.tryParse(value) : int.tryParse(value);
            if (parsed == null) return 'Invalid number';
            if (min != null && parsed < min) return 'Min: $min';
            if (max != null && parsed > max) return 'Max: $max';
            return null;
          },
        ),
      ],
    );
  }
}

/// Inner bottom sheet for picking an exercise from the library.
class _ExercisePickerSheet extends StatefulWidget {
  final List<ExerciseSummary> exercises;
  final bool loading;
  final int? selectedExerciseId;
  final String searchQuery;
  final ValueChanged<String> onSearch;

  const _ExercisePickerSheet({
    required this.exercises,
    required this.loading,
    required this.selectedExerciseId,
    required this.searchQuery,
    required this.onSearch,
  });

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  late TextEditingController _searchController;
  late List<ExerciseSummary> _filtered;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _filtered = widget.exercises;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    widget.onSearch(query);
    setState(() {
      if (query.isEmpty) {
        _filtered = widget.exercises;
      } else {
        _filtered = widget.exercises
            .where((e) =>
                e.exerciseName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          const SizedBox(height: AppDimensions.spacing8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Exercise',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppDimensions.spacing12),
                TextField(
                  controller: _searchController,
                  onChanged: _filter,
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing12,
                      vertical: AppDimensions.spacing8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.loading)
            const Padding(
              padding: EdgeInsets.all(AppDimensions.spacing24),
              child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No exercises found',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.grey500,
                                ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final exercise = _filtered[index];
                        final isSelected =
                            exercise.exerciseId == widget.selectedExerciseId;
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSmall),
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: exercise.imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: exercise.imageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        color: AppColors.grey200,
                                        child: const Icon(
                                            Icons.fitness_center,
                                            color: AppColors.grey400,
                                            size: 20),
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        color: AppColors.grey200,
                                        child: const Icon(
                                            Icons.fitness_center,
                                            color: AppColors.grey400,
                                            size: 20),
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.grey200,
                                      child: const Icon(Icons.fitness_center,
                                          color: AppColors.grey400, size: 20),
                                    ),
                            ),
                          ),
                          title: Text(
                            exercise.exerciseName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.grey900,
                                ),
                          ),
                          subtitle: Text(
                            '${exercise.exerciseType} · ${exercise.difficultyLevel}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.grey500),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: AppColors.primary, size: 24)
                              : null,
                          onTap: () => Navigator.pop(context, exercise),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
