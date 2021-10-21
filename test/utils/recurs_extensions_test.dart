import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  group('Activities for 24h day', () {
    group('Recurring activity', () {
      test('Split up activity shows on day it was split up on ( bug test )',
          () {
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
        const splitStartTime = 1585735200000, splitEndTime = 1585605599999;

        final day = DateTime(2020, 04, 01);

        final splitRecurring = Activity.createNew(
          title: 'test',
          recurs: Recurs.raw(
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
        final resultDay3 =
            fullDayActivity.dayActivitiesForDay(dayAfterTomorrow);

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
          final result =
              overlappingFridayRecurring.dayActivitiesForDay(saturday);

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
          expect(
              fridayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
          expect(saturdayResult,
              [ActivityDay(overlappingFridayRecurring, friday)]);
          expect(
              sundayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
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
          expect(
              fridayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
          expect(saturdayResult,
              [ActivityDay(overlappingFridayRecurring, friday)]);
          expect(
              sundayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
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
          expect(
              fridayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
          expect(saturdayResult,
              [ActivityDay(overlappingFridayRecurring, friday)]);
          expect(
              sundayResult, [ActivityDay(overlappingFridayRecurring, friday)]);
          expect(mondayResult, isEmpty);
        });

        test(
            'recurrance spanning over midnight two days in a row should show up twice 1',
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
            'recurrance spanning over midnight two days in a row should show up twice 2',
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
  });

  group('Activities for night span', () {
    group('bounderies', () {
      test('starting on night start', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);
        final start = day.add(dayParts.night);
        final activity = Activity.createNew(startTime: start);
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, [ActivityDay(activity, day)]);
      });

      test('starting on minute before night start', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);
        final start = day.add(dayParts.night).subtract(1.minutes());
        final activity = Activity.createNew(startTime: start);
        final res = activity.nightActivitiesForDay(day, dayParts);

        expect(res, isEmpty);
      });

      test('starting on minute before night start witht 2 min duration', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);
        final start = day.add(dayParts.night).subtract(1.minutes());
        final activity = Activity.createNew(
          startTime: start,
          duration: 2.minutes(),
        );
        final res = activity.nightActivitiesForDay(day, dayParts);

        expect(res, [ActivityDay(activity, day)]);
      });

      test('starting on morning start', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);
        final start = day.nextDay().add(dayParts.morning);
        final activity = Activity.createNew(startTime: start);
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, isEmpty);
      });

      test('starting 12 at day before, ends 12 day after included', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);
        final previusDay = day.previousDay();
        final start = previusDay.add(12.hours());
        final activity = Activity.createNew(
          startTime: start,
          duration: 24.hours(),
        );
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, [ActivityDay(activity, previusDay)]);
      });

      test('starting on minute before morning start ', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);
        final nextDay = day.nextDay();
        final start = nextDay.add(dayParts.morning).subtract(1.minutes());
        final activity = Activity.createNew(startTime: start);
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, [ActivityDay(activity, nextDay)]);
      });

      test('ending on night start', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);
        final duration = 30.minutes();
        final start = day.add(dayParts.night).subtract(duration);
        final activity = Activity.createNew(
          startTime: start,
          duration: duration,
        );
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, isEmpty);
      });

      test('ending on minute after night start', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);
        final duration = 30.minutes();
        final start =
            day.add(dayParts.night).subtract(duration).add(1.minutes());
        final activity = Activity.createNew(
          startTime: start,
          duration: duration,
        );
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, [ActivityDay(activity, day)]);
      });
      test('spanning past whole span', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);

        final start = day.add(dayParts.evening);
        final activity = Activity.createNew(
          startTime: start,
          duration: 24.hours(),
        );
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, [ActivityDay(activity, day)]);
      });
    });

    group('other DayParts', () {
      test('early night', () {
        final dayParts = DayParts(nightStart: DayParts.nightLimit.min);
        final day = DateTime(2021, 09, 03);
        final start = day.add(dayParts.night);
        final activity = Activity.createNew(startTime: start);
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, [ActivityDay(activity, day)]);
      });

      test('late night', () {
        final dayParts = DayParts(nightStart: DayParts.nightLimit.max);
        final day = DateTime(2021, 09, 03);
        final nextDay = day.nextDay();
        final start = day.add(dayParts.night);
        final activity1 = Activity.createNew(startTime: start);
        final activity2 = Activity.createNew(
          startTime: start.subtract(1.minutes()),
        );
        final res = activity1.nightActivitiesForDay(day, dayParts);
        expect(res, [ActivityDay(activity1, nextDay)]);
        final res2 = activity2.nightActivitiesForDay(day, dayParts);
        expect(res2, isEmpty);
      });

      test('early morning', () {
        final dayParts = DayParts(morningStart: DayParts.morningLimit.min);
        final day = DateTime(2021, 09, 03);
        final nextDay = day.nextDay();
        final start = nextDay.add(dayParts.morning);
        final activity = Activity.createNew(startTime: start);
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, isEmpty);

        final start2 = start.subtract(1.minutes());
        final activity2 = Activity.createNew(startTime: start2);
        final res2 = activity2.nightActivitiesForDay(day, dayParts);
        expect(res2, [ActivityDay(activity2, nextDay)]);
      });

      test('late morning', () {
        final dayParts = DayParts(
          morningStart: DayParts.morningLimit.max,
          dayStart: DayParts.dayDefault + Duration.millisecondsPerHour,
        );
        final day = DateTime(2021, 09, 03);
        final nextDay = day.nextDay();
        final start = nextDay.add(dayParts.morning);
        final activity = Activity.createNew(startTime: start);
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, isEmpty);

        final start2 = start.subtract(1.minutes());
        final activity2 = Activity.createNew(startTime: start2);
        final res2 = activity2.nightActivitiesForDay(day, dayParts);
        expect(res2, [ActivityDay(activity2, nextDay)]);
      });
    });

    group('fullday', () {
      test('on day ', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);
        final activity = Activity.createNew(
          startTime: day,
          duration: 24.hours() - 1.milliseconds(),
          fullDay: true,
        );
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, isEmpty);
      });

      test('on next day ', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);
        final nextDay = day.nextDay();
        final activity = Activity.createNew(
          startTime: nextDay,
          duration: 24.hours() - 1.milliseconds(),
          fullDay: true,
        );
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, isEmpty);
      });

      test('on day - recurring', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);
        final activity = Activity.createNew(
          startTime: day,
          duration: 24.hours() - 1.milliseconds(),
          fullDay: true,
          recurs: Recurs.everyDay,
        );
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, isEmpty);
      });

      test('on next day ', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);
        final nextDay = day.nextDay();
        final activity = Activity.createNew(
          startTime: nextDay,
          duration: 24.hours() - 1.milliseconds(),
          fullDay: true,
        );
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, isEmpty);
      });

      test('on next day - recurring', () {
        final dayParts = DayParts.standard();
        final day = DateTime(2021, 09, 03);
        final nextDay = day.nextDay();
        final activity = Activity.createNew(
          startTime: nextDay,
          duration: 24.hours() - 1.milliseconds(),
          fullDay: true,
          recurs: Recurs.everyDay,
        );
        final res = activity.nightActivitiesForDay(day, dayParts);
        expect(res, isEmpty);
      });
    });

    group('recurring', () {
      test(
          'Activity with endtime before start time does not shows ( bug SGC-148 )',
          () {
        final dayParts = DayParts.standard();
        // Arrange
        final splitStartTime = DateTime(2020, 04, 01, 23, 30, 00, 00);
        final splitEndTime = DateTime(2020, 03, 30, 23, 59, 59, 999);
        final day = DateTime(2020, 04, 01);

        final splitRecurring = Activity.createNew(
          title: 'test',
          recurs: Recurs.raw(
            Recurs.typeWeekly,
            16383,
            splitEndTime.millisecondsSinceEpoch,
          ),
          startTime: splitStartTime,
        );
        // Act
        final result = splitRecurring.nightActivitiesForDay(day, dayParts);

        // Assert
        expect(result, isEmpty);
      });

      group('bounderies', () {
        group('monthly', () {
          test('monthly on day before midnight', () {
            final dayParts = DayParts.standard();
            final day = DateTime(2021, 09, 03);
            final start = DateTime(2001, 01, 01).add(
              dayParts.night,
            );
            final activity = Activity.createNew(
              startTime: start,
              recurs: Recurs.monthly(day.day),
            );
            final res = activity.nightActivitiesForDay(day, dayParts);
            expect(res, [ActivityDay(activity, day)]);
          });

          test('monthly on day before midnight out of range', () {
            final dayParts = DayParts.standard();
            final day = DateTime(2021, 09, 03);
            final start = DateTime(2001, 01, 01)
                .add(
                  dayParts.night,
                )
                .subtract(1.minutes());
            final activity = Activity.createNew(
              startTime: start,
              recurs: Recurs.monthly(day.day),
            );
            final res = activity.nightActivitiesForDay(day, dayParts);
            expect(res, isEmpty);
          });

          test('monthly on day after midnight at 24', () {
            final dayParts = DayParts.standard();
            final day = DateTime(2021, 09, 03);
            final nextDay = day.nextDay();
            final start = DateTime(2001, 01, 01);
            final activity = Activity.createNew(
              startTime: start,
              recurs: Recurs.monthly(nextDay.day),
            );
            final res = activity.nightActivitiesForDay(day, dayParts);
            expect(res, [ActivityDay(activity, nextDay)]);
          });

          test('monthly on day after midnight when night starts at 24', () {
            final dayParts =
                DayParts(nightStart: 23 * Duration.millisecondsPerHour);
            final day = DateTime(2021, 09, 03);
            final nextDay = day.nextDay();
            final start = DateTime(2001, 01, 01);
            final activity = Activity.createNew(
              startTime: start,
              recurs: Recurs.monthly(nextDay.day),
            );
            final res = activity.nightActivitiesForDay(day, dayParts);
            expect(res, [ActivityDay(activity, nextDay)]);
          });

          test('monthly on day before midnight starts before ends in night',
              () {
            final dayParts = DayParts.standard();
            final day = DateTime(2021, 09, 03);
            final start = DateTime(2001, 01, 01)
                .add(
                  dayParts.night,
                )
                .subtract(30.minutes());
            final activity = Activity.createNew(
                startTime: start,
                recurs: Recurs.monthly(day.day),
                duration: 31.minutes());
            final res = activity.nightActivitiesForDay(day, dayParts);
            expect(res, [ActivityDay(activity, day)]);
          });

          test('monthly on day before midnight and spans over midnight', () {
            final dayParts = DayParts.standard();
            final day = DateTime(2021, 09, 03);
            final nextday = day.nextDay();
            final start = DateTime(2001, 01, 01)
                .add(dayParts.night)
                .subtract(30.minutes());

            final activity = Activity.createNew(
                startTime: start,
                recurs: Recurs.monthlyOnDays([day.day, nextday.day]),
                duration: 4.hours());

            final res = activity.nightActivitiesForDay(day, dayParts);
            expect(res, [ActivityDay(activity, day)]);
          });
        });

        group('weekly', () {
          test('start 12:00 end 12:00 next day recurs once', () {
            final dayParts = DayParts.standard();
            final day = DateTime(2021, 12, 12);

            final activity = Activity.createNew(
              startTime: DateTime(2020, 01, 01, 12),
              duration: 24.hours(),
              recurs: Recurs.everyDay,
            );
            final res = activity.nightActivitiesForDay(day, dayParts);
            expect(res, [
              ActivityDay(activity, day),
            ]);
          });

          test('start 00:00 end 24:00 next day recurs every day twice', () {
            final dayParts = DayParts.standard();
            final day = DateTime(2021, 12, 12);
            final previusDay = day.previousDay();
            final nextDay = day.nextDay();

            final activity = Activity.createNew(
              startTime: DateTime(2020),
              duration: 48.hours(),
              recurs: Recurs.everyDay,
            );
            final res = activity.nightActivitiesForDay(day, dayParts);
            expect(res, [
              ActivityDay(activity, previusDay),
              ActivityDay(activity, day),
              ActivityDay(activity, nextDay),
            ]);
          });
        });
      });
    });
  });
}
