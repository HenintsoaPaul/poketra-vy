import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/hive_service.dart';
import '../../expenses/providers/expenses_provider.dart';

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<String>>((ref) {
      final hiveService = ref.watch(hiveServiceProvider);
      return CategoriesNotifier(hiveService);
    });

class CategoriesNotifier extends StateNotifier<List<String>> {
  final HiveService _hiveService;

  CategoriesNotifier(this._hiveService) : super([]) {
    _loadCategories();
  }

  void _loadCategories() {
    state = _hiveService.getCategories();
  }

  Future<void> addCategory(String category) async {
    final cleanCategory = category.trim().toLowerCase();
    if (cleanCategory.isEmpty || state.contains(cleanCategory)) return;

    final newState = [...state, cleanCategory];
    state = newState;
    await _hiveService.saveCategories(newState);
  }

  Future<void> removeCategory(String category) async {
    final newState = state.where((c) => c != category).toList();
    state = newState;
    await _hiveService.saveCategories(newState);
  }
}
