import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poketra_vy/core/models/category.dart';
import '../../../core/models/expense.dart';
import '../providers/expenses_provider.dart';
import '../providers/expense_filter_provider.dart';
import '../widgets/expense_tile.dart';

class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(filteredExpensesProvider);
    final Category selectedCategory = ref.watch(selectedCategoryProvider);
    final List<Category> allCategories = ref.watch(availableCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: Column(
        children: [
          // Category filter chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: allCategories.length,
              itemBuilder: (context, index) {
                final category = allCategories[index];
                final isSelected = category == selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(selectedCategoryProvider.notifier).state =
                          category;
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Expenses list
          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text('No expenses yet'))
                : _buildGroupedListView(expenses),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedListView(List<Expense> expenses) {
    // 1. Sort expenses by date descending
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    // 2. Group expenses by date (yyyy-MM-dd)
    final Map<String, List<Expense>> grouped = {};
    for (var expense in sortedExpenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
      grouped.putIfAbsent(dateKey, () => []).add(expense);
    }

    final dateKeys = grouped.keys.toList();

    return ListView.builder(
      itemCount: dateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = dateKeys[index];
        final groupExpenses = grouped[dateKey]!;
        final date = DateTime.parse(dateKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                DateFormat('EEEE, MMM dd, yyyy').format(date),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Items in this group
            ...groupExpenses.map((expense) => ExpenseTile(expense: expense)),
            // Group separator (box + divider) if not the last group
            if (index < dateKeys.length - 1) ...[
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }
}
