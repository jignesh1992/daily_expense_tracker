import 'package:pocketa_expense_tracker/services/local_db_service.dart';
import 'package:pocketa_expense_tracker/services/api_service.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';
import 'dart:convert';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final LocalDbService _localDb = LocalDbService();
  final ApiService _api = ApiService();
  bool _isSyncing = false;

  bool get isSyncing => _isSyncing;

  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Process sync queue
      await _processSyncQueue();

      // Fetch latest expenses from server
      await _fetchAndSyncExpenses();
    } catch (e) {
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processSyncQueue() async {
    final queue = await _localDb.getSyncQueue();

    for (final item in queue) {
      try {
        final operation = item['operation'] as String;
        final data = json.decode(item['data'] as String) as Map<String, dynamic>;
        final expenseId = item['expense_id'] as String;
        final queueId = item['id'] as int;

        switch (operation) {
          case 'create':
            await _api.createExpense(
              amount: data['amount'] as double,
              category: Category.fromString(data['category'] as String),
              description: data['description'] as String?,
              date: DateTime.parse(data['date'] as String),
            );
            break;
          case 'update':
            await _api.updateExpense(
              id: expenseId,
              amount: data['amount'] as double?,
              category: data['category'] != null
                  ? Category.fromString(data['category'] as String)
                  : null,
              description: data['description'] as String?,
              date: data['date'] != null ? DateTime.parse(data['date'] as String) : null,
            );
            break;
          case 'delete':
            await _api.deleteExpense(expenseId);
            break;
        }

        // Remove from queue
        await _localDb.removeFromSyncQueue(queueId);
      } catch (e) {
        print('Error processing sync queue item: $e');
        // Keep item in queue for retry
      }
    }
  }

  Future<void> _fetchAndSyncExpenses() async {
    try {
      final serverExpenses = await _api.getExpenses();
      
      for (final expense in serverExpenses) {
        await _localDb.insertExpense(expense, synced: true);
      }
    } catch (e) {
      print('Error fetching expenses: $e');
    }
  }

  Future<void> syncExpense(Expense expense) async {
    try {
      // Try to sync immediately
      final syncedExpense = await _api.createExpense(
        amount: expense.amount,
        category: expense.category,
        description: expense.description,
        date: expense.date,
      );

      await _localDb.insertExpense(syncedExpense, synced: true);
    } catch (e) {
      // If sync fails, add to queue
      await _localDb.insertExpense(expense, synced: false);
      await _localDb.addToSyncQueue(
        expense.id,
        'create',
        expense.toJson(),
      );
    }
  }
}
