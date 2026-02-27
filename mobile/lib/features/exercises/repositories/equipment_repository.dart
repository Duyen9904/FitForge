import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/local_storage.dart';
import '../models/exercise_models.dart';
import '../services/equipment_service.dart';

/// Provider for EquipmentRepository
final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  final service = ref.watch(equipmentServiceProvider);
  final localStorage = ref.watch(localStorageProvider);
  return EquipmentRepository(
    service: service,
    localStorage: localStorage,
  );
});

/// Repository for equipment operations
/// Orchestrates between API service and local storage
class EquipmentRepository {
  final EquipmentService _service;
  final LocalStorage _localStorage;

  EquipmentRepository({
    required EquipmentService service,
    required LocalStorage localStorage,
  })  : _service = service,
        _localStorage = localStorage;

  /// Unwrap ApiResponse and throw if not successful
  T _unwrapResponse<T>(ApiResponse<T> response) {
    if (!response.success) {
      final errorMessage =
          response.error?.message ?? response.message ?? 'Request failed';
      throw EquipmentException(
        message: errorMessage,
      );
    }
    if (response.data == null) {
      throw EquipmentException(message: 'No data in response');
    }
    return response.data as T;
  }

  /// Get all equipment
  Future<List<Equipment>> getAllEquipment() async {
    final response = await _service.getAllEquipment();
    final equipment = _unwrapResponse(response);

    // Cache locally for offline access
    await _cacheEquipment(equipment);

    return equipment;
  }

  /// Get equipment details by ID
  Future<Equipment> getEquipmentById(int equipmentId) async {
    final response = await _service.getEquipmentById(equipmentId);
    return _unwrapResponse(response);
  }

  /// Get exercises by equipment
  Future<PageData<ExerciseSummary>> getExercisesByEquipment(
    int equipmentId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _service.getExercisesByEquipment(
      equipmentId,
      page: page,
      size: size,
    );
    return _unwrapResponse(response);
  }

  // ===== Local Storage Helpers =====

  /// Cache equipment list locally
  Future<void> _cacheEquipment(List<Equipment> equipment) async {
    try {
      final jsonList = equipment.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _localStorage.setString(StorageKeys.cachedEquipment, jsonString);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Get cached equipment
  Future<List<Equipment>?> getCachedEquipment() async {
    try {
      final jsonString =
          await _localStorage.getString(StorageKeys.cachedEquipment);
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((item) => Equipment.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Clear equipment cache
  Future<void> clearCache() async {
    await _localStorage.remove(StorageKeys.cachedEquipment);
  }
}

/// Custom exception for equipment operations
class EquipmentException implements Exception {
  final String message;

  EquipmentException({required this.message});

  @override
  String toString() => message;
}
