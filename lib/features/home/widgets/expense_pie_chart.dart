import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/categories_provider.dart';
import '../../../../core/models/expense.dart';

class ExpensePieChart extends ConsumerWidget {
  final List<Expense> expenses;

  const ExpensePieChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No data for this period'));
    }

    final categories = ref.watch(categoriesProvider);

    final categoryTotals = <String, double>{};
    for (var expense in expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: categoryTotals.entries.map((entry) {
            final categoryId = entry.key;
            final category = categories.firstWhere((c) => c.id == categoryId);

            final color = _getCategoryColor(category.name);
            final percentage = (entry.value / total) * 100;

            return PieChartSectionData(
              color: color,
              value: entry.value,
              title: '${percentage.toStringAsFixed(0)}%',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              badgeWidget: _Badge(category.name, size: 40, borderColor: color),
              badgePositionPercentageOffset: 1.3,
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    final colors = {
      'food': Colors.orange,
      'transport': Colors.blue,
      'rent': Colors.purple,
      'fun': Colors.green,
      'shopping': Colors.pink,
      'misc': Colors.grey,
    };

    return colors[categoryName.toLowerCase()] ??
        Colors.primaries[categoryName.length % Colors.primaries.length];
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final double size;
  final Color borderColor;

  const _Badge(this.label, {required this.size, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Text(
          label[0].toUpperCase(),
          style: TextStyle(
            fontSize: size * .4,
            fontWeight: FontWeight.bold,
            color: borderColor,
          ),
        ),
      ),
    );
  }
}
