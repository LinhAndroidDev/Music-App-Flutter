import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/modules/zing_chart/utils/chart_date_format.dart';

void main() {
  test('timeWithHourCurrent formats dd/MM/yyyy - HH:00', () {
    final label = ChartDateFormat.timeWithHourCurrent(
      DateTime(2024, 8, 9, 14, 30),
    );
    expect(label, '09/08/2024 - 14:00');
  });

  test('last12Hours returns 12 ascending hour values', () {
    final hours = ChartDateFormat.last12Hours(DateTime(2024, 1, 1, 15, 0));
    expect(hours, hasLength(12));
    expect(hours.last, 15);
    expect(hours.first, 4);
  });
}
