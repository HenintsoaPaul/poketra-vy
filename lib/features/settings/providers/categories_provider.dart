import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/models/category.dart';
import '../../expenses/providers/expenses_provider.dart';

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
      final hiveService = ref.watch(hiveServiceProvider);
      return CategoriesNotifier(hiveService);
    });

class CategoriesNotifier extends StateNotifier<List<Category>> {
  final HiveService _hiveService;

  CategoriesNotifier(this._hiveService) : super([]) {
    _loadCategories();
  }

  void _loadCategories() {
    state = _hiveService.getCategories();
  }

  Future<void> addCategory(String name, int iconCodePoint) async {
    final cleanName = name.trim().toLowerCase();
    if (cleanName.isEmpty || state.any((c) => c.name == cleanName)) return;

    final newCategory = Category(name: cleanName, iconCodePoint: iconCodePoint);
    final newState = [...state, newCategory];
    state = newState;
    await _hiveService.saveCategories(newState);
  }

  Future<void> updateCategory(String id, Category updatedCategory) async {
    final cleanNewName = updatedCategory.name.trim().toLowerCase();

    // 1. Update state
    state = [
      for (final c in state)
        if (c.id == id) updatedCategory.copyWith(name: cleanNewName) else c,
    ];

    // 2. Save categories
    await _hiveService.saveCategories(state);
  }

  Future<void> removeCategory(String id) async {
    final newState = state.where((c) => c.id != id).toList();
    state = newState;
    await _hiveService.saveCategories(newState);
  }
}
