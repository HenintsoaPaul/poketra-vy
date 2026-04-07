import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../category/providers/categories_provider.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/models/category.dart';

class ExpensePieChart extends ConsumerStatefulWidget {
  final List<Expense> expenses;

  const ExpensePieChart({super.key, required this.expenses});

  @override
  ConsumerState<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends ConsumerState<ExpensePieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.expenses.isEmpty) {
      return const Center(child: Text('No data for this period'));
    }

    final categories = ref.watch(categoriesProvider);

    final categoryTotals = <String, double>{};
    for (var expense in widget.expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  _touchedIndex = -1;
                  return;
                }
                _touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          sectionsSpace: 4,
          centerSpaceRadius: 50,
          sections: List.generate(sortedEntries.length, (i) {
            final entry = sortedEntries[i];
            final categoryId = entry.key;
            final category = categories.firstWhere(
              (c) => c.id == categoryId,
              orElse: () => Category(
                id: 'unknown',
                name: 'Unknown',
                iconCodePoint: Icons.help.codePoint,
              ),
            );

            final isTouched = i == _touchedIndex;
            final color = _getCategoryColor(category.name);
            final percentage = (entry.value / total) * 100;
            final radius = isTouched ? 70.0 : 60.0;
            final fontSize = isTouched ? 16.0 : 12.0;

            return PieChartSectionData(
              color: color,
              value: entry.value,
              title: isTouched
                  ? '${percentage.toStringAsFixed(1)}%'
                  : '${percentage.toStringAsFixed(0)}%',
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
              ),
              badgeWidget: isTouched
                  ? _Badge(category.name, size: 50, borderColor: color)
                  : _Badge(category.name, size: 40, borderColor: color),
              badgePositionPercentageOffset: 1.3,
            );
          }),
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
