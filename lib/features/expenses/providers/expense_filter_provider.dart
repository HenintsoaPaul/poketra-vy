import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/expense_parser.dart';

// State provider for selected category filter
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Get all available categories (from ExpenseParser + 'All' and 'misc')
List<String> get allCategories {
  return ['All', ...ExpenseParser.categories, 'misc'];
}
