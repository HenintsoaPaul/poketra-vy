import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/core/models/expense.dart';
import 'package:poketra_vy/core/services/hive_service.dart';
import 'package:poketra_vy/features/expenses/providers/expense_list_provider.dart';
import 'package:poketra_vy/features/settings/widgets/export_excel_dialog.dart';
import 'package:intl/intl.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockHiveService mockHiveService;
  late List<Category> categories;
  late List<Expense> expenses;

  setUp(() {
    mockHiveService = MockHiveService();
    categories = [
      Category(id: '1', name: 'Food', iconCodePoint: 0),
      Category(id: '2', name: 'Transport', iconCodePoint: 0),
    ];
    expenses = [];

    when(() => mockHiveService.getCategories()).thenReturn(categories);
    when(() => mockHiveService.getExpenses()).thenReturn(expenses);
  });

  Widget createDialog() {
    return ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(mockHiveService),
      ],
      child: const MaterialApp(
        home: Scaffold(body: ExportExcelDialog()),
      ),
    );
  }

  group('ExportExcelDialog', () {
    testWidgets('shows title and labels', (tester) async {
      await tester.pumpWidget(createDialog());
      expect(find.text('Export to Excel'), findsOneWidget);
      expect(find.text('DATE RANGE'), findsOneWidget);
      expect(find.text('CATEGORIES'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
    });

    testWidgets('shows correctly selected date ranges initially', (tester) async {
      await tester.pumpWidget(createDialog());
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final formatter = DateFormat('MMM d, yyyy');

      expect(find.text(formatter.format(startOfMonth)), findsOneWidget);
      expect(find.text(formatter.format(now)), findsOneWidget);
    });

    testWidgets('displays category chips and All chip', (tester) async {
      await tester.pumpWidget(createDialog());
      expect(find.byType(FilterChip), findsNWidgets(3)); // All + Food + Transport
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('can select and deselect categories', (tester) async {
      await tester.pumpWidget(createDialog());

      // Initial state: All should be selected
      final allChipFinder = find.widgetWithText(FilterChip, 'All');
      expect((tester.widget<FilterChip>(allChipFinder)).selected, isTrue);

      // Tap on a specific category
      final foodChipFinder = find.widgetWithText(FilterChip, 'Food');
      await tester.tap(foodChipFinder);
      await tester.pump();

      // All should be deselected
      expect((tester.widget<FilterChip>(allChipFinder)).selected, isFalse);
      expect((tester.widget<FilterChip>(foodChipFinder)).selected, isTrue);
      
      // Tap on All again
      await tester.tap(allChipFinder);
      await tester.pump();
      
      expect((tester.widget<FilterChip>(allChipFinder)).selected, isTrue);
      expect((tester.widget<FilterChip>(foodChipFinder)).selected, isFalse);
    });
  });
}
