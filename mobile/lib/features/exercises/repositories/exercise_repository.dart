import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_response.dart';
import '../../../core/storage/local_storage.dart';
import '../models/exercise_filter.dart';
import '../models/exercise_category_response.dart';
import '../models/exercise_models.dart';
import '../models/exercise_type_response.dart';
import '../services/exercise_service.dart';

/// Provider for ExerciseRepository
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final service = ref.watch(exerciseServiceProvider);
  final localStorage = ref.watch(localStorageProvider);
  return ExerciseRepository(
    service: service,
    localStorage: localStorage,
  );
});

/// Repository for exercise operations
/// Orchestrates between API service and local storage
class ExerciseRepository {
  final ExerciseService _service;
  final LocalStorage _localStorage;

  ExerciseRepository({
    required ExerciseService service,
    required LocalStorage localStorage,
  })  : _service = service,
        _localStorage = localStorage;

  /// Unwrap ApiResponse and throw if not successful
  T _unwrapResponse<T>(ApiResponse<T> response) {
    if (!response.success) {
      final errorMessage =
          response.error?.message ?? response.message ?? 'Request failed';
      throw ExerciseException(
        message: errorMessage,
        fieldErrors: response.error?.fieldErrors,
      );
    }
    if (response.data == null) {
      throw ExerciseException(message: 'No data in response');
    }
    return response.data as T;
  }

  /// Unwrap ApiResponse for void operations
  void _unwrapVoidResponse(ApiResponse<void> response) {
    if (!response.success) {
      final errorMessage =
          response.error?.message ?? response.message ?? 'Request failed';
      throw ExerciseException(
        message: errorMessage,
        fieldErrors: response.error?.fieldErrors,
      );
    }
  }

  /// Get all available exercise types with counts
  Future<List<ExerciseTypeResponse>> getExerciseTypes() async {
    final response = await _service.getExerciseTypes();
    return _unwrapResponse(response);
  }

  /// Get exercise categories with counts
  Future<List<ExerciseCategoryResponse>> getExerciseCategories() async {
    final response = await _service.getExerciseCategories();
    return _unwrapResponse(response);
  }

  /// UC-4.1: Browse exercises with filters and pagination
  Future<PageData<ExerciseSummary>> browseExercises({
    ExerciseFilter? filter,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final response = await _service.browseExercises(
      filter: filter,
      page: page,
      size: size,
      sort: sort,
    );
    return _unwrapResponse(response);
  }

  /// UC-4.2: Get exercise details by ID
  Future<Exercise> getExerciseById(String exerciseId) async {
    final response = await _service.getExerciseById(exerciseId);
    final exercise = _unwrapResponse(response);
    
    // Track recently viewed exercises
    await _addToRecentExercises(exerciseId);
    
    return exercise;
  }

  /// UC-4.3: Add exercise to favorites
  Future<void> addToFavorites(String exerciseId) async {
    final response = await _service.addToFavorites(exerciseId);
    _unwrapVoidResponse(response);
    
    // Update local cache
    await _addToFavoritesCache(exerciseId);
  }

  /// UC-4.3: Remove exercise from favorites
  Future<void> removeFromFavorites(String exerciseId) async {
    final response = await _service.removeFromFavorites(exerciseId);
    _unwrapVoidResponse(response);
    
    // Update local cache
    await _removeFromFavoritesCache(exerciseId);
  }

  /// UC-4.3: Check if exercise is in favorites
  Future<bool> isFavorite(String exerciseId) async {
    try {
      final response = await _service.isFavorite(exerciseId);
      return _unwrapResponse(response);
    } catch (e) {
      // Fallback to local cache if API fails
      return _isInFavoritesCache(exerciseId);
    }
  }

  /// UC-4.3: Get user's favorite exercises
  Future<PageData<ExerciseSummary>> getUserFavorites({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _service.getUserFavorites(
      page: page,
      size: size,
    );
    return _unwrapResponse(response);
  }

  /// UC-4.4: Get alternative exercises
  Future<List<ExerciseAlternative>> getAlternatives(String exerciseId) async {
    final response = await _service.getAlternatives(exerciseId);
    return _unwrapResponse(response);
  }

  /// Get exercise suggestions for a muscle group
  Future<List<ExerciseSuggestion>> getExerciseSuggestions({
    required String muscleGroup,
    int limit = 2,
  }) async {
    final response = await _service.getExerciseSuggestions(
      muscleGroup: muscleGroup,
      limit: limit,
    );
    return _unwrapResponse(response);
  }

  /// UC-12.3: Get exercise recommendations
  Future<List<ExerciseRecommendation>> getRecommendations({
    int? sessionId,
    int limit = 10,
  }) async {
    final response = await _service.getRecommendations(
      sessionId: sessionId,
      limit: limit,
    );
    return _unwrapResponse(response);
  }

  // ===== Local Storage Helpers =====

  /// Add exercise to favorites cache
  Future<void> _addToFavoritesCache(String exerciseId) async {
    final favorites = await _getFavoritesCache();
    if (!favorites.contains(exerciseId)) {
      favorites.add(exerciseId);
      await _localStorage.setStringList(
        StorageKeys.favoriteExercises,
        favorites.toList(),
      );
    }
  }

  /// Remove exercise from favorites cache
  Future<void> _removeFromFavoritesCache(String exerciseId) async {
    final favorites = await _getFavoritesCache();
    favorites.remove(exerciseId);
    await _localStorage.setStringList(
      StorageKeys.favoriteExercises,
      favorites.toList(),
    );
  }

  /// Check if exercise is in favorites cache
  Future<bool> _isInFavoritesCache(String exerciseId) async {
    final favorites = await _getFavoritesCache();
    return favorites.contains(exerciseId);
  }

  /// Get favorites from cache
  Future<Set<String>> _getFavoritesCache() async {
    final favorites = await _localStorage.getStringList(
      StorageKeys.favoriteExercises,
    );
    if (favorites == null) return {};
    return favorites.toSet();
  }

  /// Add exercise to recent exercises
  Future<void> _addToRecentExercises(String exerciseId) async {
    final recent = await _getRecentExercises();
    
    // Remove if already exists to reorder
    recent.remove(exerciseId);
    
    // Add to beginning
    recent.insert(0, exerciseId);
    
    // Keep only last 20
    if (recent.length > 20) {
      recent.removeRange(20, recent.length);
    }
    
    await _localStorage.setStringList(
      StorageKeys.recentExercises,
      recent,
    );
  }

  /// Get recent exercises
  Future<List<String>> _getRecentExercises() async {
    final recent = await _localStorage.getStringList(
      StorageKeys.recentExercises,
    );
    if (recent == null) return [];
    return recent.toList();
  }

  /// Clear favorites cache (e.g., on logout)
  Future<void> clearFavoritesCache() async {
    await _localStorage.remove(StorageKeys.favoriteExercises);
    await _localStorage.remove(StorageKeys.recentExercises);
  }
}

/// Custom exception for exercise operations
class ExerciseException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  ExerciseException({required this.message, this.fieldErrors});

  @override
  String toString() => message;
}
