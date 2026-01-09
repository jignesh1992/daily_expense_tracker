import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';
import 'package:pocketa_expense_tracker/services/api_service.dart';
import 'package:pocketa_expense_tracker/services/local_db_service.dart';
import 'package:pocketa_expense_tracker/services/sync_service.dart';
import 'package:pocketa_expense_tracker/providers/auth_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ExpenseState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;
  final DateTime? filterDate;
  final Category? filterCategory;

  ExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
    this.filterDate,
    this.filterCategory,
  });

  ExpenseState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
    DateTime? filterDate,
    Category? filterCategory,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterDate: filterDate ?? this.filterDate,
      filterCategory: filterCategory ?? this.filterCategory,
    );
  }
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  ExpenseNotifier(this.ref) : super(ExpenseState()) {
    // Delay initial load to avoid modifying provider during initialization
    Future.microtask(() => _init());
  }

  final Ref ref;
  final _apiService = ApiService();
  final _localDb = LocalDbService();
  final _syncService = SyncService();

  Future<void> _init() async {
    await loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      List<Expense> expenses;

      if (isOnline) {
        // Try to fetch from API
        try {
          expenses = await _apiService.getExpenses(
            date: state.filterDate,
            category: state.filterCategory,
          );
          // Save to local DB
          for (final expense in expenses) {
            await _localDb.insertExpense(expense, synced: true);
          }
        } catch (e) {
          // Fallback to local DB
          expenses = await _localDb.getAllExpenses();
        }
      } else {
        // Use local DB
        expenses = await _localDb.getAllExpenses();
      }

      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createExpense({
    required double amount,
    required Category category,
    String? description,
    DateTime? date,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      Expense expense;
      if (isOnline) {
        expense = await _apiService.createExpense(
          amount: amount,
          category: category,
          description: description,
          date: date,
        );
        await _localDb.insertExpense(expense, synced: true);
      } else {
        // Create locally and add to sync queue
        expense = Expense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: ref.read(authProvider).user?.uid ?? '',
          amount: amount,
          category: category,
          description: description,
          date: date ?? DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _localDb.insertExpense(expense, synced: false);
        await _localDb.addToSyncQueue(expense.id, 'create', expense.toJson());
      }

      await loadExpenses();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateExpense({
    required String id,
    double? amount,
    Category? category,
    String? description,
    DateTime? date,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      Expense expense;
      if (isOnline) {
        expense = await _apiService.updateExpense(
          id: id,
          amount: amount,
          category: category,
          description: description,
          date: date,
        );
        await _localDb.updateExpense(expense, synced: true);
      } else {
        // Update locally and add to sync queue
        final existing = await _localDb.getExpense(id);
        if (existing == null) throw Exception('Expense not found');
        
        expense = existing.copyWith(
          amount: amount ?? existing.amount,
          category: category ?? existing.category,
          description: description ?? existing.description,
          date: date ?? existing.date,
          updatedAt: DateTime.now(),
        );
        await _localDb.updateExpense(expense, synced: false);
        await _localDb.addToSyncQueue(id, 'update', expense.toJson());
      }

      await loadExpenses();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        await _apiService.deleteExpense(id);
        await _localDb.deleteExpense(id);
      } else {
        // Delete locally and add to sync queue
        final expense = await _localDb.getExpense(id);
        if (expense != null) {
          await _localDb.addToSyncQueue(id, 'delete', expense.toJson());
        }
        await _localDb.deleteExpense(id);
      }

      await loadExpenses();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> setFilterDate(DateTime? date) async {
    state = state.copyWith(filterDate: date);
    await loadExpenses();
  }

  Future<void> setFilterCategory(Category? category) async {
    state = state.copyWith(filterCategory: category);
    await loadExpenses();
  }

  Future<void> sync() async {
    await _syncService.syncAll();
    await loadExpenses();
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  return ExpenseNotifier(ref);
});
