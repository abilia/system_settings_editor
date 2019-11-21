import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/utils.dart';

void main() {
  group('week number', () {
    test('Year shift 2019/2020', () {
      expect(getWeekNumber(DateTime(2019, 12, 29)), 52);
      expect(getWeekNumber(DateTime(2019, 12, 30)), 1);
      expect(getWeekNumber(DateTime(2019, 12, 31)), 1);
      expect(getWeekNumber(DateTime(2020, 1, 1)), 1);
      expect(getWeekNumber(DateTime(2020, 1, 4)), 1);
      expect(getWeekNumber(DateTime(2020, 1, 5)), 1);
    });

    test('Week 2 2020', () {
      expect(getWeekNumber(DateTime(2020, 1, 6)), 2);
    });

    test('Year shift 2020/2021', () {
      expect(getWeekNumber(DateTime(2020, 12, 27)), 52);
      expect(getWeekNumber(DateTime(2020, 12, 28)), 53);
      expect(getWeekNumber(DateTime(2020, 12, 29)), 53);
      expect(getWeekNumber(DateTime(2020, 12, 30)), 53);
      expect(getWeekNumber(DateTime(2020, 12, 31)), 53);
      expect(getWeekNumber(DateTime(2021, 01, 01)), 53);
      expect(getWeekNumber(DateTime(2021, 01, 02)), 53);
      expect(getWeekNumber(DateTime(2021, 01, 03)), 53);
      expect(getWeekNumber(DateTime(2021, 01, 04)), 1);
      expect(getWeekNumber(DateTime(2021, 01, 05)), 1);
    });

    test('Year shift 2021/22', () {
      expect(getWeekNumber(DateTime(2021, 12, 26)), 51, reason: '2021-12-26 is week 51');
      expect(getWeekNumber(DateTime(2021, 12, 27)), 52, reason: '2021-12-27 is week 52');
      expect(getWeekNumber(DateTime(2021, 12, 28)), 52, reason: '2021-12-28 is week 52');
      expect(getWeekNumber(DateTime(2021, 12, 29)), 52, reason: '2021-12-29 is week 52');
      expect(getWeekNumber(DateTime(2021, 12, 30)), 52, reason: '2021-12-30 is week 52');
      expect(getWeekNumber(DateTime(2021, 12, 31)), 52, reason: '2021-12-31 is week 52');
      expect(getWeekNumber(DateTime(2022, 01, 01)), 52, reason: '2022-01-01 is week 52');
      expect(getWeekNumber(DateTime(2022, 01, 02)), 52, reason: '2022-01-02 is week 52');
      expect(getWeekNumber(DateTime(2022, 01, 03)), 01, reason: '2022-01-03 is week 01');
      expect(getWeekNumber(DateTime(2022, 01, 04)), 01, reason: '2022-01-03 is week 01');
      expect(getWeekNumber(DateTime(2022, 01, 05)), 01, reason: '2022-01-03 is week 01');
    });

    test('week 14 2020', () {
      expect(getWeekNumber(DateTime(2020, 03, 29)), 13, reason: '2020-03-29 is week 13');
      expect(getWeekNumber(DateTime(2020, 03, 30)), 14, reason: '2020-03-30 is week 14');
      expect(getWeekNumber(DateTime(2020, 03, 31)), 14, reason: '2020-03-31 is week 14');
      expect(getWeekNumber(DateTime(2020, 04, 01)), 14, reason: '2020-04-01 is week 14');
      expect(getWeekNumber(DateTime(2020, 04, 02)), 14, reason: '2020-04-02 is week 14');
      expect(getWeekNumber(DateTime(2020, 04, 03)), 14, reason: '2020-04-03 is week 14');
      expect(getWeekNumber(DateTime(2020, 04, 04)), 14, reason: '2020-04-04 is week 14');
      expect(getWeekNumber(DateTime(2020, 04, 05)), 14, reason: '2020-04-05 is week 14');
      expect(getWeekNumber(DateTime(2020, 04, 06)), 15, reason: '2020-04-05 is week 15');
    });
  });
  group('onOrBetween', () {
    test('Should accept between start and endDay', () {
      // arrange
      DateTime startDay = DateTime(1999, 01, 12);
      DateTime endDay = DateTime(2020, 01, 12);
      DateTime currentDay = DateTime(1999, 12, 12);
      // act
      bool result = onOrBetween(
        dayInQuestion: currentDay,
        startDate: startDay,
        endDate: endDay,
      );
      // assert
      expect(result, true);
    });

    test('Should accept same as startDay', () {
      // arrange
      DateTime startDay = DateTime(1999, 12, 12);
      DateTime endDay = DateTime(2020, 01, 12);
      DateTime currentDay = DateTime(1999, 12, 12);
      // act
      bool result = onOrBetween(
        dayInQuestion: currentDay,
        startDate: startDay,
        endDate: endDay,
      );
      // assert
      expect(result, true);
    });

    test('Should accept same as endDay', () {
      // arrange
      DateTime startDay = DateTime(1999, 12, 12);
      DateTime endDay = DateTime(2020, 01, 12);
      DateTime currentDay = DateTime(2020, 01, 12);
      // act
      bool result = onOrBetween(
        dayInQuestion: currentDay,
        startDate: startDay,
        endDate: endDay,
      );
      // assert
      expect(result, true);
    });

    test('Should not accept before startDay', () {
      // arrange
      DateTime startDay = DateTime(199, 12, 12);
      DateTime endDay = DateTime(2020, 01, 12);
      DateTime currentDay = DateTime(1999, 12, 11);
      // act
      bool result = onOrBetween(
        dayInQuestion: currentDay,
        startDate: startDay,
        endDate: endDay,
      );
      // assert
      expect(result, true);
    });

    test('Should not accept after endDay', () {
      // arrange
      DateTime startDay = DateTime(1999, 12, 13);
      DateTime endDay = DateTime(2020, 01, 12);
      DateTime currentDay = DateTime(2020, 01, 13);
      // act
      bool result = onOrBetween(
        dayInQuestion: currentDay,
        startDate: startDay,
        endDate: endDay,
      );
      // assert
      expect(result, false);
    });
  });
}
