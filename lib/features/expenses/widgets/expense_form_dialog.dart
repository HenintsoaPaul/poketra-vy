import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/expense.dart';
import '../../settings/providers/categories_provider.dart';

class ExpenseFormDialog extends ConsumerStatefulWidget {
  final Expense expense;
  final String title;
  final String? subtitle;
  final String confirmLabel;
  final String cancelLabel;

  const ExpenseFormDialog({
    super.key,
    required this.expense,
    required this.title,
    this.subtitle,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
  });

  @override
  ConsumerState<ExpenseFormDialog> createState() => _ExpenseFormDialogState();

  /// Show the form dialog and return the updated Expense if confirmed, null otherwise
  static Future<Expense?> show(
    BuildContext context,
    Expense expense, {
    required String title,
    String? subtitle,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
  }) {
    return showDialog<Expense>(
      context: context,
      builder: (context) => ExpenseFormDialog(
        expense: expense,
        title: title,
        subtitle: subtitle,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );
  }
}

class _ExpenseFormDialogState extends ConsumerState<ExpenseFormDialog> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(0),
    );
    _descriptionController = TextEditingController(
      text: widget.expense.description,
    );
    _selectedDate = widget.expense.date;
    _selectedCategoryId = widget.expense.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.subtitle != null) ...[
              Text(
                widget.subtitle!,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: categories.map((c) {
                return DropdownMenuItem(value: c.id, child: Text(c.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(dateFormat.format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text) ?? 0.0;
            final updatedExpense = widget.expense.copyWith(
              amount: amount,
              categoryId: _selectedCategoryId,
              date: _selectedDate,
              description: _descriptionController.text,
            );
            Navigator.of(context).pop(updatedExpense);
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
