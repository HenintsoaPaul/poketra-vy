import 'package:flutter_test/flutter_test.dart';
import 'package:excel/excel.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/core/services/excel_import_service.dart';

void main() {
  late ExcelImportService service;
  late List<Category> categories;

  setUp(() {
    service = ExcelImportService();
    categories = [
      Category(id: 'cat1', name: 'Food', iconCodePoint: 0),
      Category(id: 'cat2', name: 'Transport', iconCodePoint: 0),
      Category(id: 'cat3', name: 'Misc', iconCodePoint: 0),
    ];
  });

  List<int> createExcelBytes({
    required List<List<dynamic>> rows,
  }) {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    for (var row in rows) {
      sheet.appendRow(row.map((v) {
        if (v is double) return DoubleCellValue(v);
        if (v is int) return IntCellValue(v);
        // ignore: deprecated_member_use
        if (v is DateTime) return DateTimeCellValue(year: v.year, month: v.month, day: v.day, hour: v.hour, minute: v.minute, second: v.second);
        return TextCellValue(v.toString());
      }).toList());
    }

    return excel.save()!;
  }

  group('ExcelImportService Logic', () {
    test('successfully parses valid excel data', () {
      final bytes = createExcelBytes(rows: [
        ['Date', 'Description', 'Category', 'Amount'],
        [DateTime(2023, 10, 1), 'Lunch', 'Food', 5000.0],
        [DateTime(2023, 10, 2), 'Bus', 'Transport', 2000],
      ]);

      final results = service.parseExcel(bytes, categories);

      expect(results.length, 2);
      expect(results[0].amount, 5000.0);
      expect(results[0].categoryId, 'cat1');
      expect(results[0].description, 'Lunch');
      expect(results[1].amount, 2000.0);
      expect(results[1].categoryId, 'cat2');
    });

    test('resolves category names case-insensitively', () {
      final bytes = createExcelBytes(rows: [
        ['Date', 'Description', 'Category', 'Amount'],
        [DateTime(2023, 10, 1), 'Lunch', 'food', 5000.0],
      ]);

      final results = service.parseExcel(bytes, categories);

      expect(results.length, 1);
      expect(results[0].categoryId, 'cat1');
    });

    test('defaults to misc for unknown categories', () {
      final bytes = createExcelBytes(rows: [
        ['Date', 'Description', 'Category', 'Amount'],
        [DateTime(2023, 10, 1), 'Unknown', 'SpaceTravel', 99999.0],
      ]);

      final results = service.parseExcel(bytes, categories);

      expect(results.length, 1);
      expect(results[0].categoryId, 'cat3'); // cat3 is Misc
    });

    test('skips rows with missing date or amount', () {
      final bytes = createExcelBytes(rows: [
        ['Date', 'Description', 'Category', 'Amount'],
        ['', 'Invalid', 'Food', 5000.0],
        [DateTime(2023, 10, 1), 'No Amount', 'Food', ''],
      ]);

      final results = service.parseExcel(bytes, categories);

      expect(results.isEmpty, isTrue);
    });

    test('ignores TOTAL row', () {
      final bytes = createExcelBytes(rows: [
        ['Date', 'Description', 'Category', 'Amount'],
        [DateTime(2023, 10, 1), 'Lunch', 'Food', 5000.0],
        ['', '', 'TOTAL', 5000.0],
      ]);

      final results = service.parseExcel(bytes, categories);

      expect(results.length, 1);
      expect(results[0].description, 'Lunch');
    });

    test('handles files even if headers are in different order', () {
      final bytes = createExcelBytes(rows: [
        ['Amount', 'Category', 'Description', 'Date'],
        [3000.0, 'Transport', 'Taxi', DateTime(2023, 10, 5)],
      ]);

      final results = service.parseExcel(bytes, categories);

      expect(results.length, 1);
      expect(results[0].amount, 3000.0);
      expect(results[0].categoryId, 'cat2');
      expect(results[0].description, 'Taxi');
    });

    test('returns empty list if essential headers are missing', () {
      final bytes = createExcelBytes(rows: [
        ['WrongHeader', 'Description'],
        ['Value', 'Test'],
      ]);

      final results = service.parseExcel(bytes, categories);
      expect(results.isEmpty, isTrue);
    });
  });
}
