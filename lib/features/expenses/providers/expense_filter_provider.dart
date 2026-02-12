import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/categories_provider.dart';
import '../../../core/models/category.dart';

// State provider for selected category ID filter (or 'All')
final selectedCategoryProvider = StateProvider<Category>(
  (ref) => Category(name: 'All', iconCodePoint: 0),
);

// Provider for all available categories (adds 'All' to the list)
final availableCategoriesProvider = Provider<List<Category>>((ref) {
  final dynamicCategories = ref.watch(categoriesProvider);
  return [Category(name: 'All', iconCodePoint: 0), ...dynamicCategories];
});
