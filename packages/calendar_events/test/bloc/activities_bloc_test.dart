import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/auth.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:seagull_fakes/all.dart';
import 'package:utils/utils.dart';

void main() {
  final anyTime = DateTime(2020, 03, 28, 15, 20);
  final anyDay = DateTime(2020, 03, 28);

  late ActivitiesCubit activitiesCubit;
  late MockActivityRepository mockActivityRepository;
  late SyncBloc mockSyncBloc;
  late SyncBloc syncBloc;
  late LicenseCubit mockLicenseCubit;

  setUp(() async {
    mockActivityRepository = MockActivityRepository();
    mockSyncBloc = MockSyncBloc();
    mockLicenseCubit = MockLicenseCubit();

    when(() => mockActivityRepository.save(any()))
        .thenAnswer((_) => Future.value(true));

    when(() => mockLicenseCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockLicenseCubit.state).thenAnswer((_) => ValidLicense());
    when(() => mockLicenseCubit.validLicense).thenAnswer((_) => true);

    syncBloc = SyncBloc(
      pushCubit: FakePushCubit(),
      licenseCubit: FakeLicenseCubit(),
      activityRepository: FakeDataRepository(),
      userFileRepository: FakeDataRepository(),
      sortableRepository: FakeDataRepository(),
      genericRepository: FakeDataRepository(),
      lastSyncDb: FakeLastSyncDb(),
      clockCubit: ClockCubit.fixed(DateTime(2000)),
      syncDelay: Duration.zero,
      retryDelay: Duration.zero,
    );

    activitiesCubit = ActivitiesCubit(
      activityRepository: mockActivityRepository,
      syncBloc: mockSyncBloc,
      analytics: FakeSeagullAnalytics(),
    );
  });

  group('ActivitiesCubit', () {
    final storedActivity = Activity.createNew(
          title: 'title',
          startTime: DateTime(1900),
          duration: 2.milliseconds(),
          alarmType: alarmSilentOnlyOnStart,
        ),
        activity1 = Activity.createNew(title: 'a1', startTime: anyTime),
        updatedActivity1 = activity1.copyWith(title: 'new title'),
        deletedStoredActivity = storedActivity.copyWith(deleted: true);

    blocTest('AddActivity calls save activities on mockActivityRepository',
        build: () => ActivitiesCubit(
              activityRepository: mockActivityRepository,
              syncBloc: mockSyncBloc,
              analytics: FakeSeagullAnalytics(),
            ),
        act: (ActivitiesCubit cubit) async {
          cubit.notifyChange();
          await cubit.addActivity(activity1);
        },
        expect: () => [
              isA<ActivitiesChanged>(),
              isA<ActivitiesChanged>(),
            ],
        verify: (bloc) async {
          verify(() => mockActivityRepository.save([activity1]));
          verify(() => mockSyncBloc.add(const SyncActivities()));
        });

    blocTest('UpdateActivities calls save activities on mockActivityRepository',
        build: () => ActivitiesCubit(
              activityRepository: mockActivityRepository,
              syncBloc: mockSyncBloc,
              analytics: FakeSeagullAnalytics(),
            ),
        act: (ActivitiesCubit cubit) async =>
            cubit.addActivity(updatedActivity1),
        expect: () => [
              isA<ActivitiesChanged>(),
            ],
        verify: (bloc) async {
          verify(() => mockActivityRepository.save([updatedActivity1]));
          verify(() => mockSyncBloc.add(const SyncActivities()));
        });

    blocTest(
        'DeleteActivities calls save activities with deleted activity on mockActivityRepository',
        build: () => ActivitiesCubit(
              activityRepository: mockActivityRepository,
              syncBloc: mockSyncBloc,
              analytics: FakeSeagullAnalytics(),
            ),
        act: (ActivitiesCubit cubit) async {
          cubit.notifyChange();
          await cubit.addActivity(storedActivity.copyWith(deleted: true));
        },
        expect: () => [
              isA<ActivitiesChanged>(),
              isA<ActivitiesChanged>(),
            ],
        verify: (bloc) async {
          verify(() => mockActivityRepository.save([deletedStoredActivity]));
          verify(() => mockSyncBloc.add(const SyncActivities()));
        });

    test('Nothing happens when UnSynced is emitted', () async {
      // Arrange
      activitiesCubit = ActivitiesCubit(
        activityRepository: mockActivityRepository,
        syncBloc: syncBloc,
        analytics: FakeSeagullAnalytics(),
      );

      // Act
      syncBloc.emit(const SyncedFailed());

      // Assert
      await expectLater(
        activitiesCubit.stream,
        emitsInOrder([]),
      );
    });

    test(
        'Activities are loaded when Synced is emitted with didFetchData = true',
        () async {
      // Arrange
      activitiesCubit = ActivitiesCubit(
        activityRepository: mockActivityRepository,
        syncBloc: syncBloc,
        analytics: FakeSeagullAnalytics(),
      );

      // Act
      syncBloc.emit(const Synced(didFetchData: true));

      // Assert
      await expectLater(
        activitiesCubit.stream,
        emitsInOrder([
          isA<ActivitiesChanged>(),
        ]),
      );
    });

    blocTest(
      'Activities are not loaded when Synced is emitted with didFetchData = false',
      build: () {
        activitiesCubit = ActivitiesCubit(
          activityRepository: mockActivityRepository,
          syncBloc: syncBloc,
          analytics: FakeSeagullAnalytics(),
        );
        syncBloc.emit(const Synced(didFetchData: false));
        return activitiesCubit;
      },
      expect: () => [], // no event emitted
    );
  });

  group('Delete recurring activity', () {
    test('Delete All days recurring deletes all with seriesId', () async {
      // Arrange
      final recurringActivity = FakeActivity.reoccursFridays(anyTime);
      final recurringActivity2 = recurringActivity.copyWith(newId: true);

      when(() => mockActivityRepository.getBySeries(recurringActivity.seriesId))
          .thenAnswer((_) => Future.value([
                recurringActivity,
                recurringActivity2,
              ]));

      // Act
      activitiesCubit.notifyChange();
      await activitiesCubit.deleteRecurringActivity(
          ActivityDay(recurringActivity, anyDay), ApplyTo.allDays);

      // Assert calls save with deleted recurring
      verify(() => mockActivityRepository.save([
            recurringActivity,
            recurringActivity2
          ].map((a) => a.copyWith(deleted: true))));
      verify(() => mockSyncBloc.add(const SyncActivities()));
    });

    group('Only this day', () {
      test('for first day edits start time', () async {
        // Arrange
        final inAWeek = anyDay.add(7.days());
        final orgRecurringActivity = FakeActivity.reoccursFridays(anyTime);
        final recurringActivity = orgRecurringActivity
            .copyWithRecurringEnd(inAWeek.millisecondBefore());
        final recurringActivity2 = orgRecurringActivity.copyWith(
          newId: true,
          startTime: inAWeek,
        );

        when(() =>
                mockActivityRepository.getBySeries(recurringActivity.seriesId))
            .thenAnswer(
                (_) => Future.value([recurringActivity, recurringActivity2]));

        final expectedRecurring =
            recurringActivity.copyWith(startTime: anyTime.nextDay());

        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.deleteRecurringActivity(
            ActivityDay(recurringActivity, anyDay), ApplyTo.onlyThisDay);

        // Assert calls save with deleted recurring
        verify(() => mockActivityRepository.save([
              expectedRecurring,
            ]));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });

      test('for last day edits end time', () async {
        // Arrange
        final orgRecurringActivity = FakeActivity.reoccursFridays(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final in6Days = inAWeek.previousDay();
        final recurringActivity = orgRecurringActivity
            .copyWithRecurringEnd(inAWeek.onlyDays().millisecondBefore());
        final recurringActivity2 = orgRecurringActivity.copyWith(
          newId: true,
          title: 'other title',
          startTime: inAWeek,
        );

        when(() =>
                mockActivityRepository.getBySeries(recurringActivity.seriesId))
            .thenAnswer(
                (_) => Future.value([recurringActivity, recurringActivity2]));

        final expectedRecurring =
            recurringActivity.copyWithRecurringEnd(in6Days.millisecondBefore());

        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.deleteRecurringActivity(
          ActivityDay(recurringActivity, in6Days),
          ApplyTo.onlyThisDay,
        );

        // Assert calls save with deleted recurring
        verify(() => mockActivityRepository.save([
              expectedRecurring,
            ]));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });

      test('for a mid day splits the activity up', () async {
        // Arrange
        final recurringActivity = FakeActivity.reoccursFridays(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final inAWeekdays = inAWeek.onlyDays();

        final activityList = [recurringActivity];

        when(() =>
                mockActivityRepository.getBySeries(recurringActivity.seriesId))
            .thenAnswer((_) => Future.value(activityList));

        final expectedRecurring1 = recurringActivity
            .copyWithRecurringEnd(inAWeekdays.millisecondBefore());
        final expectedRecurring2 = recurringActivity.copyWith(
          newId: true,
          startTime: inAWeek.nextDay(),
        );

        final expectedActivityList = [
          expectedRecurring1,
          expectedRecurring2,
        ];

        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.deleteRecurringActivity(
          ActivityDay(recurringActivity, inAWeek.onlyDays()),
          ApplyTo.onlyThisDay,
        );

        // Assert calls save with deleted recurring
        verify(() => mockActivityRepository
            .save(any(that: MatchActivitiesWithoutId(expectedActivityList))));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });
    });

    group('This day and forward', () {
      test('for first day deletes all with seriesId', () async {
        // Arrange
        final inAWeek = anyDay.add(7.days());
        final orgRecurringActivity = FakeActivity.reoccursFridays(anyTime);
        final recurringActivity = orgRecurringActivity
            .copyWithRecurringEnd(inAWeek.millisecondBefore());
        final recurringActivity2 = orgRecurringActivity.copyWith(
          newId: true,
          startTime: inAWeek,
        );

        when(() =>
                mockActivityRepository.getBySeries(recurringActivity.seriesId))
            .thenAnswer(
                (_) => Future.value([recurringActivity, recurringActivity2]));

        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.deleteRecurringActivity(
          ActivityDay(recurringActivity, anyDay),
          ApplyTo.thisDayAndForward,
        );

        // Assert calls save with deleted recurring
        verify(() => mockActivityRepository.save([
              recurringActivity,
              recurringActivity2
            ].map((a) => a.copyWith(deleted: true))));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });

      test('for a day modifies end time on activity', () async {
        // Arrange
        final inAWeek = anyDay.add(7.days());
        final recurringActivity = FakeActivity.reoccursFridays(anyTime);
        final recurringActivityWithEndTime =
            recurringActivity.copyWithRecurringEnd(inAWeek.millisecondBefore());

        when(() =>
                mockActivityRepository.getBySeries(recurringActivity.seriesId))
            .thenAnswer((_) => Future.value([recurringActivity]));

        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.deleteRecurringActivity(
          ActivityDay(recurringActivity, inAWeek),
          ApplyTo.thisDayAndForward,
        );

        // Assert calls save with deleted recurring
        verify(
            () => mockActivityRepository.save([recurringActivityWithEndTime]));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });

      test('for a day modifies end time on activity and deletes future series',
          () async {
        // Arrange
        final inTwoWeeks = anyDay.add(14.days());
        final inAWeek = anyDay.add(7.days());

        final orgRecurringActivity = FakeActivity.reoccursFridays(anyTime);

        final recurringActivity1 = orgRecurringActivity.copyWithRecurringEnd(
          inTwoWeeks.millisecondBefore(),
        );
        final recurringActivity2 = orgRecurringActivity.copyWith(
          newId: true,
          startTime:
              inTwoWeeks.copyWith(hour: anyTime.hour, minute: anyTime.minute),
        );

        when(() => mockActivityRepository
                .getBySeries(orgRecurringActivity.seriesId))
            .thenAnswer(
                (_) => Future.value([recurringActivity1, recurringActivity2]));

        final recurringActivity1AfterDelete = recurringActivity1
            .copyWithRecurringEnd(inAWeek.millisecondBefore());
        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.deleteRecurringActivity(
          ActivityDay(recurringActivity1, inAWeek),
          ApplyTo.thisDayAndForward,
        );

        // Assert calls save with deleted recurring
        verify(() => mockActivityRepository.save([
              recurringActivity2.copyWith(deleted: true),
              recurringActivity1AfterDelete,
            ]));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });
    });
  });

  group('Update recurring activity', () {
    group('Only this day', () {
      test('on a recurring only spanning one day just updates that activity',
          () async {
        // Arrange
        final recurring = FakeActivity.reoccursEveryDay(anyTime)
            .copyWithRecurringEnd(anyDay.nextDay().millisecondBefore());
        when(() => mockActivityRepository.getBySeries(recurring.seriesId))
            .thenAnswer((_) => Future.value([recurring]));
        final startTime = anyTime.subtract(1.hours());
        final updated = recurring.copyWith(
          title: 'new title',
          startTime: startTime,
        );

        final expected = updated.copyWith(recurs: Recurs.not);
        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.updateRecurringActivity(
          ActivityDay(updated, anyDay),
          ApplyTo.onlyThisDay,
        );

        // Assert calls save
        verify(() => mockActivityRepository.save([expected]));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });

      test('on first day split activity in two and updates the activity',
          () async {
        // Arrange
        final recurring = FakeActivity.reoccursEveryDay(anyTime)
            .copyWithRecurringEnd(anyDay.add(5.days()).millisecondBefore());
        when(() => mockActivityRepository.getBySeries(recurring.seriesId))
            .thenAnswer((_) => Future.value([recurring]));

        final startTime = recurring.startTime.subtract(1.hours());
        final updated =
            recurring.copyWith(title: 'new title', startTime: startTime);

        final expectedUpdatedActivity = updated.copyWith(
          newId: true,
          recurs: Recurs.not,
        );
        final updatedOldActivity =
            recurring.copyWith(startTime: recurring.startTime.nextDay());

        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.updateRecurringActivity(
          ActivityDay(updated, anyDay),
          ApplyTo.onlyThisDay,
        );

        // Assert calls save
        verify(() => mockActivityRepository.save(any(
            that: MatchActivitiesWithoutId(
                [expectedUpdatedActivity, updatedOldActivity]))));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });

      test('on last day split activity in two and updates the activity',
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

        when(() => mockActivityRepository.getBySeries(recurring.seriesId))
            .thenAnswer((_) => Future.value([recurring]));

        final newStartTime = recurring.startClock(lastDay).subtract(1.hours());
        final updated =
            recurring.copyWith(title: 'new title', startTime: newStartTime);

        final expectedUpdatedActivity = updated.copyWith(
          recurs: Recurs.not,
          newId: true,
        );
        final expectedUpdatedOldActivity =
            recurring.copyWithRecurringEnd(lastDay.millisecondBefore());

        final expected = MatchActivitiesWithoutId(
            [expectedUpdatedOldActivity, expectedUpdatedActivity]);

        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.updateRecurringActivity(
          ActivityDay(updated, lastDay),
          ApplyTo.onlyThisDay,
        );

        // Assert calls save
        verify(() => mockActivityRepository.save(any(that: expected)));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });

      test(
          'on a day split in middle activity in three and updates the activity',
          () async {
        // Arrange
        final updatedDay = anyDay.add(5.days()).onlyDays();
        final recurring = Activity.createNew(
          title: 'title',
          startTime: anyTime,
          recurs: const Recurs.raw(
            Recurs.typeWeekly,
            Recurs.allDaysOfWeek,
            noEnd,
          ),
        );

        when(() => mockActivityRepository.getBySeries(recurring.seriesId))
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
        activitiesCubit.notifyChange();
        await activitiesCubit.updateRecurringActivity(
          ActivityDay(updated, updatedDay),
          ApplyTo.onlyThisDay,
        );

        // Assert calls save
        verify(() => mockActivityRepository.save(any(that: expected)));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });

      test('fullDay split', () async {
        // Arrange
        final aDay = DateTime(2020, 04, 01);
        final recurring = FakeActivity.reoccursEveryDay(anyTime);
        when(() => mockActivityRepository.getBySeries(recurring.seriesId))
            .thenAnswer((_) => Future.value([recurring]));

        final fullDay = recurring.copyWith(
            title: 'new title',
            alarmType: noAlarm,
            reminderBefore: [],
            fullDay: true,
            duration: 1.days() - 1.milliseconds(),
            startTime: aDay);

        final expectedUpdatedActivity = fullDay.copyWith(
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
        activitiesCubit.notifyChange();
        await activitiesCubit.updateRecurringActivity(
          ActivityDay(fullDay, aDay),
          ApplyTo.onlyThisDay,
        );

        // Assert calls save
        verify(() => mockActivityRepository.save(any(that: expected)));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });
    });

    group('This day and forward', () {
      test('on first day, just updates the activity', () async {
        // Arrange
        final recurringActivity = FakeActivity.reoccursFridays(anyTime);
        final updatedRecurringActivity =
            recurringActivity.copyWith(title: 'new title');

        when(() =>
                mockActivityRepository.getBySeries(recurringActivity.seriesId))
            .thenAnswer((_) => Future.value([recurringActivity]));

        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.updateRecurringActivity(
          ActivityDay(updatedRecurringActivity, anyDay),
          ApplyTo.thisDayAndForward,
        );

        // Assert calls save with deleted recurring
        verify(() => mockActivityRepository.save([updatedRecurringActivity]));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });

      test('on second day splits the activity ', () async {
        // Arrange
        final recurringActivity = FakeActivity.reoccursFridays(anyTime);
        final aDay = anyDay.add(2.days()).onlyDays();
        final updatedRecurringActivity = recurringActivity.copyWith(
            title: 'new title', startTime: aDay.copyWith(hour: 4, minute: 4));

        final beforeModifiedDay = recurringActivity.copyWithRecurringEnd(
          aDay.millisecondBefore(),
          newId: true,
        );
        final onAndAfterModifiedDay = updatedRecurringActivity.copyWith();

        when(() =>
                mockActivityRepository.getBySeries(recurringActivity.seriesId))
            .thenAnswer((_) => Future.value([recurringActivity]));

        final expected = [beforeModifiedDay, onAndAfterModifiedDay];

        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.updateRecurringActivity(
          ActivityDay(
            updatedRecurringActivity,
            aDay,
          ),
          ApplyTo.thisDayAndForward,
        );

        verify(() => mockActivityRepository
            .save(any(that: MatchActivitiesWithoutId(expected))));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });

      test('change on occurrence backwards ', () async {
        // Arrange
        final recurringActivity = FakeActivity.reoccursEveryDay(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final inTwoWeek = anyTime.copyWith(day: anyTime.day + 14);

        final updatedRecurringActivity =
            recurringActivity.copyWith(title: 'new title', startTime: inAWeek);

        when(() =>
                mockActivityRepository.getBySeries(recurringActivity.seriesId))
            .thenAnswer((_) => Future.value([recurringActivity]));

        final expectedPreModified = recurringActivity.copyWithRecurringEnd(
          inAWeek.onlyDays().millisecondBefore(),
          newId: true,
        );
        final expectedList = [expectedPreModified, updatedRecurringActivity];

        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.updateRecurringActivity(
          ActivityDay(
            updatedRecurringActivity,
            inTwoWeek.onlyDays(),
          ),
          ApplyTo.thisDayAndForward,
        );

        verify(() => mockActivityRepository
            .save(any(that: MatchActivitiesWithoutId(expectedList))));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });

      test('change on occurrence forward ', () async {
        // Arrange
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final inTwoWeeks = anyTime.copyWith(day: anyTime.day + 14);
        final inFourWeeks = anyTime.copyWith(day: anyTime.day + 4 * 7);

        final recurringActivity = FakeActivity.reoccursEveryDay(anyTime)
            .copyWithRecurringEnd(inFourWeeks);

        final updatedRecurringActivity = recurringActivity.copyWith(
            title: 'new title', startTime: inTwoWeeks);

        when(() =>
                mockActivityRepository.getBySeries(recurringActivity.seriesId))
            .thenAnswer((_) => Future.value([recurringActivity]));

        final expectedPreModified = recurringActivity.copyWithRecurringEnd(
          inTwoWeeks.onlyDays().millisecondBefore(),
          newId: true,
        );
        final expectedList = [expectedPreModified, updatedRecurringActivity];

        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.updateRecurringActivity(
          ActivityDay(
            updatedRecurringActivity,
            inAWeek.onlyDays(),
          ),
          ApplyTo.thisDayAndForward,
        );

        verify(() => mockActivityRepository
            .save(any(that: MatchActivitiesWithoutId(expectedList))));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });

      test('changes all future activities in series ', () async {
        // Arrange
        final inFiveDays = anyTime.copyWith(day: anyTime.day + 5);
        final inSevenDays = anyTime.copyWith(day: anyTime.day + 7);
        final inNineDays = anyTime.copyWith(day: anyTime.day + 8);
        final in12Days = anyTime.copyWith(day: anyTime.day + 12);

        final org = FakeActivity.reoccursEveryDay(anyTime);
        final before = org
            .copyWith(title: 'original')
            .copyWithRecurringEnd(inSevenDays.onlyDays().millisecondBefore());

        final after = org.copyWith(
            newId: true,
            startTime: inNineDays,
            fullDay: true,
            title: 'now full day');

        final stray = org.copyWith(
          newId: true,
          startTime: in12Days,
          duration: 10.minutes(),
          recurs: Recurs.not,
          title: 'a stray',
        );

        final stray2 = org
            .copyWith(
                newId: true,
                startTime: inFiveDays,
                duration: 66.minutes(),
                title: 'a second stray')
            .copyWithRecurringEnd(inFiveDays.add(66.minutes()));

        final currentActivities = [before, after, stray, stray2];
        when(() => mockActivityRepository.getBySeries(org.seriesId))
            .thenAnswer((_) => Future.value(currentActivities));

        const newTitle = 'newTitle';
        final newTime = inFiveDays.add(2.hours());
        final newDuration = 30.minutes();

        final updatedRecurringActivity = stray2.copyWith(
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

        final expectedList = <Activity>[
          beforePostMod,
          updatedRecurringActivity,
          beforeSplitPostMod,
          afterPostMod,
          strayPostMod
        ];

        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.updateRecurringActivity(
          ActivityDay(
            updatedRecurringActivity,
            inFiveDays.onlyDays(),
          ),
          ApplyTo.thisDayAndForward,
        );

        verify(() => mockActivityRepository
            .save(any(that: MatchActivitiesWithoutId(expectedList))));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });

      test("don't edited activity before", () async {
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
        when(() => mockActivityRepository.getBySeries(a1.seriesId))
            .thenAnswer((_) => Future.value([a1, a2, a3]));

        const newTitle = 'updated';
        final newTime = DateTime(2020, 04, 08, 13, 00);
        final updatedA2 = a2.copyWith(title: 'updated', startTime: newTime);

        final a2Part1 =
            a2.copyWithRecurringEnd(newTime.onlyDays().millisecondBefore());

        final expectedA3 = a3.copyWith(title: newTitle);

        // Act
        activitiesCubit.notifyChange();
        await activitiesCubit.updateRecurringActivity(
          ActivityDay(
            updatedA2,
            newTime.onlyDays(),
          ),
          ApplyTo.thisDayAndForward,
        );

        verify(() => mockActivityRepository.save(any(
            that: MatchActivitiesWithoutId([a2Part1, updatedA2, expectedA3]))));
        verify(() => mockSyncBloc.add(const SyncActivities()));
      });
    });
  });

  tearDown(() async {
    return activitiesCubit.close();
  });
}
