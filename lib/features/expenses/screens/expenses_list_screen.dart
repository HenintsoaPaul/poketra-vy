import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poketra_vy/core/models/category.dart';
import '../../../core/models/expense.dart';
import '../providers/expenses_provider.dart';
import '../providers/expense_filter_provider.dart';
import '../widgets/expense_tile.dart';
import '../../../core/widgets/glass_container.dart';

class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(filteredExpensesProvider);
    final Category selectedCategory = ref.watch(selectedCategoryProvider);
    final List<Category> allCategories = ref.watch(availableCategoriesProvider);

    return Column(
      children: [
        // Category filter chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: GlassContainer(
            height: 60,
            opacity: 0.1,
            blur: 8,
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
                  child: ChoiceChip(
                    label: Text(category.name),
                    selected: isSelected,
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.transparent,
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.2),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      ref.read(selectedCategoryProvider.notifier).state =
                          category;
                    },
                  ),
                );
              },
            ),
          ),
        ),

        // Expenses list
        Expanded(
          child: expenses.isEmpty
              ? const Center(child: Text('No expenses yet'))
              : _buildGroupedListView(expenses),
        ),
      ],
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      itemBuilder: (context, index) {
        final dateKey = dateKeys[index];
        final groupExpenses = grouped[dateKey]!;
        final date = DateTime.parse(dateKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Text(
                DateFormat('EEEE, MMM dd').format(date),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Items in this group wrapped in Glass
            GlassContainer(
              opacity: 0.08,
              blur: 10,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: groupExpenses.asMap().entries.map((entry) {
                  final expense = entry.value;
                  final isLast = entry.key == groupExpenses.length - 1;
                  return Column(
                    children: [
                      ExpenseTile(expense: expense),
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.05),
                          indent: 72,
                          endIndent: 16,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
