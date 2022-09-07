import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../fakes/all.dart';
import '../../mocks/mock_bloc.dart';
import '../../mocks/mocks.dart';
import '../../test_helpers/matchers.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  final anyTime = DateTime(2020, 03, 28, 15, 20);
  final anyDay = DateTime(2020, 03, 28);

  late ActivitiesBloc activitiesBloc;
  late MockActivityRepository mockActivityRepository;
  late PushCubit mockPushCubit;
  late SyncBloc mockSyncBloc;
  late LicenseCubit mockLicenseCubit;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockActivityRepository = MockActivityRepository();
    mockPushCubit = MockPushCubit();
    mockSyncBloc = MockSyncBloc();
    mockLicenseCubit = MockLicenseCubit();

    when(() => mockPushCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockActivityRepository.save(any()))
        .thenAnswer((_) => Future.value(true));

    when(() => mockLicenseCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockLicenseCubit.state).thenAnswer((_) => ValidLicense());
    when(() => mockLicenseCubit.validLicense).thenAnswer((_) => true);

    activitiesBloc = ActivitiesBloc(
      activityRepository: mockActivityRepository,
      syncBloc: mockSyncBloc,
    );
  });

  group('ActivitiesBloc', () {
    blocTest(
      'initial state is ActivitiesNotLoaded',
      build: () => ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: mockSyncBloc,
      ),
      verify: (ActivitiesBloc bloc) => expect(
        bloc.state,
        ActivitiesNotLoaded(),
      ),
    );

    blocTest(
      'load activities calls load activities on mockActivityRepostitory',
      build: () => ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: mockSyncBloc,
      ),
      act: (ActivitiesBloc bloc) => bloc.add(LoadActivities()),
      verify: (ActivitiesBloc bloc) =>
          verify(() => mockActivityRepository.getAll()),
    );

    blocTest(
      'LoadActivities event returns ActivitiesLoaded state',
      setUp: () => when(() => mockActivityRepository.getAll())
          .thenAnswer((_) => Future.value(<Activity>[])),
      build: () => ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: mockSyncBloc,
      ),
      act: (ActivitiesBloc bloc) => bloc.add(LoadActivities()),
      expect: () => [ActivitiesLoaded(const [])],
    );

    final storedActivity = Activity.createNew(
          title: 'title',
          startTime: DateTime(1900),
          duration: 2.milliseconds(),
          alarmType: alarmSilentOnlyOnStart,
        ),
        activity1 = Activity.createNew(title: 'a1', startTime: anyTime),
        activity2 = Activity.createNew(title: 'a2', startTime: anyTime),
        activity3 = Activity.createNew(title: 'a3', startTime: anyTime),
        activity4 = Activity.createNew(title: 'a4', startTime: anyTime),
        updatedActivity1 = activity1.copyWith(title: 'new title'),
        deletedStoredActivity = storedActivity.copyWith(deleted: true);

    blocTest(
      'LoadActivities event returns ActivitiesLoaded state with Activity',
      setUp: () => when(() => mockActivityRepository.getAll())
          .thenAnswer((_) => Future.value(<Activity>[storedActivity])),
      build: () => ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: mockSyncBloc,
      ),
      act: (ActivitiesBloc bloc) => bloc.add(LoadActivities()),
      expect: () => [
        ActivitiesLoaded([storedActivity])
      ],
    );

    blocTest('calls add activities on mockActivityRepostitory',
        setUp: () => when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value(<Activity>[storedActivity])),
        build: () => ActivitiesBloc(
              activityRepository: mockActivityRepository,
              syncBloc: mockSyncBloc,
            ),
        act: (ActivitiesBloc bloc) => bloc
          ..add(LoadActivities())
          ..add(AddActivity(activity1)),
        expect: () => [
              ActivitiesLoaded([storedActivity]),
              ActivitiesLoaded([storedActivity, activity1])
            ],
        verify: (bloc) {
          verify(() => mockActivityRepository.save([activity1]));
          verify(() => mockSyncBloc.add(const ActivitySaved()));
        });

    blocTest(
        'UpdateActivities calls save activities on mockActivityRepostitory',
        setUp: () => when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value(<Activity>[activity1])),
        build: () => ActivitiesBloc(
              activityRepository: mockActivityRepository,
              syncBloc: mockSyncBloc,
            ),
        act: (ActivitiesBloc bloc) => bloc
          ..add(LoadActivities())
          ..add(UpdateActivity(updatedActivity1)),
        expect: () => [
              ActivitiesLoaded([activity1]),
              ActivitiesLoaded([updatedActivity1]),
            ],
        verify: (bloc) {
          verify(() => mockActivityRepository.save([updatedActivity1]));
          verify(() => mockSyncBloc.add(const ActivitySaved()));
        });

    blocTest(
        'DeleteActivities calls save activities on mockActivityRepostitory',
        setUp: () => when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value(<Activity>[storedActivity])),
        build: () => ActivitiesBloc(
              activityRepository: mockActivityRepository,
              syncBloc: mockSyncBloc,
            ),
        act: (ActivitiesBloc bloc) => bloc
          ..add(LoadActivities())
          ..add(DeleteActivity(storedActivity)),
        expect: () => [
              ActivitiesLoaded([storedActivity]),
              ActivitiesLoaded(const []),
            ],
        verify: (bloc) {
          verify(() => mockActivityRepository.save([deletedStoredActivity]));
          verify(() => mockSyncBloc.add(const ActivitySaved()));
        });

    final fullActivityList = [activity1, activity2, activity3, activity4],
        activityListDeleted = [activity1, activity2, activity4];
    blocTest(
      'DeleteActivities does not yeild the deleted activity',
      setUp: () => when(() => mockActivityRepository.getAll())
          .thenAnswer((_) => Future.value(fullActivityList)),
      build: () => ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: mockSyncBloc,
      ),
      act: (ActivitiesBloc bloc) => bloc
        ..add(LoadActivities())
        ..add(DeleteActivity(activity3)),
      expect: () => [
        ActivitiesLoaded(fullActivityList),
        ActivitiesLoaded(activityListDeleted),
      ],
      verify: (bloc) => verify(() => mockSyncBloc.add(const ActivitySaved())),
    );

    final updatedActivityList = [
      updatedActivity1,
      activity2,
      activity3,
      activity4
    ];
    blocTest(
      'UpdateActivities state order',
      setUp: () {
        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value(fullActivityList));
        when(() => mockActivityRepository.save(updatedActivityList))
            .thenAnswer((_) => Future.value(true));
      },
      build: () => ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: mockSyncBloc,
      ),
      act: (ActivitiesBloc bloc) => bloc
        ..add(LoadActivities())
        ..add(UpdateActivity(updatedActivity1)),
      expect: () => [
        ActivitiesLoaded(fullActivityList),
        ActivitiesLoaded(updatedActivityList),
      ],
      verify: (bloc) => verify(() => mockSyncBloc.add(const ActivitySaved())),
    );

    group('License', () {
      test('valid license will sync with repo', () async {
        final List<Activity> activityList = [activity1, activity2, activity3];
        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value(activityList));
        when(() => mockLicenseCubit.validLicense).thenAnswer((_) => true);
        activitiesBloc.add(LoadActivities());

        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded(activityList),
          ]),
        );
      });

      test('can add activity with no valid license, no sync', () async {
        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value(<Activity>[activity2, activity3]));
        when(() => mockLicenseCubit.validLicense).thenAnswer((_) => false);
        final expect = expectLater(
          activitiesBloc.stream,
          emits(
            ActivitiesLoaded([activity1]),
          ),
        );
        activitiesBloc.add(AddActivity(activity1));
        await expect;
      });
    });
  });

  group('Delete recurring activity', () {
    test('Delete All days recurring deletes all with seriesId', () async {
      // Arrange
      final anActivity = FakeActivity.starts(anyTime);
      final recurrringActivity = FakeActivity.reocurrsFridays(anyTime);
      final recurrringActivity2 = recurrringActivity.copyWith(newId: true);

      final activityList = [
        anActivity,
        recurrringActivity,
        recurrringActivity2
      ];

      when(() => mockActivityRepository.getAll())
          .thenAnswer((_) => Future.value(activityList));

      // Act
      activitiesBloc.add(LoadActivities());
      activitiesBloc.add(DeleteRecurringActivity(
          ActivityDay(recurrringActivity, anyDay), ApplyTo.allDays));

      // Assert
      await expectLater(
        activitiesBloc.stream,
        emitsInOrder([
          ActivitiesLoaded(activityList),
          ActivitiesLoaded([anActivity].followedBy([])),
        ]),
      );
      // Assert calls save with deleted recurring
      verify(() => mockActivityRepository.save([
            recurrringActivity,
            recurrringActivity2
          ].map((a) => a.copyWith(deleted: true))));
      verify(() => mockSyncBloc.add(const ActivitySaved()));
    });

    group('Only this day', () {
      test('for first day edits start time', () async {
        // Arrange
        final anActivity = FakeActivity.starts(anyTime);
        final inAWeek = anyDay.add(7.days());
        final ogRecurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final recurrringActivity = ogRecurrringActivity
            .copyWithRecurringEnd(inAWeek.millisecondBefore());
        final recurrringActivity2 = ogRecurrringActivity.copyWith(
          newId: true,
          startTime: inAWeek,
        );

        final activityList = [
          anActivity,
          recurrringActivity,
          recurrringActivity2
        ];

        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value(activityList));

        final expextedRecurring =
            recurrringActivity.copyWith(startTime: anyTime.nextDay());

        final activityList2 = [
          anActivity,
          expextedRecurring,
          recurrringActivity2
        ];
        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(DeleteRecurringActivity(
            ActivityDay(recurrringActivity, anyDay), ApplyTo.onlyThisDay));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded(activityList),
            ActivitiesLoaded(activityList2.followedBy({})),
          ]),
        );
        // Assert calls save with deleted recurring
        verify(() => mockActivityRepository.save([
              expextedRecurring,
            ]));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });

      test('for last day edits end time', () async {
        // Arrange
        final anActivity = FakeActivity.starts(anyTime);
        final ogRecurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final in6Days = inAWeek.previousDay();
        final recurrringActivity = ogRecurrringActivity
            .copyWithRecurringEnd(inAWeek.onlyDays().millisecondBefore());
        final recurrringActivity2 = ogRecurrringActivity.copyWith(
          newId: true,
          title: 'other title',
          startTime: inAWeek,
        );

        final activityList = [
          anActivity,
          recurrringActivity,
          recurrringActivity2
        ];

        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value(activityList));

        final expextedRecurring = recurrringActivity
            .copyWithRecurringEnd(in6Days.millisecondBefore());

        final activityList2 = [
          anActivity,
          expextedRecurring,
          recurrringActivity2
        ];
        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(DeleteRecurringActivity(
          ActivityDay(recurrringActivity, in6Days),
          ApplyTo.onlyThisDay,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded(activityList),
            ActivitiesLoaded(activityList2.followedBy({})),
          ]),
        );
        // Assert calls save with deleted recurring
        verify(() => mockActivityRepository.save([
              expextedRecurring,
            ]));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });

      test('for a mid day splits the activity up', () async {
        // Arrange
        final recurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final inAWeekDays = inAWeek.onlyDays();

        final activityList = [recurrringActivity];

        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value(activityList));

        final expextedRecurring1 = recurrringActivity
            .copyWithRecurringEnd(inAWeekDays.millisecondBefore());
        final expextedRecurring2 = recurrringActivity.copyWith(
          newId: true,
          startTime: inAWeek.nextDay(),
        );

        final expectedActivityList = [
          expextedRecurring1,
          expextedRecurring2,
        ];

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(DeleteRecurringActivity(
          ActivityDay(recurrringActivity, inAWeek.onlyDays()),
          ApplyTo.onlyThisDay,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded(activityList),
            MatchActivitiesWithoutId(expectedActivityList),
          ]),
        );
        // Assert calls save with deleted recurring
        verify(() => mockActivityRepository
            .save(any(that: MatchActivitiesWithoutId(expectedActivityList))));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });
    });

    group('This day and forward', () {
      test('for first day deletes all with seriesId', () async {
        // Arrange
        final anActivity = FakeActivity.starts(anyTime);
        final inAWeek = anyDay.add(7.days());
        final ogRecurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final recurrringActivity = ogRecurrringActivity
            .copyWithRecurringEnd(inAWeek.millisecondBefore());
        final recurrringActivity2 = ogRecurrringActivity.copyWith(
          newId: true,
          startTime: inAWeek,
        );

        final activityList = [
          anActivity,
          recurrringActivity,
          recurrringActivity2
        ];

        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value(activityList));

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(DeleteRecurringActivity(
          ActivityDay(recurrringActivity, anyDay),
          ApplyTo.thisDayAndForward,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded(activityList),
            ActivitiesLoaded([anActivity].followedBy({})),
          ]),
        );
        // Assert calls save with deleted recurring
        verify(() => mockActivityRepository.save([
              recurrringActivity,
              recurrringActivity2
            ].map((a) => a.copyWith(deleted: true))));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });

      test('for a day modifies end time on activity', () async {
        // Arrange
        final inAWeek = anyDay.add(7.days());
        final recurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final recurrringActivityWithEndTime = recurrringActivity
            .copyWithRecurringEnd(inAWeek.millisecondBefore());

        final activityList = [recurrringActivity];

        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value(activityList));

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(DeleteRecurringActivity(
            ActivityDay(recurrringActivity, inAWeek),
            ApplyTo.thisDayAndForward));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded(activityList),
            ActivitiesLoaded([recurrringActivityWithEndTime].followedBy({})),
          ]),
        );
        // Assert calls save with deleted recurring
        verify(
            () => mockActivityRepository.save([recurrringActivityWithEndTime]));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });

      test('for a day modifies end time on activity and deletes future series',
          () async {
        // Arrange
        final inTwoWeeks = anyDay.add(14.days());
        final inAWeek = anyDay.add(7.days());

        final ogRecurrringActivity = FakeActivity.reocurrsFridays(anyTime);

        final recurrringActivity1 = ogRecurrringActivity.copyWithRecurringEnd(
          inTwoWeeks.millisecondBefore(),
        );
        final recurrringActivity2 = ogRecurrringActivity.copyWith(
          newId: true,
          startTime:
              inTwoWeeks.copyWith(hour: anyTime.hour, minute: anyTime.minute),
        );

        final activityList = [recurrringActivity1, recurrringActivity2];

        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value(activityList));

        final recurrringActivity1AfterDelete = recurrringActivity1
            .copyWithRecurringEnd(inAWeek.millisecondBefore());
        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(DeleteRecurringActivity(
          ActivityDay(recurrringActivity1, inAWeek),
          ApplyTo.thisDayAndForward,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded(activityList),
            ActivitiesLoaded([recurrringActivity1AfterDelete].followedBy({})),
          ]),
        );
        // Assert calls save with deleted recurring
        verify(() => mockActivityRepository.save([
              recurrringActivity2.copyWith(deleted: true),
              recurrringActivity1AfterDelete,
            ]));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });
    });
  });

  group('Update recurring activity', () {
    group('Only this day', () {
      test('on a recurring only spanning one day just updates that activity',
          () async {
        // Arrange
        final recurring = FakeActivity.reocurrsEveryDay(anyTime)
            .copyWithRecurringEnd(anyDay.nextDay().millisecondBefore());
        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value([recurring]));
        final starttime = anyTime.subtract(1.hours());
        final updated = recurring.copyWith(
          title: 'new title',
          startTime: starttime,
        );

        final expected = updated.copyWith(recurs: Recurs.not);
        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          ActivityDay(updated, anyDay),
          ApplyTo.onlyThisDay,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded([recurring]),
            ActivitiesLoaded([expected].followedBy([])),
          ]),
        );

        // Assert calls save
        verify(() => mockActivityRepository.save([expected]));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });

      test('on first day split activity in two and updates the activty ',
          () async {
        // Arrange
        final recurring = FakeActivity.reocurrsEveryDay(anyTime)
            .copyWithRecurringEnd(anyDay.add(5.days()).millisecondBefore());
        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value([recurring]));

        final starttime = recurring.startTime.subtract(1.hours());
        final updated =
            recurring.copyWith(title: 'new title', startTime: starttime);

        final expcetedUpdatedActivity = updated.copyWith(
          newId: true,
          recurs: Recurs.not,
        );
        final updatedOldActivity =
            recurring.copyWith(startTime: recurring.startTime.nextDay());

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          ActivityDay(updated, anyDay),
          ApplyTo.onlyThisDay,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded([recurring]),
            MatchActivitiesWithoutId(
                [expcetedUpdatedActivity, updatedOldActivity]),
          ]),
        );

        // Assert calls save
        verify(() => mockActivityRepository.save(any(
            that: MatchActivitiesWithoutId(
                [expcetedUpdatedActivity, updatedOldActivity]))));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });

      test('on last day split activity in two and updates the activty ',
          () async {
        // Arrange
        final startTime = DateTime(2020, 01, 01, 15, 20);
        final lastDay = DateTime(2020, 05, 05);
        final lastDayEndTime = DateTime(2020, 05, 06).millisecondBefore();
        final recurring = Activity.createNew(
          title: 'null',
          startTime: startTime,
          recurs: Recurs.weeklyOnDays(
            const [
              DateTime.monday,
              DateTime.tuesday,
              DateTime.wednesday,
              DateTime.thursday,
              DateTime.friday,
              DateTime.saturday,
              DateTime.sunday,
            ],
            ends: lastDayEndTime,
          ),
        );

        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value([recurring]));

        final newStartTime = recurring.startClock(lastDay).subtract(1.hours());
        final updated =
            recurring.copyWith(title: 'new title', startTime: newStartTime);

        final expectedUpdatedActivity = updated.copyWith(
          recurs: Recurs.not,
          newId: true,
        );
        final exptectedUpdatedOldActivity =
            recurring.copyWithRecurringEnd(lastDay.millisecondBefore());

        final exptected = MatchActivitiesWithoutId(
            [exptectedUpdatedOldActivity, expectedUpdatedActivity]);

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          ActivityDay(updated, lastDay),
          ApplyTo.onlyThisDay,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded([recurring]),
            exptected,
          ]),
        );

        // Assert calls save
        verify(() => mockActivityRepository.save(any(that: exptected)));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });

      test(
          'on a day split in middle activity in three and updates the activty ',
          () async {
        // Arrange
        final updatedDay = anyDay.add(5.days()).onlyDays();
        final recurring = Activity.createNew(
          title: 'title',
          startTime: anyTime,
          recurs: const Recurs.raw(
            Recurs.typeWeekly,
            Recurs.allDaysOfWeek,
            Recurs.noEnd,
          ),
        );

        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value([recurring]));

        final updated = recurring.copyWith(
            title: 'new title',
            startTime: updatedDay.copyWith(
                hour: anyTime.hour - 1, minute: anyTime.millisecond));

        final expectedUpdatedActivity = updated.copyWith(
          recurs: Recurs.not,
          newId: true,
        );
        final preModDaySeries =
            recurring.copyWithRecurringEnd(updatedDay.millisecondBefore());
        final postModDaySeries = recurring.copyWith(
            newId: true,
            startTime: updatedDay.nextDay().copyWith(
                hour: recurring.startTime.hour,
                minute: recurring.startTime.minute));

        final expected = MatchActivitiesWithoutId(
            [preModDaySeries, expectedUpdatedActivity, postModDaySeries]);

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          ActivityDay(updated, updatedDay),
          ApplyTo.onlyThisDay,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded([recurring]),
            expected,
          ]),
        );

        // Assert calls save
        verify(() => mockActivityRepository.save(any(that: expected)));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });

      test('fullday split', () async {
        // Arrange
        final aDay = DateTime(2020, 04, 01);
        final recurring = FakeActivity.reocurrsEveryDay(anyTime);
        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value([recurring]));

        final fullday = recurring.copyWith(
            title: 'new title',
            alarmType: noAlarm,
            reminderBefore: [],
            fullDay: true,
            duration: 1.days() - 1.milliseconds(),
            startTime: aDay);

        final expectedUpdatedActivity = fullday.copyWith(
          newId: true,
          recurs: Recurs.not,
        );

        final preModDaySeries =
            recurring.copyWithRecurringEnd(aDay.millisecondBefore());
        final postModDaySeries = recurring.copyWith(
            newId: true,
            startTime: aDay.nextDay().copyWith(
                hour: recurring.startTime.hour,
                minute: recurring.startTime.minute));

        final expected = MatchActivitiesWithoutId(
            [preModDaySeries, expectedUpdatedActivity, postModDaySeries]);

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          ActivityDay(fullday, aDay),
          ApplyTo.onlyThisDay,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded([recurring]),
            expected,
          ]),
        );

        // Assert calls save
        verify(() => mockActivityRepository.save(any(that: expected)));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });
    });

    group('This day and forward', () {
      test('on first day, just updates the activty ', () async {
        // Arrange
        final recurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final updatedRecurrringActivity =
            recurrringActivity.copyWith(title: 'new title');

        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value([recurrringActivity]));

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          ActivityDay(updatedRecurrringActivity, anyDay),
          ApplyTo.thisDayAndForward,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded([recurrringActivity]),
            ActivitiesLoaded([updatedRecurrringActivity].followedBy([])),
          ]),
        );

        // Assert calls save with deleted recurring
        verify(() => mockActivityRepository.save([updatedRecurrringActivity]));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });

      test('on second day splits the activity ', () async {
        // Arrange
        final recurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final aDay = anyDay.add(2.days()).onlyDays();
        final updatedRecurrringActivity = recurrringActivity.copyWith(
            title: 'new title', startTime: aDay.copyWith(hour: 4, minute: 4));

        final beforeModifiedDay = recurrringActivity.copyWithRecurringEnd(
          aDay.millisecondBefore(),
          newId: true,
        );
        final onAndAfterModifiedDay = updatedRecurrringActivity.copyWith();

        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value([recurrringActivity]));

        final exptected = [beforeModifiedDay, onAndAfterModifiedDay];

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          ActivityDay(
            updatedRecurrringActivity,
            aDay,
          ),
          ApplyTo.thisDayAndForward,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded([recurrringActivity]),
            MatchActivitiesWithoutId(exptected),
          ]),
        );
        verify(() => mockActivityRepository
            .save(any(that: MatchActivitiesWithoutId(exptected))));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });

      test('change on occourance backwards ', () async {
        // Arrange
        final recurrringActivity = FakeActivity.reocurrsEveryDay(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final inTwoWeek = anyTime.copyWith(day: anyTime.day + 14);

        final updatedRecurrringActivity =
            recurrringActivity.copyWith(title: 'new title', startTime: inAWeek);

        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value([recurrringActivity]));

        final expectedPreModified = recurrringActivity.copyWithRecurringEnd(
          inAWeek.onlyDays().millisecondBefore(),
          newId: true,
        );
        final exptectedList = [expectedPreModified, updatedRecurrringActivity];

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          ActivityDay(
            updatedRecurrringActivity,
            inTwoWeek.onlyDays(),
          ),
          ApplyTo.thisDayAndForward,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded([recurrringActivity]),
            MatchActivitiesWithoutId(exptectedList),
          ]),
        );

        verify(() => mockActivityRepository
            .save(any(that: MatchActivitiesWithoutId(exptectedList))));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });

      test('change on occourance forward ', () async {
        // Arrange
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final inTwoWeeks = anyTime.copyWith(day: anyTime.day + 14);
        final inFourWeeks = anyTime.copyWith(day: anyTime.day + 4 * 7);

        final recurrringActivity = FakeActivity.reocurrsEveryDay(anyTime)
            .copyWithRecurringEnd(inFourWeeks);

        final updatedRecurrringActivity = recurrringActivity.copyWith(
            title: 'new title', startTime: inTwoWeeks);

        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value([recurrringActivity]));

        final expectedPreModified = recurrringActivity.copyWithRecurringEnd(
          inTwoWeeks.onlyDays().millisecondBefore(),
          newId: true,
        );
        final exptectedList = [expectedPreModified, updatedRecurrringActivity];

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          ActivityDay(
            updatedRecurrringActivity,
            inAWeek.onlyDays(),
          ),
          ApplyTo.thisDayAndForward,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded([recurrringActivity]),
            MatchActivitiesWithoutId(exptectedList),
          ]),
        );

        verify(() => mockActivityRepository
            .save(any(that: MatchActivitiesWithoutId(exptectedList))));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });

      test('changes all future activities in series ', () async {
        // Arrange
        final inFiveDays = anyTime.copyWith(day: anyTime.day + 5);
        final inSevenDays = anyTime.copyWith(day: anyTime.day + 7);
        final inNineDays = anyTime.copyWith(day: anyTime.day + 8);
        final in12Days = anyTime.copyWith(day: anyTime.day + 12);

        final og = FakeActivity.reocurrsEveryDay(anyTime);
        final before = og
            .copyWith(title: 'original')
            .copyWithRecurringEnd(inSevenDays.onlyDays().millisecondBefore());

        final after = og.copyWith(
            newId: true,
            startTime: inNineDays,
            fullDay: true,
            title: 'now full day');

        final stray = og.copyWith(
          newId: true,
          startTime: in12Days,
          duration: 10.minutes(),
          recurs: Recurs.not,
          title: 'a stray',
        );

        final stray2 = og
            .copyWith(
                newId: true,
                startTime: inFiveDays,
                duration: 66.minutes(),
                title: 'a second stray')
            .copyWithRecurringEnd(inFiveDays.add(66.minutes()));

        final currentActivities = [before, after, stray, stray2];
        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value(currentActivities));

        const newTitle = 'newTitle';
        final newTime = inFiveDays.add(2.hours());
        final newDuration = 30.minutes();

        final updatedRecurrringActivity = stray2.copyWith(
          title: newTitle,
          startTime: newTime,
          duration: newDuration,
          removeAfter: true,
        );

        final beforePostMod = before
            .copyWithRecurringEnd(inFiveDays.onlyDays().millisecondBefore());

        final beforeSplitPostMod = before.copyWith(
          newId: true,
          title: newTitle,
          startTime: newTime,
          duration: newDuration,
          removeAfter: true,
        );

        final afterPostMod = after.copyWith(
          title: newTitle,
          startTime: after.startTime
              .copyWith(hour: newTime.hour, minute: newTime.minute),
          duration: newDuration,
          fullDay: false,
          removeAfter: true,
        );
        final strayPostMod = stray.copyWith(
          title: newTitle,
          startTime: stray.startTime
              .copyWith(hour: newTime.hour, minute: newTime.minute),
          duration: newDuration,
          removeAfter: true,
        );

        final exptectedList = <Activity>[
          beforePostMod,
          updatedRecurrringActivity,
          beforeSplitPostMod,
          afterPostMod,
          strayPostMod
        ];

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          ActivityDay(
            updatedRecurrringActivity,
            inFiveDays.onlyDays(),
          ),
          ApplyTo.thisDayAndForward,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded(currentActivities),
            MatchActivitiesWithoutId(exptectedList),
          ]),
        );

        verify(() => mockActivityRepository
            .save(any(that: MatchActivitiesWithoutId(exptectedList))));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });

      test('dont edited activity before ', () async {
        final a1Start = DateTime(2020, 04, 01, 13, 00);
        final a1End = DateTime(2020, 04, 05).millisecondBefore();
        final a2Start = DateTime(2020, 04, 06, 13, 00);
        final a2End = DateTime(10000);
        final a3Time = DateTime(2020, 04, 18, 13, 00);

        // Arrange
        final a1 = Activity.createNew(
          title: 'asdf',
          startTime: a1Start,
          recurs: Recurs.raw(
            Recurs.typeWeekly,
            16383,
            a1End.millisecondsSinceEpoch,
          ),
        );
        final a2 = a1.copyWith(
          newId: true,
          title: 'asdf',
          startTime: a2Start,
          recurs: Recurs.raw(
            Recurs.typeWeekly,
            16383,
            a2End.millisecondsSinceEpoch,
          ),
        );
        final a3 = a2.copyWith(
          newId: true,
          title: 'Moved',
          startTime: a3Time,
          recurs: Recurs.not,
        );
        when(() => mockActivityRepository.getAll())
            .thenAnswer((_) => Future.value([a1, a2, a3]));

        const newTitle = 'updated';
        final newTime = DateTime(2020, 04, 08, 13, 00);
        final updatedA2 = a2.copyWith(title: 'updated', startTime: newTime);

        final a2Part1 =
            a2.copyWithRecurringEnd(newTime.onlyDays().millisecondBefore());

        final expectedA3 = a3.copyWith(title: newTitle);

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          ActivityDay(
            updatedA2,
            newTime.onlyDays(),
          ),
          ApplyTo.thisDayAndForward,
        ));

        // Assert
        await expectLater(
          activitiesBloc.stream,
          emitsInOrder([
            ActivitiesLoaded([a1, a2, a3]),
            MatchActivitiesWithoutId([a1, a2Part1, updatedA2, expectedA3]),
          ]),
        );
        verify(() => mockActivityRepository.save(any(
            that: MatchActivitiesWithoutId([a2Part1, updatedA2, expectedA3]))));
        verify(() => mockSyncBloc.add(const ActivitySaved()));
      });
    });
  });

  tearDown(() {
    activitiesBloc.close();
    mockPushCubit.close();
  });
}
