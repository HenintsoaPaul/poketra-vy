import '../models/category.dart';
import '../models/expense.dart';

class ExpenseParser {
  const ExpenseParser();

  static Expense? parse(String text, List<Category> categories) {
    if (text.isEmpty) return null;
    final lowerText = text.toLowerCase();
    final words = lowerText.split(' ');

    double? amount;
    // Default to 'misc' category ID if found, else first available, else empty String (will be migrated/fixed)
    final miscCategory = categories.firstWhere(
      (c) => c.name.toLowerCase() == 'misc',
      orElse: () => categories.isNotEmpty
          ? categories.first
          : Category(name: 'misc', iconCodePoint: 0),
    );
    String categoryId = miscCategory.id;

    DateTime date = DateTime.now();

    // 1. Extract Amount (First number)
    // Simple heuristic: find first token that parses to double
    for (var word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^0-9.]'), '');
      if (cleanWord.isNotEmpty) {
        final parsed = double.tryParse(cleanWord);
        if (parsed != null) {
          amount = parsed;
          break; // Stop after first number
        }
      }
    }

    if (amount == null) return null; // Amount is mandatory for an expense

    // 2. Extract Category
    for (var cat in categories) {
      if (lowerText.contains(cat.name.toLowerCase())) {
        categoryId = cat.id;
        break; // Take first matching category
      }
    }

    // 3. Extract Date
    if (lowerText.contains('yesterday')) {
      date = DateTime.now().subtract(const Duration(days: 1));
    }
    // "today" is default

    return Expense(
      amount: amount,
      categoryId: categoryId,
      date: date,
      description: text,
    );
  }
}
