import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocketa_expense_tracker/providers/expense_provider.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';
import 'package:pocketa_expense_tracker/widgets/expense_card.dart';
import 'package:pocketa_expense_tracker/widgets/loading_indicator.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  DateTime? _filterDate;
  Category? _filterCategory;

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
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
                          onTap: () => _showEditDialog(context, expense),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Expenses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Filter by Date'),
              trailing: _filterDate != null
                  ? Chip(
                      label: Text(DateFormat('MMM dd, yyyy').format(_filterDate!)),
                      onDeleted: () {
                        setState(() {
                          _filterDate = null;
                        });
                        ref.read(expenseProvider.notifier).setFilterDate(null);
                      },
                    )
                  : null,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _filterDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _filterDate = picked;
                  });
                  ref.read(expenseProvider.notifier).setFilterDate(picked);
                  Navigator.of(context).pop();
                }
              },
            ),
            ListTile(
              title: const Text('Filter by Category'),
              trailing: _filterCategory != null
                  ? Chip(
                      label: Text(_filterCategory!.displayName),
                      onDeleted: () {
                        setState(() {
                          _filterCategory = null;
                        });
                        ref.read(expenseProvider.notifier).setFilterCategory(null);
                      },
                    )
                  : null,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Category'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: Category.values.map((category) {
                        return ListTile(
                          title: Text(category.displayName),
                          onTap: () {
                            setState(() {
                              _filterCategory = category;
                            });
                            ref.read(expenseProvider.notifier).setFilterCategory(category);
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
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
              setState(() {
                _filterDate = null;
                _filterCategory = null;
              });
              ref.read(expenseProvider.notifier).setFilterDate(null);
              ref.read(expenseProvider.notifier).setFilterCategory(null);
              Navigator.of(context).pop();
            },
            child: const Text('Clear Filters'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Expense expense) {
    // Edit dialog implementation would go here
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
    );
  }
}
