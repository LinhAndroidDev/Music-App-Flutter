import 'package:intl/intl.dart';

/// Parity with ServiceMusic [DateUtils] for ZingChart header date and X-axis hours.
abstract final class ChartDateFormat {
  static String timeWithHourCurrent([DateTime? now]) {
    final date = now ?? DateTime.now();
    final formatted = DateFormat('dd/MM/yyyy - HH').format(date);
    return '$formatted:00';
  }

  /// Last 12 clock hours ending at [now], ascending (oldest → newest).
  static List<int> last12Hours([DateTime? now]) {
    final current = now ?? DateTime.now();
    final currentHour = current.hour;
    final hours = <int>[];
    for (var i = 11; i >= 0; i--) {
      var h = currentHour - i;
      while (h < 0) {
        h += 24;
      }
      hours.add(h);
    }
    return hours;
  }
}
