import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/expense.dart';
import '../models/category.dart';

class ExcelImportService {
  Future<List<Expense>?> importFromExcel(List<Category> categories) async {
    // 1. Pick file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null || result.files.single.path == null) return null;

    final bytes = File(result.files.single.path!).readAsBytesSync();
    return parseExcel(bytes, categories);
  }

  List<Expense> parseExcel(List<int> bytes, List<Category> categories) {
    final excel = Excel.decodeBytes(bytes);
    final List<Expense> importedExpenses = [];

    // 2. Process sheets
    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null) continue;

      // Check headers
      if (sheet.maxColumns < 4 || sheet.rows.isEmpty) continue;

      final headers = sheet.rows.first
          .map((c) => c?.value?.toString().toLowerCase() ?? '')
          .toList();
      if (!headers.contains('date') || !headers.contains('amount')) continue;

      final dateIdx = headers.indexOf('date');
      final descIdx = headers.indexOf('description');
      final categoryIdx = headers.indexOf('category');
      final amountIdx = headers.indexOf('amount');

      // 3. Parse rows (skip header)
      for (var i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.length < 4) continue;

        // Skip the TOTAL row if it exists
        final firstCellValue = row[dateIdx]?.value?.toString() ?? '';
        final categoryValue = row[categoryIdx]?.value?.toString() ?? '';

        if (firstCellValue.isEmpty && categoryValue.toUpperCase() == 'TOTAL') {
          continue;
        }
        if (firstCellValue.isEmpty) continue;

        try {
          // Parse Date
          final dateVal = row[dateIdx]?.value;
          DateTime? date;

          if (dateVal is DateTimeCellValue) {
            date = DateTime(
              dateVal.year,
              dateVal.month,
              dateVal.day,
              dateVal.hour,
              dateVal.minute,
              dateVal.second,
            );
          } else if (dateVal != null) {
            date = DateTime.parse(dateVal.toString());
          }

          if (date == null) continue;

          // Parse Amount
          final amtVal = row[amountIdx]?.value;
          double? amount;

          if (amtVal is IntCellValue) {
            amount = amtVal.value.toDouble();
          } else if (amtVal is DoubleCellValue) {
            amount = amtVal.value;
          } else if (amtVal != null) {
            amount = double.parse(amtVal.toString());
          }

          if (amount == null) continue;

          // Parse Description
          final description = row[descIdx]?.value?.toString() ?? '';

          // Resolve Category
          final categoryName =
              row[categoryIdx]?.value?.toString().trim().toLowerCase() ?? '';
          final matchedCategory = categories.firstWhere(
            (c) => c.name.toLowerCase() == categoryName || c.id == categoryName,
            orElse: () => categories.firstWhere(
              (c) => c.name.toLowerCase() == 'misc',
              orElse: () =>
                  categories.isNotEmpty
                      ? categories.first
                      : Category(id: 'unknown', name: 'Unknown', iconCodePoint: 0),
            ),
          );

          importedExpenses.add(
            Expense(
              amount: amount,
              categoryId: matchedCategory.id,
              date: date,
              description: description,
            ),
          );
        } catch (e) {
          // Skip invalid rows
          continue;
        }
      }
    }

    return importedExpenses;
  }
}
