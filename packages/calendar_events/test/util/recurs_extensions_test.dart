import 'package:calendar_events/calendar_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull_fakes/all.dart';
import 'package:utils/utils.dart';

void main() {
  group('Activities for 24h day', () {
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
          Recurs.typeWeekly,
          16383,
          splitEndTime.millisecondsSinceEpoch,
        ),
        // Weekly every day odd and even week
        alarmType: 104,
        // NO_ALARM
        duration: 86399999.milliseconds(),
        // 23:59:59.999000
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
        title: 'FullDay ',
        recurs: Recurs.everyDay,
        alarmType: 104,
        // NO_ALARM
        duration: 86399999.milliseconds(),
        // 23:59:59.999000
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
        'Activity with end time before start time does not shows ( bug SGC-148 )',
        () {
      // Arrange
      const splitStartTime = 1585735200000, splitEndTime = 1585605599999;

      final day = DateTime(2020, 04, 01);

      final splitRecurring = Activity.createNew(
        title: 'test',
        recurs: const Recurs.raw(
          Recurs.typeWeekly,
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
    test('FullDay', () {
      // Arrange
      final initialMinutes =
          DateTime(2006, 06, 06, 06, 06, 06, 06).onlyMinutes();
      final fullDayActivity = FakeActivity.fullDay(initialMinutes);
      final tomorrowFullDay =
          FakeActivity.fullDay(initialMinutes.add(1.days()));
      final yesterdayFullDay =
          FakeActivity.fullDay(initialMinutes.subtract(1.days()));

      final today = initialMinutes.onlyDays();
      final tomorrow = initialMinutes.nextDay().onlyDays();
      final yesterday = initialMinutes.previousDay().onlyDays();

      // Act
      final result1Day1 = fullDayActivity.dayActivitiesForDay(today);
      final result2Day1 = tomorrowFullDay.dayActivitiesForDay(today);
      final result3Day1 = yesterdayFullDay.dayActivitiesForDay(today);

      final result1Day2 = fullDayActivity.dayActivitiesForDay(tomorrow);
      final result2Day2 = tomorrowFullDay.dayActivitiesForDay(tomorrow);
      final result3Day2 = yesterdayFullDay.dayActivitiesForDay(tomorrow);

      final result1Day3 = fullDayActivity.dayActivitiesForDay(yesterday);
      final result2Day3 = tomorrowFullDay.dayActivitiesForDay(yesterday);
      final result3Day3 = yesterdayFullDay.dayActivitiesForDay(yesterday);

      // Assert
      expect(result1Day1, [ActivityDay(fullDayActivity, today)]);
      expect(result2Day1, isEmpty);
      expect(result3Day1, isEmpty);

      expect(result1Day2, isEmpty);
      expect(result2Day2, [ActivityDay(tomorrowFullDay, tomorrow)]);
      expect(result3Day2, isEmpty);

      expect(result1Day3, isEmpty);
      expect(result2Day3, isEmpty);
      expect(result3Day3, [ActivityDay(yesterdayFullDay, yesterday)]);
    });

    test('FullDay with duration should be ignored', () {
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
      test('weekly recurrence past midnight is true for next day', () {
        final startTime = DateTime(2010, 01, 01, 22, 00);
        final saturday = DateTime(2020, 05, 30);
        final friday = DateTime(2020, 05, 29);

        // arrange
        final overlappingFridayRecurring = Activity.createNew(
          title: 'title',
          startTime: startTime,
          duration: const Duration(hours: 4),
          recurs: Recurs.weeklyOnDay(DateTime.friday),
        );

        // act
        final result = overlappingFridayRecurring.dayActivitiesForDay(saturday);

        // assert
        expect(result, [ActivityDay(overlappingFridayRecurring, friday)]);
      });

      test('weekly recurrence with duration 36 hours is true for 3 day', () {
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
            duration: const Duration(hours: 36),
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

      test('monthly recurrence with 36 hours duration is true for 3 day', () {
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
          duration: const Duration(hours: 36),
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

      test('yearly recurrence with 36 hours duration is true for 3 day', () {
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
          duration: const Duration(hours: 36),
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
          'recurrence spanning over midnight '
          'two days in a row should show up twice 1', () {
        final startTime = DateTime(2010, 01, 01, 21, 00);
        final wednesday = DateTime(2020, 05, 27);
        final thursday = DateTime(2020, 05, 28);

        // arrange
        final overlappingFridayRecurring = Activity.createNew(
          title: 'title',
          startTime: startTime,
          duration: const Duration(hours: 12),
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
          'recurrence spanning over midnight '
          'two days in a row should show up twice 2', () {
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
          duration: const Duration(hours: 36),
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

    test('Split up activity shows on day it was split up on ( bug test )', () {
      final day = DateTime(2019, 11, 22);
      final test = Activity.createNew(
        title: 'Pre split Recurring fullDay ',
        startTime: DateTime(2019, 11, 12),
        duration: const Duration(
            hours: 23, minutes: 59, seconds: 59, milliseconds: 999),
        fullDay: true,
        recurs: Recurs.raw(
          Recurs.typeWeekly,
          Recurs.allDaysOfWeek,
          DateTime(2019, 11, 21, 23, 59, 59, 999).millisecondsSinceEpoch,
        ),
      );

      final result = test.dayActivitiesForDay(day);
      expect(result, isEmpty);
    });

    test('SGC-755 Activity spanning midnight shows up on correct days', () {
      // Arrange
      final day1 = DateTime(2021, 11, 08);
      final day2 = DateTime(2021, 11, 09);

      final day6 = DateTime(2021, 11, 13);
      final day7 = DateTime(2021, 11, 14);
      final day8 = DateTime(2021, 11, 15);
      final startTime = day1.add(const Duration(hours: 22));
      final spanningMidnightRecurring = Activity.createNew(
        title: 'spanning 00:00 recurring ',
        startTime: startTime,
        duration: const Duration(hours: 4),
        recurs: Recurs.everyDay.changeEnd(day7),
      );

      // Act
      final resultD1 = spanningMidnightRecurring.dayActivitiesForDay(day1);
      final resultD2 = spanningMidnightRecurring.dayActivitiesForDay(day2);
      final resultD7 = spanningMidnightRecurring.dayActivitiesForDay(day7);
      final resultD8 = spanningMidnightRecurring.dayActivitiesForDay(day8);

      // Assert
      expect(resultD1, [ActivityDay(spanningMidnightRecurring, day1)]);
      expect(resultD2, [
        ActivityDay(spanningMidnightRecurring, day2),
        ActivityDay(spanningMidnightRecurring, day1),
      ]);
      expect(resultD7, [
        ActivityDay(spanningMidnightRecurring, day7),
        ActivityDay(spanningMidnightRecurring, day6),
      ]);
      expect(resultD8, [ActivityDay(spanningMidnightRecurring, day7)]);
    });

    test('SGC-757 Activity starting at 00:00 without duration shows', () {
      // Arrange
      final day0 = DateTime(2021, 11, 04);
      final day1 = DateTime(2021, 11, 05);
      final day2 = DateTime(2021, 11, 06);
      final midnightRecurring = Activity.createNew(
        title: '00:00 recurring ',
        recurs: Recurs.everyDay,
        startTime: day0,
      );
      // Act
      final resultD0 = midnightRecurring.dayActivitiesForDay(day0);
      final resultD1 = midnightRecurring.dayActivitiesForDay(day1);
      final resultD2 = midnightRecurring.dayActivitiesForDay(day2);

      // Assert
      expect(resultD0, [ActivityDay(midnightRecurring, day0)]);
      expect(resultD1, [ActivityDay(midnightRecurring, day1)]);
      expect(resultD2, [ActivityDay(midnightRecurring, day2)]);
    });
  });
}
