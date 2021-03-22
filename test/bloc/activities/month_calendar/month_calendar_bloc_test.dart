import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

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

  test('initial state basics', () {
    // Arrange
    monthCalendarBloc =
        MonthCalendarBloc(activitiesBloc: activitiesBloc, clockBloc: clockBloc);
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
    monthCalendarBloc =
        MonthCalendarBloc(activitiesBloc: activitiesBloc, clockBloc: clockBloc);

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
              MonthDay(1, null, false, 0),
              MonthDay(2, null, false, 0),
              MonthDay(3, null, false, 0),
              MonthDay(4, null, false, 0),
              MonthDay(5, null, false, 0),
              MonthDay(6, null, false, 0),
              MonthDay(7, null, false, 0),
            ],
          ),
          MonthWeek(
            10,
            [
              MonthDay(8, null, false, 0),
              MonthDay(9, null, false, 0),
              MonthDay(10, null, false, 0),
              MonthDay(11, null, false, 0),
              MonthDay(12, null, false, 0),
              MonthDay(13, null, false, 0),
              MonthDay(14, null, false, 0),
            ],
          ),
          MonthWeek(
            11,
            [
              MonthDay(15, null, false, 0),
              MonthDay(16, null, false, 0),
              MonthDay(17, null, false, 0),
              MonthDay(18, null, false, 0),
              MonthDay(19, null, false, 0),
              MonthDay(20, null, false, 0),
              MonthDay(21, null, false, 0),
            ],
          ),
          MonthWeek(
            12,
            [
              MonthDay(22, null, false, 0),
              MonthDay(23, null, false, 0),
              MonthDay(24, null, false, 0),
              MonthDay(25, null, false, 0),
              MonthDay(26, null, false, 0),
              MonthDay(27, null, false, 0),
              MonthDay(28, null, false, 0),
            ],
          ),
          MonthWeek(
            13,
            [
              MonthDay(29, null, false, 0),
              MonthDay(30, null, false, 0),
              MonthDay(31, null, false, 0),
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
    monthCalendarBloc =
        MonthCalendarBloc(activitiesBloc: activitiesBloc, clockBloc: clockBloc);

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
    monthCalendarBloc =
        MonthCalendarBloc(activitiesBloc: activitiesBloc, clockBloc: clockBloc);

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
                MonthDay(1, null, false, 0),
                MonthDay(2, null, false, 0),
                MonthDay(3, null, false, 0),
                MonthDay(4, null, false, 0),
              ],
            ),
            MonthWeek(
              14,
              [
                MonthDay(5, null, false, 0),
                MonthDay(6, null, false, 0),
                MonthDay(7, null, false, 0),
                MonthDay(8, null, false, 0),
                MonthDay(9, null, false, 0),
                MonthDay(10, null, false, 0),
                MonthDay(11, null, false, 0),
              ],
            ),
            MonthWeek(
              15,
              [
                MonthDay(12, null, false, 0),
                MonthDay(13, null, false, 0),
                MonthDay(14, null, false, 0),
                MonthDay(15, null, false, 0),
                MonthDay(16, null, false, 0),
                MonthDay(17, null, false, 0),
                MonthDay(18, null, false, 0),
              ],
            ),
            MonthWeek(
              16,
              [
                MonthDay(19, null, false, 0),
                MonthDay(20, null, false, 0),
                MonthDay(21, null, false, 0),
                MonthDay(22, null, false, 0),
                MonthDay(23, null, false, 0),
                MonthDay(24, null, false, 0),
                MonthDay(25, null, false, 0),
              ],
            ),
            MonthWeek(
              17,
              [
                MonthDay(26, null, false, 0),
                MonthDay(27, null, false, 0),
                MonthDay(28, null, false, 0),
                MonthDay(29, null, false, 0),
                MonthDay(30, null, false, 0),
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
    monthCalendarBloc =
        MonthCalendarBloc(activitiesBloc: activitiesBloc, clockBloc: clockBloc);

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
    monthCalendarBloc =
        MonthCalendarBloc(activitiesBloc: activitiesBloc, clockBloc: clockBloc);

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
                MonthDay(1, null, false, 0),
                MonthDay(2, null, false, 0),
                MonthDay(3, null, false, 0),
                MonthDay(4, null, false, 0),
                MonthDay(5, null, false, 0),
                MonthDay(6, null, false, 0),
                MonthDay(7, null, false, 0),
              ],
            ),
            MonthWeek(
              6,
              [
                MonthDay(8, null, false, 0),
                MonthDay(9, null, false, 0),
                MonthDay(10, null, false, 0),
                MonthDay(11, null, false, 0),
                MonthDay(12, null, false, 0),
                MonthDay(13, null, false, 0),
                MonthDay(14, null, false, 0),
              ],
            ),
            MonthWeek(
              7,
              [
                MonthDay(15, null, false, 0),
                MonthDay(16, null, false, 0),
                MonthDay(17, null, false, 0),
                MonthDay(18, null, false, 0),
                MonthDay(19, null, false, 0),
                MonthDay(20, null, false, 0),
                MonthDay(21, null, false, 0),
              ],
            ),
            MonthWeek(
              8,
              [
                MonthDay(22, null, false, 0),
                MonthDay(23, null, false, 0),
                MonthDay(24, null, false, 0),
                MonthDay(25, null, false, 0),
                MonthDay(26, null, false, 0),
                MonthDay(27, null, false, 0),
                MonthDay(28, null, false, 0),
              ],
            ),
          ],
        ),
      ),
    );
  });
}
