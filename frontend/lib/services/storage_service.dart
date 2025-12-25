import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketa_expense_tracker/utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Auth token
  Future<void> saveAuthToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.storageAuthTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.storageAuthTokenKey);
  }

  Future<void> removeAuthToken() async {
    final prefs = await _prefs;
    await prefs.remove(AppConstants.storageAuthTokenKey);
  }

  // User ID
  Future<void> saveUserId(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.storageUserIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.storageUserIdKey);
  }

  Future<void> removeUserId() async {
    final prefs = await _prefs;
    await prefs.remove(AppConstants.storageUserIdKey);
  }

  // Last sync timestamp
  Future<void> saveLastSync(DateTime timestamp) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.storageLastSyncKey, timestamp.toIso8601String());
  }

  Future<DateTime?> getLastSync() async {
    final prefs = await _prefs;
    final timestamp = prefs.getString(AppConstants.storageLastSyncKey);
    if (timestamp == null) return null;
    return DateTime.parse(timestamp);
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
