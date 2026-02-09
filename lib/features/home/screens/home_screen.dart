import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../expenses/providers/expenses_provider.dart';
import '../../expenses/widgets/expense_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);

    // Calculate Total Expenses
    final totalAmount = expenses.fold(0.0, (sum, item) => sum + item.amount);

    // Calculate Recent Activities (Last 5 this week)
    final now = DateTime.now();
    // Monday as start of week
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

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Analytics Section
              _buildAnalyticsSection(context, totalAmount),
              const SizedBox(height: 32),

              // Recent Activities Section
              Text(
                'Recent Activities (This Week)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (displayActivities.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No activities this week'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayActivities.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final expense = displayActivities[index];
                    return ExpenseTile(expense: expense);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, double totalAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Analytics',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Total Expenses', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(
            '${totalAmount.toStringAsFixed(0)} Ar',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
