import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../../mocks.dart';

void main() {
  ActivitiesBloc mockActivitiesBloc;
  MemoplannerSettingBloc mockMemoplannerSettingsBloc;

  ClockBloc clockBloc;
  final day = DateTime(2020, 10, 06);

  setUp(() {
    mockActivitiesBloc = MockActivitiesBloc();
    mockMemoplannerSettingsBloc = MockMemoplannerSettingsBloc();
    clockBloc = ClockBloc(StreamController<DateTime>().stream);
    when(mockMemoplannerSettingsBloc.state)
        .thenReturn(MemoplannerSettingsLoaded(MemoplannerSettings()));
  });

  test('Initial state', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: day,
    );
    final initialS = editActivityBloc.state;

    final recurringWeekBloc = RecurringWeekBloc(editActivityBloc);

    // Act // Assert
    expect(
      recurringWeekBloc.state,
      RecurringWeekState(
        UnmodifiableSetView({day.weekday}),
        false,
        initialS.timeInterval.startDate,
        Recurs.noEndDate,
      ),
    );
    expect(
      recurringWeekBloc.state.recurs,
      Recurs.weeklyOnDays({day.weekday}),
    );

    await expectLater(
      editActivityBloc,
      emits(
        initialS.copyWith(
          initialS.activity.copyWith(
            recurs: Recurs.weeklyOnDay(day.weekday),
          ),
        ),
      ),
    );
  });

  test('Adding and removing days', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: day,
    );

    final recurringWeekBloc = RecurringWeekBloc(editActivityBloc);

    // Act
    recurringWeekBloc.add(AddOrRemoveWeekday(DateTime.monday));
    recurringWeekBloc.add(AddOrRemoveWeekday(DateTime.wednesday));
    recurringWeekBloc.add(AddOrRemoveWeekday(day.weekday));

    await expectLater(
      recurringWeekBloc,
      emitsInOrder(
        [
          RecurringWeekState(
            UnmodifiableSetView({
              day.weekday,
              DateTime.monday,
            }),
            false,
            editActivityBloc.state.timeInterval.startDate,
            Recurs.noEndDate,
          ),
          RecurringWeekState(
            UnmodifiableSetView({
              day.weekday,
              DateTime.monday,
              DateTime.wednesday,
            }),
            false,
            editActivityBloc.state.timeInterval.startDate,
            Recurs.noEndDate,
          ),
          RecurringWeekState(
            UnmodifiableSetView({
              DateTime.monday,
              DateTime.wednesday,
            }),
            false,
            editActivityBloc.state.timeInterval.startDate,
            Recurs.noEndDate,
          ),
        ],
      ),
    );
  });

  test('Adding and removing days on EditActivityBloc', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: day,
    );
    final initialS = editActivityBloc.state;

    final recurringWeekBloc = RecurringWeekBloc(editActivityBloc);

    // Act
    recurringWeekBloc.add(AddOrRemoveWeekday(DateTime.monday));
    recurringWeekBloc.add(AddOrRemoveWeekday(DateTime.wednesday));
    recurringWeekBloc.add(AddOrRemoveWeekday(day.weekday));

    await expectLater(
      editActivityBloc,
      emitsInOrder([
        initialS.copyWith(
          initialS.activity.copyWith(
            recurs: Recurs.weeklyOnDays(
              {
                day.weekday,
              },
            ),
          ),
        ),
        initialS.copyWith(
          initialS.activity.copyWith(
            recurs: Recurs.weeklyOnDays(
              {
                day.weekday,
                DateTime.monday,
              },
            ),
          ),
        ),
        initialS.copyWith(
          initialS.activity.copyWith(
            recurs: Recurs.weeklyOnDays(
              {
                day.weekday,
                DateTime.monday,
                DateTime.wednesday,
              },
            ),
          ),
        ),
        initialS.copyWith(
          initialS.activity.copyWith(
            recurs: Recurs.weeklyOnDays(
              {
                DateTime.monday,
                DateTime.wednesday,
              },
            ),
          ),
        ),
      ]),
    );
  });

  test('Changing to every other week ', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: day,
    );

    final recurringWeekBloc = RecurringWeekBloc(editActivityBloc);

    // Act
    recurringWeekBloc.add(AddOrRemoveWeekday(DateTime.monday));
    recurringWeekBloc.add(ChangeEveryOtherWeek(true));

    await expectLater(
      recurringWeekBloc,
      emitsInOrder(
        [
          RecurringWeekState(
            UnmodifiableSetView({
              day.weekday,
              DateTime.monday,
            }),
            false,
            editActivityBloc.state.timeInterval.startDate,
            Recurs.noEndDate,
          ),
          RecurringWeekState(
            UnmodifiableSetView({
              day.weekday,
              DateTime.monday,
            }),
            true,
            editActivityBloc.state.timeInterval.startDate,
            Recurs.noEndDate,
          ),
        ],
      ),
    );
  });

  test('Changing to every other week on EditActivityBloc', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: day,
    );
    final initialS = editActivityBloc.state;

    final recurringWeekBloc = RecurringWeekBloc(editActivityBloc);

    // Act
    recurringWeekBloc.add(AddOrRemoveWeekday(DateTime.monday));
    recurringWeekBloc.add(ChangeEveryOtherWeek(true));

    await expectLater(
      editActivityBloc,
      emitsInOrder([
        initialS.copyWith(
          initialS.activity.copyWith(
            recurs: Recurs.weeklyOnDays(
              {
                day.weekday,
              },
            ),
          ),
        ),
        initialS.copyWith(
          initialS.activity.copyWith(
            recurs: Recurs.weeklyOnDays(
              {
                day.weekday,
                DateTime.monday,
              },
            ),
          ),
        ),
        initialS.copyWith(
          initialS.activity.copyWith(
            recurs: Recurs.biWeeklyOnDays(
              odds: {
                day.weekday,
                DateTime.monday,
              },
            ),
          ),
        ),
      ]),
    );
  });

  test('Changing to every other week on even weeks', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: day,
    );

    final recurringWeekBloc = RecurringWeekBloc(editActivityBloc);
    final newStartDate = day.add(7.days());
    final noEnd = DateTime.fromMillisecondsSinceEpoch(Recurs.NO_END);

    // Act
    recurringWeekBloc.add(AddOrRemoveWeekday(DateTime.monday));
    recurringWeekBloc.add(ChangeEveryOtherWeek(true));
    editActivityBloc.add(ChangeDate(newStartDate));

    await expectLater(
      recurringWeekBloc,
      emitsInOrder(
        [
          RecurringWeekState(
            UnmodifiableSetView({
              day.weekday,
              DateTime.monday,
            }),
            false,
            day,
            noEnd,
          ),
          RecurringWeekState(
            UnmodifiableSetView({
              day.weekday,
              DateTime.monday,
            }),
            true,
            day,
            noEnd,
          ),
          RecurringWeekState(
            UnmodifiableSetView({
              day.weekday,
              DateTime.monday,
            }),
            true,
            newStartDate,
            noEnd,
          ),
        ],
      ),
    );
  });

  test('Changing to every other week on even week on EditActivityBloc',
      () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: day,
    );
    final initialState = editActivityBloc.state;

    final recurringWeekBloc = RecurringWeekBloc(editActivityBloc);

    final activity1 = initialState.activity.copyWith(
      recurs: Recurs.weeklyOnDay(day.weekday),
    );
    final activity2 = initialState.activity.copyWith(
      recurs: Recurs.weeklyOnDays([day.weekday, DateTime.monday]),
    );
    final activity3 = initialState.activity.copyWith(
      recurs: Recurs.biWeeklyOnDays(
        odds: {
          day.weekday,
          DateTime.monday,
        },
      ),
    );

    // Act
    recurringWeekBloc.add(AddOrRemoveWeekday(DateTime.monday));
    recurringWeekBloc.add(ChangeEveryOtherWeek(true));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        initialState.copyWith(activity1),
        initialState.copyWith(activity2),
        initialState.copyWith(activity3),
      ]),
    );

    // Arrange
    final newStartDay = day.add(7.days());
    final newTimeInterval =
        initialState.timeInterval.copyWith(startDate: newStartDay);

    final activity4 = initialState.activity.copyWith(
      recurs: Recurs.biWeeklyOnDays(
        evens: {
          day.weekday,
          DateTime.monday,
        },
      ),
    );

    // Act
    editActivityBloc.add(ChangeDate(newStartDay));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        initialState.copyWith(activity3, timeInterval: newTimeInterval),
        initialState.copyWith(activity4, timeInterval: newTimeInterval),
      ]),
    );
  });
}
