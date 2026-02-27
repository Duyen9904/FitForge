import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise_models.dart';
import '../repositories/equipment_repository.dart';
import 'equipment_list_state.dart';

/// Provider for EquipmentListViewModel
final equipmentListViewModelProvider =
    StateNotifierProvider<EquipmentListViewModel, EquipmentListState>((ref) {
  final repository = ref.watch(equipmentRepositoryProvider);
  return EquipmentListViewModel(repository: repository);
});

/// ViewModel for managing equipment list state
class EquipmentListViewModel extends StateNotifier<EquipmentListState> {
  final EquipmentRepository _repository;

  EquipmentListViewModel({required EquipmentRepository repository})
      : _repository = repository,
        super(const EquipmentListState.initial());

  /// Load all equipment and group by type
  Future<void> loadEquipment() async {
    state = const EquipmentListState.loading();

    try {
      final equipment = await _repository.getAllEquipment();

      // Group by equipment type
      final grouped = <String, List<Equipment>>{};
      for (final eq in equipment) {
        final type = eq.equipmentType;
        if (!grouped.containsKey(type)) {
          grouped[type] = [];
        }
        grouped[type]!.add(eq);
      }

      state = EquipmentListState.loaded(
        equipment: equipment,
        groupedEquipment: grouped,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load equipment',
        name: 'EquipmentListViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = EquipmentListState.error(e.toString());
    }
  }

  /// Refresh equipment list
  Future<void> refresh() async {
    await loadEquipment();
  }
}
