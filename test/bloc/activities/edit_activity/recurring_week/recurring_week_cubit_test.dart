import 'package:bloc_test/bloc_test.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  final day = DateTime(2020, 10, 06);

  blocTest(
    'Initial state',
    build: () => RecurringWeekCubit(
      EditActivityBloc.edit(
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
          Recurs.noEndDate,
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
            EditActivityBloc.edit(
              ActivityDay(
                Activity.createNew(
                    title: 'null',
                    startTime: day,
                    recurs: Recurs.weeklyOnDay(day.weekday)),
                day,
              ),
            ),
          ),
      act: (RecurringWeekCubit cubit) {
        cubit.addOrRemoveWeekday(DateTime.monday);
        cubit.addOrRemoveWeekday(DateTime.wednesday);
        cubit.addOrRemoveWeekday(day.weekday);
      },
      expect: () => [
            RecurringWeekState(
              UnmodifiableSetView({
                day.weekday,
                DateTime.monday,
              }),
              false,
              day,
              Recurs.noEndDate,
            ),
            RecurringWeekState(
              UnmodifiableSetView({
                day.weekday,
                DateTime.monday,
                DateTime.wednesday,
              }),
              false,
              day,
              Recurs.noEndDate,
            ),
            RecurringWeekState(
              UnmodifiableSetView({
                DateTime.monday,
                DateTime.wednesday,
              }),
              false,
              day,
              Recurs.noEndDate,
            ),
          ]);

  final ad = ActivityDay(
    Activity.createNew(
        title: 'null', startTime: day, recurs: Recurs.weeklyOnDay(day.weekday)),
    day,
  );

  blocTest('Adding and removing days on EditActivityBloc',
      build: () => EditActivityBloc.edit(ad),
      act: (EditActivityBloc bloc) {
        final cubit = RecurringWeekCubit(bloc);
        cubit.addOrRemoveWeekday(DateTime.monday);
        cubit.addOrRemoveWeekday(DateTime.wednesday);
        cubit.addOrRemoveWeekday(day.weekday);
      },
      expect: () {
        final initialS = StoredActivityState(
          ad.activity,
          TimeInterval.fromDateTime(ad.activity.startClock(ad.day), null),
          day,
        );
        return [
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
        ];
      });

  blocTest('Changing to every other week',
      build: () => RecurringWeekCubit(
            EditActivityBloc.edit(
              ActivityDay(
                Activity.createNew(
                    title: 'null',
                    startTime: day,
                    recurs: Recurs.weeklyOnDay(day.weekday)),
                day,
              ),
            ),
          ),
      act: (RecurringWeekCubit cubit) {
        cubit.addOrRemoveWeekday(DateTime.monday);
        cubit.changeEveryOtherWeek(true);
      },
      expect: () => [
            RecurringWeekState(
              UnmodifiableSetView({
                day.weekday,
                DateTime.monday,
              }),
              false,
              day,
              Recurs.noEndDate,
            ),
            RecurringWeekState(
              UnmodifiableSetView({
                day.weekday,
                DateTime.monday,
              }),
              true,
              day,
              Recurs.noEndDate,
            ),
          ]);

  blocTest('Changing to every other week on EditActivityBloc',
      build: () => EditActivityBloc.edit(ad),
      act: (EditActivityBloc bloc) {
        final recurringWeekBloc = RecurringWeekCubit(bloc);

        // Act
        recurringWeekBloc.addOrRemoveWeekday(DateTime.monday);
        recurringWeekBloc.changeEveryOtherWeek(true);
      },
      expect: () {
        final initialS = StoredActivityState(
          ad.activity,
          TimeInterval.fromDateTime(ad.activity.startClock(ad.day), null),
          day,
        );
        return [
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
        ];
      });

  {
    final editActivityBloc = EditActivityBloc.edit(
      ActivityDay(
        Activity.createNew(
            title: 'null',
            startTime: day,
            recurs: Recurs.weeklyOnDay(day.weekday)),
        day,
      ),
    );
    final newStartDate = day.add(7.days());

    final noEnd = DateTime.fromMillisecondsSinceEpoch(Recurs.noEnd);
    blocTest(
      'Changing to every other week on even weeks',
      build: () => RecurringWeekCubit(editActivityBloc),
      act: (RecurringWeekCubit cubit) {
        final newStartDate = day.add(7.days());

        // Act
        cubit.addOrRemoveWeekday(DateTime.monday);
        cubit.changeEveryOtherWeek(true);
        editActivityBloc.add(ChangeDate(newStartDate));
      },
      expect: () => [
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
    final EditActivityState initialState = StoredActivityState(activity,
        TimeInterval.fromDateTime(activity.startClock(day), null), day);
    final TimeInterval newTimeInterval =
        initialState.timeInterval.copyWith(startDate: newStartDay);

    blocTest(
      'Changing to every other week on even week on EditActivityBloc',
      build: () => EditActivityBloc.edit(ActivityDay(activity, day)),
      act: (EditActivityBloc bloc) async {
        RecurringWeekCubit(bloc)
          ..addOrRemoveWeekday(DateTime.monday)
          ..changeEveryOtherWeek(true);
        await bloc.stream.any((element) => true);
        bloc.add(ChangeDate(newStartDay));
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
