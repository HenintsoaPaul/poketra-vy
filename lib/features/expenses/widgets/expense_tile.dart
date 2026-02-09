import 'package:flutter/material.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/utils/date_utils.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;

  // TODO: set to global variable
  final String currency = 'Ar';

  const ExpenseTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(expense.category[0].toUpperCase()),
      ),
      title: Text(expense.category),
      subtitle: Text('${expense.description} • ${DateUtilsHelper.format(expense.date)}'),
      trailing: Text(
        '${expense.amount.toStringAsFixed(0)} $currency',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
