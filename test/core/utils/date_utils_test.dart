import 'package:flutter_test/flutter_test.dart';
import 'package:poketra_vy/core/utils/date_utils.dart';

void main() {
  group('DateUtilsHelper', () {
    test('formats date correctly (yMMMd)', () {
      final date = DateTime(2023, 10, 27);
      // Depending on locale, but standard is Oct 27, 2023
      final formatted = DateUtilsHelper.format(date);
      expect(formatted, contains('Oct 27'));
      expect(formatted, contains('2023'));
    });

    test('formats different year', () {
      final date = DateTime(2024, 1, 1);
      final formatted = DateUtilsHelper.format(date);
      expect(formatted, contains('Jan 1'));
      expect(formatted, contains('2024'));
    });
  });
}
