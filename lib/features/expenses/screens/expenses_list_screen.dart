import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/expenses_provider.dart';
import '../widgets/expense_tile.dart';
import '../../../core/models/expense.dart'; // Import Expense model for dummy button (features evolution)

class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: expenses.isEmpty
          ? const Center(child: Text('No expenses yet'))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return ExpenseTile(expense: expense);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/voice'),
        child: const Icon(Icons.mic),
      ),
    );
  }
}
