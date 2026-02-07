import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String format(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }
}
