import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/core/services/hive_service.dart';
import 'package:poketra_vy/features/expenses/providers/expense_list_provider.dart';
import 'package:poketra_vy/features/settings/screens/settings_screen.dart';
import 'package:poketra_vy/features/settings/widgets/export_data_dialog.dart';
import 'package:go_router/go_router.dart';

class MockHiveService extends Mock implements HiveService {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockHiveService mockHiveService;

  setUp(() {
    mockHiveService = MockHiveService();
    when(() => mockHiveService.getCategories()).thenReturn([
      Category(id: '1', name: 'Food', iconCodePoint: 0),
    ]);
    when(() => mockHiveService.getExpenses()).thenReturn([]);
    when(() => mockHiveService.isOnboardingComplete()).thenReturn(true);
    when(() => mockHiveService.getNotificationTime()).thenReturn({'hour': 9, 'minute': 0});
  });

  Widget createSettingsScreen() {
    return ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(mockHiveService),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SettingsScreen()),
      ),
    );
  }

  group('SettingsScreen Export Tile', () {
    testWidgets('shows Export Data tile', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      
      expect(find.text('Export Data'), findsOneWidget);
      expect(find.text('Download your data in Excel or JSON format'), findsOneWidget);
      expect(find.byIcon(Icons.file_download_outlined), findsOneWidget);
    });

    testWidgets('tapping Export Data opens ExportDataDialog', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      
      // Tap the tile
      await tester.tap(find.text('Export Data'));
      await tester.pumpAndSettle();
      
      // Check if dialog is shown
      expect(find.byType(ExportDataDialog), findsOneWidget);
    });

    testWidgets('shows Import Data tile', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      expect(find.text('Import Data'), findsOneWidget);
    });

    testWidgets('shows Delete All Records tile', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      expect(find.text('Delete All Records'), findsOneWidget);
    });

    testWidgets('confirming deletion calls deleteAllExpenses', (tester) async {
      when(() => mockHiveService.clearAll()).thenAnswer((_) async {});
      
      await tester.pumpWidget(createSettingsScreen());
      
      await tester.tap(find.text('Delete All Records'));
      await tester.pumpAndSettle();
      
      expect(find.text('Delete All Data?'), findsOneWidget);
      
      await tester.tap(find.text('Delete All'));
      await tester.pumpAndSettle();
      
      verify(() => mockHiveService.clearAll()).called(1);
      expect(find.text('All records have been deleted.'), findsOneWidget);
    });
  });
}
