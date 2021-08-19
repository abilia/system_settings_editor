// @dart=2.9

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  group('Recurring activity', () {
    test('Split up activity shows on day it was split up on ( bug test )', () {
      // Arrange
      final splitStartTime = 1574380800000
              .fromMillisecondsSinceEpoch(), // 2019-11-22 01:00:00.000
          splitEndTime = 253402297199000
              .fromMillisecondsSinceEpoch(); // 9999-12-31 23:59:59.000
      final dayOnSplit = splitStartTime.onlyDays();

      final splitRecurring = Activity.createNew(
        title: 'Split recurring ',
        recurs: Recurs.raw(
          Recurs.TYPE_WEEKLY,
          16383,
          splitEndTime.millisecondsSinceEpoch,
        ), // Weekly every day odd and even week
        alarmType: 104, // NO_ALARM
        duration: 86399999.milliseconds(), // 23:59:59.999000
        startTime: splitStartTime,
        fullDay: true,
      );
      // Act
      final result = splitRecurring.dayActivitiesForDay(dayOnSplit);

      // Assert
      expect(result, [
        ActivityDay(splitRecurring, dayOnSplit),
      ]);
    });

    test('Full day with duration spanning, should not show twice on one day ',
        () {
      // Arrange
      final day = DateTime(2020, 06, 02);
      final splitRecurring = Activity.createNew(
        title: 'Fullday ',
        recurs: Recurs.everyDay,
        alarmType: 104, // NO_ALARM
        duration: 86399999.milliseconds(), // 23:59:59.999000
        category: Category.right,
        startTime: DateTime(1970, 01, 01, 12, 00),
        fullDay: true,
      );

      // Act
      final result = splitRecurring.dayActivitiesForDay(day);

      // Assert
      expect(result, [
        ActivityDay(splitRecurring, day),
      ]);
    });

    test('Should show when starts at 00:00 ', () {
      // Arrange
      final startTime = DateTime(2020, 04, 01, 00, 00);
      final day = DateTime(2020, 04, 01);

      final overlapping = Activity.createNew(
        title: 'test',
        startTime: startTime,
      );
      // Act
      final resultDay1 = overlapping.dayActivitiesForDay(day);

      // Assert
      expect(resultDay1, [ActivityDay(overlapping, day)]);
    });

    test(
        'Activity with endtime before start time does not shows ( bug SGC-148 )',
        () {
      // Arrange
      final splitStartTime = 1585735200000, splitEndTime = 1585605599999;

      final day = DateTime(2020, 04, 01);

      final splitRecurring = Activity.createNew(
        title: 'test',
        recurs: Recurs.raw(
          Recurs.TYPE_WEEKLY,
          16383,
          splitEndTime,
        ),
        startTime: splitStartTime.fromMillisecondsSinceEpoch(),
      );
      // Act
      final result = splitRecurring.dayActivitiesForDay(day);

      // Assert
      expect(result, isEmpty);
    });

    test(
        'Activity with end on day after start should show for next day ( bug SGC-16 )',
        () {
      // Arrange
      final startTime = DateTime(2020, 04, 01, 23, 30);
      final startDay = startTime.onlyDays();
      final day = DateTime(2020, 04, 02);

      final overlapping = Activity.createNew(
        title: 'test',
        startTime: startTime,
        duration: 2.hours(),
      );
      // Act
      final result = overlapping.dayActivitiesForDay(day);

      // Assert
      expect(result, [ActivityDay(overlapping, startDay)]);
    });

    test(
        'Activity with end two days after start should show for two days after, but not 3 ( bug SGC-16 )',
        () {
      // Arrange
      final startTime = DateTime(2020, 04, 01, 23, 30);
      final startDay = DateTime(2020, 04, 01);
      final day = DateTime(2020, 04, 03);
      final day2 = DateTime(2020, 04, 04);

      final overlapping = Activity.createNew(
        title: 'test',
        startTime: startTime,
        duration: 26.hours(),
      );
      // Act
      final result1 = overlapping.dayActivitiesForDay(day);
      final result2 = overlapping.dayActivitiesForDay(day2);

      // Assert
      expect(result1, [ActivityDay(overlapping, startDay)]);
      expect(result2, isEmpty);
    });

    test('Should not show time that ends at 00:00 in that day', () {
      // Arrange
      final startTime = DateTime(2020, 05, 02, 00, 00);
      final day = DateTime(2020, 05, 02);
      final day2 = DateTime(2020, 05, 03);
      final day3 = DateTime(2020, 05, 04);

      final overlapping = Activity.createNew(
        title: 'test',
        startTime: startTime,
        duration: 48.hours(),
      );
      // Act
      final resultDay1 = overlapping.dayActivitiesForDay(day);
      final resultDay2 = overlapping.dayActivitiesForDay(day2);
      final resultDay3 = overlapping.dayActivitiesForDay(day3);

      // Assert
      expect(resultDay1, [ActivityDay(overlapping, day)]);
      expect(resultDay2, [ActivityDay(overlapping, day)]);
      expect(resultDay3, isEmpty);
    });
    test('Fullday', () {
      // Arrange
      final initialMinutes =
          DateTime(2006, 06, 06, 06, 06, 06, 06).onlyMinutes();
      final fullDayActivity = FakeActivity.fullday(initialMinutes);
      final tomorrowFullday =
          FakeActivity.fullday(initialMinutes.add(1.days()));
      final yesterdayFullday =
          FakeActivity.fullday(initialMinutes.subtract(1.days()));

      final today = initialMinutes.onlyDays();
      final tomorrow = initialMinutes.nextDay().onlyDays();
      final yesterday = initialMinutes.previousDay().onlyDays();

      // Act
      final result1Day1 = fullDayActivity.dayActivitiesForDay(today);
      final result2Day1 = tomorrowFullday.dayActivitiesForDay(today);
      final result3Day1 = yesterdayFullday.dayActivitiesForDay(today);

      final result1Day2 = fullDayActivity.dayActivitiesForDay(tomorrow);
      final result2Day2 = tomorrowFullday.dayActivitiesForDay(tomorrow);
      final result3Day2 = yesterdayFullday.dayActivitiesForDay(tomorrow);

      final result1Day3 = fullDayActivity.dayActivitiesForDay(yesterday);
      final result2Day3 = tomorrowFullday.dayActivitiesForDay(yesterday);
      final result3Day3 = yesterdayFullday.dayActivitiesForDay(yesterday);

      // Assert
      expect(result1Day1, [ActivityDay(fullDayActivity, today)]);
      expect(result2Day1, isEmpty);
      expect(result3Day1, isEmpty);

      expect(result1Day2, isEmpty);
      expect(result2Day2, [ActivityDay(tomorrowFullday, tomorrow)]);
      expect(result3Day2, isEmpty);

      expect(result1Day3, isEmpty);
      expect(result2Day3, isEmpty);
      expect(result3Day3, [ActivityDay(yesterdayFullday, yesterday)]);
    });

    test('Fullday with duration should be ignored', () {
      // Arrange
      final initialMinutes = DateTime(2006, 06, 06, 06, 06, 06, 06);
      final fullDayActivity = Activity.createNew(
        title: 'Full day',
        fullDay: true,
        startTime: initialMinutes,
        duration: 24.hours(),
      );

      final today = initialMinutes.onlyDays();
      final tomorrow = initialMinutes.nextDay().onlyDays();
      final dayAfterTomorrow = initialMinutes.nextDay().onlyDays();

      // Act
      final resultDay1 = fullDayActivity.dayActivitiesForDay(today);
      final resultDay2 = fullDayActivity.dayActivitiesForDay(tomorrow);
      final resultDay3 = fullDayActivity.dayActivitiesForDay(dayAfterTomorrow);

      // Assert
      expect(resultDay1, [ActivityDay(fullDayActivity, today)]);
      expect(resultDay2, isEmpty);
      expect(resultDay3, isEmpty);
    });

    group('dayActivitiesForDay with longer than 24h duration', () {
      test('weekly recurrance past midnight is true for next day', () {
        final startTime = DateTime(2010, 01, 01, 22, 00);
        final saturday = DateTime(2020, 05, 30);
        final friday = DateTime(2020, 05, 29);

        // arrange
        final overlappingFridayRecurring = Activity.createNew(
          title: 'title',
          startTime: startTime,
          duration: Duration(hours: 4),
          recurs: Recurs.weeklyOnDay(DateTime.friday),
        );

        // act
        final result = overlappingFridayRecurring.dayActivitiesForDay(saturday);

        // assert
        expect(result, [ActivityDay(overlappingFridayRecurring, friday)]);
      });

      test('weekly recurrance with duration 36 hours is true for 3 day', () {
        final startTime = DateTime(2010, 01, 01, 22, 00);
        final thursday = DateTime(2020, 05, 28);
        final friday = DateTime(2020, 05, 29);
        final saturday = DateTime(2020, 05, 30);
        final sunday = DateTime(2020, 05, 31);
        final monday = DateTime(2020, 06, 01);

        // arrange
        final overlappingFridayRecurring = Activity.createNew(
            title: 'title',
            startTime: startTime,
            duration: Duration(hours: 36),
            recurs: Recurs.weeklyOnDay(DateTime.friday));

        // act
        final thursdayResult =
            overlappingFridayRecurring.dayActivitiesForDay(thursday);
        final fridayResult =
            overlappingFridayRecurring.dayActivitiesForDay(friday);
        final saturdayResult =
            overlappingFridayRecurring.dayActivitiesForDay(saturday);
        final sundayResult =
            overlappingFridayRecurring.dayActivitiesForDay(sunday);
        final mondayResult =
            overlappingFridayRecurring.dayActivitiesForDay(monday);

        // assert
        expect(thursdayResult, isEmpty);
        expect(fridayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
        expect(
            saturdayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
        expect(sundayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
        expect(mondayResult, isEmpty);
      });

      test('monthly recurrance with 36 hours duration is true for 3 day', () {
        final startTime = DateTime(2010, 01, 01, 22, 00);
        final thursday = DateTime(2020, 05, 28);
        final friday = DateTime(2020, 05, 29);
        final saturday = DateTime(2020, 05, 30);
        final sunday = DateTime(2020, 05, 31);
        final monday = DateTime(2020, 06, 01);

        // arrange
        final overlappingFridayRecurring = Activity.createNew(
          title: 'title',
          startTime: startTime,
          duration: Duration(hours: 36),
          recurs: Recurs.monthly(29),
        );

        // act
        final thursdayResult =
            overlappingFridayRecurring.dayActivitiesForDay(thursday);
        final fridayResult =
            overlappingFridayRecurring.dayActivitiesForDay(friday);
        final saturdayResult =
            overlappingFridayRecurring.dayActivitiesForDay(saturday);
        final sundayResult =
            overlappingFridayRecurring.dayActivitiesForDay(sunday);
        final mondayResult =
            overlappingFridayRecurring.dayActivitiesForDay(monday);

        // assert
        expect(thursdayResult, isEmpty);
        expect(fridayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
        expect(
            saturdayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
        expect(sundayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
        expect(mondayResult, isEmpty);
      });

      test('yearly recurrance with 36 hours duration is true for 3 day', () {
        final startTime = DateTime(2010, 01, 01, 22, 00);
        final thursday = DateTime(2020, 05, 28);
        final friday = DateTime(2020, 05, 29);
        final saturday = DateTime(2020, 05, 30);
        final sunday = DateTime(2020, 05, 31);
        final monday = DateTime(2020, 06, 01);

        // arrange
        final overlappingFridayRecurring = Activity.createNew(
          title: 'title',
          startTime: startTime,
          duration: Duration(hours: 36),
          recurs: Recurs.yearly(friday),
        );

        // act
        final thursdayResult =
            overlappingFridayRecurring.dayActivitiesForDay(thursday);
        final fridayResult =
            overlappingFridayRecurring.dayActivitiesForDay(friday);
        final saturdayResult =
            overlappingFridayRecurring.dayActivitiesForDay(saturday);
        final sundayResult =
            overlappingFridayRecurring.dayActivitiesForDay(sunday);
        final mondayResult =
            overlappingFridayRecurring.dayActivitiesForDay(monday);

        // assert
        expect(thursdayResult, isEmpty);
        expect(fridayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
        expect(
            saturdayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
        expect(sundayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
        expect(mondayResult, isEmpty);
      });

      test(
          'recurrance spanning over midnight two days in a row should show up twice',
          () {
        final startTime = DateTime(2010, 01, 01, 21, 00);
        final wednesday = DateTime(2020, 05, 27);
        final thursday = DateTime(2020, 05, 28);

        // arrange
        final overlappingFridayRecurring = Activity.createNew(
          title: 'title',
          startTime: startTime,
          duration: Duration(hours: 12),
          recurs: Recurs.everyDay,
        );

        // act
        final thursdayResult =
            overlappingFridayRecurring.dayActivitiesForDay(thursday);

        // assert
        expect(
            thursdayResult,
            containsAll([
              ActivityDay(overlappingFridayRecurring, wednesday),
              ActivityDay(overlappingFridayRecurring, thursday),
            ]));
      });

      test(
          'recurrance spanning over midnight two days in a row should show up twice',
          () {
        final startTime = DateTime(2010, 01, 01, 21, 00);
        final wednesday = DateTime(2020, 05, 27);
        final thursday = DateTime(2020, 05, 28);
        final friday = DateTime(2020, 05, 29);
        final saturday = DateTime(2020, 05, 30);
        final sunday = DateTime(2020, 05, 31);
        final monday = DateTime(2020, 06, 01);

        // arrange
        final overlappingFridayRecurring = Activity.createNew(
          title: 'title',
          startTime: startTime,
          duration: Duration(hours: 36),
          recurs: Recurs.everyDay,
        );

        // act
        final fridayResult =
            overlappingFridayRecurring.dayActivitiesForDay(friday);
        final saturdayResult =
            overlappingFridayRecurring.dayActivitiesForDay(saturday);
        final sundayResult =
            overlappingFridayRecurring.dayActivitiesForDay(sunday);
        final mondayResult =
            overlappingFridayRecurring.dayActivitiesForDay(monday);

        // assert
        expect(
            fridayResult,
            containsAll([
              ActivityDay(overlappingFridayRecurring, wednesday),
              ActivityDay(overlappingFridayRecurring, thursday),
              ActivityDay(overlappingFridayRecurring, friday),
            ]));
        expect(
            saturdayResult,
            containsAll([
              ActivityDay(overlappingFridayRecurring, thursday),
              ActivityDay(overlappingFridayRecurring, friday),
              ActivityDay(overlappingFridayRecurring, saturday),
            ]));
        expect(
            sundayResult,
            containsAll([
              ActivityDay(overlappingFridayRecurring, friday),
              ActivityDay(overlappingFridayRecurring, saturday),
              ActivityDay(overlappingFridayRecurring, sunday),
            ]));
        expect(
            mondayResult,
            containsAll([
              ActivityDay(overlappingFridayRecurring, saturday),
              ActivityDay(overlappingFridayRecurring, sunday),
              ActivityDay(overlappingFridayRecurring, monday),
            ]));
      });
    });
  });

  group('Recurring tests', () {
    group('Recurring factories', () {
      test('Yearly', () {
        final expected = Recurs.raw(Recurs.TYPE_YEARLY, 1124, Recurs.NO_END);
        final yearly = Recurs.yearly(DateTime(2000, 12, 24));
        expect(yearly, expected);
      });

      test('Monthly', () {
        final expected = Recurs.raw(Recurs.TYPE_MONTHLY, 8, Recurs.NO_END);
        final monthly = Recurs.monthly(4);
        expect(monthly, expected);
      });

      test('Monthly on days', () {
        final expected = Recurs.raw(Recurs.TYPE_MONTHLY, 523, Recurs.NO_END);
        final monthly = Recurs.monthlyOnDays([1, 2, 4, 10]);
        expect(monthly, expected);

        final expected2 = Recurs.raw(Recurs.TYPE_MONTHLY, 3, Recurs.NO_END);
        final monthly2 = Recurs.monthlyOnDays([1, 2]);
        expect(monthly2, expected2);
      });

      test('Weekly', () {
        final expected = Recurs.raw(Recurs.TYPE_WEEKLY, 129, Recurs.NO_END);
        final weekly = Recurs.weeklyOnDay(1);
        expect(weekly, expected);
      });

      test('Weekly on days', () {
        final expected = Recurs.raw(Recurs.TYPE_WEEKLY, 903, Recurs.NO_END);
        final weekly = Recurs.weeklyOnDays([1, 2, 3]);
        expect(weekly, expected);
      });

      test('Weekly on days', () {
        final expected = Recurs.raw(Recurs.TYPE_WEEKLY, 1, Recurs.NO_END);
        final weekly = Recurs.biWeeklyOnDays(evens: [1]);
        expect(weekly, expected);

        final expected2 = Recurs.raw(Recurs.TYPE_WEEKLY, 32, Recurs.NO_END);
        final weekly2 = Recurs.biWeeklyOnDays(evens: [6]);
        expect(weekly2, expected2);

        final expected3 = Recurs.raw(Recurs.TYPE_WEEKLY, 129, Recurs.NO_END);
        final weekly3 = Recurs.biWeeklyOnDays(evens: [1], odds: [1]);
        expect(weekly3, expected3);
      });

      test('Recurring end from Handi 9223372036854775807 is limited to NO_END',
          () {
        final handiEnd = 9223372036854775807;
        final handiRecur = Recurs.raw(Recurs.TYPE_WEEKLY, 129, handiEnd);
        expect(handiRecur.endTime, Recurs.NO_END);
      });
    });
    group('onCorrectYearsDay', () {
      test('-1 is not a correct day of the year', () {
        // arrange
        final rec = Recurs.raw(Recurs.TYPE_YEARLY, -1, Recurs.NO_END);
        final start = DateTime(1999, 12, 12);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, false);
      });

      test('onCorrectYearsDay christmas day', () {
        // arrange
        final rec = Recurs.raw(Recurs.TYPE_YEARLY, 1124, Recurs.NO_END);
        final start = DateTime(1999, 12, 24);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, true);
      });

      test('onCorrectYearsDay new years day', () {
        // arrange
        final recurrentData = 1;
        final rec =
            Recurs.raw(Recurs.TYPE_YEARLY, recurrentData, Recurs.NO_END);
        final start = DateTime(2000, 01, 01);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, true);
      });

      test('onCorrectYearsDay midsummer day', () {
        // arrange
        final recurrentData = 0521;
        final rec =
            Recurs.raw(Recurs.TYPE_YEARLY, recurrentData, Recurs.NO_END);
        final start = DateTime(2000, 06, 21);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, true);
      });

      test('onCorrectYearsDay day after midsummer day is not midsummer day',
          () {
        // arrange
        final recurrentData = 0521;
        final rec =
            Recurs.raw(Recurs.TYPE_YEARLY, recurrentData, Recurs.NO_END);
        final start = DateTime(2000, 06, 22);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, false);
      });

      test('onCorrectYearsDay midsummer 2500', () {
        // arrange
        final recurrentData = 0521;
        final rec =
            Recurs.raw(Recurs.TYPE_YEARLY, recurrentData, Recurs.NO_END);
        final start = DateTime(2500, 06, 21);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, true);
      });
    });

    group('on correct month day', () {
      test('onCorrectMonthDay first day of month', () {
        // arrange
        final recurrentData = Recurs.onDayOfMonth(1);
        final rec =
            Recurs.raw(Recurs.TYPE_MONTHLY, recurrentData, Recurs.NO_END);
        final start = DateTime(2020, 06, 01);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, true);
      });

      test('onCorrectMonthDay not first day of month', () {
        // arrange
        final recurrentData = Recurs.onDayOfMonth(1);
        final rec =
            Recurs.raw(Recurs.TYPE_MONTHLY, recurrentData, Recurs.NO_END);
        final start = DateTime(2020, 06, 02);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, false);
      });

      test('onCorrectMonthDay second day of month', () {
        // arrange
        final recurrentData = Recurs.onDayOfMonth(2);
        final rec =
            Recurs.raw(Recurs.TYPE_MONTHLY, recurrentData, Recurs.NO_END);
        final start = DateTime(2020, 06, 02);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, true);
      });

      test('onCorrectMonthDay second day of month ignores other', () {
        // arrange
        final recurrentData = Recurs.onDayOfMonth(2);
        final rec =
            Recurs.raw(Recurs.TYPE_MONTHLY, recurrentData, Recurs.NO_END);
        final start = DateTime(2020, 01, 02, 20, 20, 20, 20);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, true);
      });

      test('onCorrectMonthDay third day of month', () {
        // arrange
        final recurrentData = Recurs.onDayOfMonth(3);
        final rec =
            Recurs.raw(Recurs.TYPE_MONTHLY, recurrentData, Recurs.NO_END);
        final start = DateTime(2020, 01, 03);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, true);
      });

      test('onCorrectMonthDay 10th day of month', () {
        // arrange
        final recurrentData = Recurs.onDayOfMonth(10);
        final rec =
            Recurs.raw(Recurs.TYPE_MONTHLY, recurrentData, Recurs.NO_END);
        final start = DateTime(2011, 11, 10);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, true);
      });

      test('onCorrectMonthDay 1st, 2nd, 3rd and 10th day of month', () {
        // arrange
        final recurrentData = Recurs.onDaysOfMonth([1, 2, 3, 10]);
        final rec =
            Recurs.raw(Recurs.TYPE_MONTHLY, recurrentData, Recurs.NO_END);
        final first = DateTime(2011, 11, 1);
        final second = DateTime(2011, 11, 2);
        final third = DateTime(2011, 11, 3);
        final fourth = DateTime(2011, 11, 4);
        final tenth = DateTime(2011, 11, 10);
        // act
        final firstResult = rec.recursOnDay(first);
        final secondResult = rec.recursOnDay(second);
        final thirdResult = rec.recursOnDay(third);
        final fourthResult = rec.recursOnDay(fourth);
        final tenthResult = rec.recursOnDay(tenth);
        // assert
        expect(firstResult, true);
        expect(secondResult, true);
        expect(thirdResult, true);
        expect(fourthResult, false);
        expect(tenthResult, true);
      });

      test('onCorrectMonthDay all day of month', () {
        // arrange
        final recurrentData = 0x7FFFFFFF;
        final rec =
            Recurs.raw(Recurs.TYPE_MONTHLY, recurrentData, Recurs.NO_END);
        final dates = List.generate(31, (i) => DateTime(2020, 10, i + 1));
        // act
        final result = dates.every((d) => rec.recursOnDay(d));
        // assert
        expect(result, true);
      });

      test('onCorrectMonthDay no day of month', () {
        // arrange
        final recurrentData = 0x0;
        final rec =
            Recurs.raw(Recurs.TYPE_MONTHLY, recurrentData, Recurs.NO_END);
        final dates = List.generate(31, (i) => DateTime(2020, 10, i + 1));
        // act
        final result = dates.any((d) => rec.recursOnDay(d));
        // assert
        expect(result, false);
      });

      test('onCorrectMonthDay one day of month', () {
        // arrange
        final recurrentData = Recurs.onDayOfMonth(5);
        final rec =
            Recurs.raw(Recurs.TYPE_MONTHLY, recurrentData, Recurs.NO_END);
        final dates = List.generate(31, (i) => DateTime(2020, 10, i + 1));
        // act
        final results = dates.map((d) => rec.recursOnDay(d));
        final correctDays = results.where((b) => b).length;
        // assert
        expect(correctDays, 1);
      });

      test('onCorrectMonthDay day 1 and day 2', () {
        // arrange
        final day1 = DateTime(2001, 01, 01, 01, 01);
        final day2 = DateTime(2002, 02, 02, 02, 02);
        final day3 = DateTime(2003, 03, 03, 03, 03);
        final day4 = DateTime(2004, 04, 04, 04, 04);
        final days = [day1.day, day2.day];
        final recurrentData = Recurs.onDaysOfMonth(days);
        final rec =
            Recurs.raw(Recurs.TYPE_MONTHLY, recurrentData, Recurs.NO_END);
        // act
        final results1 = rec.recursOnDay(day1);
        final results2 = rec.recursOnDay(day2);
        final results3 = rec.recursOnDay(day3);
        final results4 = rec.recursOnDay(day4);

        // assert
        expect(results1, isTrue);
        expect(results2, isTrue);
        expect(results3, isFalse);
        expect(results4, isFalse);
      });
    });
    group('on correct week day', () {
      test('All weekdays, monday is true', () {
        // arrange
        final recurrentData = Recurs.allWeekdays;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final evenWeekMonday = DateTime(2019, 11, 25);

        // act
        final correctDays = rec.recursOnDay(evenWeekMonday);
        // assert
        expect(correctDays, true);
      });

      test('All weekdays, sunday is false', () {
        // arrange
        final recurrentData = Recurs.allWeekdays;
        final evenWeekMonday = DateTime(2019, 11, 24);
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        // act
        final correctDays = rec.recursOnDay(evenWeekMonday);
        // assert
        expect(correctDays, false);
      });

      test('All weekdays, correct for whole month', () {
        // arrange
        final recurrentData = Recurs.allWeekdays;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final dates = List.generate(31, (i) => DateTime(2020, 10, i + 1));
        // act
        final correctDays =
            dates.every((d) => rec.recursOnDay(d) != (d.weekday > 5));
        // assert
        expect(correctDays, true);
      });

      test('Even monday is true', () {
        // arrange
        final recurrentData = Recurs.EVEN_MONDAY;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final evenWeekMonday = DateTime(2019, 11, 25);

        // act
        final correctDays = rec.recursOnDay(evenWeekMonday);
        // assert
        expect(correctDays, true);
      });

      test('Odd monday is false', () {
        // arrange
        final recurrentData = Recurs.EVEN_MONDAY;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final evenWeekMonday = DateTime(2019, 11, 18);

        // act
        final correctDays = rec.recursOnDay(evenWeekMonday);
        // assert
        expect(correctDays, false);
      });

      test('Odd and even Monday is true', () {
        // arrange
        final recurrentData = Recurs.EVEN_MONDAY | Recurs.ODD_MONDAY;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final evenWeekMonday = DateTime(2019, 11, 18);

        // act
        final correctDays = rec.recursOnDay(evenWeekMonday);
        // assert
        expect(correctDays, true);
      });

      test('Monday is true all year', () {
        // arrange
        final recurrentData = Recurs.EVEN_MONDAY | Recurs.ODD_MONDAY;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final dates = List.generate(2000, (i) => DateTime(2020, 01, i + 1));
        // act
        final correctDays =
            dates.every((d) => rec.recursOnDay(d) != (d.weekday != 1));
        // assert
        expect(correctDays, true);
      });

      test('Not sunday is true all year', () {
        // arrange
        final recurrentData = Recurs.EVEN_MONDAY | Recurs.ODD_MONDAY;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final dates = List.generate(2000, (i) => DateTime(2020, 01, i + 1));
        // act
        final correctDays =
            dates.every((d) => rec.recursOnDay(d) != (d.weekday != 1));
        // assert
        expect(correctDays, true);
      });

      test('Odd fridays', () {
        // arrange
        final recurrentData = Recurs.ODD_FRIDAY;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final anOddFriday = DateTime(2019, 11, 22);
        // act
        final result = rec.recursOnDay(anOddFriday);
        // assert
        expect(result, true);
      });

      test('Odd fridays 2', () {
        // arrange
        final recurrentData = Recurs.ODD_FRIDAY;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final anOddFriday = DateTime(2019, 11, 29);
        // act
        final result = rec.recursOnDay(anOddFriday);
        // assert
        expect(result, false);
      });

      test('Even weekdays', () {
        // arrange
        final recurrentData = Recurs.EVEN_MONDAY |
            Recurs.EVEN_TUESDAY |
            Recurs.EVEN_WEDNESDAY |
            Recurs.EVEN_THURSDAY |
            Recurs.EVEN_FRIDAY;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final twoWeeks = List.generate(14, (i) => DateTime(2019, 11, 25 + i));
        // act
        final correctDays = twoWeeks.takeWhile((d) => rec.recursOnDay(d));
        final incorrects =
            twoWeeks.reversed.takeWhile((d) => !rec.recursOnDay(d));
        // assert
        expect(correctDays.length, 5);
        expect(incorrects.length, 9);
      });

      test('saturdays week 53 time is odd', () {
        // arrange
        final recurrentData = Recurs.ODD_SATURDAY;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final saturDayWeek53 = DateTime(2021, 01, 02);
        // act
        final correctDays = rec.recursOnDay(saturDayWeek53);
        // assert
        expect(correctDays, true);
      });

      test('saturdays 11th april is odd', () {
        // arrange
        final recurrentData = Recurs.ODD_SATURDAY;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final april11th = DateTime(2020, 04, 11);
        // act
        final result = rec.recursOnDay(april11th);
        // assert
        expect(result, true);
      });

      test(
          'every other saturdays for until there is a week 53 then two in a row then every other again',
          () {
        // arrange
        final recurrentData = Recurs.ODD_SATURDAY;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final twoWeeks =
            List.generate(29, (i) => DateTime(2019, 11, 23 + (i * 14)))
              ..add(DateTime(2021, 01, 02))
              ..addAll(
                  List.generate(150, (i) => DateTime(2021, 01, 09 + (i * 14))));
        // act
        final correctDays = twoWeeks.every((d) => rec.recursOnDay(d));
        // assert
        expect(correctDays, true);
      });

      test(
          'every other saturdays for until there is a week 53 then nothing for two weeks then every other again',
          () {
        // arrange
        final recurrentData = Recurs.EVEN_SATURDAY;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final twoWeeks =
            List.generate(29, (i) => DateTime(2019, 11, 30 + (i * 14)))
              ..addAll(
                  List.generate(150, (i) => DateTime(2021, 01, 16 + (i * 14))));
        // act
        final correctDays = twoWeeks.every((d) => rec.recursOnDay(d));
        // assert
        expect(correctDays, true);
      });

      test('everyDay is always true', () {
        // arrange
        final recurrentData = Recurs.allDaysOfWeek;
        final rec =
            Recurs.raw(Recurs.TYPE_WEEKLY, recurrentData, Recurs.NO_END);
        final loadsOfDays =
            List.generate(3333, (i) => DateTime(2019, 01, 01 + i));
        // act
        final allCorrect = loadsOfDays.every((d) => rec.recursOnDay(d));
        // assert
        expect(allCorrect, true);
      });
    });

    group('Recurs monthly', () {
      test('on day 1', () {
        // arrange
        final day1 = DateTime(2001, 01, 01, 01, 01);

        final days = [day1.day];
        final monthDays = Recurs.monthlyOnDays(days);
        final recurrentData = Recurs.onDaysOfMonth(days);

        // assert
        expect(monthDays.data, recurrentData);
      });

      test('on day 2', () {
        // arrange
        final day2 = DateTime(2002, 02, 02, 02, 02);

        final days = [day2.day];
        final monthDays = Recurs.monthlyOnDays(days);
        final recurrentData = Recurs.onDaysOfMonth(days);

        // assert
        expect(monthDays.data, recurrentData);
      });

      test('on day 1 and 2', () {
        // arrange
        final day1 = DateTime(2001, 01, 01, 01, 01);
        final day2 = DateTime(2002, 02, 02, 02, 02);
        final days = [day1.day, day2.day];
        final monthDays = Recurs.monthlyOnDays(days);
        final recurrentData = Recurs.onDaysOfMonth(days);

        // assert
        expect(monthDays.data, recurrentData);
      });
      test('on all days', () {
        // arrange
        final days = List.generate(31, (day) => day + 1);
        final monthDays = Recurs.monthlyOnDays(days);
        final recurrentData = Recurs.onDaysOfMonth(days);

        // assert
        expect(monthDays.data, recurrentData);
      });
    });
    group('Recurs weekly', () {
      test('on mondays', () {
        // arrange
        final days = [DateTime.monday];
        final monthDays = Recurs.weeklyOnDays(days);
        final recurrentData = Recurs.onDaysOfWeek(days);

        // assert
        expect(monthDays.data, recurrentData);
        expect(recurrentData, Recurs.MONDAY);
      });

      test('on tuesday', () {
        // arrange

        final days = [DateTime.tuesday];
        final monthDays = Recurs.weeklyOnDays(days);
        final recurrentData = Recurs.onDaysOfWeek(days);

        // assert
        expect(monthDays.data, recurrentData);
      });

      test('on odd monday and tuesday', () {
        // arrange
        final odds = [DateTime.monday, DateTime.tuesday];
        final monthDays = Recurs.biWeeklyOnDays(odds: odds);
        final recurrentData = Recurs.biWeekly(odds: odds);

        // assert
        expect(monthDays.data, recurrentData);
      });

      test('on day 1 and 2', () {
        // arrange
        final day1 = DateTime(2001, 01, 01, 01, 01);
        final day2 = DateTime(2002, 02, 02, 02, 02);
        final days = [day1.weekday, day2.weekday];
        final monthDays = Recurs.weeklyOnDays(days);
        final recurrentData = Recurs.onDaysOfWeek(days);

        // assert
        expect(monthDays.data, recurrentData);
      });

      test('on all days', () {
        // arrange
        final days = List.generate(7, (day) => day + 1);
        final monthDays = Recurs.weeklyOnDays(days);
        final recurrentData = Recurs.onDaysOfWeek(days);

        // assert
        expect(monthDays.data, recurrentData);
        expect(recurrentData, Recurs.allDaysOfWeek);
      });

      test('on all even week days', () {
        // arrange
        final days = List.generate(5, (day) => day + 1);
        final monthDays = Recurs.biWeeklyOnDays(evens: days);

        // assert
        expect(monthDays.data, Recurs.evenWeekdays);
      });
    });

    group('monthDays', () {
      test('wrong type year return empty list', () {
        // arrange
        final yearly = Recurs.yearly(DateTime(1111, 11, 11, 11, 11));
        // assert
        expect(yearly.monthDays, []);
      });
      test('wrong type week return empty list', () {
        // arrange
        final weekly =
            Recurs.raw(Recurs.TYPE_WEEKLY, Recurs.allDaysOfWeek, null);
        // assert
        expect(weekly.monthDays, []);
      });
      test('wrong type none return empty list', () {
        // arrange
        final not = Recurs.not;
        // assert
        expect(not.monthDays, []);
      });

      test('on day 1', () {
        // arrange
        final monthDays = Recurs.monthly(1);
        // assert
        expect(monthDays.monthDays, [1]);
      });
      test('on day 2', () {
        // arrange
        final monthDays = Recurs.monthly(2);
        // assert
        expect(monthDays.monthDays, [2]);
      });
      test('on day 1 and 2', () {
        // arrange
        final day1 = DateTime(2001, 01, 01, 01, 01);
        final day2 = DateTime(2002, 02, 02, 02, 02);
        final days = [day1.day, day2.day];
        final monthDays = Recurs.monthlyOnDays(days);

        // assert
        expect(monthDays.monthDays, days);
      });
      test('on day all days', () {
        // arrange
        final days = List.generate(31, (index) => index + 1);
        final monthDays = Recurs.monthlyOnDays(days);
        // assert
        expect(monthDays.monthDays, days);
      });
      test('on  all days from month', () {
        // arrange
        final days = List.generate(31, (index) => DateTime(2000, 12, index + 1))
            .map((e) => e.day)
            .toList();
        final monthDays = Recurs.monthlyOnDays(days);
        // assert
        expect(monthDays.monthDays, days);
      });
    });

    group('weekDays', () {
      test('wrong type year return empty list', () {
        // arrange
        final yearly = Recurs.yearly(DateTime(1111, 11, 11, 11, 11));
        // assert
        expect(yearly.weekDays, []);
      });
      test('wrong type monthly return empty list', () {
        // arrange
        final monthly = Recurs.monthly(Recurs.allDaysOfWeek);
        // assert
        expect(monthly.weekDays, []);
      });
      test('wrong type none return empty list', () {
        // arrange
        final not = Recurs.not;
        // assert
        expect(not.weekDays, []);
      });

      test('on monday', () {
        // arrange
        final monthDays = Recurs.weeklyOnDay(DateTime.monday);
        // assert
        expect(monthDays.weekDays, [DateTime.monday]);
      });

      test('on tuesday', () {
        // arrange
        final monthDays = Recurs.weeklyOnDay(DateTime.tuesday);
        // assert
        expect(monthDays.weekDays, [DateTime.tuesday]);
      });

      test('on day monday and tuesday', () {
        // arrange
        final days = [DateTime.monday, DateTime.tuesday];
        final monthDays = Recurs.weeklyOnDays(days);

        // assert
        expect(monthDays.weekDays, days);
      });

      test('on day all weekdays', () {
        // arrange
        final days = [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        ];
        final monthDays = Recurs.weeklyOnDays(days);
        // assert
        expect(monthDays.weekDays, days);
      });

      test('on all days dateTime', () {
        // arrange
        final days = List.generate(7, (index) => DateTime(2000, 12, index + 1))
            .map((e) => e.weekday)
            .toList();
        final monthDays = Recurs.weeklyOnDays(days);
        // assert
        expect(monthDays.weekDays, unorderedEquals(days));
      });
    });
  });
}
