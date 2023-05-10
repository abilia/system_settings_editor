import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/models/all.dart';

void main() {
  group('Recurring tests', () {
    group('Recurring factories', () {
      test('Yearly', () {
        const expected =
            Recurs.raw(Recurs.typeYearly, 1124, TimeInterval.noEnd);
        final yearly = Recurs.yearly(DateTime(2000, 12, 24));
        expect(yearly, expected);
      });

      test('Monthly', () {
        const expected = Recurs.raw(Recurs.typeMonthly, 8, TimeInterval.noEnd);
        final monthly = Recurs.monthly(4);
        expect(monthly, expected);
      });

      test('Monthly on days', () {
        const expected =
            Recurs.raw(Recurs.typeMonthly, 523, TimeInterval.noEnd);
        final monthly = Recurs.monthlyOnDays(const [1, 2, 4, 10]);
        expect(monthly, expected);

        const expected2 = Recurs.raw(Recurs.typeMonthly, 3, TimeInterval.noEnd);
        final monthly2 = Recurs.monthlyOnDays(const [1, 2]);
        expect(monthly2, expected2);
      });

      test('Weekly', () {
        const expected = Recurs.raw(Recurs.typeWeekly, 129, TimeInterval.noEnd);
        final weekly = Recurs.weeklyOnDay(1);
        expect(weekly, expected);
      });

      test('Weekly on days 1,2,3', () {
        const expected = Recurs.raw(Recurs.typeWeekly, 903, TimeInterval.noEnd);
        final weekly = Recurs.weeklyOnDays(const [1, 2, 3]);
        expect(weekly, expected);
      });

      test('Biweekly on days', () {
        const expected = Recurs.raw(Recurs.typeWeekly, 1, TimeInterval.noEnd);
        final weekly = Recurs.biWeeklyOnDays(evens: const [1]);
        expect(weekly, expected);

        const expected2 = Recurs.raw(Recurs.typeWeekly, 32, TimeInterval.noEnd);
        final weekly2 = Recurs.biWeeklyOnDays(evens: const [6]);
        expect(weekly2, expected2);

        const expected3 =
            Recurs.raw(Recurs.typeWeekly, 129, TimeInterval.noEnd);
        final weekly3 =
            Recurs.biWeeklyOnDays(evens: const [1], odds: const [1]);
        expect(weekly3, expected3);
      });

      test('Recurring end from Handi 9223372036854775807 is limited to NO_END',
          () {
        const handiEnd = 9223372036854775807;
        const handiRecur = Recurs.raw(Recurs.typeWeekly, 129, handiEnd);
        expect(handiRecur.endTime, TimeInterval.noEnd);
      });
    });
    group('onCorrectYearsDay', () {
      test('-1 is not a correct day of the year', () {
        // arrange
        const rec = Recurs.raw(Recurs.typeYearly, -1, TimeInterval.noEnd);
        final start = DateTime(1999, 12, 12);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, false);
      });

      test('onCorrectYearsDay christmas day', () {
        // arrange
        const rec = Recurs.raw(Recurs.typeYearly, 1124, TimeInterval.noEnd);
        final start = DateTime(1999, 12, 24);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, true);
      });

      test('onCorrectYearsDay new years day', () {
        // arrange
        const recurrentData = 1;
        const rec =
            Recurs.raw(Recurs.typeYearly, recurrentData, TimeInterval.noEnd);
        final start = DateTime(2000, 01, 01);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, true);
      });

      test('onCorrectYearsDay midsummer day', () {
        // arrange
        const recurrentData = 0521;
        const rec =
            Recurs.raw(Recurs.typeYearly, recurrentData, TimeInterval.noEnd);
        final start = DateTime(2000, 06, 21);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, true);
      });

      test('onCorrectYearsDay day after midsummer day is not midsummer day',
          () {
        // arrange
        const recurrentData = 0521;
        const rec =
            Recurs.raw(Recurs.typeYearly, recurrentData, TimeInterval.noEnd);
        final start = DateTime(2000, 06, 22);
        // act
        final result = rec.recursOnDay(start);
        // assert
        expect(result, false);
      });

      test('onCorrectYearsDay midsummer 2500', () {
        // arrange
        const recurrentData = 0521;
        const rec =
            Recurs.raw(Recurs.typeYearly, recurrentData, TimeInterval.noEnd);
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
            Recurs.raw(Recurs.typeMonthly, recurrentData, TimeInterval.noEnd);
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
            Recurs.raw(Recurs.typeMonthly, recurrentData, TimeInterval.noEnd);
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
            Recurs.raw(Recurs.typeMonthly, recurrentData, TimeInterval.noEnd);
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
            Recurs.raw(Recurs.typeMonthly, recurrentData, TimeInterval.noEnd);
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
            Recurs.raw(Recurs.typeMonthly, recurrentData, TimeInterval.noEnd);
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
            Recurs.raw(Recurs.typeMonthly, recurrentData, TimeInterval.noEnd);
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
            Recurs.raw(Recurs.typeMonthly, recurrentData, TimeInterval.noEnd);
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
        const recurrentData = 0x7FFFFFFF;
        const rec =
            Recurs.raw(Recurs.typeMonthly, recurrentData, TimeInterval.noEnd);
        final dates = List.generate(31, (i) => DateTime(2020, 10, i + 1));
        // act
        final result = dates.every((d) => rec.recursOnDay(d));
        // assert
        expect(result, true);
      });

      test('onCorrectMonthDay no day of month', () {
        // arrange
        const recurrentData = 0x0;
        const rec =
            Recurs.raw(Recurs.typeMonthly, recurrentData, TimeInterval.noEnd);
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
            Recurs.raw(Recurs.typeMonthly, recurrentData, TimeInterval.noEnd);
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
            Recurs.raw(Recurs.typeMonthly, recurrentData, TimeInterval.noEnd);
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
        const recurrentData = Recurs.allWeekdays;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
        final evenWeekMonday = DateTime(2019, 11, 25);

        // act
        final correctDays = rec.recursOnDay(evenWeekMonday);
        // assert
        expect(correctDays, true);
      });

      test('All weekdays, sunday is false', () {
        // arrange
        const recurrentData = Recurs.allWeekdays;
        final evenWeekMonday = DateTime(2019, 11, 24);
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
        // act
        final correctDays = rec.recursOnDay(evenWeekMonday);
        // assert
        expect(correctDays, false);
      });

      test('All weekdays, correct for whole month', () {
        // arrange
        const recurrentData = Recurs.allWeekdays;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
        final dates = List.generate(31, (i) => DateTime(2020, 10, i + 1));
        // act
        final correctDays =
            dates.every((d) => rec.recursOnDay(d) != (d.weekday > 5));
        // assert
        expect(correctDays, true);
      });

      test('Even monday is true', () {
        // arrange
        const recurrentData = Recurs.evenMonday;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
        final evenWeekMonday = DateTime(2019, 11, 25);

        // act
        final correctDays = rec.recursOnDay(evenWeekMonday);
        // assert
        expect(correctDays, true);
      });

      test('Odd monday is false', () {
        // arrange
        const recurrentData = Recurs.evenMonday;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
        final evenWeekMonday = DateTime(2019, 11, 18);

        // act
        final correctDays = rec.recursOnDay(evenWeekMonday);
        // assert
        expect(correctDays, false);
      });

      test('Odd and even Monday is true', () {
        // arrange
        const recurrentData = Recurs.evenMonday | Recurs.oddMonday;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
        final evenWeekMonday = DateTime(2019, 11, 18);

        // act
        final correctDays = rec.recursOnDay(evenWeekMonday);
        // assert
        expect(correctDays, true);
      });

      test('Monday is true all year', () {
        // arrange
        const recurrentData = Recurs.evenMonday | Recurs.oddMonday;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
        final dates = List.generate(2000, (i) => DateTime(2020, 01, i + 1));
        // act
        final correctDays =
            dates.every((d) => rec.recursOnDay(d) != (d.weekday != 1));
        // assert
        expect(correctDays, true);
      });

      test('Not sunday is true all year', () {
        // arrange
        const recurrentData = Recurs.evenMonday | Recurs.oddMonday;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
        final dates = List.generate(2000, (i) => DateTime(2020, 01, i + 1));
        // act
        final correctDays =
            dates.every((d) => rec.recursOnDay(d) != (d.weekday != 1));
        // assert
        expect(correctDays, true);
      });

      test('Odd fridays', () {
        // arrange
        const recurrentData = Recurs.oddFriday;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
        final anOddFriday = DateTime(2019, 11, 22);
        // act
        final result = rec.recursOnDay(anOddFriday);
        // assert
        expect(result, true);
      });

      test('Odd fridays 2', () {
        // arrange
        const recurrentData = Recurs.oddFriday;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
        final anOddFriday = DateTime(2019, 11, 29);
        // act
        final result = rec.recursOnDay(anOddFriday);
        // assert
        expect(result, false);
      });

      test('Even weekdays', () {
        // arrange
        const recurrentData = Recurs.evenMonday |
            Recurs.evenTuesday |
            Recurs.evenWednesday |
            Recurs.evenThursday |
            Recurs.evenFriday;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
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
        const recurrentData = Recurs.oddSaturday;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
        final saturDayWeek53 = DateTime(2021, 01, 02);
        // act
        final correctDays = rec.recursOnDay(saturDayWeek53);
        // assert
        expect(correctDays, true);
      });

      test('saturdays 11th april is odd', () {
        // arrange
        const recurrentData = Recurs.oddSaturday;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
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
        const recurrentData = Recurs.oddSaturday;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
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
        const recurrentData = Recurs.evenSaturday;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
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
        const recurrentData = Recurs.allDaysOfWeek;
        const rec =
            Recurs.raw(Recurs.typeWeekly, recurrentData, TimeInterval.noEnd);
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
        expect(recurrentData, Recurs.monday);
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
        const weekly =
            Recurs.raw(Recurs.typeWeekly, Recurs.allDaysOfWeek, null);
        // assert
        expect(weekly.monthDays, []);
      });
      test('wrong type none return empty list', () {
        // assert
        expect(Recurs.not.monthDays, []);
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

    group('weekdays', () {
      test('wrong type year return empty list', () {
        // arrange
        final yearly = Recurs.yearly(DateTime(1111, 11, 11, 11, 11));
        // assert
        expect(yearly.weekdays, []);
      });
      test('wrong type monthly return empty list', () {
        // arrange
        final monthly = Recurs.monthly(Recurs.allDaysOfWeek);
        // assert
        expect(monthly.weekdays, []);
      });
      test('wrong type none return empty list', () {
        // assert
        expect(Recurs.not.weekdays, []);
      });

      test('on monday', () {
        // arrange
        final monthDays = Recurs.weeklyOnDay(DateTime.monday);
        // assert
        expect(monthDays.weekdays, [DateTime.monday]);
      });

      test('on tuesday', () {
        // arrange
        final monthDays = Recurs.weeklyOnDay(DateTime.tuesday);
        // assert
        expect(monthDays.weekdays, [DateTime.tuesday]);
      });

      test('on day monday and tuesday', () {
        // arrange
        final days = [DateTime.monday, DateTime.tuesday];
        final monthDays = Recurs.weeklyOnDays(days);

        // assert
        expect(monthDays.weekdays, days);
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
        expect(monthDays.weekdays, days);
      });

      test('on all days dateTime', () {
        // arrange
        final days = List.generate(7, (index) => DateTime(2000, 12, index + 1))
            .map((e) => e.weekday)
            .toList();
        final monthDays = Recurs.weeklyOnDays(days);
        // assert
        expect(monthDays.weekdays, unorderedEquals(days));
      });
    });
  });
}
