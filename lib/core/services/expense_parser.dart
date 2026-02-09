import '../models/expense.dart';

class ExpenseParser {
  static final List<String> _categories = [
    'food',
    'transport',
    'rent',
    'fun',
    'shopping',
    'misc',
  ];

  // Public getter for categories
  static List<String> get categories => _categories;

  static Expense? parse(String text) {
    if (text.isEmpty) return null;
    final lowerText = text.toLowerCase();
    final words = lowerText.split(' ');

    double? amount;
    String category = 'misc'; // Miscellaneous

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
    for (var cat in _categories) {
      if (lowerText.contains(cat)) {
        category = cat;
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
      category: category,
      date: date,
      description: text,
    );
  }
}
