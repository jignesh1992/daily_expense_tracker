import 'package:flutter/material.dart';

class AppConstants {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const String storageAuthTokenKey = 'auth_token';
  static const String storageUserIdKey = 'user_id';
  static const String storageLastSyncKey = 'last_sync';

  static const List<String> categoryNames = [
    'food',
    'transport',
    'shopping',
    'entertainment',
    'bills',
    'other',
  ];

  static Map<String, String> categoryDisplayNames = {
    'food': 'Food',
    'transport': 'Transport',
    'shopping': 'Shopping',
    'entertainment': 'Entertainment',
    'bills': 'Bills',
    'other': 'Other',
  };

  static Map<String, Color> categoryColors = {
    'food': const Color(0xFFEF4444),
    'transport': const Color(0xFF3B82F6),
    'shopping': const Color(0xFF8B5CF6),
    'entertainment': const Color(0xFFEC4899),
    'bills': const Color(0xFFF59E0B),
    'other': const Color(0xFF6B7280),
  };
}
