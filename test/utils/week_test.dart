import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/utils/datetime_utils.dart';

void main() {
  test('Test week number', () {
    expect(getWeekNumber(DateTime.utc(2019, 12, 29)), 52);
    expect(getWeekNumber(DateTime.utc(2019, 12, 30)), 1);
    expect(getWeekNumber(DateTime.utc(2019, 12, 31)), 1);
    expect(getWeekNumber(DateTime.utc(2020, 1, 1)), 1);
    expect(getWeekNumber(DateTime.utc(2020, 1, 5)), 1);

    expect(getWeekNumber(DateTime(2019, 12, 29)), 52);
    expect(getWeekNumber(DateTime(2019, 12, 30)), 1);
    expect(getWeekNumber(DateTime(2019, 12, 31)), 1);
    expect(getWeekNumber(DateTime(2020, 1, 1)), 1);
    expect(getWeekNumber(DateTime(2020, 1, 5)), 1);
  });

  test('Week 2', () {
    expect(getWeekNumber(DateTime.utc(2020, 1, 6)), 2);
    expect(getWeekNumber(DateTime(2020, 1, 6)), 2);
  });
}
