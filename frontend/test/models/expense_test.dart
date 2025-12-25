import 'package:flutter_test/flutter_test.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';

void main() {
  group('Expense Model', () {
    test('should create expense from JSON', () {
      final json = {
        'id': 'test-id',
        'userId': 'user-id',
        'amount': 100.0,
        'category': 'food',
        'description': 'Test expense',
        'date': '2024-01-01T00:00:00.000Z',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final expense = Expense.fromJson(json);

      expect(expense.id, 'test-id');
      expect(expense.amount, 100.0);
      expect(expense.category, Category.food);
      expect(expense.description, 'Test expense');
    });

    test('should convert expense to JSON', () {
      final expense = Expense(
        id: 'test-id',
        userId: 'user-id',
        amount: 100.0,
        category: Category.food,
        description: 'Test expense',
        date: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = expense.toJson();

      expect(json['id'], 'test-id');
      expect(json['amount'], 100.0);
      expect(json['category'], 'food');
    });
  });
}
