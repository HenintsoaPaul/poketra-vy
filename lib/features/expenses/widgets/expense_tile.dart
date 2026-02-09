import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/utils/date_utils.dart';
import '../providers/expenses_provider.dart';
import 'edit_expense_sheet.dart';

class ExpenseTile extends ConsumerWidget {
  final Expense expense;

  // TODO: set to global variable
  final String currency = 'Ar';

  const ExpenseTile({super.key, required this.expense});

  void _onDismissed(WidgetRef ref, BuildContext context) {
    ref.read(expensesProvider.notifier).deleteExpense(expense.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Expense deleted')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _onDismissed(ref, context);
      },
      child: ListTile(
        leading: CircleAvatar(child: Text(expense.category[0].toUpperCase())),
        title: Text(expense.category),
        subtitle: Text(
          '${expense.description} • ${DateUtilsHelper.format(expense.date)}',
        ),
        trailing: Text(
          '${expense.amount.toStringAsFixed(0)} $currency',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => EditExpenseSheet(expense: expense),
          );
        },
      ),
    );
  }
}
