import 'package:flutter_test/flutter_test.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/core/services/expense_parser.dart';

void main() {
  final categories = [
    Category(id: '1', name: 'food', iconCodePoint: 0),
    Category(id: '2', name: 'transport', iconCodePoint: 0),
    Category(id: '3', name: 'rent', iconCodePoint: 0),
    Category(id: '4', name: 'fun', iconCodePoint: 0),
    Category(id: '5', name: 'shopping', iconCodePoint: 0),
    Category(id: '6', name: 'misc', iconCodePoint: 0),
  ];

  group('ExpenseParser', () {
    test('parses amount and category correctly', () {
      final expense = ExpenseParser.parse('I spent 5000 on food', categories);
      expect(expense, isNotNull);
      expect(expense!.amount, 5000);
      expect(expense.categoryId, '1');
    });

    test('parses date keywords (today)', () {
      final expense = ExpenseParser.parse('5000 food today', categories);
      expect(expense, isNotNull);
      final now = DateTime.now();
      expect(expense!.date.day, now.day);
      expect(expense.date.month, now.month);
    });

    test('parses date keywords (yesterday)', () {
      final expense = ExpenseParser.parse('5000 food yesterday', categories);
      expect(expense, isNotNull);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(expense!.date.day, yesterday.day);
    });

    test('defaults to misc category if unknown', () {
      final expense = ExpenseParser.parse('5000 something', categories);
      expect(expense!.categoryId, '6');
    });

    test('returns null if no amount found', () {
      final expense = ExpenseParser.parse('food today', categories);
      expect(expense, isNull);
    });

    test('uses full text logic for description (heuristics)', () {
      final expense = ExpenseParser.parse('dinner 20000 food', categories);
      expect(expense!.description, contains('dinner'));
      expect(expense.description, isNotEmpty);
    });
  });
}
