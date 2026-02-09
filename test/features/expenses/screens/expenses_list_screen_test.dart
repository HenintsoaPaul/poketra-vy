import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poketra_vy/core/models/expense.dart';
import 'package:poketra_vy/features/expenses/providers/expenses_provider.dart';
import 'package:poketra_vy/features/expenses/screens/expenses_list_screen.dart';
import 'package:poketra_vy/features/expenses/widgets/expense_tile.dart';
import 'package:poketra_vy/core/services/hive_service.dart';

void main() {
  testWidgets('ExpensesListScreen shows empty message when no expenses', (
    tester,
  ) async {
    final mockHiveService = _MockHiveService([]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
        child: const MaterialApp(home: ExpensesListScreen()),
      ),
    );

    expect(find.text('No expenses yet'), findsOneWidget);
    expect(find.byType(ExpenseTile), findsNothing);
  });

  testWidgets('ExpensesListScreen shows list of expenses', (tester) async {
    final expense = Expense(
      amount: 5000,
      category: 'food',
      date: DateTime.now(),
      description: 'Lunch',
    );

    // Create a mock HiveService
    final mockHiveService = _MockHiveService([expense]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
        child: const MaterialApp(home: ExpensesListScreen()),
      ),
    );

    // Pump provider changes
    await tester.pump();

    expect(find.text('No expenses yet'), findsNothing);
    expect(find.byType(ExpenseTile), findsOneWidget);
    // Category appears in both filter chip and expense tile, so we check the tile exists
    expect(find.text('5000 Ar'), findsOneWidget);
  });
}

// Mock HiveService for testing
class _MockHiveService extends HiveService {
  final List<Expense> _expenses;

  _MockHiveService(this._expenses);

  @override
  Future<void> init() async {
    // No-op for testing
  }

  @override
  List<Expense> getExpenses() => _expenses;

  @override
  Future<void> saveExpense(Expense expense) async {
    _expenses.add(expense);
  }

  @override
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> clearAll() async {
    _expenses.clear();
  }

  @override
  Future<void> close() async {
    // No-op for testing
  }
}
