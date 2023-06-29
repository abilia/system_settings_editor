import 'package:bloc_test/bloc_test.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

void main() {
  final day = DateTime(2020, 10, 06);

  blocTest(
    'Initial state',
    build: () => RecurringWeekCubit(
      EditActivityCubit.edit(
        ActivityDay(
          Activity.createNew(
              title: 'title',
              startTime: day,
              recurs: Recurs.weeklyOnDay(day.weekday)),
          day,
        ),
      ),
    ),
    verify: (RecurringWeekCubit cubit) {
      expect(
        cubit.state,
        RecurringWeekState(
          UnmodifiableSetView({day.weekday}),
          false,
          day,
          noEndDate,
        ),
      );
      expect(
        cubit.state.recurs,
        Recurs.weeklyOnDays({day.weekday}),
      );
    },
  );

  blocTest('Adding and removing days',
      build: () => RecurringWeekCubit(
            EditActivityCubit.edit(
              ActivityDay(
                Activity.createNew(
                    title: 'null',
                    startTime: day,
                    recurs: Recurs.weeklyOnDay(day.weekday)),
                day,
              ),
            ),
          ),
      act: (RecurringWeekCubit cubit) => cubit
        ..addOrRemoveWeekday(DateTime.monday)
        ..addOrRemoveWeekday(DateTime.wednesday)
        ..addOrRemoveWeekday(day.weekday),
      expect: () => [
            RecurringWeekState(
              UnmodifiableSetView({
                day.weekday,
                DateTime.monday,
              }),
              false,
              day,
              noEndDate,
            ),
            RecurringWeekState(
              UnmodifiableSetView({
                day.weekday,
                DateTime.monday,
                DateTime.wednesday,
              }),
              false,
              day,
              noEndDate,
            ),
            RecurringWeekState(
              UnmodifiableSetView({
                DateTime.monday,
                DateTime.wednesday,
              }),
              false,
              day,
              noEndDate,
            ),
          ]);

  final activityDay = ActivityDay(
    Activity.createNew(
        title: 'null', startTime: day, recurs: Recurs.weeklyOnDay(day.weekday)),
    day,
  );

  blocTest('Adding and removing days on EditActivityBloc',
      build: () => EditActivityCubit.edit(activityDay),
      act: (EditActivityCubit bloc) {
        RecurringWeekCubit(bloc)
          ..addOrRemoveWeekday(DateTime.monday)
          ..addOrRemoveWeekday(DateTime.wednesday)
          ..addOrRemoveWeekday(day.weekday);
      },
      expect: () {
        final initialState = StoredActivityState(
          activityDay.activity,
          TimeInterval.fromDateTime(
            activityDay.activity.startClock(activityDay.day),
            null,
            noEndDate,
          ),
          day,
          RecurrentType.weekly,
        );
        return [
          initialState.copyWith(
            initialState.activity.copyWith(
              recurs: Recurs.weeklyOnDays(
                {
                  day.weekday,
                  DateTime.monday,
                },
              ),
            ),
          ),
          initialState.copyWith(
            initialState.activity.copyWith(
              recurs: Recurs.weeklyOnDays(
                {
                  day.weekday,
                  DateTime.monday,
                  DateTime.wednesday,
                },
              ),
            ),
          ),
          initialState.copyWith(
            initialState.activity.copyWith(
              recurs: Recurs.weeklyOnDays(
                const {
                  DateTime.monday,
                  DateTime.wednesday,
                },
              ),
            ),
          ),
        ];
      });

  blocTest('Changing to every other week',
      build: () => RecurringWeekCubit(
            EditActivityCubit.edit(
              ActivityDay(
                Activity.createNew(
                    title: 'null',
                    startTime: day,
                    recurs: Recurs.weeklyOnDay(day.weekday)),
                day,
              ),
            ),
          ),
      act: (RecurringWeekCubit cubit) => cubit
        ..addOrRemoveWeekday(DateTime.monday)
        ..changeEveryOtherWeek(true),
      expect: () => [
            RecurringWeekState(
              UnmodifiableSetView({
                day.weekday,
                DateTime.monday,
              }),
              false,
              day,
              noEndDate,
            ),
            RecurringWeekState(
              UnmodifiableSetView({
                day.weekday,
                DateTime.monday,
              }),
              true,
              day,
              noEndDate,
            ),
          ]);

  blocTest('Changing to every other week on EditActivityBloc',
      build: () => EditActivityCubit.edit(activityDay),
      act: (EditActivityCubit bloc) => RecurringWeekCubit(bloc)
        ..addOrRemoveWeekday(DateTime.monday)
        ..changeEveryOtherWeek(true),
      expect: () {
        final initialState = StoredActivityState(
          activityDay.activity,
          TimeInterval.fromDateTime(
              activityDay.activity.startClock(activityDay.day),
              null,
              noEndDate),
          day,
        );
        return [
          initialState.copyWith(
            initialState.activity.copyWith(
              recurs: Recurs.weeklyOnDays(
                {
                  day.weekday,
                  DateTime.monday,
                },
              ),
            ),
            selectedType: RecurrentType.weekly,
          ),
          initialState.copyWith(
            initialState.activity.copyWith(
              recurs: Recurs.biWeeklyOnDays(
                odds: {
                  day.weekday,
                  DateTime.monday,
                },
              ),
            ),
            selectedType: RecurrentType.weekly,
          ),
        ];
      });

  {
    final editActivityBloc = EditActivityCubit.edit(
      ActivityDay(
        Activity.createNew(
            title: 'null',
            startTime: day,
            recurs: Recurs.weeklyOnDay(day.weekday)),
        day,
      ),
    );
    final newStartDate = day.add(7.days());

    blocTest(
      'Changing to every other week on even weeks',
      build: () => RecurringWeekCubit(editActivityBloc),
      act: (RecurringWeekCubit cubit) {
        final newStartDate = day.add(7.days());
        // Act
        cubit
          ..addOrRemoveWeekday(DateTime.monday)
          ..changeEveryOtherWeek(true);
        editActivityBloc.changeStartDate(newStartDate);
      },
      expect: () => [
        RecurringWeekState(
          UnmodifiableSetView({
            day.weekday,
            DateTime.monday,
          }),
          false,
          day,
          noEndDate,
        ),
        RecurringWeekState(
          UnmodifiableSetView({
            day.weekday,
            DateTime.monday,
          }),
          true,
          day,
          noEndDate,
        ),
        RecurringWeekState(
          UnmodifiableSetView({
            day.weekday,
            DateTime.monday,
          }),
          true,
          newStartDate,
          noEndDate,
        ),
      ],
    );
  }

  {
    final activity = Activity.createNew(
          title: 'null',
          startTime: day,
          recurs: Recurs.weeklyOnDay(day.weekday),
        ),
        activity2 = activity.copyWith(
          recurs: Recurs.weeklyOnDays([day.weekday, DateTime.monday]),
        ),
        activity3 = activity.copyWith(
          recurs: Recurs.biWeeklyOnDays(
            odds: {
              day.weekday,
              DateTime.monday,
            },
          ),
        ),
        activity4 = activity.copyWith(
          recurs: Recurs.biWeeklyOnDays(
            evens: {
              day.weekday,
              DateTime.monday,
            },
          ),
        );
    final newStartDay = day.add(7.days());
    final EditActivityState initialState = StoredActivityState(
      activity,
      TimeInterval.fromDateTime(activity.startClock(day), null, noEndDate),
      day,
      RecurrentType.weekly,
    );
    final TimeInterval newTimeInterval =
        initialState.timeInterval.copyWith(startDate: newStartDay);

    blocTest(
      'Changing to every other week on even week on EditActivityBloc',
      build: () => EditActivityCubit.edit(ActivityDay(activity, day)),
      act: (EditActivityCubit bloc) async {
        final rwc = RecurringWeekCubit(bloc)
          ..addOrRemoveWeekday(DateTime.monday);
        await bloc.stream.any((element) => true);
        rwc.changeEveryOtherWeek(true);
        await bloc.stream.any((element) => true);
        bloc.changeStartDate(newStartDay);
      },
      expect: () => [
        initialState.copyWith(activity2),
        initialState.copyWith(activity3),
        initialState.copyWith(activity3, timeInterval: newTimeInterval),
        initialState.copyWith(activity4, timeInterval: newTimeInterval),
      ],
    );
  }
}
