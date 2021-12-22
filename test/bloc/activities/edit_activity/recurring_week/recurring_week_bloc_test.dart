import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timezone/data/latest.dart' as tz;

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  final day = DateTime(2020, 10, 06);

  setUp(tz.initializeTimeZones);

  test('Initial state', () {
    // Arrange
    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(
        Activity.createNew(
            title: 'title',
            startTime: day,
            recurs: Recurs.weeklyOnDay(day.weekday)),
        day,
      ),
    );
    final initialS = editActivityCubit.state;

    final recurringWeekBloc = RecurringWeekBloc(editActivityCubit);

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
  });

  test('Adding and removing days', () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(
        Activity.createNew(
            title: 'null',
            startTime: day,
            recurs: Recurs.weeklyOnDay(day.weekday)),
        day,
      ),
    );

    final recurringWeekBloc = RecurringWeekBloc(editActivityCubit);

    // Act
    recurringWeekBloc.add(const AddOrRemoveWeekday(DateTime.monday));
    recurringWeekBloc.add(const AddOrRemoveWeekday(DateTime.wednesday));
    recurringWeekBloc.add(AddOrRemoveWeekday(day.weekday));

    await expectLater(
      recurringWeekBloc.stream,
      emitsInOrder(
        [
          RecurringWeekState(
            UnmodifiableSetView({
              day.weekday,
              DateTime.monday,
            }),
            false,
            editActivityCubit.state.timeInterval.startDate,
            Recurs.noEndDate,
          ),
          RecurringWeekState(
            UnmodifiableSetView({
              day.weekday,
              DateTime.monday,
              DateTime.wednesday,
            }),
            false,
            editActivityCubit.state.timeInterval.startDate,
            Recurs.noEndDate,
          ),
          RecurringWeekState(
            UnmodifiableSetView({
              DateTime.monday,
              DateTime.wednesday,
            }),
            false,
            editActivityCubit.state.timeInterval.startDate,
            Recurs.noEndDate,
          ),
        ],
      ),
    );
  });

  test('Adding and removing days on editActivityCubit', () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(
        Activity.createNew(
            title: 'null',
            startTime: day,
            recurs: Recurs.weeklyOnDay(day.weekday)),
        day,
      ),
    );
    final initialS = editActivityCubit.state;

    final recurringWeekBloc = RecurringWeekBloc(editActivityCubit);

    // Act
    recurringWeekBloc.add(const AddOrRemoveWeekday(DateTime.monday));
    recurringWeekBloc.add(const AddOrRemoveWeekday(DateTime.wednesday));
    recurringWeekBloc.add(AddOrRemoveWeekday(day.weekday));

    await expectLater(
      editActivityCubit.stream,
      emitsInOrder([
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
              const {
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
    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(
        Activity.createNew(
            title: 'null',
            startTime: day,
            recurs: Recurs.weeklyOnDay(day.weekday)),
        day,
      ),
    );

    final recurringWeekBloc = RecurringWeekBloc(editActivityCubit);

    // Act
    recurringWeekBloc.add(const AddOrRemoveWeekday(DateTime.monday));
    recurringWeekBloc.add(const ChangeEveryOtherWeek(true));

    await expectLater(
      recurringWeekBloc.stream,
      emitsInOrder(
        [
          RecurringWeekState(
            UnmodifiableSetView({
              day.weekday,
              DateTime.monday,
            }),
            false,
            editActivityCubit.state.timeInterval.startDate,
            Recurs.noEndDate,
          ),
          RecurringWeekState(
            UnmodifiableSetView({
              day.weekday,
              DateTime.monday,
            }),
            true,
            editActivityCubit.state.timeInterval.startDate,
            Recurs.noEndDate,
          ),
        ],
      ),
    );
  });

  test('Changing to every other week on editActivityCubit', () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(
        Activity.createNew(
            title: 'null',
            startTime: day,
            recurs: Recurs.weeklyOnDay(day.weekday)),
        day,
      ),
    );
    final initialS = editActivityCubit.state;

    final recurringWeekBloc = RecurringWeekBloc(editActivityCubit);

    // Act
    recurringWeekBloc.add(const AddOrRemoveWeekday(DateTime.monday));
    recurringWeekBloc.add(const ChangeEveryOtherWeek(true));

    await expectLater(
      editActivityCubit.stream,
      emitsInOrder([
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
    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(
        Activity.createNew(
            title: 'null',
            startTime: day,
            recurs: Recurs.weeklyOnDay(day.weekday)),
        day,
      ),
    );

    final recurringWeekBloc = RecurringWeekBloc(editActivityCubit);
    final newStartDate = day.add(7.days());
    final noEnd = DateTime.fromMillisecondsSinceEpoch(Recurs.noEnd);

    // Act
    recurringWeekBloc.add(const AddOrRemoveWeekday(DateTime.monday));
    recurringWeekBloc.add(const ChangeEveryOtherWeek(true));
    editActivityCubit.changeDate(newStartDate);

    await expectLater(
      recurringWeekBloc.stream,
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

  test('Changing to every other week on even week on editActivityCubit',
      () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(
        Activity.createNew(
            title: 'null',
            startTime: day,
            recurs: Recurs.weeklyOnDay(day.weekday)),
        day,
      ),
    );
    final initialState = editActivityCubit.state;

    final recurringWeekBloc = RecurringWeekBloc(editActivityCubit);
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
    recurringWeekBloc.add(const AddOrRemoveWeekday(DateTime.monday));
    await expectLater(
      editActivityCubit.stream,
      emits(
        initialState.copyWith(activity2),
      ),
    );
    recurringWeekBloc.add(const ChangeEveryOtherWeek(true));

    // Assert
    await expectLater(
      editActivityCubit.stream,
      emits(
        initialState.copyWith(activity3),
      ),
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
    editActivityCubit.changeDate(newStartDay);

    // Assert
    await expectLater(
      editActivityCubit.stream,
      emits(
        initialState.copyWith(activity4, timeInterval: newTimeInterval),
      ),
    );
  });
}
