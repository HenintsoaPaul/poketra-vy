import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/expense.dart';

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier() : super([]);

  void addExpense(Expense expense) {
    state = [...state, expense];
  }
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier();
});
