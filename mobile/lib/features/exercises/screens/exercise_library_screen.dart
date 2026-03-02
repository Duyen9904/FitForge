import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../viewmodels/exercise_types_viewmodel.dart';
import '../viewmodels/equipment_list_viewmodel.dart';
import '../widgets/categories_tab_content.dart';
import '../widgets/equipment_tab_content.dart';

/// Exercise Library Screen
/// Shows exercise types and equipment with an underline-style tab bar.
/// - "Categories" tab: exercise types with difficulty dropdown
/// - "Equipment" tab: equipment list grouped by type
class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState
    extends ConsumerState<ExerciseLibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Rebuild when tab changes so we can show/hide the dropdown
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseTypesViewModelProvider.notifier).loadTypes();
      ref.read(equipmentListViewModelProvider.notifier).loadEquipment();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      ),
      body: Column(
        children: [
          // Underline-style TabBar
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.grey200,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey500,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Categories'),
                Tab(text: 'Equipment'),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacing8),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                CategoriesTabContent(),
                EquipmentTabContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
