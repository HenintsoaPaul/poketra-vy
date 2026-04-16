import 'dart:convert';
import 'package:poketra_vy/core/models/expense.dart';
import 'package:poketra_vy/core/models/category.dart';

class JsonImportService {
  List<Expense> parseJson(String content, List<Category> categories) {
    try {
      final decoded = jsonDecode(content);
      List<dynamic> jsonList = [];

      // Check format
      if (decoded is List) {
        jsonList = decoded;
      } else if (decoded is Map && decoded.containsKey('expenses')) {
        jsonList = decoded['expenses'] as List<dynamic>;
      } else {
        return [];
      }

      final List<Expense> importedExpenses = [];

      for (var item in jsonList) {
        if (item is! Map<String, dynamic>) continue;
        
        try {
          final double amount = (item['amount'] as num).toDouble();
          final String description = item['description']?.toString() ?? '';
          final DateTime date = DateTime.parse(item['date'].toString());
          
          final categoryName = item['category']?.toString().toLowerCase();
          final categoryId = item['categoryId']?.toString();

          final matchedCategory = categories.firstWhere(
            (c) => c.id == categoryId || c.name.toLowerCase() == categoryName,
            orElse: () => categories.firstWhere(
              (c) => c.name.toLowerCase() == 'misc',
              orElse: () => categories.isNotEmpty
                  ? categories.first
                  : Category(id: 'unknown', name: 'Unknown', iconCodePoint: 0),
            ),
          );

          importedExpenses.add(
            Expense(
              amount: amount,
              categoryId: matchedCategory.id,
              date: date,
              description: description,
            ),
          );
        } catch (e) {
          // skip invalid entries
        }
      }

      return importedExpenses;
    } catch (e) {
      return [];
    }
  }
}
