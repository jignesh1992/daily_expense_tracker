import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pocketa_expense_tracker/models/expense.dart';
import 'package:pocketa_expense_tracker/models/summary.dart';
import 'package:pocketa_expense_tracker/services/firebase_service.dart';
import 'package:pocketa_expense_tracker/utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl => AppConstants.apiBaseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await FirebaseService.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }
      return fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      final error = json.decode(response.body) as Map<String, dynamic>;
      throw Exception(error['error'] ?? 'Request failed');
    }
  }

  Future<List<T>> _handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } else {
      final error = json.decode(response.body) as Map<String, dynamic>;
      throw Exception(error['error'] ?? 'Request failed');
    }
  }

  // Auth
  Future<Map<String, dynamic>> verifyToken() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/verify'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response, (json) => json);
  }

  // Expenses
  Future<Expense> createExpense({
    required double amount,
    required Category category,
    String? description,
    DateTime? date,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/expenses'),
      headers: await _getHeaders(),
      body: json.encode({
        'amount': amount,
        'category': category.name,
        'description': description,
        'date': (date ?? DateTime.now()).toIso8601String(),
      }),
    );
    return _handleResponse(response, (json) => Expense.fromJson(json));
  }

  Future<List<Expense>> getExpenses({
    DateTime? date,
    Category? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (date != null) {
      queryParams['date'] = date.toIso8601String();
    }
    if (category != null) {
      queryParams['category'] = category.name;
    }
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final uri = Uri.parse('$baseUrl/api/expenses').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());
    return _handleListResponse(response, (json) => Expense.fromJson(json));
  }

  Future<Expense> getExpense(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/expenses/$id'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response, (json) => Expense.fromJson(json));
  }

  Future<Expense> updateExpense({
    required String id,
    double? amount,
    Category? category,
    String? description,
    DateTime? date,
  }) async {
    final body = <String, dynamic>{};
    if (amount != null) body['amount'] = amount;
    if (category != null) body['category'] = category.name;
    if (description != null) body['description'] = description;
    if (date != null) body['date'] = date.toIso8601String();

    final response = await http.put(
      Uri.parse('$baseUrl/api/expenses/$id'),
      headers: await _getHeaders(),
      body: json.encode(body),
    );
    return _handleResponse(response, (json) => Expense.fromJson(json));
  }

  Future<void> deleteExpense(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/expenses/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = json.decode(response.body) as Map<String, dynamic>;
      throw Exception(error['error'] ?? 'Delete failed');
    }
  }

  // Summary
  Future<DailySummary> getDailySummary(DateTime? date) async {
    final queryParams = <String, String>{};
    if (date != null) {
      queryParams['date'] = date.toIso8601String();
    }

    final uri = Uri.parse('$baseUrl/api/summary/daily').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());
    return _handleResponse(response, (json) => DailySummary.fromJson(json));
  }

  Future<WeeklySummary> getWeeklySummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final uri = Uri.parse('$baseUrl/api/summary/weekly').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());
    return _handleResponse(response, (json) => WeeklySummary.fromJson(json));
  }

  Future<MonthlySummary> getMonthlySummary({
    int? year,
    int? month,
  }) async {
    final queryParams = <String, String>{};
    if (year != null) {
      queryParams['year'] = year.toString();
    }
    if (month != null) {
      queryParams['month'] = month.toString();
    }

    final uri = Uri.parse('$baseUrl/api/summary/monthly').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());
    return _handleResponse(response, (json) => MonthlySummary.fromJson(json));
  }

  // Voice
  Future<Map<String, dynamic>> parseVoiceInput(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/voice/parse'),
      headers: await _getHeaders(),
      body: json.encode({'text': text}),
    );
    return _handleResponse(response, (json) => json);
  }

  // Categories
  Future<List<String>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/categories'),
      headers: await _getHeaders(),
    );
    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    return data.map((e) => e.toString()).toList();
  }
}
