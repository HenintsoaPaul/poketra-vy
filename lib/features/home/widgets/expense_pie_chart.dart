import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/models/expense.dart';

class ExpensePieChart extends StatelessWidget {
  final List<Expense> expenses;

  const ExpensePieChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No data for this period'));
    }

    final categoryTotals = <String, double>{};
    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: categoryTotals.entries.map((entry) {
            final color = _getCategoryColor(entry.key);
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
              badgeWidget: _Badge(entry.key, size: 40, borderColor: color),
              badgePositionPercentageOffset: 1.3,
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'rent':
        return Colors.purple;
      case 'fun':
        return Colors.green;
      case 'shopping':
        return Colors.pink;
      case 'misc':
        return Colors.grey;
      default:
        return Colors.teal;
    }
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
