import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  group('week number', () {
    test('Year shift 2019/2020', () {
      expect(DateTime(2019, 12, 29).getWeekNumber(), 52);
      expect(DateTime(2019, 12, 30).getWeekNumber(), 1);
      expect(DateTime(2019, 12, 31).getWeekNumber(), 1);
      expect(DateTime(2020, 1, 1).getWeekNumber(), 1);
      expect(DateTime(2020, 1, 4).getWeekNumber(), 1);
      expect(DateTime(2020, 1, 5).getWeekNumber(), 1);
    });

    test('Week 2 2020', () {
      expect(DateTime(2020, 1, 6).getWeekNumber(), 2);
    });

    test('Year shift 2020/2021', () {
      expect(DateTime(2020, 12, 27).getWeekNumber(), 52);
      expect(DateTime(2020, 12, 28).getWeekNumber(), 53);
      expect(DateTime(2020, 12, 29).getWeekNumber(), 53);
      expect(DateTime(2020, 12, 30).getWeekNumber(), 53);
      expect(DateTime(2020, 12, 31).getWeekNumber(), 53);
      expect(DateTime(2021, 01, 01).getWeekNumber(), 53);
      expect(DateTime(2021, 01, 02).getWeekNumber(), 53);
      expect(DateTime(2021, 01, 03).getWeekNumber(), 53);
      expect(DateTime(2021, 01, 04).getWeekNumber(), 1);
      expect(DateTime(2021, 01, 05).getWeekNumber(), 1);
    });

    test('Year shift 2021/22', () {
      expect(DateTime(2021, 12, 26).getWeekNumber(), 51,
          reason: '2021-12-26 is week 51');
      expect(DateTime(2021, 12, 27).getWeekNumber(), 52,
          reason: '2021-12-27 is week 52');
      expect(DateTime(2021, 12, 28).getWeekNumber(), 52,
          reason: '2021-12-28 is week 52');
      expect(DateTime(2021, 12, 29).getWeekNumber(), 52,
          reason: '2021-12-29 is week 52');
      expect(DateTime(2021, 12, 30).getWeekNumber(), 52,
          reason: '2021-12-30 is week 52');
      expect(DateTime(2021, 12, 31).getWeekNumber(), 52,
          reason: '2021-12-31 is week 52');
      expect(DateTime(2022, 01, 01).getWeekNumber(), 52,
          reason: '2022-01-01 is week 52');
      expect(DateTime(2022, 01, 02).getWeekNumber(), 52,
          reason: '2022-01-02 is week 52');
      expect(DateTime(2022, 01, 03).getWeekNumber(), 01,
          reason: '2022-01-03 is week 01');
      expect(DateTime(2022, 01, 04).getWeekNumber(), 01,
          reason: '2022-01-03 is week 01');
      expect(DateTime(2022, 01, 05).getWeekNumber(), 01,
          reason: '2022-01-03 is week 01');
    });

    test('week 14 2020', () {
      expect(DateTime(2020, 03, 29).getWeekNumber(), 13,
          reason: '2020-03-29 is week 13');
      expect(DateTime(2020, 03, 30).getWeekNumber(), 14,
          reason: '2020-03-30 is week 14');
      expect(DateTime(2020, 03, 31).getWeekNumber(), 14,
          reason: '2020-03-31 is week 14');
      expect(DateTime(2020, 04, 01).getWeekNumber(), 14,
          reason: '2020-04-01 is week 14');
      expect(DateTime(2020, 04, 02).getWeekNumber(), 14,
          reason: '2020-04-02 is week 14');
      expect(DateTime(2020, 04, 03).getWeekNumber(), 14,
          reason: '2020-04-03 is week 14');
      expect(DateTime(2020, 04, 04).getWeekNumber(), 14,
          reason: '2020-04-04 is week 14');
      expect(DateTime(2020, 04, 05).getWeekNumber(), 14,
          reason: '2020-04-05 is week 14');
      expect(DateTime(2020, 04, 06).getWeekNumber(), 15,
          reason: '2020-04-05 is week 15');
    });
  });
  group('onOrBetween', () {
    test('Should accept between start and endDay', () {
      // arrange
      final startDay = DateTime(1999, 01, 12);
      final endDay = DateTime(2020, 01, 12);
      final currentDay = DateTime(1999, 12, 12);
      // act
      final result = currentDay.inInclusiveRange(
        startDate: startDay,
        endDate: endDay,
      );
      // assert
      expect(result, true);
    });

    test('Should accept same as startDay', () {
      // arrange
      final startDay = DateTime(1999, 12, 12);
      final endDay = DateTime(2020, 01, 12);
      final currentDay = DateTime(1999, 12, 12);
      // act
      final result = currentDay.inInclusiveRange(
        startDate: startDay,
        endDate: endDay,
      );
      // assert
      expect(result, true);
    });

    test('Should accept same as endDay', () {
      // arrange
      final startDay = DateTime(1999, 12, 12);
      final endDay = DateTime(2020, 01, 12);
      final currentDay = DateTime(2020, 01, 12);
      // act
      final result = currentDay.inInclusiveRange(
        startDate: startDay,
        endDate: endDay,
      );
      // assert
      expect(result, true);
    });

    test('Should not accept before startDay', () {
      // arrange
      final startDay = DateTime(199, 12, 12);
      final endDay = DateTime(2020, 01, 12);
      final currentDay = DateTime(1999, 12, 11);
      // act
      final result = currentDay.inInclusiveRange(
        startDate: startDay,
        endDate: endDay,
      );
      // assert
      expect(result, true);
    });

    test('Should not accept after endDay', () {
      // arrange
      final startDay = DateTime(1999, 12, 13);
      final endDay = DateTime(2020, 01, 12);
      final currentDay = DateTime(2020, 01, 13);
      // act
      final result = currentDay.inInclusiveRange(
        startDate: startDay,
        endDate: endDay,
      );
      // assert
      expect(result, false);
    });

    test('Should not accept reveresed spans ( bug SGC-148 )', () {
      // arrange
      final startDay = DateTime(2020, 04, 01);
      final endDay = DateTime(2020, 04, 01).millisecondBefore();
      final day = DateTime(2020, 04, 01);
      // act
      final result = day.inInclusiveRange(
        startDate: startDay,
        endDate: endDay,
      );
      // assert
      expect(result, isFalse);
    });
  });

  group('roundToMinute', () {
    test('rounds down on 7', () {
      const minutesPerDot = 15;
      expect(
        DateTime(2000, 12, 12, 12, 07)
            .roundToMinute(minutesPerDot, minutesPerDot ~/ 2),
        DateTime(2000, 12, 12, 12, 00),
      );
    });
    test('rounds up on 8', () {
      const minutesPerDot = 15;
      expect(
        DateTime(2000, 12, 12, 12, 08)
            .roundToMinute(minutesPerDot, minutesPerDot ~/ 2),
        DateTime(2000, 12, 12, 12, 15),
      );
    });
    test('rounds up on 53', () {
      const minutesPerDot = 15;
      expect(
        DateTime(2000, 12, 12, 12, 53)
            .roundToMinute(minutesPerDot, minutesPerDot ~/ 2),
        DateTime(2000, 12, 12, 13, 00),
      );
    });
    test('rounds down on 52', () {
      const minutesPerDot = 15;
      expect(
        DateTime(2000, 12, 12, 12, 52)
            .roundToMinute(minutesPerDot, minutesPerDot ~/ 2),
        DateTime(2000, 12, 12, 12, 45),
      );
    });
    test('rounds to next day', () {
      const minutesPerDot = 15;
      expect(
        DateTime(2000, 12, 12, 23, 55)
            .roundToMinute(minutesPerDot, minutesPerDot ~/ 2),
        DateTime(2000, 12, 13, 00, 00),
      );
    });
  });

  group('First day in week', () {
    test('Test', () {
      final firstInWeek = DateTime(2021, 03, 01);
      expect(DateTime(2021, 03, 01).firstInWeek(), firstInWeek);
      expect(DateTime(2021, 03, 02).firstInWeek(), firstInWeek);
      expect(DateTime(2021, 03, 03).firstInWeek(), firstInWeek);
      expect(DateTime(2021, 03, 04).firstInWeek(), firstInWeek);
      expect(DateTime(2021, 03, 05).firstInWeek(), firstInWeek);
      expect(DateTime(2021, 03, 06).firstInWeek(), firstInWeek);
      expect(DateTime(2021, 03, 07).firstInWeek(), firstInWeek);

      expect(DateTime(2021, 01, 01).firstInWeek(), DateTime(2020, 12, 28));
    });
  });

  group('DayPart', () {
    test('Correct day part', () {
      final dayParts = DayParts(
        morning: 6.hours(),
        day: 10.hours(),
        evening: 18.hours(),
        night: 23.hours(),
      );
      expect(DateTime(2020, 10, 07, 00, 00).dayPart(dayParts), DayPart.night);
      expect(DateTime(2020, 10, 07, 02, 00).dayPart(dayParts), DayPart.night);
      expect(DateTime(2020, 10, 07, 05, 59).dayPart(dayParts), DayPart.night);
      expect(DateTime(2020, 10, 07, 06, 00).dayPart(dayParts), DayPart.morning);
      expect(DateTime(2020, 10, 07, 09, 59).dayPart(dayParts), DayPart.morning);
      expect(DateTime(2020, 10, 07, 10, 00).dayPart(dayParts), DayPart.day);
      expect(DateTime(2020, 10, 07, 11, 59).dayPart(dayParts), DayPart.day);
      expect(DateTime(2020, 10, 07, 18, 00).dayPart(dayParts), DayPart.evening);
      expect(DateTime(2020, 10, 07, 22, 59).dayPart(dayParts), DayPart.evening);
      expect(DateTime(2020, 10, 07, 23, 00).dayPart(dayParts), DayPart.night);
      expect(DateTime(2020, 10, 07, 23, 59).dayPart(dayParts), DayPart.night);
    });
  });

  group('Occasion', () {
    test('Correct occasion', () {
      final day = DateTime(2022, 05, 18);
      expect(day.dayOccasion(DateTime(2022, 05, 18, 19, 55)), Occasion.current);
      expect(day.dayOccasion(DateTime(2022, 05, 19, 19, 55)), Occasion.past);
      expect(day.dayOccasion(DateTime(2022, 05, 18, 23, 59)), Occasion.current);
      expect(day.dayOccasion(DateTime(2022, 05, 18, 00, 00)), Occasion.current);
      expect(day.dayOccasion(DateTime(2022, 05, 17, 23, 59)), Occasion.future);
    });
  });
}
