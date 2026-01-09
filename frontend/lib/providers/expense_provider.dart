import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';
import 'package:pocketa_expense_tracker/services/api_service.dart';
import 'package:pocketa_expense_tracker/services/local_db_service.dart';
import 'package:pocketa_expense_tracker/services/sync_service.dart';
import 'package:pocketa_expense_tracker/providers/auth_provider.dart';
import 'package:pocketa_expense_tracker/providers/summary_provider.dart';
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
    bool clearFilterDate = false,
    bool clearFilterCategory = false,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterDate: clearFilterDate ? null : (filterDate ?? this.filterDate),
      filterCategory: clearFilterCategory ? null : (filterCategory ?? this.filterCategory),
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

      final currentUserId = ref.read(authProvider).user?.uid;
      print('Loading expenses - isOnline: $isOnline, userId: $currentUserId');
      
      if (isOnline) {
        // Try to fetch from API
        try {
          // Always fetch all expenses first, then apply filters client-side
          // This ensures filtering works even if API doesn't support it correctly
          final allExpenses = await _apiService.getExpenses();
          print('Fetched ${allExpenses.length} expenses from API');
          
          // Debug: Check userIds in expenses
          if (allExpenses.isNotEmpty) {
            final uniqueUserIds = allExpenses.map((e) => e.userId).toSet();
            print('Expenses have userIds: $uniqueUserIds');
            print('Current userId: $currentUserId');
          }
          
          // Filter by userId first (only show current user's expenses)
          // If userId is null or empty, show all expenses (for backward compatibility)
          List<Expense> userExpenses;
          if (currentUserId != null && currentUserId.isNotEmpty) {
            userExpenses = allExpenses.where((e) => e.userId == currentUserId).toList();
            print('Filtered to ${userExpenses.length} expenses for userId: $currentUserId');
            
            // If no expenses match userId, show all expenses (backward compatibility)
            // This handles cases where expenses were created before userId filtering
            if (userExpenses.isEmpty && allExpenses.isNotEmpty) {
              print('No expenses match userId, showing all expenses for backward compatibility');
              userExpenses = allExpenses;
            }
          } else {
            // If no userId, show all expenses (backward compatibility)
            userExpenses = allExpenses;
            print('No userId, showing all ${userExpenses.length} expenses');
          }
          
          // Save user's expenses to local DB
          // Update userId if it doesn't match (for backward compatibility)
          for (final expense in userExpenses) {
            Expense expenseToSave = expense;
            if (currentUserId != null && currentUserId.isNotEmpty && expense.userId != currentUserId) {
              // Update expense with current userId
              expenseToSave = expense.copyWith(userId: currentUserId);
            }
            await _localDb.insertExpense(expenseToSave, synced: true);
          }
          
          // Then apply date/category filtering for display
          expenses = _applyFilters(userExpenses, state.filterDate, state.filterCategory);
          print('After filters: ${expenses.length} expenses');
        } catch (e) {
          print('Error loading expenses from API: $e');
          // Fallback to local DB - show all expenses
          expenses = await _localDb.getAllExpenses(
            date: state.filterDate,
            category: state.filterCategory,
            userId: null, // Don't filter by userId to show all expenses
          );
          print('Loaded ${expenses.length} expenses from local DB (fallback)');
        }
      } else {
        // Use local DB - show all expenses
        expenses = await _localDb.getAllExpenses(
          date: state.filterDate,
          category: state.filterCategory,
          userId: null, // Don't filter by userId to show all expenses
        );
        print('Loaded ${expenses.length} expenses from local DB (offline)');
      }

      print('Final expenses count: ${expenses.length}');
      print('Active filters - date: ${state.filterDate}, category: ${state.filterCategory}');
      
      // If no expenses found and filters are active, log a warning
      if (expenses.isEmpty && (state.filterDate != null || state.filterCategory != null)) {
        print('WARNING: No expenses found but filters are active!');
      }
      
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      print('Error in loadExpenses: $e');
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

      // Normalize date to UTC midnight to avoid timezone issues
      // Extract date components from local date and create UTC date
      final normalizedDate = date != null
          ? DateTime.utc(date.year, date.month, date.day)
          : DateTime.now();

      Expense expense;
      if (isOnline) {
        expense = await _apiService.createExpense(
          amount: amount,
          category: category,
          description: description,
          date: normalizedDate,
        );
        await _localDb.insertExpense(expense, synced: true);
      } else {
        // Create locally and add to sync queue
        final now = DateTime.now();
        expense = Expense(
          id: now.millisecondsSinceEpoch.toString(),
          userId: ref.read(authProvider).user?.uid ?? '',
          amount: amount,
          category: category,
          description: description,
          date: normalizedDate,
          createdAt: now,
          updatedAt: now,
        );
        await _localDb.insertExpense(expense, synced: false);
        await _localDb.addToSyncQueue(expense.id, 'create', expense.toJson());
      }

      await loadExpenses();
      // Wait a bit to ensure expenses are loaded, then refresh summary
      await Future.delayed(const Duration(milliseconds: 100));
      // Refresh today's summary after creating expense
      ref.read(summaryProvider.notifier).loadDailySummary(null);
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

      // Normalize date to UTC midnight to avoid timezone issues
      // Extract date components from local date and create UTC date
      DateTime? normalizedDate;
      if (date != null) {
        normalizedDate = DateTime.utc(date.year, date.month, date.day);
      }

      Expense expense;
      if (isOnline) {
        expense = await _apiService.updateExpense(
          id: id,
          amount: amount,
          category: category,
          description: description,
          date: normalizedDate,
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
          date: normalizedDate ?? existing.date,
          updatedAt: DateTime.now(),
        );
        await _localDb.updateExpense(expense, synced: false);
        await _localDb.addToSyncQueue(id, 'update', expense.toJson());
      }

      await loadExpenses();
      // Wait a bit to ensure expenses are loaded, then refresh summary
      await Future.delayed(const Duration(milliseconds: 100));
      // Refresh today's summary after updating expense
      ref.read(summaryProvider.notifier).loadDailySummary(null);
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
      // Wait a bit to ensure expenses are loaded, then refresh summary
      await Future.delayed(const Duration(milliseconds: 100));
      // Refresh today's summary after deleting expense
      ref.read(summaryProvider.notifier).loadDailySummary(null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> setFilterDate(DateTime? date) async {
    // Keep filter date as local date for UI display
    // The filtering logic will handle UTC conversion
    DateTime? normalizedDate;
    if (date != null) {
      // Keep as local date for filtering comparison
      normalizedDate = DateTime(date.year, date.month, date.day);
    }
    state = state.copyWith(
      filterDate: normalizedDate,
      clearFilterDate: date == null,
    );
    await loadExpenses();
  }

  Future<void> setFilterCategory(Category? category) async {
    state = state.copyWith(
      filterCategory: category,
      clearFilterCategory: category == null,
    );
    await loadExpenses();
  }

  Future<void> sync() async {
    await _syncService.syncAll();
    await loadExpenses();
  }

  List<Expense> _applyFilters(
    List<Expense> expenses,
    DateTime? filterDate,
    Category? filterCategory,
  ) {
    var filtered = expenses;
    print('Applying filters - initial count: ${filtered.length}, filterDate: $filterDate, filterCategory: $filterCategory');

    // Filter by date (compare only date part, not time)
    if (filterDate != null) {
      final filterYear = filterDate.year;
      final filterMonth = filterDate.month;
      final filterDay = filterDate.day;
      
      filtered = filtered.where((expense) {
        return expense.date.year == filterYear &&
               expense.date.month == filterMonth &&
               expense.date.day == filterDay;
      }).toList();
      print('After date filter: ${filtered.length} expenses');
    }

    // Filter by category
    if (filterCategory != null) {
      filtered = filtered.where((expense) => expense.category == filterCategory).toList();
      print('After category filter: ${filtered.length} expenses');
    }

    // Sort by createdAt DESC to show latest first
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    print('Final filtered count: ${filtered.length} expenses');
    return filtered;
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  return ExpenseNotifier(ref);
});
