import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poketra_vy/core/providers/formatter_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('currencyFormatterProvider', () {
    test('formats amount with Ar suffix and no decimals', () {
      final formatter = container.read(currencyFormatterProvider);
      
      expect(formatter.format(1000), '1,000 Ar');
      expect(formatter.format(50), '50 Ar');
      expect(formatter.format(1234567), '1,234,567 Ar');
    });

    test('handles decimal amounts by rounding or stripping', () {
      final formatter = container.read(currencyFormatterProvider);
      
      // Since decimalDigits: 0
      expect(formatter.format(100.25), '100 Ar');
      expect(formatter.format(100.75), '101 Ar');
    });
  });

  group('numberFormatterProvider', () {
    test('formats numbers with decimal patterns', () {
      final formatter = container.read(numberFormatterProvider);
      
      expect(formatter.format(1000), '1,000');
      expect(formatter.format(12.34), '12.34');
    });
  });
}
