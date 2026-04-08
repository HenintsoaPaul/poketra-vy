import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/core/models/expense.dart';
import 'package:poketra_vy/core/services/hive_service.dart';
import 'package:poketra_vy/features/expenses/providers/expense_list_provider.dart';
import 'package:poketra_vy/features/expenses/screens/expenses_list_screen.dart';
import 'package:poketra_vy/features/expenses/widgets/expense_list_tile.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockHiveService mockHiveService;
  final testCategory1 = Category(id: '1', name: 'Food', iconCodePoint: 0);
  final testCategory2 = Category(id: '2', name: 'Transport', iconCodePoint: 1);
  final testExpense1 = Expense(
    id: 'e1',
    amount: 50.0,
    categoryId: '1',
    date: DateTime(2024, 1, 1),
    description: 'Lunch',
  );
  final testExpense2 = Expense(
    id: 'e2',
    amount: 20.0,
    categoryId: '2',
    date: DateTime(2024, 1, 2),
    description: 'Bus',
  );

  setUp(() {
    mockHiveService = MockHiveService();
    when(() => mockHiveService.getCategories()).thenReturn([testCategory1, testCategory2]);
  });

  Widget createExpensesListScreen() {
    return ProviderScope(
      overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
      child: const MaterialApp(home: Scaffold(body: ExpensesListScreen())),
    );
  }

  testWidgets('ExpensesListScreen displays "No expenses yet" when list is empty', (
    tester,
  ) async {
    when(() => mockHiveService.getExpenses()).thenReturn([]);

    await tester.pumpWidget(createExpensesListScreen());
    await tester.pumpAndSettle();

    expect(find.text('No expenses yet'), findsOneWidget);
  });

  testWidgets('ExpensesListScreen displays list of expenses', (tester) async {
    when(() => mockHiveService.getExpenses()).thenReturn([testExpense1, testExpense2]);

    await tester.pumpWidget(createExpensesListScreen());
    await tester.pumpAndSettle();

    expect(find.byType(ExpenseListTile), findsNWidgets(2));
    expect(find.text('50 Ar'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Bus'), findsOneWidget);
  });

  testWidgets('ExpensesListScreen filters expenses by category', (tester) async {
    when(() => mockHiveService.getExpenses()).thenReturn([testExpense1, testExpense2]);

    await tester.pumpWidget(createExpensesListScreen());
    await tester.pumpAndSettle();

    // Verify both are present initially (default "All" filter)
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Bus'), findsOneWidget);

    // Tap on "Food" category chip. Use descendant to avoid matching the text in the list tile.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Food'));
    await tester.pumpAndSettle();

    // Only Lunch should be visible
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Bus'), findsNothing);

    // Tap on "Transport" category chip
    await tester.tap(find.widgetWithText(ChoiceChip, 'Transport'));
    await tester.pumpAndSettle();

    // Only Bus should be visible
    expect(find.text('Lunch'), findsNothing);
    expect(find.text('Bus'), findsOneWidget);
  });
}
