import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/formatter_provider.dart';
import '../../expenses/providers/expenses_provider.dart';
import '../../expenses/widgets/expense_tile.dart';
import '../widgets/expense_pie_chart.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expensesProvider);

    // Calculate total amount for all time
    final allTimeTotal = expenses.fold(0.0, (sum, item) => sum + item.amount);

    // Filter expenses for selected month/year for the chart
    final filteredForChart = expenses.where((e) {
      return e.date.month == _selectedMonth && e.date.year == _selectedYear;
    }).toList();

    // Calculate Recent Activities (Last 5 this week)
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartTime = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );

    final recentActivities =
        expenses
            .where(
              (e) =>
                  e.date.isAfter(weekStartTime) ||
                  e.date.isAtSameMomentAs(weekStartTime),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final displayActivities = recentActivities.take(5).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics Section (All Time)
            _buildAnalyticsSummary(context, allTimeTotal),

            /// Spacer
            const SizedBox(height: 24),

            // Recent Activities Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Recent Activities (This Week)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: displayActivities.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('No activities this week'),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayActivities.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final expense = displayActivities[index];
                        return ExpenseTile(expense: expense);
                      },
                    ),
            ),

            /// Spacer
            const SizedBox(height: 24),

            // Charts Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Category Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildMonthYearSelectors(),
                    const SizedBox(height: 16),
                    ExpensePieChart(expenses: filteredForChart),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthYearSelectors() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: _selectedMonth,
            decoration: const InputDecoration(labelText: 'Month'),
            items: List.generate(12, (index) => index + 1).map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text(DateFormat('MMMM').format(DateTime(2024, month))),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedMonth = val);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: _selectedYear,
            decoration: const InputDecoration(labelText: 'Year'),
            items: List.generate(5, (index) => DateTime.now().year - index).map(
              (year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              },
            ).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedYear = val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSummary(BuildContext context, double totalAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance Spent',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ref.watch(currencyFormatterProvider).format(totalAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
