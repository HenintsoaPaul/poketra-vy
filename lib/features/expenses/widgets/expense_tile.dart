import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/models/category.dart';
import '../../../../core/providers/formatter_provider.dart';
import '../providers/expenses_provider.dart';
import '../../settings/providers/categories_provider.dart';
import 'edit_expense_sheet.dart';

class ExpenseTile extends ConsumerWidget {
  final Expense expense;

  const ExpenseTile({super.key, required this.expense});

  void _onDismissed(WidgetRef ref, BuildContext context) {
    ref.read(expensesProvider.notifier).deleteExpense(expense.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Expense deleted')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final category = categories.firstWhere(
      (c) => c.id == expense.categoryId,
      orElse: () => Category(name: "Unknown", iconCodePoint: 0),
    );

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
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Expense'),
            content: const Text(
              'Are you sure you want to delete this expense?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      child: ListTile(
        /// Expense Category Icon
        leading: CircleAvatar(
          child: Icon(
            IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
          ),
        ),

        /// Expense Category
        title: Text(category.name),

        /// Expense Description
        subtitle: Text(expense.description),

        /// Expense Amount
        trailing: Text(
          ref.watch(currencyFormatterProvider).format(expense.amount),
          style: Theme.of(context).textTheme.titleMedium,
        ),

        /// On Tap
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
