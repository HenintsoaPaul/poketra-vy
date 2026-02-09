import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/expense.dart';
import '../../../core/services/hive_service.dart';
import 'expense_filter_provider.dart';

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  final HiveService _hiveService;

  ExpensesNotifier(this._hiveService) : super([]) {
    _loadExpenses();
  }

  void _loadExpenses() {
    try {
      state = _hiveService.getExpenses();
    } catch (e) {
      // If there's an error loading, start with empty list
      state = [];
    }
  }

  Future<void> addExpense(Expense expense) async {
    await _hiveService.saveExpense(expense);
    state = [...state, expense];
  }

  Future<void> updateExpense(Expense expense) async {
    await _hiveService.saveExpense(expense);
    state = [
      for (final e in state)
        if (e.id == expense.id) expense else e,
    ];
  }

  Future<void> deleteExpense(String id) async {
    await _hiveService.deleteExpense(id);
    state = state.where((expense) => expense.id != id).toList();
  }
}

// Provider for HiveService
final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('HiveService must be overridden in main.dart');
});

// Provider for ExpensesNotifier
final expensesProvider = StateNotifierProvider<ExpensesNotifier, List<Expense>>(
  (ref) {
    final hiveService = ref.watch(hiveServiceProvider);
    return ExpensesNotifier(hiveService);
  },
);

// Provider for filtered expenses based on selected category
final filteredExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expensesProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory == 'All') {
    return expenses;
  }

  return expenses
      .where((expense) => expense.category == selectedCategory)
      .toList();
});
