import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/expense.dart';
import '../../../core/providers/formatter_provider.dart';

class ExpenseValidationDialog extends ConsumerWidget {
  final Expense expense;

  const ExpenseValidationDialog({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return AlertDialog(
      title: const Text('Confirm Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please review the parsed expense:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Amount:',
            ref.watch(currencyFormatterProvider).format(expense.amount),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Category:', expense.category),
          const SizedBox(height: 8),
          _buildInfoRow('Date:', dateFormat.format(expense.date)),
          const SizedBox(height: 8),
          _buildInfoRow('Description:', expense.description),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Retry'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  /// Show the validation dialog and return true if confirmed, false if retry
  static Future<bool?> show(BuildContext context, Expense expense) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ExpenseValidationDialog(expense: expense),
    );
  }
}
