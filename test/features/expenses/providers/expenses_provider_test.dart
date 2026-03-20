import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poketra_vy/core/models/expense.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/core/services/hive_service.dart';
import 'package:poketra_vy/features/expenses/providers/expense_list_provider.dart';
import 'package:poketra_vy/features/expenses/providers/expense_filter_provider.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeExpense());
  });

  late MockHiveService mockHiveService;
  late ProviderContainer container;

  final foodCategory = Category(id: '1', name: 'Food', iconCodePoint: 0);
  final transportCategory = Category(
    id: '2',
    name: 'Transport',
    iconCodePoint: 0,
  );
  final allCategory = Category(id: 'all', name: 'All', iconCodePoint: 0);

  final testExpenses = [
    Expense(
      id: 'e1',
      amount: 100,
      categoryId: '1',
      date: DateTime.now(),
      description: 'Lunch',
    ),
    Expense(
      id: 'e2',
      amount: 200,
      categoryId: '2',
      date: DateTime.now(),
      description: 'Bus',
    ),
  ];

  setUp(() {
    mockHiveService = MockHiveService();
    // Default mock behavior
    when(() => mockHiveService.getExpenses()).thenReturn([]);
    when(
      () => mockHiveService.getCategories(),
    ).thenReturn([foodCategory, transportCategory]);

    container = ProviderContainer(
      overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ExpensesNotifier', () {
    test('loads expenses on initialization', () {
      when(() => mockHiveService.getExpenses()).thenReturn(testExpenses);

      when(
        () => mockHiveService.getCategories(),
      ).thenReturn([foodCategory, transportCategory]);

      // Re-initialize container to trigger notifier constructor
      final testContainer = ProviderContainer(
        overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
      );

      final expenses = testContainer.read(expenseListProvider);
      expect(expenses, testExpenses);
      testContainer.dispose();
    });

    test('addExpense saves to hive and updates state', () async {
      final newExpense = Expense(
        amount: 50,
        categoryId: '1',
        date: DateTime.now(),
        description: 'Snack',
      );
      when(
        () => mockHiveService.saveExpense(any()),
      ).thenAnswer((_) async => {});

      await container.read(expenseListProvider.notifier).addExpense(newExpense);

      expect(container.read(expenseListProvider), contains(newExpense));
      verify(() => mockHiveService.saveExpense(newExpense)).called(1);
    });

    test('deleteExpense removes from hive and updates state', () async {
      when(() => mockHiveService.getExpenses()).thenReturn(testExpenses);
      final testContainer = ProviderContainer(
        overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
      );

      when(
        () => mockHiveService.deleteExpense(any()),
      ).thenAnswer((_) async => {});

      await testContainer
          .read(expenseListProvider.notifier)
          .deleteExpense('e1');

      final state = testContainer.read(expenseListProvider);
      expect(state.length, 1);
      expect(state.first.id, 'e2');
      verify(() => mockHiveService.deleteExpense('e1')).called(1);
      testContainer.dispose();
    });
  });

  group('filteredExpensesProvider', () {
    test('returns all expenses when "All" is selected', () {
      // Mock expenses in notifier
      when(() => mockHiveService.getExpenses()).thenReturn(testExpenses);

      // Select "All" category
      container.read(selectedCategoryProvider.notifier).state = allCategory;

      final filtered = container.read(filteredExpensesProvider);
      expect(filtered.length, 2);
    });

    test('filters expenses by category', () {
      when(() => mockHiveService.getExpenses()).thenReturn(testExpenses);

      // Select "Food" category
      container.read(selectedCategoryProvider.notifier).state = foodCategory;

      final filtered = container.read(filteredExpensesProvider);
      expect(filtered.length, 1);
      expect(filtered.first.categoryId, '1');
    });
  });
}

// Dummy classes for mocking if needed (ExpensesNotifier already uses them)
class _FakeExpense extends Fake implements Expense {}
