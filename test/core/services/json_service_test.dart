import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/core/services/json_import_service.dart';

void main() {
  group('JsonImportService', () {
    late JsonImportService importService;
    late List<Category> categories;

    setUp(() {
      importService = JsonImportService();
      categories = [
        Category(id: 'c1', name: 'food', iconCodePoint: 1),
        Category(id: 'c2', name: 'misc', iconCodePoint: 2),
      ];
    });

    test('imports expenses from valid JSON list', () {
      final jsonString = json.encode([
        {
          'amount': 100.0,
          'categoryId': 'c1',
          'date': '2024-01-01T00:00:00.000',
          'description': 'Lunch',
        },
      ]);

      final result = importService.parseJson(jsonString, categories);

      expect(result.length, 1);
      expect(result[0].description, 'Lunch');
      expect(result[0].categoryId, 'c1');
    });

    test('imports expenses from valid JSON object with expenses key', () {
      final jsonString = json.encode({
        'expenses': [
          {
            'amount': 200.0,
            'category': 'food',
            'date': '2024-01-02T00:00:00.000',
            'description': 'Dinner',
          },
        ],
      });

      final result = importService.parseJson(jsonString, categories);

      expect(result.length, 1);
      expect(result[0].description, 'Dinner');
      expect(result[0].categoryId, 'c1'); // Matched by name 'food'
    });

    test('falls back to misc category if no match', () {
      final jsonString = json.encode([
        {
          'amount': 50.0,
          'category': 'unknown',
          'date': '2024-01-03T00:00:00.000',
          'description': 'Something',
        },
      ]);

      final result = importService.parseJson(jsonString, categories);

      expect(result.length, 1);
      expect(result[0].categoryId, 'c2'); // Matched to 'misc'
    });

    test('returns empty list on invalid JSON', () {
      final result = importService.parseJson('invalid json', categories);
      expect(result, isEmpty);
    });

    test('skips invalid entries in the list', () {
      final jsonString = json.encode([
        {'amount': 'not a number', 'date': 'invalid date'},
        {
          'amount': 10.0,
          'date': '2024-01-04T00:00:00.000',
          'description': 'Valid',
        },
      ]);

      final result = importService.parseJson(jsonString, categories);

      expect(result.length, 1);
      expect(result[0].description, 'Valid');
    });
  });
}
