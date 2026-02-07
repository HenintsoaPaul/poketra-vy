import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poketra_vy/core/models/expense.dart';
import 'package:poketra_vy/features/expenses/providers/expenses_provider.dart';

void main() {
  group('ExpensesNotifier', () {
    test('starts with empty list', () {
      final container = ProviderContainer();
      final expenses = container.read(expensesProvider);
      expect(expenses, isEmpty);
    });

    test('addExpense adds an expense', () {
      final container = ProviderContainer();
      final expense = Expense(
        amount: 100, 
        category: 'test', 
        date: DateTime.now(), 
        description: 'test desc'
      );
      
      container.read(expensesProvider.notifier).addExpense(expense);
      
      final expenses = container.read(expensesProvider);
      expect(expenses.length, 1);
      expect(expenses.first, expense);
    });
  });
}
