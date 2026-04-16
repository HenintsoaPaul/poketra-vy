import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poketra_vy/core/models/expense.dart';
import 'package:poketra_vy/core/services/hive_service.dart';
import 'package:poketra_vy/features/expenses/providers/expense_list_provider.dart';
import 'package:poketra_vy/features/home/screens/home_screen.dart';
import 'package:poketra_vy/features/home/widgets/expense_pie_chart.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockHiveService mockHiveService;

  setUp(() {
    mockHiveService = MockHiveService();
  });

  Widget createHomeScreen(List<Expense> expenses) {
    when(() => mockHiveService.getExpenses()).thenReturn(expenses);
    when(() => mockHiveService.getCategories()).thenReturn([]);

    return ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(mockHiveService),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: HomeScreen(),
        ),
      ),
    );
  }

  testWidgets('HomeScreen displays total balance spent correctly', (tester) async {
    final expenses = [
      Expense(
        id: '1',
        description: 'Lunch',
        amount: 25000,
        date: DateTime.now(),
        categoryId: 'food',
      ),
      Expense(
        id: '2',
        description: 'Taxi',
        amount: 15000,
        date: DateTime.now(),
        categoryId: 'transport',
      ),
    ];

    await tester.pumpWidget(createHomeScreen(expenses));

    // Total should be 40000
    // Check for the large text in the balance card
    expect(find.descendant(
      of: find.byType(Column), // More specific would be better but let's try this
      matching: find.textContaining('40,000'),
    ), findsAtLeastNWidgets(1));
    
    expect(find.text('Total Balance Spent'), findsOneWidget);
  });

  testWidgets('HomeScreen displays "No activities this week" when no recent expenses', (tester) async {
    await tester.pumpWidget(createHomeScreen([]));

    expect(find.text('No activities this week'), findsOneWidget);
  });

  testWidgets('HomeScreen displays recent activities', (tester) async {
    final now = DateTime.now();
    final expenses = [
      Expense(
        id: '1',
        description: 'Groceries',
        amount: 50000,
        date: now,
        categoryId: 'food',
      ),
    ];

    await tester.pumpWidget(createHomeScreen(expenses));

    expect(find.text('Groceries'), findsOneWidget);
    // There might be 2: one in the total balance, one in the list tile
    expect(find.textContaining('50,000'), findsNWidgets(2));
  });

  testWidgets('HomeScreen displays Categorized Spent section with chart', (tester) async {
    await tester.pumpWidget(createHomeScreen([]));

    expect(find.text('Categorized Spent'), findsOneWidget);
    expect(find.byType(ExpensePieChart), findsOneWidget);
  });
}
