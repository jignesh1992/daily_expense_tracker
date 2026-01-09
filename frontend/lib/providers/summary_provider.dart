import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketa_expense_tracker/models/summary.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';
import 'package:pocketa_expense_tracker/providers/expense_provider.dart';
import 'package:pocketa_expense_tracker/services/api_service.dart';
import 'package:pocketa_expense_tracker/services/local_db_service.dart';
import 'package:pocketa_expense_tracker/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class SummaryState {
  final DailySummary? dailySummary;
  final WeeklySummary? weeklySummary;
  final MonthlySummary? monthlySummary;
  final bool isLoading;
  final String? error;

  SummaryState({
    this.dailySummary,
    this.weeklySummary,
    this.monthlySummary,
    this.isLoading = false,
    this.error,
  });

  SummaryState copyWith({
    DailySummary? dailySummary,
    WeeklySummary? weeklySummary,
    MonthlySummary? monthlySummary,
    bool? isLoading,
    String? error,
  }) {
    return SummaryState(
      dailySummary: dailySummary ?? this.dailySummary,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SummaryNotifier extends StateNotifier<SummaryState> {
  SummaryNotifier(this.ref) : super(SummaryState()) {
    // Delay initial load to avoid modifying provider during initialization
    Future.microtask(() => loadDailySummary(null));
  }

  final Ref ref;
  final _apiService = ApiService();
  final _localDb = LocalDbService();

  Future<void> loadDailySummary(DateTime? date) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Always calculate from expenses first to ensure accuracy
      // This ensures the summary matches what's displayed in the expense list
      final summary = await _calculateDailySummaryFromExpenses(date);
      state = state.copyWith(dailySummary: summary, isLoading: false);
      
      // Optionally sync with API in background (non-blocking)
      try {
        await _apiService.getDailySummary(date);
      } catch (e) {
        // API sync failed, but we already have client-side calculation
        print('API summary sync failed: $e');
      }
    } catch (e) {
      // Fallback: Try API if client-side calculation fails
      print('Error calculating summary client-side: $e, trying API');
      try {
        final summary = await _apiService.getDailySummary(date);
        state = state.copyWith(dailySummary: summary, isLoading: false);
      } catch (e2) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  Future<DailySummary> _calculateDailySummaryFromExpenses(DateTime? date) async {
    final targetDate = date ?? DateTime.now();
    // Use local date components but create UTC date for consistent comparison
    final targetDateUtc = DateTime.utc(targetDate.year, targetDate.month, targetDate.day);
    final targetDateLocal = DateTime(targetDate.year, targetDate.month, targetDate.day);
    
    print('Calculating summary for date: ${DateFormat('yyyy-MM-dd').format(targetDateLocal)}');
    
    // Get expenses from expense provider state (already loaded)
    final expenseState = ref.read(expenseProvider);
    print('Total expenses in provider state: ${expenseState.expenses.length}');
    
    // Filter expenses for today by comparing date components
    // This works regardless of timezone since we compare year/month/day
    final todayExpenses = expenseState.expenses.where((expense) {
      return expense.date.year == targetDateLocal.year &&
             expense.date.month == targetDateLocal.month &&
             expense.date.day == targetDateLocal.day;
    }).toList();
    
    print('Expenses for today from provider: ${todayExpenses.length}');
    
    // If no expenses found in provider state, try querying DB directly
    if (todayExpenses.isEmpty) {
      print('No expenses in provider state, querying DB directly');
      try {
        final currentUserId = ref.read(authProvider).user?.uid;
        final dbExpenses = await _localDb.getAllExpenses(
          date: targetDateLocal, // Use local date for query
          category: null,
          userId: null, // Get all expenses first
        );
        
        print('Expenses from DB: ${dbExpenses.length}');
        
        // Filter by userId if available
        final filteredExpenses = currentUserId != null && currentUserId.isNotEmpty
            ? dbExpenses.where((e) => e.userId == currentUserId).toList()
            : dbExpenses;
        
        // Filter by date again (client-side) to ensure accuracy
        final dbTodayExpenses = filteredExpenses.where((expense) {
          return expense.date.year == targetDateLocal.year &&
                 expense.date.month == targetDateLocal.month &&
                 expense.date.day == targetDateLocal.day;
        }).toList();
        
        print('Expenses from DB for today: ${dbTodayExpenses.length}');
        return _createSummaryFromExpenses(dbTodayExpenses, targetDateLocal);
      } catch (e) {
        print('Error querying DB: $e');
      }
    }
    
    return _createSummaryFromExpenses(todayExpenses, targetDateLocal);
  }
  
  DailySummary _createSummaryFromExpenses(List<Expense> expenses, DateTime targetDate) {
    
    // Calculate total and count
    final total = expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    final count = expenses.length;
    
    print('Calculated total: $total, count: $count');

    // Calculate breakdown by category
    final categoryMap = <Category, double>{};
    final categoryCountMap = <Category, int>{};
    
    for (final expense in expenses) {
      categoryMap[expense.category] = (categoryMap[expense.category] ?? 0.0) + expense.amount;
      categoryCountMap[expense.category] = (categoryCountMap[expense.category] ?? 0) + 1;
    }

    final breakdown = categoryMap.entries.map((entry) {
      return CategoryBreakdown(
        category: entry.key,
        amount: entry.value,
        count: categoryCountMap[entry.key] ?? 0,
      );
    }).toList();

    return DailySummary(
      date: DateFormat('yyyy-MM-dd').format(targetDate),
      total: total,
      count: count,
      breakdown: breakdown,
    );
  }

  Future<void> loadWeeklySummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final summary = await _apiService.getWeeklySummary(
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(weeklySummary: summary, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMonthlySummary({
    int? year,
    int? month,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Calculate from expenses first to ensure accuracy
      final summary = await _calculateMonthlySummaryFromExpenses(year, month);
      state = state.copyWith(monthlySummary: summary, isLoading: false);
      
      // Optionally sync with API in background (non-blocking)
      try {
        await _apiService.getMonthlySummary(year: year, month: month);
      } catch (e) {
        print('API monthly summary sync failed: $e');
      }
    } catch (e) {
      // Fallback: Try API if client-side calculation fails
      print('Error calculating monthly summary client-side: $e, trying API');
      try {
        final summary = await _apiService.getMonthlySummary(
          year: year,
          month: month,
        );
        state = state.copyWith(monthlySummary: summary, isLoading: false);
      } catch (e2) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  Future<MonthlySummary> _calculateMonthlySummaryFromExpenses(int? year, int? month) async {
    final targetYear = year ?? DateTime.now().year;
    final targetMonth = month ?? DateTime.now().month;
    
    print('Calculating monthly summary for $targetMonth/$targetYear');
    
    // Always query DB directly to get ALL expenses for the month (ignore filters)
    // This ensures accurate summary regardless of active filters
    try {
      final currentUserId = ref.read(authProvider).user?.uid;
      // Get all expenses (no filters)
      final allExpenses = await _localDb.getAllExpenses(
        date: null,
        category: null,
        userId: null,
      );
      
      print('Total expenses from DB: ${allExpenses.length}');
      
      // Filter by userId if available
      final userExpenses = currentUserId != null && currentUserId.isNotEmpty
          ? allExpenses.where((e) => e.userId == currentUserId).toList()
          : allExpenses;
      
      print('Expenses for current user: ${userExpenses.length}');
      
      // Filter for target month/year
      final monthExpenses = userExpenses.where((expense) {
        return expense.date.year == targetYear && expense.date.month == targetMonth;
      }).toList();
      
      print('Expenses for month $targetMonth/$targetYear: ${monthExpenses.length}');
      return _createMonthlySummaryFromExpenses(monthExpenses, targetYear, targetMonth);
    } catch (e) {
      print('Error querying DB for monthly summary: $e');
      // Fallback to provider state
      final expenseState = ref.read(expenseProvider);
      final monthExpenses = expenseState.expenses.where((expense) {
        return expense.date.year == targetYear && expense.date.month == targetMonth;
      }).toList();
      print('Using provider state - expenses for month: ${monthExpenses.length}');
      return _createMonthlySummaryFromExpenses(monthExpenses, targetYear, targetMonth);
    }
  }
  
  MonthlySummary _createMonthlySummaryFromExpenses(List<Expense> expenses, int year, int month) {
    // Calculate total and count
    final total = expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    final count = expenses.length;
    
    print('Monthly summary - total: $total, count: $count');
    
    // Calculate breakdown by category
    final categoryMap = <Category, double>{};
    final categoryCountMap = <Category, int>{};
    
    for (final expense in expenses) {
      categoryMap[expense.category] = (categoryMap[expense.category] ?? 0.0) + expense.amount;
      categoryCountMap[expense.category] = (categoryCountMap[expense.category] ?? 0) + 1;
    }
    
    final breakdown = categoryMap.entries.map((entry) {
      return CategoryBreakdown(
        category: entry.key,
        amount: entry.value,
        count: categoryCountMap[entry.key] ?? 0,
      );
    }).toList();
    
    // Verify count matches breakdown
    final breakdownCount = breakdown.fold<int>(0, (sum, b) => sum + b.count);
    print('Breakdown count: $breakdownCount, total count: $count');
    
    // Count should always match breakdown count (each expense is in exactly one category)
    // If they don't match, there's a calculation error - use actual expense count
    if (breakdownCount != count) {
      print('WARNING: Breakdown count ($breakdownCount) does not match expense count ($count)');
    }
    
    // Use actual expense count (this is the source of truth)
    final finalCount = count;
    
    // Calculate daily totals
    final dailyTotalsMap = <String, double>{};
    for (final expense in expenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
      dailyTotalsMap[dateKey] = (dailyTotalsMap[dateKey] ?? 0.0) + expense.amount;
    }
    
    final dailyTotals = dailyTotalsMap.entries.map((entry) {
      return DailyTotal(
        date: entry.key,
        total: entry.value,
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
    
    final monthName = DateFormat('MMMM').format(DateTime(year, month));
    
    return MonthlySummary(
      month: monthName,
      year: year,
      total: total,
      count: finalCount, // Use verified count
      breakdown: breakdown,
      dailyTotals: dailyTotals,
    );
  }
}

final summaryProvider = StateNotifierProvider<SummaryNotifier, SummaryState>((ref) {
  return SummaryNotifier(ref);
});
