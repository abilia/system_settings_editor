import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  group('Recurring activity', () {
    test('Split up activity shows on day it was split up on ( bug test )', () {
      // Arrange
      DateTime splitStartTime = 1574380800000.fromMillisecondsSinceEpoch(),
          splitEndTime = 253402297199000.fromMillisecondsSinceEpoch();
      final dayOnSplit = splitStartTime.onlyDays();

      final splitRecurring = Activity.createNew(
        title: 'Split recurring ',
        reminderBefore: [],
        recurrentType: 1,
        recurrentData: 16383,
        alarmType: 104,
        duration: 86399999.milliseconds(),
        category: 0,
        startTime: splitStartTime,
        endTime: splitEndTime,
        fullDay: true,
      );
      // Act
      final result = splitRecurring.shouldShowForDay(dayOnSplit);

      // Assert
      expect(result, true);
    });

    test(
        'Activity with endtime before start time does not shows ( bug SGC-148 )',
        () {
      // Arrange
      int splitStartTime = 1585735200000, splitEndTime = 1585605599999;

      final day = DateTime(2020, 04, 01);

      final splitRecurring = Activity.createNew(
        title: 'test',
        recurrentType: 1,
        recurrentData: 16383,
        startTime: splitStartTime.fromMillisecondsSinceEpoch(),
        endTime: splitEndTime.fromMillisecondsSinceEpoch(),
      );
      // Act
      final result = splitRecurring.shouldShowForDay(day);

      // Assert
      expect(result, isFalse);
    });
  });

  group('Recurring tests', () {
    test('-1 is not a correct day of the year', () {
      // arrange
      int recurrentData = -1;
      DateTime start = DateTime(1999, 12, 12);
      // act
      bool result = Recurs.onCorrectYearsDay(recurrentData, start);
      // assert
      expect(result, false);
    });

    test('onCorrectYearsDay christmas day', () {
      // arrange
      int recurrentData = 1124;
      DateTime start = DateTime(1999, 12, 24);
      // act
      bool result = Recurs.onCorrectYearsDay(recurrentData, start);
      // assert
      expect(result, true);
    });

    test('onCorrectYearsDay new years day', () {
      // arrange
      int recurrentData = 1;
      DateTime start = DateTime(2000, 01, 01);
      // act
      bool result = Recurs.onCorrectYearsDay(recurrentData, start);
      // assert
      expect(result, true);
    });

    test('onCorrectYearsDay midsummer day', () {
      // arrange
      int recurrentData = 0521;
      DateTime start = DateTime(2000, 06, 21);
      // act
      bool result = Recurs.onCorrectYearsDay(recurrentData, start);
      // assert
      expect(result, true);
    });

    test('onCorrectYearsDay day after midsummer day is not midsummer day', () {
      // arrange
      int recurrentData = 0521;
      DateTime start = DateTime(2000, 06, 22);
      // act
      bool result = Recurs.onCorrectYearsDay(recurrentData, start);
      // assert
      expect(result, false);
    });

    test('onCorrectYearsDay midsummer 2500', () {
      // arrange
      int recurrentData = 0521;
      DateTime start = DateTime(2500, 06, 21);
      // act
      bool result = Recurs.onCorrectYearsDay(recurrentData, start);
      // assert
      expect(result, true);
    });

    test('onCorrectYearsDay midsummer 2500', () {
      // arrange
      int recurrentData = 0521;
      DateTime start = DateTime(2500, 06, 21);
      // act
      bool result = Recurs.onCorrectYearsDay(recurrentData, start);
      // assert
      expect(result, true);
    });

    test('onCorrectMonthDay first day of month', () {
      // arrange
      int recurrentData = Recurs.onDayOfMonth(1);
      DateTime start = DateTime(2020, 06, 01);
      // act
      bool result = Recurs.onCorrectMonthDay(recurrentData, start);
      // assert
      expect(result, true);
    });

    test('onCorrectMonthDay not first day of month', () {
      // arrange
      int recurrentData = Recurs.onDayOfMonth(1);
      DateTime start = DateTime(2020, 06, 02);
      // act
      bool result = Recurs.onCorrectMonthDay(recurrentData, start);
      // assert
      expect(result, false);
    });

    test('onCorrectMonthDay second day of month', () {
      // arrange
      int recurrentData = Recurs.onDayOfMonth(2);
      DateTime start = DateTime(2020, 06, 02);
      // act
      bool result = Recurs.onCorrectMonthDay(recurrentData, start);
      // assert
      expect(result, true);
    });

    test('onCorrectMonthDay second day of month ignores other', () {
      // arrange
      int recurrentData = Recurs.onDayOfMonth(2);
      DateTime start = DateTime(2020, 01, 02, 20, 20, 20, 20);
      // act
      bool result = Recurs.onCorrectMonthDay(recurrentData, start);
      // assert
      expect(result, true);
    });

    test('onCorrectMonthDay third day of month', () {
      // arrange
      int recurrentData = Recurs.onDayOfMonth(3);
      DateTime start = DateTime(2020, 01, 03);
      // act
      bool result = Recurs.onCorrectMonthDay(recurrentData, start);
      // assert
      expect(result, true);
    });

    test('onCorrectMonthDay 10th day of month', () {
      // arrange
      int recurrentData = Recurs.onDayOfMonth(10);
      DateTime start = DateTime(2011, 11, 10);
      // act
      bool result = Recurs.onCorrectMonthDay(recurrentData, start);
      // assert
      expect(result, true);
    });

    test('onCorrectMonthDay 1st, 2nd, 3rd and 10th day of month', () {
      // arrange
      int recurrentData = Recurs.onDaysOfMonth([1, 2, 3, 10]);
      DateTime first = DateTime(2011, 11, 1);
      DateTime second = DateTime(2011, 11, 2);
      DateTime third = DateTime(2011, 11, 3);
      DateTime forth = DateTime(2011, 11, 4);
      DateTime tenth = DateTime(2011, 11, 10);
      // act
      bool firstResult = Recurs.onCorrectMonthDay(recurrentData, first);
      bool secondResult = Recurs.onCorrectMonthDay(recurrentData, second);
      bool thirdResult = Recurs.onCorrectMonthDay(recurrentData, third);
      bool forthResult = Recurs.onCorrectMonthDay(recurrentData, forth);
      bool tenthResult = Recurs.onCorrectMonthDay(recurrentData, tenth);
      // assert
      expect(firstResult, true);
      expect(secondResult, true);
      expect(thirdResult, true);
      expect(forthResult, false);
      expect(tenthResult, true);
    });

    test('onCorrectMonthDay all day of month', () {
      // arrange
      int recurrentData = 0xFFFFFFFF;
      final dates = List.generate(31, (i) => DateTime(2020, 10, i + 1));
      // act
      bool result =
          dates.every((d) => Recurs.onCorrectMonthDay(recurrentData, d));
      // assert
      expect(result, true);
    });

    test('onCorrectMonthDay no day of month', () {
      // arrange
      int recurrentData = 0x0;
      final dates = List.generate(31, (i) => DateTime(2020, 10, i + 1));
      // act
      bool result =
          dates.any((d) => Recurs.onCorrectMonthDay(recurrentData, d));
      // assert
      expect(result, false);
    });

    test('onCorrectMonthDay one day of month', () {
      // arrange
      int recurrentData = Recurs.onDayOfMonth(5);
      final dates = List.generate(31, (i) => DateTime(2020, 10, i + 1));
      // act
      final results =
          dates.map((d) => Recurs.onCorrectMonthDay(recurrentData, d));
      final correctDays = results.where((b) => b).length;
      // assert
      expect(correctDays, 1);
    });

    test('All weekdays, monday is true', () {
      // arrange
      int recurrentData = allWeekdays;
      final evenWeekMonday = DateTime(2019, 11, 25);

      // act
      final correctDays =
          Recurs.onCorrectWeeklyDay(recurrentData, evenWeekMonday);
      // assert
      expect(correctDays, true);
    });

    test('All weekdays, sunday is false', () {
      // arrange
      int recurrentData = allWeekdays;
      final evenWeekMonday = DateTime(2019, 11, 24);
      // act
      final correctDays =
          Recurs.onCorrectWeeklyDay(recurrentData, evenWeekMonday);
      // assert
      expect(correctDays, false);
    });

    test('All weekdays, correct for whole month', () {
      // arrange
      int recurrentData = allWeekdays;
      final dates = List.generate(31, (i) => DateTime(2020, 10, i + 1));
      // act
      final correctDays = dates.every((d) =>
          Recurs.onCorrectWeeklyDay(recurrentData, d) != (d.weekday > 5));
      // assert
      expect(correctDays, true);
    });

    test('Even monday is true', () {
      // arrange
      int recurrentData = Recurs.EVEN_MONDAY;
      final evenWeekMonday = DateTime(2019, 11, 25);

      // act
      final correctDays =
          Recurs.onCorrectWeeklyDay(recurrentData, evenWeekMonday);
      // assert
      expect(correctDays, true);
    });

    test('Odd monday is false', () {
      // arrange
      int recurrentData = Recurs.EVEN_MONDAY;
      final evenWeekMonday = DateTime(2019, 11, 18);

      // act
      final correctDays =
          Recurs.onCorrectWeeklyDay(recurrentData, evenWeekMonday);
      // assert
      expect(correctDays, false);
    });

    test('Odd and even Monday is true', () {
      // arrange
      int recurrentData = Recurs.EVEN_MONDAY | Recurs.ODD_MONDAY;
      final evenWeekMonday = DateTime(2019, 11, 18);

      // act
      final correctDays =
          Recurs.onCorrectWeeklyDay(recurrentData, evenWeekMonday);
      // assert
      expect(correctDays, true);
    });

    test('Monday is true all year', () {
      // arrange
      int recurrentData = Recurs.EVEN_MONDAY | Recurs.ODD_MONDAY;
      final dates = List.generate(2000, (i) => DateTime(2020, 01, i + 1));
      // act
      final correctDays = dates.every((d) =>
          Recurs.onCorrectWeeklyDay(recurrentData, d) != (d.weekday != 1));
      // assert
      expect(correctDays, true);
    });

    test('Not sunday is true all year', () {
      // arrange
      int recurrentData = Recurs.EVEN_MONDAY | Recurs.ODD_MONDAY;
      final dates = List.generate(2000, (i) => DateTime(2020, 01, i + 1));
      // act
      final correctDays = dates.every((d) =>
          Recurs.onCorrectWeeklyDay(recurrentData, d) != (d.weekday != 1));
      // assert
      expect(correctDays, true);
    });

    test('Odd fridays', () {
      // arrange
      int recurrentData = Recurs.ODD_FRIDAY;
      final anOddFriday = DateTime(2019, 11, 22);
      // act
      final result = Recurs.onCorrectWeeklyDay(recurrentData, anOddFriday);
      // assert
      expect(result, true);
    });

    test('Odd fridays', () {
      // arrange
      int recurrentData = Recurs.ODD_FRIDAY;
      final anOddFriday = DateTime(2019, 11, 29);
      // act
      final result = Recurs.onCorrectWeeklyDay(recurrentData, anOddFriday);
      // assert
      expect(result, false);
    });

    test('Even weekdays', () {
      // arrange
      int recurrentData = Recurs.EVEN_MONDAY |
          Recurs.EVEN_TUESDAY |
          Recurs.EVEN_WEDNESDAY |
          Recurs.EVEN_THURSDAY |
          Recurs.EVEN_FRIDAY;
      final twoWeeks = List.generate(14, (i) => DateTime(2019, 11, 25 + i));
      // act
      final correctDays = twoWeeks
          .takeWhile((d) => Recurs.onCorrectWeeklyDay(recurrentData, d));
      final incorrects = twoWeeks.reversed
          .takeWhile((d) => !Recurs.onCorrectWeeklyDay(recurrentData, d));
      // assert
      expect(correctDays.length, 5);
      expect(incorrects.length, 9);
    });

    test('saturdays week 53 time is odd', () {
      // arrange
      int recurrentData = Recurs.ODD_SATURDAY;
      final saturDayWeek53 = DateTime(2021, 01, 02);
      // act
      final correctDays =
          Recurs.onCorrectWeeklyDay(recurrentData, saturDayWeek53);
      // assert
      expect(correctDays, true);
    });

    test('saturdays 11th april is odd', () {
      // arrange
      int recurrentData = Recurs.ODD_SATURDAY;
      final april11th = DateTime(2020, 04, 11);
      // act
      final result = Recurs.onCorrectWeeklyDay(recurrentData, april11th);
      // assert
      expect(result, true);
    });

    test(
        'every other saturdays for until there is a week 53 then two in a row then every other again',
        () {
      // arrange
      int recurrentData = Recurs.ODD_SATURDAY;
      final twoWeeks = List.generate(
          29, (i) => DateTime(2019, 11, 23 + (i * 14)))
        ..add(DateTime(2021, 01, 02))
        ..addAll(List.generate(150, (i) => DateTime(2021, 01, 09 + (i * 14))));
      // act
      final correctDays =
          twoWeeks.every((d) => Recurs.onCorrectWeeklyDay(recurrentData, d));
      // assert
      expect(correctDays, true);
    });

    test(
        'every other saturdays for until there is a week 53 then nothing for two weeks then every other again',
        () {
      // arrange
      int recurrentData = Recurs.EVEN_SATURDAY;
      final twoWeeks = List.generate(
          29, (i) => DateTime(2019, 11, 30 + (i * 14)))
        ..addAll(List.generate(150, (i) => DateTime(2021, 01, 16 + (i * 14))));
      // act
      final correctDays =
          twoWeeks.every((d) => Recurs.onCorrectWeeklyDay(recurrentData, d));
      // assert
      expect(correctDays, true);
    });

    test('everyDay is always true', () {
      // arrange
      int recurrentData = allWeek;
      final loadsOfDays =
          List.generate(3333, (i) => DateTime(2019, 01, 01 + i));
      // act
      final allCorrect =
          loadsOfDays.every((d) => Recurs.onCorrectWeeklyDay(recurrentData, d));
      // assert
      expect(allCorrect, true);
    });
  });
}
