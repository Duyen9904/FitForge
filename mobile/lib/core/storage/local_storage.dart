import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for LocalStorage
final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});

/// Wrapper for SharedPreferences
class LocalStorage {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // String operations
  Future<String?> getString(String key) async {
    final prefs = await _preferences;
    return prefs.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    final prefs = await _preferences;
    return prefs.setString(key, value);
  }

  // Bool operations
  Future<bool?> getBool(String key) async {
    final prefs = await _preferences;
    return prefs.getBool(key);
  }

  Future<bool> setBool(String key, bool value) async {
    final prefs = await _preferences;
    return prefs.setBool(key, value);
  }

  // Int operations
  Future<int?> getInt(String key) async {
    final prefs = await _preferences;
    return prefs.getInt(key);
  }

  Future<bool> setInt(String key, int value) async {
    final prefs = await _preferences;
    return prefs.setInt(key, value);
  }

  // Double operations
  Future<double?> getDouble(String key) async {
    final prefs = await _preferences;
    return prefs.getDouble(key);
  }

  Future<bool> setDouble(String key, double value) async {
    final prefs = await _preferences;
    return prefs.setDouble(key, value);
  }

  // List<String> operations
  Future<List<String>?> getStringList(String key) async {
    final prefs = await _preferences;
    return prefs.getStringList(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _preferences;
    return prefs.setStringList(key, value);
  }

  // Remove and clear
  Future<bool> remove(String key) async {
    final prefs = await _preferences;
    return prefs.remove(key);
  }

  Future<bool> clear() async {
    final prefs = await _preferences;
    return prefs.clear();
  }

  Future<bool> containsKey(String key) async {
    final prefs = await _preferences;
    return prefs.containsKey(key);
  }
}

/// Local storage keys
class StorageKeys {
  StorageKeys._();

  static const String onboardingCompleted = 'onboarding_completed';
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String lastSyncTime = 'last_sync_time';
  static const String userId = 'user_id';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String favoriteExercises = 'favorite_exercises';
  static const String recentExercises = 'recent_exercises';
  static const String cachedEquipment = 'cached_equipment';
}
