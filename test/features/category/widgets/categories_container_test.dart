import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/core/services/hive_service.dart';
import 'package:poketra_vy/features/category/providers/categories_provider.dart';
import 'package:poketra_vy/features/category/widgets/categories_container.dart';
import 'package:poketra_vy/features/expenses/providers/expense_list_provider.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockHiveService mockHiveService;

  setUpAll(() {
    registerFallbackValue(Category(name: '', iconCodePoint: 0));
  });

  setUp(() {
    mockHiveService = MockHiveService();
    when(() => mockHiveService.getCategories()).thenReturn([
      Category(
        id: '1',
        name: 'food',
        iconCodePoint: Icons.restaurant.codePoint,
      ),
    ]);
    when(() => mockHiveService.getExpenses()).thenReturn([]);
    when(
      () => mockHiveService.saveCategories(any()),
    ).thenAnswer((_) async => {});
  });

  Widget createContainer() {
    return ProviderScope(
      overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, child) {
              final categories = ref.watch(categoriesProvider);
              return SingleChildScrollView(
                child: CategoriesContainer(categories: categories),
              );
            },
          ),
        ),
      ),
    );
  }

  group('CategoriesContainer', () {
    testWidgets('displays list of categories', (tester) async {
      await tester.pumpWidget(createContainer());

      expect(find.text('food'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsNWidgets(2));
    });

    testWidgets('shows empty state when no categories', (tester) async {
      when(() => mockHiveService.getCategories()).thenReturn([]);
      await tester.pumpWidget(createContainer());

      expect(find.text('No categories added yet.'), findsOneWidget);
    });

    testWidgets('can add category', (tester) async {
      await tester.pumpWidget(createContainer());

      await tester.enterText(find.byType(TextField), 'Gym');
      final addIcon = find.byIcon(Icons.add);
      await tester.ensureVisible(addIcon);
      await tester.tap(addIcon);
      await tester.pump();

      expect(find.text('gym'), findsOneWidget);
      verify(() => mockHiveService.saveCategories(any())).called(1);
    });

    testWidgets('can open edit dialog', (tester) async {
      await tester.pumpWidget(createContainer());

      final editIcon = find.byIcon(Icons.edit_outlined);
      await tester.ensureVisible(editIcon);
      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      expect(find.text('Edit Category'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'food'), findsOneWidget);
    });

    testWidgets('can delete category', (tester) async {
      await tester.pumpWidget(createContainer());

      final deleteIcon = find.byIcon(Icons.delete_outline);
      await tester.ensureVisible(deleteIcon);
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      expect(find.text('Delete Category?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('food'), findsNothing);
      verify(() => mockHiveService.saveCategories([])).called(1);
    });
  });
}
