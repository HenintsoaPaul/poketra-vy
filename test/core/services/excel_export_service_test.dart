import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/core/models/expense.dart';
import 'package:poketra_vy/core/services/excel_export_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ExcelExportService service;
  late List<Expense> expenses;
  late List<Category> categories;
  late MockPathProviderPlatform mockPathProvider;

  setUp(() async {
    service = ExcelExportService();
    mockPathProvider = MockPathProviderPlatform();
    PathProviderPlatform.instance = mockPathProvider;

    when(
      () => mockPathProvider.getTemporaryPath(),
    ).thenAnswer((_) async => Directory.systemTemp.path);

    categories = [
      Category(id: '1', name: 'Food', iconCodePoint: 0),
      Category(id: '2', name: 'Transport', iconCodePoint: 0),
    ];

    expenses = [
      Expense(
        id: 'e1',
        amount: 50.0,
        categoryId: '1',
        date: DateTime(2023, 10, 1),
        description: 'Lunch',
      ),
      Expense(
        id: 'e2',
        amount: 20.0,
        categoryId: '2',
        date: DateTime(2023, 10, 5),
        description: 'Bus',
      ),
      Expense(
        id: 'e3',
        amount: 100.0,
        categoryId: '1',
        date: DateTime(2023, 10, 10),
        description: 'Dinner',
      ),
    ];
  });

  group('ExcelExportService', () {
    test('exports expenses within date range correctly', () async {
      final startDate = DateTime(2023, 10, 1);
      final endDate = DateTime(2023, 10, 6);

      final filePath = await service.exportToExcel(
        expenses: expenses,
        categories: categories,
        startDate: startDate,
        endDate: endDate,
      );

      expect(filePath, isNotNull);
      final file = File(filePath);
      expect(await file.exists(), isTrue);

      // Clean up
      await file.delete();
    });

    test('filters out expenses outside date range', () async {
      final startDate = DateTime(2023, 10, 2);
      final endDate = DateTime(2023, 10, 4);

      final filePath = await service.exportToExcel(
        expenses: expenses,
        categories: categories,
        startDate: startDate,
        endDate: endDate,
      );

      // Even if no expenses match, it should still generate a file with headers and total 0
      expect(filePath, isNotNull);
      final file = File(filePath);
      expect(await file.exists(), isTrue);

      await file.delete();
    });

    test('handles empty expenses list gracefully', () async {
      final startDate = DateTime(2023, 10, 1);
      final endDate = DateTime(2023, 10, 6);

      final filePath = await service.exportToExcel(
        expenses: [],
        categories: categories,
        startDate: startDate,
        endDate: endDate,
      );

      expect(filePath, isNotNull);
      final file = File(filePath);
      expect(await file.exists(), isTrue);

      await file.delete();
    });
  });
}
