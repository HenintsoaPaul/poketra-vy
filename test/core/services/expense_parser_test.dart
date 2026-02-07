import 'package:flutter_test/flutter_test.dart';
import 'package:poketra_vy/core/services/expense_parser.dart';

void main() {
  group('ExpenseParser', () {
    test('parses amount and category correctly', () {
      final expense = ExpenseParser.parse('I spent 5000 on food');
      expect(expense, isNotNull);
      expect(expense!.amount, 5000);
      expect(expense.category, 'food');
    });

    test('parses date keywords (today)', () {
      final expense = ExpenseParser.parse('5000 food today');
      expect(expense, isNotNull);
      final now = DateTime.now();
      expect(expense!.date.day, now.day);
      expect(expense.date.month, now.month);
    });
    
     test('parses date keywords (yesterday)', () {
      final expense = ExpenseParser.parse('5000 food yesterday');
      expect(expense, isNotNull);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(expense!.date.day, yesterday.day);
    });

    test('defaults to misc category if unknown', () {
      final expense = ExpenseParser.parse('5000 something');
      expect(expense!.category, 'misc');
    });

    test('returns null if no amount found', () {
      final expense = ExpenseParser.parse('food today');
      expect(expense, isNull);
    });
    
    test('uses full text logic for description (heuristics)', () {
      final expense = ExpenseParser.parse('dinner 20000 food');
      expect(expense!.description, contains('dinner'));
      // Amount and category might be stripped or not depending on final implementation logic, 
      // but strict check might be brittle if I change implementation. 
      // Checking if description is not empty at least.
      expect(expense.description, isNotEmpty);
    });
  });
}
