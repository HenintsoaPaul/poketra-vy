import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/core/services/hive_service.dart';
import 'package:poketra_vy/features/category/providers/categories_provider.dart';
import 'package:poketra_vy/features/expenses/providers/expense_list_provider.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  setUpAll(() {
    registerFallbackValue(<Category>[]);
  });

  late MockHiveService mockHiveService;
  late ProviderContainer container;

  final foodCategory = Category(id: '1', name: 'food', iconCodePoint: 0);

  setUp(() {
    mockHiveService = MockHiveService();
    when(() => mockHiveService.getCategories()).thenReturn([foodCategory]);

    container = ProviderContainer(
      overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CategoriesNotifier', () {
    test('loads categories on initialization', () {
      final categories = container.read(categoriesProvider);
      expect(categories, contains(foodCategory));
      verify(() => mockHiveService.getCategories()).called(1);
    });

    test('addCategory should save to hive and update state', () async {
      when(
        () => mockHiveService.saveCategories(any()),
      ).thenAnswer((_) async => {});

      await container
          .read(categoriesProvider.notifier)
          .addCategory('transport', 123);

      final state = container.read(categoriesProvider);
      expect(state.length, 2);
      expect(state.any((c) => c.name == 'transport'), isTrue);
      verify(() => mockHiveService.saveCategories(any())).called(1);
    });

    test('addCategory should not add duplicate category names', () async {
      await container.read(categoriesProvider.notifier).addCategory('food', 0);

      final state = container.read(categoriesProvider);
      expect(state.length, 1); // food existed in setUp
    });

    test('addCategory should not add empty or whitespace-only names', () async {
      await container.read(categoriesProvider.notifier).addCategory('   ', 0);
      await container.read(categoriesProvider.notifier).addCategory('', 0);

      final state = container.read(categoriesProvider);
      expect(state.length, 1); // Only food should exist
    });

    test('removeCategory should save and update state', () async {
      when(
        () => mockHiveService.saveCategories(any()),
      ).thenAnswer((_) async => {});

      await container.read(categoriesProvider.notifier).removeCategory('1');

      final state = container.read(categoriesProvider);
      expect(state, isEmpty);
      verify(() => mockHiveService.saveCategories([])).called(1);
    });

    test('updateCategory should change details while keeping ID', () async {
      when(
        () => mockHiveService.saveCategories(any()),
      ).thenAnswer((_) async => {});

      final updatedCategory = foodCategory.copyWith(
        name: 'Healthy food',
        iconCodePoint: 1,
      );
      await container
          .read(categoriesProvider.notifier)
          .updateCategory('1', updatedCategory);

      final state = container.read(categoriesProvider);
      expect(state.length, 1);
      expect(state.first.name, 'healthy food'); // lowercase logic
      expect(state.first.iconCodePoint, 1);
      expect(state.first.id, '1');
    });
  });
}
