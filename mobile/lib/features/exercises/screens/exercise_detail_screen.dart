import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/states/state_widgets.dart';
import '../models/exercise_models.dart';
import '../viewmodels/exercise_detail_state.dart';
import '../viewmodels/exercise_detail_viewmodel.dart';
import '../widgets/alternative_exercise_card.dart';
import '../widgets/add_exercise_to_session_sheet.dart';
import '../widgets/difficulty_badge.dart';
import '../widgets/equipment_detail_bottom_sheet.dart';
import '../widgets/equipment_list_item.dart';
import '../widgets/muscle_group_chip.dart';

/// UC-4.2: Exercise Detail Screen
/// View comprehensive exercise information including alternatives
class ExerciseDetailScreen extends ConsumerWidget {
  final int exerciseId;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exerciseDetailViewModelProvider(exerciseId));

    return Scaffold(
      body: state.when(
        initial: () => const Center(
          child: Text('Loading...'),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        loaded: (exercise, isFavorite, isTogglingFavorite) {
          return CustomScrollView(
            slivers: [
              // App bar with image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: exercise.imageUrl != null
                      ? Image.network(
                          exercise.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                actions: [
                  // Favorite button
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: isTogglingFavorite
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.black,
                            ),
                            onPressed: () async {
                              try {
                                await ref
                                    .read(exerciseDetailViewModelProvider(
                                            exerciseId)
                                        .notifier)
                                    .toggleFavorite();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isFavorite
                                            ? 'Removed from favorites'
                                            : 'Added to favorites',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and difficulty
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              exercise.exerciseName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacing12),
                          DifficultyBadge(
                            difficultyLevel: exercise.difficultyLevel,
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.primary,
                            ),
                            tooltip: 'Add to workout session',
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: AppColors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                        AppDimensions.radiusXLarge),
                                  ),
                                ),
                                builder: (_) => AddExerciseToSessionSheet(
                                  exerciseId: exercise.exerciseId,
                                  exerciseName: exercise.exerciseName,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Description
                      Text(
                        exercise.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppDimensions.spacing24),

                      // Quick Info
                      _buildQuickInfo(context, exercise),
                      const SizedBox(height: AppDimensions.spacing24),

                      // Muscle Groups
                      if (exercise.primaryMuscleGroups.isNotEmpty ||
                          exercise.secondaryMuscleGroups.isNotEmpty) ...[
                        _buildSectionTitle(context, 'Target Muscles'),
                        const SizedBox(height: AppDimensions.spacing12),
                        Wrap(
                          spacing: AppDimensions.spacing8,
                          runSpacing: AppDimensions.spacing8,
                          children: [
                            ...exercise.primaryMuscleGroups.map(
                              (mg) => MuscleGroupChip(
                                groupName: mg.groupName,
                                isPrimary: true,
                              ),
                            ),
                            ...exercise.secondaryMuscleGroups.map(
                              (mg) => MuscleGroupChip(
                                groupName: mg.groupName,
                                isPrimary: false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacing24),
                      ],

                      // Instructions
                      _buildSectionTitle(context, 'Instructions'),
                      const SizedBox(height: AppDimensions.spacing12),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.spacing16),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadius12),
                        ),
                        child: Text(
                          exercise.instructions,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing24),

                      // Equipment
                      if (exercise.equipment.isNotEmpty) ...[
                        _buildSectionTitle(context, 'Equipment Needed'),
                        const SizedBox(height: AppDimensions.spacing12),
                        ...exercise.equipment.map(
                          (eq) => EquipmentListItem(
                            equipment: eq,
                            onTap: () => _showEquipmentDetail(context, eq),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacing24),
                      ],

                      // Safety Notes
                      if (exercise.requiresSpotter) ...[
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.spacing16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadius12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: AppDimensions.spacing12),
                              Expanded(
                                child: Text(
                                  'This exercise requires a spotter for safety',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.orange.shade900,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacing24),
                      ],

                      // Alternatives (UC-4.4)
                      if (exercise.alternatives.isNotEmpty) ...[
                        _buildSectionTitle(context, 'Alternative Exercises'),
                        const SizedBox(height: AppDimensions.spacing12),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: exercise.alternatives.length,
                            itemBuilder: (context, index) {
                              final alternative = exercise.alternatives[index];
                              return AlternativeExerciseCard(
                                alternative: alternative,
                                onTap: () {
                                  context.push(
                                    '/exercises/${alternative.alternativeExercise.exerciseId}',
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (message) => Center(
          child: ErrorState(
            message: message,
            onRetry: () => ref
                .read(exerciseDetailViewModelProvider(exerciseId).notifier)
                .refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.grey200,
      child: Center(
        child: Icon(
          Icons.fitness_center,
          size: 80,
          color: AppColors.grey400,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildQuickInfo(BuildContext context, exercise) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            context,
            icon: Icons.category,
            label: 'Type',
            value: exercise.exerciseType,
          ),
          if (exercise.caloriesBurnedPerMin != null)
            _buildInfoItem(
              context,
              icon: Icons.local_fire_department,
              label: 'Calories',
              value: '${exercise.caloriesBurnedPerMin}/min',
            ),
          if (exercise.equipmentCategory != null)
            _buildInfoItem(
              context,
              icon: Icons.fitness_center,
              label: 'Category',
              value: exercise.equipmentCategory!,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: AppDimensions.spacing4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey600,
              ),
        ),
        const SizedBox(height: AppDimensions.spacing4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  void _showEquipmentDetail(BuildContext context, Equipment equipment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EquipmentDetailBottomSheet(equipment: equipment),
    );
  }
}
