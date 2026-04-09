import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/core/services/hive_service.dart';
import 'package:poketra_vy/features/category/screens/categories_screen.dart';
import 'package:poketra_vy/features/category/widgets/categories_container.dart';
import 'package:poketra_vy/features/expenses/providers/expense_list_provider.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockHiveService mockHiveService;

  setUpAll(() {
    registerFallbackValue([]);
  });

  setUp(() {
    mockHiveService = MockHiveService();
    when(() => mockHiveService.getCategories()).thenReturn([
      Category(id: '1', name: 'food', iconCodePoint: Icons.restaurant.codePoint),
    ]);
    when(() => mockHiveService.getExpenses()).thenReturn([]);
    when(() => mockHiveService.saveCategories(any())).thenAnswer((_) async {});
  });

  Widget createCategoriesScreen() {
    return ProviderScope(
      overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
      child: const MaterialApp(home: Scaffold(body: CategoriesScreen())),
    );
  }

  testWidgets('CategoriesScreen displays CategoriesContainer and initial category', (tester) async {
    await tester.pumpWidget(createCategoriesScreen());

    expect(find.byType(CategoriesContainer), findsOneWidget);
    expect(find.text('food'), findsOneWidget);
  });

  testWidgets('CategoriesScreen allows adding a new category', (tester) async {
    await tester.pumpWidget(createCategoriesScreen());

    // Find the text field and enter text
    final textFieldFinder = find.byType(TextField);
    await tester.ensureVisible(textFieldFinder);
    await tester.enterText(textFieldFinder, 'Gym');
    await tester.pumpAndSettle();
    
    // Find the add button and tap it
    final addButtonFinder = find.byIcon(Icons.add);
    await tester.ensureVisible(addButtonFinder);
    await tester.tap(addButtonFinder);
    await tester.pumpAndSettle();

    // Verify category is added to the UI
    expect(find.text('gym'), findsOneWidget); // Names are lowercased by provider
    
    // Verify saveCategories was called
    verify(() => mockHiveService.saveCategories(any())).called(1);
  });

  testWidgets('CategoriesScreen displays empty state when no categories', (tester) async {
    when(() => mockHiveService.getCategories()).thenReturn([]);
    
    await tester.pumpWidget(createCategoriesScreen());

    expect(find.text('No categories added yet.'), findsOneWidget);
  });
}
