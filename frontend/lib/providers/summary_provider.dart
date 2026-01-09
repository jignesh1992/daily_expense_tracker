import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketa_expense_tracker/models/summary.dart';
import 'package:pocketa_expense_tracker/services/api_service.dart';

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
  SummaryNotifier() : super(SummaryState()) {
    // Delay initial load to avoid modifying provider during initialization
    Future.microtask(() => loadDailySummary(null));
  }

  final _apiService = ApiService();

  Future<void> loadDailySummary(DateTime? date) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final summary = await _apiService.getDailySummary(date);
      state = state.copyWith(dailySummary: summary, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
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
      final summary = await _apiService.getMonthlySummary(
        year: year,
        month: month,
      );
      state = state.copyWith(monthlySummary: summary, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final summaryProvider = StateNotifierProvider<SummaryNotifier, SummaryState>((ref) {
  return SummaryNotifier();
});
