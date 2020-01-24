import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';

void main() {
  DayPickerBloc dayPickerBloc;
  DateTime theTime = DateTime(1987, 10, 06, 04, 34, 55, 55, 55);
  DateTime theDay = DateTime(1987, 10, 06);
  DateTime thedayBefore = DateTime(1987, 10, 05);
  DateTime theDayAfter = DateTime(1987, 10, 07);
  DateTime theDayAfterTomorrow = DateTime(1987, 10, 08);
  ClockBloc clockBloc;
  StreamController<DateTime> streamController;

  group('DayPickerBloc', () {
    setUp(() {
      streamController = StreamController();
      clockBloc = ClockBloc(streamController.stream, initialTime: theTime);
      dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
    });

    test('initial state', () {
      expect(dayPickerBloc.initialState, theDay);
      expect(dayPickerBloc.state, theDay);
      expectLater(
        dayPickerBloc,
        emitsInOrder([theDay]),
      );
    });

    test('Next day should yeild next day', () async {
      dayPickerBloc.add(NextDay());
      await expectLater(
        dayPickerBloc,
        emitsInOrder([theDay, theDayAfter]),
      );
    });

    test('Previus day should yeild previus day', () async {
      dayPickerBloc.add(PreviousDay());
      await expectLater(
        dayPickerBloc,
        emitsInOrder([theDay, thedayBefore]),
      );
    });

    test('NextDay then PreviusDay should yeild same day', () async {
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(PreviousDay());
      await expectLater(
        dayPickerBloc,
        emitsInOrder([theDay, theDayAfter, theDay]),
      );
    });

    test('currentDay state should not change until next day', () async {
      for (int i = 0; i < Duration.minutesPerDay; i++) {
        streamController.add(theDay.add(Duration(minutes: i)));
      }
      await Future.delayed(Duration(milliseconds: 100));
      dayPickerBloc.add(CurrentDay());
      await expectLater(
        dayPickerBloc,
        emitsInOrder([theDay]),
      );
    });

    test('currentDay should change with clock passing next day', () async {
      streamController.add(theDayAfter);
      await Future.doWhile(() => Future.delayed(
          Duration(milliseconds: 10), () => clockBloc.state == theDay));
      dayPickerBloc.add(CurrentDay());
      await expectLater(
        dayPickerBloc,
        emitsInOrder([theDay, theDayAfter]),
      );
    });

    test('currentDay should change with clocks passing day after next',
        () async {
      streamController.add(theDayAfterTomorrow);
      await Future.doWhile(() => Future.delayed(
          Duration(milliseconds: 10), () => clockBloc.state == theDay));
      dayPickerBloc.add(CurrentDay());
      await expectLater(
        dayPickerBloc,
        emitsInOrder([theDay, theDayAfterTomorrow]),
      );
    });

    test('state should only be day granularity', () async {
      for (int i = 0; i < 2 * Duration.secondsPerMinute; i++) {
        streamController
            .add(theDay.add(Duration(hours: 23, minutes: 59, seconds: i)));
      }
      await Future.delayed(Duration(milliseconds: 100));
      dayPickerBloc.add(CurrentDay());
      await expectLater(
        dayPickerBloc,
        emitsInOrder([theDay, theDayAfter]),
      );
    });

    tearDown(() {
      dayPickerBloc.close();
      streamController.close();
    });
  });
}
