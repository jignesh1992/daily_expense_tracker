import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';
import 'package:pocketa_expense_tracker/utils/constants.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
  });

  Color get _categoryColor {
    return AppConstants.categoryColors[expense.category.name] ?? Colors.grey;
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.food:
        return Icons.restaurant;
      case Category.transport:
        return Icons.directions_car;
      case Category.shopping:
        return Icons.shopping_bag;
      case Category.entertainment:
        return Icons.movie;
      case Category.bills:
        return Icons.receipt;
      case Category.other:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _categoryColor.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: _categoryColor.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: _categoryColor,
            size: 20,
          ),
        ),
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
