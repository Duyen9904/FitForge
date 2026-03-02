import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/states/state_widgets.dart';
import '../viewmodels/equipment_list_viewmodel.dart';
import '../viewmodels/exercise_types_state.dart';
import '../viewmodels/exercise_types_viewmodel.dart';
import '../widgets/equipment_card.dart';
import '../widgets/exercise_type_card.dart';

/// Exercise Library Screen
/// Shows exercise types and equipment with a segmented toggle.
/// - "Categories" tab: exercise types with difficulty filter chips
/// - "Equipment" tab: equipment list grouped by type
class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState
    extends ConsumerState<ExerciseLibraryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0; // 0 = Categories, 1 = Equipment

  static const _difficulties = ['Beginner', 'Intermediate', 'Expert'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseTypesViewModelProvider.notifier).loadTypes();
      ref.read(equipmentListViewModelProvider.notifier).loadEquipment();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Exercises',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Segmented toggle: Categories | Equipment
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
              vertical: AppDimensions.spacing8,
            ),
            child: _buildSegmentedToggle(),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
              vertical: AppDimensions.spacing4,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: _selectedTab == 0
                    ? 'Search categories'
                    : 'Search equipment',
                hintStyle: TextStyle(color: AppColors.grey400),
                prefixIcon: Icon(Icons.search, color: AppColors.grey400),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadius12),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadius12),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadius12),
                  borderSide:
                      BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing16,
                  vertical: AppDimensions.spacing12,
                ),
              ),
            ),
          ),

          // Difficulty filter chips (only for Categories tab)
          if (_selectedTab == 0)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing16,
                vertical: AppDimensions.spacing4,
              ),
              child: ref.watch(exerciseTypesViewModelProvider).maybeWhen(
                    loaded: (types, selectedDifficulty) =>
                        _buildDifficultyChips(selectedDifficulty),
                    orElse: () => _buildDifficultyChips(null),
                  ),
            ),

          const SizedBox(height: AppDimensions.spacing8),

          // Content
          Expanded(
            child: _selectedTab == 0
                ? _buildCategoriesContent()
                : _buildEquipmentContent(),
          ),
        ],
      ),
    );
  }

  // ===== Segmented Toggle =====

  Widget _buildSegmentedToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildToggleItem(
            index: 0,
            icon: Icons.category_outlined,
            label: 'Categories',
          ),
          _buildToggleItem(
            index: 1,
            icon: Icons.fitness_center,
            label: 'Equipment',
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.grey500,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.grey900 : AppColors.grey500,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Categories Content (existing behavior) =====

  Widget _buildCategoriesContent() {
    final state = ref.watch(exerciseTypesViewModelProvider);

    return state.when(
      initial: () => const Center(
        child: Text('Loading categories...'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      loaded: (types, selectedDifficulty) {
        // Filter types by search query
        final filteredTypes = _searchQuery.isEmpty
            ? types
            : types
                .where((t) => t.typeName
                    .toLowerCase()
                    .contains(_searchQuery))
                .toList();

        if (filteredTypes.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: 'No categories found',
            description: 'Try a different search term',
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref
              .read(exerciseTypesViewModelProvider.notifier)
              .refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.only(
              bottom: AppDimensions.spacing24,
            ),
            itemCount: filteredTypes.length,
            itemBuilder: (context, index) {
              final type = filteredTypes[index];
              return ExerciseTypeCard(
                exerciseType: type,
                onTap: () {
                  context.push(
                    '/exercises/type/${type.typeName}',
                    extra: selectedDifficulty,
                  );
                },
              );
            },
          ),
        );
      },
      error: (message) => ErrorState(
        message: message,
        onRetry: () => ref
            .read(exerciseTypesViewModelProvider.notifier)
            .loadTypes(),
      ),
    );
  }

  // ===== Equipment Content =====

  Widget _buildEquipmentContent() {
    final state = ref.watch(equipmentListViewModelProvider);

    return state.when(
      initial: () => const Center(
        child: Text('Loading equipment...'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      loaded: (equipment, groupedEquipment) {
        // Filter equipment by search query
        final filteredGroups = <String, List<dynamic>>{};
        for (final entry in groupedEquipment.entries) {
          final filteredItems = _searchQuery.isEmpty
              ? entry.value
              : entry.value
                  .where((eq) => eq.equipmentName
                      .toLowerCase()
                      .contains(_searchQuery))
                  .toList();
          if (filteredItems.isNotEmpty) {
            filteredGroups[entry.key] = filteredItems;
          }
        }

        if (filteredGroups.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: 'No equipment found',
            description: _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'No equipment available',
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(equipmentListViewModelProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            itemCount: filteredGroups.length,
            itemBuilder: (context, index) {
              final type = filteredGroups.keys.elementAt(index);
              final items = filteredGroups[type]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacing8,
                    ),
                    child: Text(
                      _formatEquipmentType(type),
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                    ),
                  ),

                  // Equipment items
                  ...items.map((eq) => EquipmentCard(
                        equipment: eq,
                        onTap: () {
                          context.push(
                            '/equipment/${eq.equipmentId}/exercises',
                            extra: eq.equipmentName,
                          );
                        },
                      )),

                  if (index < filteredGroups.length - 1)
                    const SizedBox(height: AppDimensions.spacing8),
                ],
              );
            },
          ),
        );
      },
      error: (message) => ErrorState(
        message: message,
        onRetry: () => ref
            .read(equipmentListViewModelProvider.notifier)
            .loadEquipment(),
      ),
    );
  }

  String _formatEquipmentType(String type) {
    if (type.isEmpty) return type;
    return type[0].toUpperCase() + type.substring(1).toLowerCase();
  }

  // ===== Difficulty Chips (Categories tab only) =====

  Widget _buildDifficultyChips(String? selectedDifficulty) {
    return Row(
      children: _difficulties.map((difficulty) {
        final isSelected = selectedDifficulty == difficulty;
        return Padding(
          padding: const EdgeInsets.only(right: AppDimensions.spacing8),
          child: FilterChip(
            label: Text(
              difficulty,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.grey700,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            selected: isSelected,
            onSelected: (_) {
              ref
                  .read(exerciseTypesViewModelProvider.notifier)
                  .selectDifficulty(difficulty);
            },
            backgroundColor: AppColors.white,
            selectedColor: AppColors.grey800,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
              side: BorderSide(
                color: isSelected ? AppColors.grey800 : AppColors.grey300,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing12,
              vertical: AppDimensions.spacing6,
            ),
          ),
        );
      }).toList(),
    );
  }
}
