import 'package:flutter_test/flutter_test.dart';
import 'package:poketra_vy/core/models/expense.dart';

void main() {
  group('Expense Model', () {
    test('should generate a unique ID if none is provided', () {
      final now = DateTime.now();
      final expense1 = Expense(amount: 100, categoryId: '1', date: now, description: 'D1');
      final expense2 = Expense(amount: 200, categoryId: '2', date: now, description: 'D2');

      expect(expense1.id, isNotEmpty);
      expect(expense2.id, isNotEmpty);
      expect(expense1.id, isNot(expense2.id));
    });

    test('should support equality by ID', () {
      final now = DateTime.now();
      final expense1a = Expense(id: '1', amount: 100, categoryId: '1', date: now, description: 'D1');
      final expense1b = Expense(id: '1', amount: 200, categoryId: '2', date: now, description: 'D2');
      final expense2 = Expense(id: '2', amount: 100, categoryId: '1', date: now, description: 'D1');

      expect(expense1a == expense1b, isTrue);
      expect(expense1a == expense2, isFalse);
    });

    test('toJson and fromJson should be symmetric', () {
      final now = DateTime(2023, 10, 27, 10, 30);
      final original = Expense(id: 'exp1', amount: 5000, categoryId: 'cat1', date: now, description: 'Lunch');
      
      final json = original.toJson();
      final recovered = Expense.fromJson(json);

      expect(recovered.id, original.id);
      expect(recovered.amount, original.amount);
      expect(recovered.categoryId, original.categoryId);
      expect(recovered.date, original.date);
      expect(recovered.description, original.description);
    });

    test('copyWith should return updated object', () {
      final now = DateTime.now();
      final original = Expense(id: '1', amount: 100, categoryId: '1', date: now, description: 'Old');
      final updated = original.copyWith(amount: 500, description: 'New');

      expect(updated.id, '1');
      expect(updated.amount, 500);
      expect(updated.description, 'New');
      expect(updated.categoryId, '1');
      expect(updated.date, now);
    });
  });
}
