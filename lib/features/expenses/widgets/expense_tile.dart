import 'package:flutter/material.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/utils/date_utils.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;

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
        '${expense.amount.toStringAsFixed(0)} Ar',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
