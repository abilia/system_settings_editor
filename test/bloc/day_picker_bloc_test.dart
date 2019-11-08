import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/utils/datetime_utils.dart';

DateTime _toNoneUTC(DateTime d ) => DateTime(d.year, d.month, d.day, d.hour, d.minute, d.second, d.millisecond, d.microsecond);

void main() {
  DayPickerBloc dayPickerBloc;
  DateTime initialDay = DateTime.utc(2000, 10,
      1); // Must use utc, otherwise .add(Duration(day: 1)) will not return next day on daylight saving time ends

  group('DayPickerBlock', () {
    setUp(() {
      Stream<DateTime> stream = Stream.empty();
      dayPickerBloc =
          DayPickerBloc(clockBloc: ClockBloc(stream, initialTime: initialDay));
    });

    test('initial state is DayActivitiesLoading', () {
      expect(dayPickerBloc.initialState, _toNoneUTC(initialDay));
      expect(dayPickerBloc.state, _toNoneUTC(initialDay));
    });

    test('Can go forward', () {
      final expectedResponse = [
        initialDay,
        initialDay.add(Duration(days: 1)),
      ].map(_toNoneUTC).toList();
      expectLater(
        dayPickerBloc,
        emitsInOrder(expectedResponse),
      );
      dayPickerBloc.add(NextDay());
    });

    test('Can go backward', () {
      final expectedResponse = [
        initialDay,
        initialDay.subtract(Duration(days: 1)),
      ].map(_toNoneUTC).toList();
      expectLater(
        dayPickerBloc,
        emitsInOrder(expectedResponse),
      );
      dayPickerBloc.add(PreviousDay());
    });

    test('Can go to day', () {
      final newday = DateTime(2020, 12, 12);
      final expectedResponse = [
        initialDay,
        newday,
      ].map(_toNoneUTC).toList();
      expectLater(
        dayPickerBloc,
        emitsInOrder(expectedResponse),
      );
      dayPickerBloc.add(GoTo(day: newday));
    });

    test('Can go forward then backward', () {
      final expectedResponse = [
        initialDay,
        initialDay.add(Duration(days: 1)),
        initialDay,
      ].map(_toNoneUTC).toList();

      expectLater(
        dayPickerBloc,
        emitsInOrder(expectedResponse),
      );
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(PreviousDay());
    });

    test('Can go forward 1000 days', () {
      final days = 1000;
      final expectedResponse = [
        for (int i = 0; i <= days; i++) initialDay.add(Duration(days: i)),
      ].map(_toNoneUTC).toList();

      expectLater(
        dayPickerBloc,
        emitsInOrder(expectedResponse),
      );
      for (int i = 0; i <= days; i++) dayPickerBloc.add(NextDay());
    });

    test('Can go back 1000 days', () {
      final days = 1000;
      final expectedResponse = [
        for (int i = 0; i <= days; i++) initialDay.subtract(Duration(days: i)),
      ].map(_toNoneUTC).toList();

      expectLater(
        dayPickerBloc,
        emitsInOrder(expectedResponse),
      );
      for (int i = 0; i <= days; i++) dayPickerBloc.add(PreviousDay());
    });

    test('Go forward 1000 then back 1000 lands on same day', () {
      final days = 1000;
      for (int i = 0; i <= days; i++) dayPickerBloc.add(NextDay());
      for (int i = 0; i <= days; i++) dayPickerBloc.add(PreviousDay());
      expect(dayPickerBloc.state, _toNoneUTC(initialDay));
      expect(dayPickerBloc.state, dayPickerBloc.initialState);
    });

    test('Go back 1000 then forward 1000 lands on same day', () {
      final days = 1000;
      for (int i = 0; i <= days; i++) dayPickerBloc.add(PreviousDay());
      for (int i = 0; i <= days; i++) dayPickerBloc.add(NextDay());
      expect(dayPickerBloc.state, _toNoneUTC(initialDay));
      expect(dayPickerBloc.state, dayPickerBloc.initialState);
    });

    test('Go forward 1000 never exceed the amount of milliseouns in a day', () async {
      final days = 1000;

      final expectedResponse = [
        for (int d = 0; d <= days; d++) initialDay.millisecondsSinceEpoch + Duration.millisecondsPerDay * d,
      ];

      expectLater(
        dayPickerBloc.map((d) => d.millisecondsSinceEpoch),
        emitsInOrder(expectedResponse)
      );

      for (int i = 0; i <= days; i++) dayPickerBloc.add(NextDay());
      expect(dayPickerBloc.state, _toNoneUTC(initialDay));
      expect(dayPickerBloc.state, dayPickerBloc.initialState);
    }, skip: 'This only holds when using UTC, which I am trying to go from');

    tearDown(() {
      dayPickerBloc.close();
    });
  });
}
