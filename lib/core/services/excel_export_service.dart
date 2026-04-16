import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';

class ExcelExportService {
  Future<String> exportToExcel({
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

    // 2. Create Excel
    final excel = Excel.createExcel();
    final sheet = excel['Expenses'];
    excel.delete('Sheet1'); // Remove default sheet

    // Header style
    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#244B73'),
      horizontalAlign: HorizontalAlign.Center,
    );

    // 3. Add Headers
    final headers = ['Date', 'Description', 'Category', 'Amount'];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
    
    // Apply header style
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle = headerStyle;
    }

    // 4. Add Data
    double totalAmount = 0;
    final dateFormatter = DateFormat('yyyy-MM-dd');

    for (final expense in filteredExpenses) {
      final category = categories.firstWhere(
        (c) => c.id == expense.categoryId,
        orElse: () => Category(name: 'Unknown', iconCodePoint: 0),
      );

      sheet.appendRow([
        TextCellValue(dateFormatter.format(expense.date)),
        TextCellValue(expense.description),
        TextCellValue(category.name),
        DoubleCellValue(expense.amount),
      ]);
      totalAmount += expense.amount;
    }

    // 5. Add Total Row
    sheet.appendRow(['', '', 'TOTAL', totalAmount].map((v) {
      if (v is double) return DoubleCellValue(v);
      return TextCellValue(v as String);
    }).toList());

    final totalRowIndex = filteredExpenses.length + 1;
    final totalLabelCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: totalRowIndex));
    final totalValueCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: totalRowIndex));
    
    final totalStyle = CellStyle(bold: true);
    totalLabelCell.cellStyle = totalStyle;
    totalValueCell.cellStyle = totalStyle;

    // 6. Save to temp directory
    final directory = await getTemporaryDirectory();
    final fileName = 'expenses_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
    final filePath = '${directory.path}/$fileName';
    final fileBytes = excel.save();

    if (fileBytes != null) {
      await File(filePath).writeAsBytes(fileBytes);
    }

    return filePath;
  }
}
