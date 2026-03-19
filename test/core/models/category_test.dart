import 'package:flutter_test/flutter_test.dart';
import 'package:poketra_vy/core/models/category.dart';

void main() {
  group('Category Model', () {
    test('should generate a unique ID if none is provided', () {
      final category1 = Category(name: 'Food', iconCodePoint: 123);
      final category2 = Category(name: 'Transport', iconCodePoint: 456);

      expect(category1.id, isNotEmpty);
      expect(category2.id, isNotEmpty);
      expect(category1.id, isNot(category2.id));
    });

    test('should use provided ID if provided', () {
      final category = Category(id: 'fixed-id', name: 'Fixed', iconCodePoint: 0);
      expect(category.id, 'fixed-id');
    });

    test('copyWith should return a new object with updated fields', () {
      final category = Category(id: '1', name: 'Old', iconCodePoint: 0);
      final updated = category.copyWith(name: 'New', iconCodePoint: 1);

      expect(updated.id, '1');
      expect(updated.name, 'New');
      expect(updated.iconCodePoint, 1);
    });

    test('equality should be based on ID', () {
      final category1a = Category(id: '1', name: 'Food', iconCodePoint: 0);
      final category1b = Category(id: '1', name: 'Transport', iconCodePoint: 1);
      final category2 = Category(id: '2', name: 'Food', iconCodePoint: 0);

      expect(category1a == category1b, isTrue);
      expect(category1a == category2, isFalse);
    });
  });
}
