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
              List.generate(
                7,
                (d) => MonthDay(
                    firstDay.addDays(d), null, false, 0, Occasion.past),
              ),
            ),
            MonthWeek(
              10,
              List.generate(
                7,
                (d) => MonthDay(
                    firstDay.addDays(d + 7), null, false, 0, Occasion.past),
              ),
            ),
            MonthWeek(
              11,
              List.generate(
                7,
                (d) => MonthDay(
                    firstDay.addDays(d + 14),
                    null,
                    false,
                    0,
                    d < 4
                        ? Occasion.past
                        : d > 4
                            ? Occasion.future
                            : Occasion.current),
              ),
            ),
            MonthWeek(
              12,
              List.generate(
                7,
                (d) => MonthDay(
                    firstDay.addDays(d + 21), null, false, 0, Occasion.future),
              ),
            ),
            MonthWeek(
              13,
              List.generate(
                7,
                (d) => d < 3
                    ? MonthDay(firstDay.addDays(d + 28), null, false, 0,
                        Occasion.future)
                    : NotInMonthDay(),
              ),
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
                  MonthDay(
                      DateTime(2021, 04, 1), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 2), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 3), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 4), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                14,
                [
                  MonthDay(
                      DateTime(2021, 04, 5), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 6), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 7), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 8), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 9), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 10), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 11), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                15,
                [
                  MonthDay(
                      DateTime(2021, 04, 12), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 13), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 14), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 15), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 16), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 17), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 18), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                16,
                [
                  MonthDay(
                      DateTime(2021, 04, 19), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 20), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 21), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 22), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 23), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 24), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 25), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                17,
                [
                  MonthDay(
                      DateTime(2021, 04, 26), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 27), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 28), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 29), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 30), null, false, 0, Occasion.future),
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
                  MonthDay(
                      DateTime(2021, 02, 1), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 2), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 3), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 4), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 5), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 6), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 7), null, false, 0, Occasion.past),
                ],
              ),
              MonthWeek(
                6,
                [
                  MonthDay(
                      DateTime(2021, 02, 8), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 9), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 10), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 11), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 12), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 13), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 14), null, false, 00, Occasion.past),
                ],
              ),
              MonthWeek(
                7,
                [
                  MonthDay(
                      DateTime(2021, 02, 15), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 16), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 17), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 18), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 19), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 20), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 21), null, false, 00, Occasion.past),
                ],
              ),
              MonthWeek(
                8,
                [
                  MonthDay(
                      DateTime(2021, 02, 22), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 23), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 24), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 25), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 26), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 27), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 28), null, false, 00, Occasion.past),
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
                MonthDay(DateTime(2021, 01, 1), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 2), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 3), null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              1,
              [
                MonthDay(DateTime(2021, 01, 4), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 5), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 6), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 7), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 8), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 9), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 10), null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              2,
              [
                MonthDay(DateTime(2021, 01, 11), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 12), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 13), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 14), null, false, 0, Occasion.past),
                MonthDay(
                    DateTime(2021, 01, 15), null, false, 0, Occasion.current),
                MonthDay(
                    DateTime(2021, 01, 16), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 17), null, false, 0, Occasion.future),
              ],
            ),
            MonthWeek(
              3,
              [
                MonthDay(
                    DateTime(2021, 01, 18), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 19), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 20), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 21), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 22), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 23), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 24), null, false, 0, Occasion.future),
              ],
            ),
            MonthWeek(
              4,
              [
                MonthDay(
                    DateTime(2021, 01, 25), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 26), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 27), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 28), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 29), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 30), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 31), null, false, 0, Occasion.future),
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
                MonthDay(DateTime(2021, 03, 1), null, true, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 2), null, true, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 3), null, true, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 4), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 5), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 6), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 7), null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              10,
              [
                MonthDay(DateTime(2021, 03, 8), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 9), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 10), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 11), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 12), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 13), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 14), null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              11,
              [
                MonthDay(DateTime(2021, 03, 15), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 16), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 17), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 18), null, false, 0, Occasion.past),
                MonthDay(
                    DateTime(2021, 03, 19), null, false, 0, Occasion.current),
                MonthDay(
                    DateTime(2021, 03, 20), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 21), null, false, 0, Occasion.future),
              ],
            ),
            MonthWeek(
              12,
              [
                MonthDay(
                    DateTime(2021, 03, 22), null, false, 00, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 23), null, false, 00, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 24), null, false, 00, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 25), null, false, 00, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 26), null, false, 00, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 27), null, false, 00, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 28), null, false, 00, Occasion.future),
              ],
            ),
            MonthWeek(
              13,
              [
                MonthDay(
                    DateTime(2021, 03, 29), null, false, 00, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 30), null, true, 00, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 31), null, true, 00, Occasion.future),
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
                MonthDay(firstDay, null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 2), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 3), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 4), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 5), null, false, 0, Occasion.past),
                ...[6, 7].map<MonthDay>(
                  (d) => MonthDay(
                    DateTime(2021, 03, d),
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
                MonthDay(DateTime(2021, 03, 8), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 9), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 10), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 11), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 12), null, false, 0, Occasion.past),
                ...[13, 14].map<MonthDay>(
                  (d) => MonthDay(
                    DateTime(2021, 03, d),
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
                MonthDay(DateTime(2021, 03, 15), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 16), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 17), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 18), null, false, 0, Occasion.past),
                MonthDay(
                    DateTime(2021, 03, 19), null, false, 0, Occasion.current),
                ...[20, 21].map<MonthDay>(
                  (d) => MonthDay(
                    DateTime(2021, 03, d),
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
                MonthDay(
                    DateTime(2021, 03, 22), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 23), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 24), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 25), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 26), null, false, 0, Occasion.future),
                ...[27, 28].map<MonthDay>(
                  (d) => MonthDay(
                    DateTime(2021, 03, d),
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
                MonthDay(
                    DateTime(2021, 03, 29), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 30), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 31), null, false, 0, Occasion.future),
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
