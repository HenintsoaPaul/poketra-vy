import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/categories_provider.dart';

// State provider for selected category filter
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Provider for all available categories (adds 'All' to the dynamic categories)
final availableCategoriesProvider = Provider<List<String>>((ref) {
  final dynamicCategories = ref.watch(categoriesProvider);
  return ['All', ...dynamicCategories];
});
