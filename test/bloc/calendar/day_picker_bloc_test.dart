import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';

void main() {
  DayPickerBloc dayPickerBloc;
  final theTime = DateTime(1987, 10, 06, 04, 34, 55, 55, 55);
  final theDay = DateTime(1987, 10, 06);
  final thedayBefore = DateTime(1987, 10, 05);
  final theDayAfter = DateTime(1987, 10, 07);
  final theDayAfterTomorrow = DateTime(1987, 10, 08);
  ClockBloc clockBloc;
  StreamController<DateTime> streamController;

  setUp(() {
    streamController = StreamController();
    clockBloc = ClockBloc(streamController.stream, initialTime: theTime);
    dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
  });

  test('initial state', () {
    expect(
        dayPickerBloc.state, DayPickerState(theDay, DayPickerBloc.startIndex));
  });

  test('Next day should yeild next day', () async {
    dayPickerBloc.add(NextDay());
    await expectLater(
      dayPickerBloc,
      emits(DayPickerState(theDayAfter, DayPickerBloc.startIndex + 1)),
    );
  });

  test('Previus day should yeild previus day', () async {
    dayPickerBloc.add(PreviousDay());
    await expectLater(
      dayPickerBloc,
      emits(DayPickerState(thedayBefore, DayPickerBloc.startIndex - 1)),
    );
  });

  test('NextDay then PreviusDay should yeild same day', () async {
    dayPickerBloc.add(NextDay());
    dayPickerBloc.add(PreviousDay());
    await expectLater(
      dayPickerBloc,
      emitsInOrder([
        DayPickerState(theDayAfter, DayPickerBloc.startIndex + 1),
        DayPickerState(theDay, DayPickerBloc.startIndex)
      ]),
    );
  });

  test('Current day returns to start day', () async {
    dayPickerBloc.add(NextDay());
    dayPickerBloc.add(NextDay());
    dayPickerBloc.add(CurrentDay());
    await expectLater(
      dayPickerBloc,
      emitsInOrder([
        DayPickerState(theDayAfter, DayPickerBloc.startIndex + 1),
        DayPickerState(theDayAfterTomorrow, DayPickerBloc.startIndex + 2),
        DayPickerState(theDay, DayPickerBloc.startIndex)
      ]),
    );
  });

  test('Daylight saving summer time going forward', () async {
    // Arrange
    final daybeforeDST = DateTime(2020, 03, 28);
    final dayLightSavingTime = DateTime(2020, 03, 29);
    final daysAfterDST = DateTime(2020, 03, 30);

    clockBloc = ClockBloc(StreamController<DateTime>().stream,
        initialTime: daybeforeDST);
    dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);

    // Act
    dayPickerBloc.add(NextDay());
    dayPickerBloc.add(NextDay());

    // Assert
    await expectLater(
      dayPickerBloc,
      emitsInOrder([
        DayPickerState(dayLightSavingTime, DayPickerBloc.startIndex + 1),
        DayPickerState(daysAfterDST, DayPickerBloc.startIndex + 2)
      ]),
    );
  });

  test('Daylight saving summer time going backwards', () async {
    // Arrange
    final dayLightSavingTime = DateTime(2020, 03, 29);
    final daysAfterDST = DateTime(2020, 03, 30);
    final twoDaysAfterDST = DateTime(2020, 03, 31);
    clockBloc = ClockBloc(StreamController<DateTime>().stream,
        initialTime: twoDaysAfterDST);
    dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);

    // Act
    dayPickerBloc.add(PreviousDay());
    dayPickerBloc.add(PreviousDay());

    // Assert
    await expectLater(
      dayPickerBloc,
      emitsInOrder([
        DayPickerState(daysAfterDST, DayPickerBloc.startIndex - 1),
        DayPickerState(dayLightSavingTime, DayPickerBloc.startIndex - 2)
      ]),
    );
  });

  test('Daylight saving winter time going forward', () async {
    // Arrange
    final daybeforeDST = DateTime(2020, 10, 24);
    final dayLightSavingTime = DateTime(2020, 10, 25);
    final daysAfterDST = DateTime(2020, 10, 26);

    clockBloc = ClockBloc(StreamController<DateTime>().stream,
        initialTime: daybeforeDST);
    dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);

    // Act
    dayPickerBloc.add(NextDay());
    dayPickerBloc.add(NextDay());

    // Assert
    await expectLater(
      dayPickerBloc,
      emitsInOrder([
        DayPickerState(dayLightSavingTime, DayPickerBloc.startIndex + 1),
        DayPickerState(daysAfterDST, DayPickerBloc.startIndex + 2)
      ]),
    );
  });

  test('Daylight saving winter time going backwards', () async {
    // Arrange
    final dayLightSavingTime = DateTime(2020, 10, 25);
    final daysAfterDST = DateTime(2020, 10, 26);
    final twoDaysAfterDST = DateTime(2020, 10, 27);
    clockBloc = ClockBloc(StreamController<DateTime>().stream,
        initialTime: twoDaysAfterDST);
    dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);

    // Act
    dayPickerBloc.add(PreviousDay());
    dayPickerBloc.add(PreviousDay());

    // Assert
    await expectLater(
      dayPickerBloc,
      emitsInOrder([
        DayPickerState(daysAfterDST, DayPickerBloc.startIndex - 1),
        DayPickerState(dayLightSavingTime, DayPickerBloc.startIndex - 2)
      ]),
    );
  });

  test('currentDay state should not change until next day', () async {
    for (var i = 0; i < Duration.minutesPerDay; i++) {
      streamController.add(theDay.add(Duration(minutes: i)));
    }
    await Future.delayed(Duration(milliseconds: 100));
    dayPickerBloc.add(CurrentDay());
    await expectLater(
      dayPickerBloc,
      emits(DayPickerState(theDay, DayPickerBloc.startIndex)),
    );
  });

  test('currentDay should change with clock passing next day', () async {
    streamController.add(theDayAfter);
    await Future.doWhile(() => Future.delayed(
        Duration(milliseconds: 10), () => clockBloc.state == theDay));
    dayPickerBloc.add(CurrentDay());
    await expectLater(
      dayPickerBloc,
      emits(DayPickerState(theDayAfter, DayPickerBloc.startIndex + 1)),
    );
    await dayPickerBloc.close();
    await expectLater(dayPickerBloc, emitsDone);
  });

  test('currentDay should change with clocks passing day after next', () async {
    streamController.add(theDayAfterTomorrow);
    await Future.doWhile(() => Future.delayed(
        Duration(milliseconds: 10), () => clockBloc.state == theDay));
    dayPickerBloc.add(CurrentDay());
    await expectLater(
      dayPickerBloc,
      emits(DayPickerState(theDayAfterTomorrow, DayPickerBloc.startIndex + 2)),
    );
  });

  test('state should only be day granularity', () async {
    for (var i = 0; i < 2 * Duration.secondsPerMinute; i++) {
      streamController
          .add(theDay.add(Duration(hours: 23, minutes: 59, seconds: i)));
    }
    await Future.delayed(Duration(milliseconds: 100));
    dayPickerBloc.add(CurrentDay());
    await expectLater(dayPickerBloc,
        emits(DayPickerState(theDayAfter, DayPickerBloc.startIndex + 1)));
    await dayPickerBloc.close();
    await expectLater(dayPickerBloc, emitsDone);
  });

  tearDown(() {
    dayPickerBloc.close();
    streamController.close();
  });
}
