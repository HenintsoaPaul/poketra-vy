import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poketra_vy/core/models/expense.dart';
import 'package:poketra_vy/features/expenses/providers/expenses_provider.dart';
import 'package:poketra_vy/features/expenses/screens/expenses_list_screen.dart';
import 'package:poketra_vy/features/expenses/widgets/expense_tile.dart';

void main() {
  testWidgets('ExpensesListScreen shows empty message when no expenses', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ExpensesListScreen(),
        ),
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
      description: 'Lunch'
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expensesProvider.overrideWith((ref) => ExpensesNotifier()..addExpense(expense)),
        ],
        child: const MaterialApp(
          home: ExpensesListScreen(),
        ),
      ),
    );
    
    // Pump provider changes
    await tester.pump();

    expect(find.text('No expenses yet'), findsNothing);
    expect(find.byType(ExpenseTile), findsOneWidget);
    expect(find.text('food'), findsOneWidget);
    expect(find.text('5000 Ar'), findsOneWidget);
  });
}
