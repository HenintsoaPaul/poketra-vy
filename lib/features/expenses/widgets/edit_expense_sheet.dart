import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/providers/formatter_provider.dart';
import '../providers/expenses_provider.dart';
import '../../settings/providers/categories_provider.dart';

class EditExpenseSheet extends ConsumerStatefulWidget {
  final Expense expense;

  const EditExpenseSheet({super.key, required this.expense});

  @override
  ConsumerState<EditExpenseSheet> createState() => _EditExpenseSheetState();
}

class _EditExpenseSheetState extends ConsumerState<EditExpenseSheet> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: ref.read(numberFormatterProvider).format(widget.expense.amount),
    );
    _descriptionController = TextEditingController(
      text: widget.expense.description,
    );
    _selectedDate = widget.expense.date;
    _selectedCategory = widget.expense.categoryId;
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

  void _save() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final updatedExpense = widget.expense.copyWith(
      amount: amount,
      description: _descriptionController.text,
      categoryId: _selectedCategory,
      date: _selectedDate,
    );

    ref.read(expensesProvider.notifier).updateExpense(updatedExpense);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Categories from categoriesProvider
    final categories = ref.watch(categoriesProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit Expense',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount',
              suffixText: ref.watch(currencyFormatterProvider).currencySymbol,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            items: categories.map((Category category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Row(
                  children: [
                    Icon(
                      IconData(
                        category.iconCodePoint,
                        fontFamily: 'MaterialIcons',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(category.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Date: ${DateFormat.yMMMd().format(_selectedDate)}'),
              const Spacer(),
              TextButton(
                onPressed: () => _selectDate(context),
                child: const Text('Change Date'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Save Changes')),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
