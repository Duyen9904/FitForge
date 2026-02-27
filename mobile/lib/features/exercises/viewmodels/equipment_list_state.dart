import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/exercise_models.dart';

part 'equipment_list_state.freezed.dart';

/// State for equipment list screen
@freezed
class EquipmentListState with _$EquipmentListState {
  const factory EquipmentListState.initial() = EquipmentListInitial;
  
  const factory EquipmentListState.loading() = EquipmentListLoading;
  
  const factory EquipmentListState.loaded({
    required List<Equipment> equipment,
    required Map<String, List<Equipment>> groupedEquipment,
  }) = EquipmentListLoaded;
  
  const factory EquipmentListState.error(String message) = EquipmentListError;
}
