import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final numberFormatterProvider = Provider<NumberFormat>((ref) {
  // Exposure of 'intl' formatter with common currency settings for Madagascar (Ar) or generic decimal
  return NumberFormat.decimalPattern();
});

final currencyFormatterProvider = Provider<NumberFormat>((ref) {
  // Specifically for currency with 'Ar' suffix as used in the app
  return NumberFormat.currency(
    symbol: 'Ar',
    decimalDigits: 0,
    customPattern: '#,##0 \u00A4',
  );
});
