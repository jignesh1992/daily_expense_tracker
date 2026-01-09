import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';
import 'package:pocketa_expense_tracker/widgets/category_chip.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CategoryChip(category: expense.category),
        title: Text(
          '₹${expense.amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expense.description != null && expense.description!.isNotEmpty)
              Text(expense.description!),
            Text(
              DateFormat('MMM dd, yyyy').format(expense.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
