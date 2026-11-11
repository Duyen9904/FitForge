import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/states/state_widgets.dart';
import '../models/exercise_models.dart';
import '../repositories/equipment_repository.dart';
import '../widgets/exercise_card.dart';

/// Equipment Exercises Screen
/// Shows exercises filtered by specific equipment
class EquipmentExercisesScreen extends ConsumerStatefulWidget {
  final int equipmentId;
  final String equipmentName;

  const EquipmentExercisesScreen({
    super.key,
    required this.equipmentId,
    required this.equipmentName,
  });

  @override
  ConsumerState<EquipmentExercisesScreen> createState() =>
      _EquipmentExercisesScreenState();
}

class _EquipmentExercisesScreenState
    extends ConsumerState<EquipmentExercisesScreen> {
  final _scrollController = ScrollController();
  List<ExerciseSummary> _exercises = [];
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadExercises();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoading) {
        _loadMore();
      }
    }
  }

  Future<void> _loadExercises() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(equipmentRepositoryProvider);
      final pageData = await repository.getExercisesByEquipment(
        widget.equipmentId,
        page: 0,
        size: 20,
      );

      if (mounted) {
        setState(() {
          _exercises = pageData.content;
          _currentPage = pageData.page;
          _totalPages = pageData.totalPages;
          _hasMore = !pageData.last;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(equipmentRepositoryProvider);
      final pageData = await repository.getExercisesByEquipment(
        widget.equipmentId,
        page: _currentPage + 1,
        size: 20,
      );

      if (mounted) {
        setState(() {
          _exercises = [..._exercises, ...pageData.content];
          _currentPage = pageData.page;
          _totalPages = pageData.totalPages;
          _hasMore = !pageData.last;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercises - ${widget.equipmentName}'),
      ),
      body: _error != null
          ? ErrorState(
              message: _error!,
              onRetry: _loadExercises,
            )
          : _exercises.isEmpty && _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _exercises.isEmpty
                  ? const EmptyScreen(
                      title: 'No exercises found',
                      description:
                          'No exercises available for this equipment',
                    )
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppDimensions.spacing16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: AppDimensions.spacing12,
                          mainAxisSpacing: AppDimensions.spacing12,
                        ),
                        itemCount: _exercises.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _exercises.length) {
                            // Loading indicator at bottom
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(
                                    AppDimensions.spacing16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final exercise = _exercises[index];
                          return ExerciseCard(
                            exercise: exercise,
                            onTap: () {
                              context.push(
                                '/exercises/${exercise.exerciseId}',
                              );
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}
