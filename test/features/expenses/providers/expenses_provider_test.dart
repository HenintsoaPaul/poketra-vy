import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poketra_vy/core/models/expense.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/features/expenses/providers/expenses_provider.dart';
import 'package:poketra_vy/core/services/hive_service.dart';

void main() {
  group('ExpensesNotifier', () {
    test('starts with empty list', () {
      final mockHiveService = _MockHiveService([]);
      final container = ProviderContainer(
        overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
      );
      final expenses = container.read(expensesProvider);
      expect(expenses, isEmpty);
    });

    test('addExpense adds an expense', () async {
      final mockHiveService = _MockHiveService([]);
      final container = ProviderContainer(
        overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
      );
      final expense = Expense(
        amount: 100,
        category: 'food',
        date: DateTime.now(),
        description: 'test desc',
      );

      await container.read(expensesProvider.notifier).addExpense(expense);

      final expenses = container.read(expensesProvider);
      expect(expenses.length, 1);
      expect(expenses.first, expense);
    });
  });
}

class _MockHiveService extends HiveService {
  final List<Expense> _expenses;
  _MockHiveService(this._expenses);

  @override
  List<Expense> getExpenses() => List<Expense>.from(_expenses);

  @override
  Future<void> saveExpense(Expense expense) async {
    _expenses.add(expense);
  }

  @override
  List<Category> getCategories() => [];

  @override
  Future<void> saveCategories(List<Category> categories) async {}
}
