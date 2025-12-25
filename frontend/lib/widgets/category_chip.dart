import 'package:flutter/material.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';
import 'package:pocketa_expense_tracker/utils/constants.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final double? amount;
  final bool showAmount;

  const CategoryChip({
    super.key,
    required this.category,
    this.amount,
    this.showAmount = false,
  });

  Color get _categoryColor {
    return AppConstants.categoryColors[category.name] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _categoryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _categoryColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 16,
            color: _categoryColor,
          ),
          const SizedBox(width: 4),
          Text(
            category.displayName,
            style: TextStyle(
              color: _categoryColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          if (showAmount && amount != null) ...[
            const SizedBox(width: 4),
            Text(
              '₹${amount!.toStringAsFixed(2)}',
              style: TextStyle(
                color: _categoryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
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
}
