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

  setUp(() {
    mockHiveService = MockHiveService();
    when(
      () => mockHiveService.getCategories(),
    ).thenReturn([Category(id: '1', name: 'food', iconCodePoint: 0)]);
    when(() => mockHiveService.getExpenses()).thenReturn([]);
  });

  Widget createCategoriesScreen() {
    return ProviderScope(
      overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
      child: const MaterialApp(home: Scaffold(body: CategoriesScreen())),
    );
  }

  testWidgets('CategoriesScreen displays CategoriesContainer', (tester) async {
    await tester.pumpWidget(createCategoriesScreen());

    expect(find.byType(CategoriesContainer), findsOneWidget);
    expect(
      find.text('food'),
      findsOneWidget,
    ); // CategoriesProvider lowercases names
  });
}
