import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks.dart';

void main() {
  MonthCalendarBloc monthCalendarBloc;
  ActivitiesBloc activitiesBloc;
  ClockBloc clockBloc;
  StreamController<DateTime> clock;
  final initial = DateTime(2021, 03, 19, 09, 45);

  setUp(() {
    clock = StreamController<DateTime>();
    clockBloc = ClockBloc(clock.stream, initialTime: initial);
    activitiesBloc = MockActivitiesBloc();
    when(activitiesBloc.state).thenReturn(ActivitiesLoaded([]));
  });

  group('Calendar days are correct', () {
    setUp(() {
      when(activitiesBloc.state).thenReturn(ActivitiesLoaded([]));
    });
    test('initial state basics', () {
      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);
      // Assert
      expect(
        monthCalendarBloc.state.firstDay,
        DateTime(2021, 03, 01),
      );
      expect(monthCalendarBloc.state.occasion, Occasion.current);
      expect(monthCalendarBloc.state.weeks.length, 5);
    });

    test('initial state correct', () {
      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Asserts
      expect(
        monthCalendarBloc.state,
        MonthCalendarState(
          firstDay: DateTime(2021, 03, 01),
          occasion: Occasion.current,
          weeks: [
            MonthWeek(
              9,
              [
                MonthDay(1, null, false, 0, Occasion.past),
                MonthDay(2, null, false, 0, Occasion.past),
                MonthDay(3, null, false, 0, Occasion.past),
                MonthDay(4, null, false, 0, Occasion.past),
                MonthDay(5, null, false, 0, Occasion.past),
                MonthDay(6, null, false, 0, Occasion.past),
                MonthDay(7, null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              10,
              [
                MonthDay(8, null, false, 0, Occasion.past),
                MonthDay(9, null, false, 0, Occasion.past),
                MonthDay(10, null, false, 0, Occasion.past),
                MonthDay(11, null, false, 0, Occasion.past),
                MonthDay(12, null, false, 0, Occasion.past),
                MonthDay(13, null, false, 0, Occasion.past),
                MonthDay(14, null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              11,
              [
                MonthDay(15, null, false, 0, Occasion.past),
                MonthDay(16, null, false, 0, Occasion.past),
                MonthDay(17, null, false, 0, Occasion.past),
                MonthDay(18, null, false, 0, Occasion.past),
                MonthDay(19, null, false, 0, Occasion.current),
                MonthDay(20, null, false, 0, Occasion.future),
                MonthDay(21, null, false, 0, Occasion.future),
              ],
            ),
            MonthWeek(
              12,
              [
                MonthDay(22, null, false, 0, Occasion.future),
                MonthDay(23, null, false, 0, Occasion.future),
                MonthDay(24, null, false, 0, Occasion.future),
                MonthDay(25, null, false, 0, Occasion.future),
                MonthDay(26, null, false, 0, Occasion.future),
                MonthDay(27, null, false, 0, Occasion.future),
                MonthDay(28, null, false, 0, Occasion.future),
              ],
            ),
            MonthWeek(
              13,
              [
                MonthDay(29, null, false, 0, Occasion.future),
                MonthDay(30, null, false, 0, Occasion.future),
                MonthDay(31, null, false, 0, Occasion.future),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
              ],
            ),
          ],
        ),
      );
    });

    test('next month correct, basic', () async {
      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Act
      monthCalendarBloc.add(GoToNextMonth());
      final state = await monthCalendarBloc.first;

      // Assert
      expect(
        state.firstDay,
        DateTime(2021, 04, 01),
      );
      expect(state.weeks.length, 5);
      expect(state.occasion, Occasion.future);
    });

    test('next month correct', () {
      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Act
      monthCalendarBloc.add(GoToNextMonth());

      // Assert
      expectLater(
        monthCalendarBloc,
        emits(
          MonthCalendarState(
            firstDay: DateTime(2021, 04, 01),
            occasion: Occasion.future,
            weeks: [
              MonthWeek(
                13,
                [
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  MonthDay(1, null, false, 0, Occasion.future),
                  MonthDay(2, null, false, 0, Occasion.future),
                  MonthDay(3, null, false, 0, Occasion.future),
                  MonthDay(4, null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                14,
                [
                  MonthDay(5, null, false, 0, Occasion.future),
                  MonthDay(6, null, false, 0, Occasion.future),
                  MonthDay(7, null, false, 0, Occasion.future),
                  MonthDay(8, null, false, 0, Occasion.future),
                  MonthDay(9, null, false, 0, Occasion.future),
                  MonthDay(10, null, false, 0, Occasion.future),
                  MonthDay(11, null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                15,
                [
                  MonthDay(12, null, false, 0, Occasion.future),
                  MonthDay(13, null, false, 0, Occasion.future),
                  MonthDay(14, null, false, 0, Occasion.future),
                  MonthDay(15, null, false, 0, Occasion.future),
                  MonthDay(16, null, false, 0, Occasion.future),
                  MonthDay(17, null, false, 0, Occasion.future),
                  MonthDay(18, null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                16,
                [
                  MonthDay(19, null, false, 0, Occasion.future),
                  MonthDay(20, null, false, 0, Occasion.future),
                  MonthDay(21, null, false, 0, Occasion.future),
                  MonthDay(22, null, false, 0, Occasion.future),
                  MonthDay(23, null, false, 0, Occasion.future),
                  MonthDay(24, null, false, 0, Occasion.future),
                  MonthDay(25, null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                17,
                [
                  MonthDay(26, null, false, 0, Occasion.future),
                  MonthDay(27, null, false, 0, Occasion.future),
                  MonthDay(28, null, false, 0, Occasion.future),
                  MonthDay(29, null, false, 0, Occasion.future),
                  MonthDay(30, null, false, 0, Occasion.future),
                  NotInMonthDay(),
                  NotInMonthDay(),
                ],
              ),
            ],
          ),
        ),
      );
    });

    test('previous month, basic', () async {
      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Act
      monthCalendarBloc.add(GoToPreviousMonth());
      final state = await monthCalendarBloc.first;

      // Assert
      expect(
        state.firstDay,
        DateTime(2021, 02, 01),
      );
      expect(state.weeks.length, 4);
      expect(state.occasion, Occasion.past);
    });

    test('previous month correct', () {
      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Act
      monthCalendarBloc.add(GoToPreviousMonth());

      // Assert
      expectLater(
        monthCalendarBloc,
        emits(
          MonthCalendarState(
            firstDay: DateTime(2021, 02, 01),
            occasion: Occasion.past,
            weeks: [
              MonthWeek(
                5,
                [
                  MonthDay(1, null, false, 0, Occasion.past),
                  MonthDay(2, null, false, 0, Occasion.past),
                  MonthDay(3, null, false, 0, Occasion.past),
                  MonthDay(4, null, false, 0, Occasion.past),
                  MonthDay(5, null, false, 0, Occasion.past),
                  MonthDay(6, null, false, 0, Occasion.past),
                  MonthDay(7, null, false, 0, Occasion.past),
                ],
              ),
              MonthWeek(
                6,
                [
                  MonthDay(8, null, false, 00, Occasion.past),
                  MonthDay(9, null, false, 00, Occasion.past),
                  MonthDay(10, null, false, 00, Occasion.past),
                  MonthDay(11, null, false, 00, Occasion.past),
                  MonthDay(12, null, false, 00, Occasion.past),
                  MonthDay(13, null, false, 00, Occasion.past),
                  MonthDay(14, null, false, 00, Occasion.past),
                ],
              ),
              MonthWeek(
                7,
                [
                  MonthDay(15, null, false, 00, Occasion.past),
                  MonthDay(16, null, false, 00, Occasion.past),
                  MonthDay(17, null, false, 00, Occasion.past),
                  MonthDay(18, null, false, 00, Occasion.past),
                  MonthDay(19, null, false, 00, Occasion.past),
                  MonthDay(20, null, false, 00, Occasion.past),
                  MonthDay(21, null, false, 00, Occasion.past),
                ],
              ),
              MonthWeek(
                8,
                [
                  MonthDay(22, null, false, 00, Occasion.past),
                  MonthDay(23, null, false, 00, Occasion.past),
                  MonthDay(24, null, false, 00, Occasion.past),
                  MonthDay(25, null, false, 00, Occasion.past),
                  MonthDay(26, null, false, 00, Occasion.past),
                  MonthDay(27, null, false, 00, Occasion.past),
                  MonthDay(28, null, false, 00, Occasion.past),
                ],
              ),
            ],
          ),
        ),
      );
    });

    test('january state correct', () {
      // Arrange
      final january15 = DateTime(2021, 01, 15, 15, 15);
      final newClock = StreamController<DateTime>();

      clockBloc = ClockBloc(newClock.stream, initialTime: january15);
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Asserts
      expect(
        monthCalendarBloc.state,
        MonthCalendarState(
          firstDay: DateTime(2021, 01, 01),
          occasion: Occasion.current,
          weeks: [
            MonthWeek(
              53,
              [
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                MonthDay(1, null, false, 0, Occasion.past),
                MonthDay(2, null, false, 0, Occasion.past),
                MonthDay(3, null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              1,
              [
                MonthDay(4, null, false, 0, Occasion.past),
                MonthDay(5, null, false, 0, Occasion.past),
                MonthDay(6, null, false, 0, Occasion.past),
                MonthDay(7, null, false, 0, Occasion.past),
                MonthDay(8, null, false, 0, Occasion.past),
                MonthDay(9, null, false, 0, Occasion.past),
                MonthDay(10, null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              2,
              [
                MonthDay(11, null, false, 0, Occasion.past),
                MonthDay(12, null, false, 0, Occasion.past),
                MonthDay(13, null, false, 0, Occasion.past),
                MonthDay(14, null, false, 0, Occasion.past),
                MonthDay(15, null, false, 0, Occasion.current),
                MonthDay(16, null, false, 0, Occasion.future),
                MonthDay(17, null, false, 0, Occasion.future),
              ],
            ),
            MonthWeek(
              3,
              [
                MonthDay(18, null, false, 0, Occasion.future),
                MonthDay(19, null, false, 0, Occasion.future),
                MonthDay(20, null, false, 0, Occasion.future),
                MonthDay(21, null, false, 0, Occasion.future),
                MonthDay(22, null, false, 0, Occasion.future),
                MonthDay(23, null, false, 0, Occasion.future),
                MonthDay(24, null, false, 0, Occasion.future),
              ],
            ),
            MonthWeek(
              4,
              [
                MonthDay(25, null, false, 0, Occasion.future),
                MonthDay(26, null, false, 0, Occasion.future),
                MonthDay(27, null, false, 0, Occasion.future),
                MonthDay(28, null, false, 0, Occasion.future),
                MonthDay(29, null, false, 0, Occasion.future),
                MonthDay(30, null, false, 0, Occasion.future),
                MonthDay(31, null, false, 0, Occasion.future),
              ],
            ),
          ],
        ),
      );
    });
  });

  group('Calendar days are correct', () {
    test('monthly recurrent activity', () {
      when(activitiesBloc.state).thenReturn(
        ActivitiesLoaded(
          [
            Activity.createNew(
              title: 'end and start of month',
              startTime: DateTime(2020, 01, 01, 22, 30),
              recurs: Recurs.monthlyOnDays([1, 2, 3, 30, 31]),
            ),
          ],
        ),
      );

      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Asserts
      expect(
        monthCalendarBloc.state,
        MonthCalendarState(
          firstDay: DateTime(2021, 03, 01),
          occasion: Occasion.current,
          weeks: [
            MonthWeek(
              9,
              [
                MonthDay(1, null, true, 0, Occasion.past),
                MonthDay(2, null, true, 0, Occasion.past),
                MonthDay(3, null, true, 0, Occasion.past),
                MonthDay(4, null, false, 0, Occasion.past),
                MonthDay(5, null, false, 0, Occasion.past),
                MonthDay(6, null, false, 0, Occasion.past),
                MonthDay(7, null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              10,
              [
                MonthDay(8, null, false, 0, Occasion.past),
                MonthDay(9, null, false, 0, Occasion.past),
                MonthDay(10, null, false, 0, Occasion.past),
                MonthDay(11, null, false, 0, Occasion.past),
                MonthDay(12, null, false, 0, Occasion.past),
                MonthDay(13, null, false, 0, Occasion.past),
                MonthDay(14, null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              11,
              [
                MonthDay(15, null, false, 0, Occasion.past),
                MonthDay(16, null, false, 0, Occasion.past),
                MonthDay(17, null, false, 0, Occasion.past),
                MonthDay(18, null, false, 0, Occasion.past),
                MonthDay(19, null, false, 0, Occasion.current),
                MonthDay(20, null, false, 0, Occasion.future),
                MonthDay(21, null, false, 0, Occasion.future),
              ],
            ),
            MonthWeek(
              12,
              [
                MonthDay(22, null, false, 00, Occasion.future),
                MonthDay(23, null, false, 00, Occasion.future),
                MonthDay(24, null, false, 00, Occasion.future),
                MonthDay(25, null, false, 00, Occasion.future),
                MonthDay(26, null, false, 00, Occasion.future),
                MonthDay(27, null, false, 00, Occasion.future),
                MonthDay(28, null, false, 00, Occasion.future),
              ],
            ),
            MonthWeek(
              13,
              [
                MonthDay(29, null, false, 00, Occasion.future),
                MonthDay(30, null, true, 00, Occasion.future),
                MonthDay(31, null, true, 00, Occasion.future),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
              ],
            ),
          ],
        ),
      );
    });

    test('weekend activity', () {
      final weekendFullDay = Activity.createNew(
        title: 'full day on weekends',
        startTime: DateTime(2010, 01, 01),
        recurs: Recurs.weeklyOnDays([6, 7]),
        fullDay: true,
      );
      when(activitiesBloc.state).thenReturn(
        ActivitiesLoaded(
          [
            weekendFullDay,
          ],
        ),
      );

      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);
      final firstDay = DateTime(2021, 03, 01);

      // Asserts
      expect(
        monthCalendarBloc.state,
        MonthCalendarState(
          firstDay: firstDay,
          occasion: Occasion.current,
          weeks: [
            MonthWeek(
              9,
              [
                MonthDay(1, null, false, 0, Occasion.past),
                MonthDay(2, null, false, 0, Occasion.past),
                MonthDay(3, null, false, 0, Occasion.past),
                MonthDay(4, null, false, 0, Occasion.past),
                MonthDay(5, null, false, 0, Occasion.past),
                ...[6, 7].map<MonthDay>(
                  (d) => MonthDay(
                    d,
                    ActivityDay(weekendFullDay, firstDay.addDays(d - 1)),
                    false,
                    1,
                    Occasion.past,
                  ),
                ),
              ],
            ),
            MonthWeek(
              10,
              [
                MonthDay(8, null, false, 0, Occasion.past),
                MonthDay(9, null, false, 0, Occasion.past),
                MonthDay(10, null, false, 0, Occasion.past),
                MonthDay(11, null, false, 0, Occasion.past),
                MonthDay(12, null, false, 0, Occasion.past),
                ...[13, 14].map<MonthDay>(
                  (d) => MonthDay(
                    d,
                    ActivityDay(weekendFullDay, firstDay.addDays(d - 1)),
                    false,
                    1,
                    Occasion.past,
                  ),
                ),
              ],
            ),
            MonthWeek(
              11,
              [
                MonthDay(15, null, false, 0, Occasion.past),
                MonthDay(16, null, false, 0, Occasion.past),
                MonthDay(17, null, false, 0, Occasion.past),
                MonthDay(18, null, false, 0, Occasion.past),
                MonthDay(19, null, false, 0, Occasion.current),
                ...[20, 21].map<MonthDay>(
                  (d) => MonthDay(
                    d,
                    ActivityDay(weekendFullDay, firstDay.addDays(d - 1)),
                    false,
                    1,
                    Occasion.future,
                  ),
                ),
              ],
            ),
            MonthWeek(
              12,
              [
                MonthDay(22, null, false, 0, Occasion.future),
                MonthDay(23, null, false, 0, Occasion.future),
                MonthDay(24, null, false, 0, Occasion.future),
                MonthDay(25, null, false, 0, Occasion.future),
                MonthDay(26, null, false, 0, Occasion.future),
                ...[27, 28].map<MonthDay>(
                  (d) => MonthDay(
                    d,
                    ActivityDay(weekendFullDay, firstDay.addDays(d - 1)),
                    false,
                    1,
                    Occasion.future,
                  ),
                ),
              ],
            ),
            MonthWeek(
              13,
              [
                MonthDay(29, null, false, 0, Occasion.future),
                MonthDay(30, null, false, 0, Occasion.future),
                MonthDay(31, null, false, 0, Occasion.future),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
              ],
            ),
          ],
        ),
      );
    });
  });
}
