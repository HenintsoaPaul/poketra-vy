import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';

class JsonExportService {
  Future<String> exportToJson({
    required List<Expense> expenses,
    required List<Category> categories,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 1. Filter expenses by date range (inclusive)
    final filteredExpenses = expenses.where((e) {
      final date = DateTime(e.date.year, e.date.month, e.date.day);
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      return (date.isAtSameMomentAs(start) || date.isAfter(start)) &&
             (date.isAtSameMomentAs(end) || date.isBefore(end));
    }).toList();

    // Sort by date descending
    filteredExpenses.sort((a, b) => b.date.compareTo(a.date));

    // 2. Map data
    final dateFormatter = DateFormat('yyyy-MM-dd');

    final dataList = filteredExpenses.map((expense) {
      final category = categories.firstWhere(
        (c) => c.id == expense.categoryId,
        orElse: () => Category(name: 'Unknown', iconCodePoint: 0),
      );

      return {
        'id': expense.id,
        'amount': expense.amount,
        'category': category.name,
        'categoryId': expense.categoryId,
        'date': dateFormatter.format(expense.date),
        'description': expense.description,
      };
    }).toList();

    final exportData = {
      'exportedAt': DateTime.now().toIso8601String(),
      'startDate': dateFormatter.format(startDate),
      'endDate': dateFormatter.format(endDate),
      'totalExpenses': filteredExpenses.length,
      'expenses': dataList,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

    // 3. Save to temp directory
    final directory = await getTemporaryDirectory();
    final fileName = 'expenses_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.json';
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    await file.writeAsString(jsonString);

    return filePath;
  }
}
