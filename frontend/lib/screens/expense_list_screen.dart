import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocketa_expense_tracker/providers/expense_provider.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';
import 'package:pocketa_expense_tracker/widgets/expense_card.dart';
import 'package:pocketa_expense_tracker/widgets/loading_indicator.dart';
import 'package:pocketa_expense_tracker/screens/edit_expense_screen.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);

    final hasActiveFilters = expenseState.filterDate != null || expenseState.filterCategory != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(hasActiveFilters ? 'Filtered Expenses' : 'All Expenses'),
        actions: [
          if (hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear Filters',
              onPressed: () {
                ref.read(expenseProvider.notifier).setFilterDate(null);
                ref.read(expenseProvider.notifier).setFilterCategory(null);
              },
            ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: expenseState.isLoading
          ? const LoadingIndicator()
          : expenseState.expenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No expenses found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(expenseProvider.notifier).loadExpenses(),
                  child: Column(
                    children: [
                      if (hasActiveFilters)
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Showing ${expenseState.expenses.length} expense(s)',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: expenseState.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenseState.expenses[index];
                      return Dismissible(
                        key: Key(expense.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Expense'),
                              content: const Text('Are you sure you want to delete this expense?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ) ?? false;
                        },
                        onDismissed: (direction) {
                          ref.read(expenseProvider.notifier).deleteExpense(expense.id);
                        },
                        child: ExpenseCard(
                          expense: expense,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditExpenseScreen(expense: expense),
                              ),
                            );
                          },
                        ),
                      );
                    },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Capture the notifier reference from parent widget's ref
    final notifier = ref.read(expenseProvider.notifier);
    
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, child) {
          final expenseState = ref.watch(expenseProvider);
          final filterDate = expenseState.filterDate;
          final filterCategory = expenseState.filterCategory;
          
          return AlertDialog(
            title: const Text('Filter Expenses'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Filter by Date'),
                  trailing: filterDate != null
                      ? Chip(
                          label: Text(DateFormat('MMM dd, yyyy').format(filterDate)),
                          onDeleted: () {
                            notifier.setFilterDate(null);
                          },
                        )
                      : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: filterDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)), // Allow future dates
                    );
                    if (picked != null && dialogContext.mounted) {
                      notifier.setFilterDate(picked);
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
                ListTile(
                  title: const Text('Filter by Category'),
                  trailing: filterCategory != null
                      ? Chip(
                          label: Text(filterCategory.displayName),
                          onDeleted: () {
                            notifier.setFilterCategory(null);
                          },
                        )
                      : null,
                  onTap: () {
                    showDialog(
                      context: dialogContext,
                      builder: (categoryContext) => AlertDialog(
                        title: const Text('Select Category'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: Category.values.map((category) {
                            return ListTile(
                              title: Text(category.displayName),
                              onTap: () {
                                notifier.setFilterCategory(category);
                                if (categoryContext.mounted) {
                                  Navigator.of(categoryContext).pop();
                                }
                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Clear both filters using the captured notifier
                  notifier.setFilterDate(null);
                  notifier.setFilterCategory(null);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Clear Filters'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

}
