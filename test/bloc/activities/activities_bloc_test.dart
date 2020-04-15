import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sync/sync_bloc.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../matchers.dart';
import '../../mocks.dart';

void main() {
  final anyTime = DateTime(2020, 03, 28, 15, 20);
  final anyDay = DateTime(2020, 03, 28);

  ActivitiesBloc activitiesBloc;
  MockActivityRepository mockActivityRepository;
  MockPushBloc mockPushBloc;
  MockSyncBloc mockSyncBloc;
  setUp(() {
    mockActivityRepository = MockActivityRepository();
    mockPushBloc = MockPushBloc();
    mockSyncBloc = MockSyncBloc();

    activitiesBloc = ActivitiesBloc(
      activityRepository: mockActivityRepository,
      pushBloc: mockPushBloc,
      syncBloc: mockSyncBloc,
    );
  });

  group('ActivitiesBloc', () {
    test('initial state is ActivitiesNotLoaded', () {
      expect(activitiesBloc.initialState, ActivitiesNotLoaded());
    });

    test('load activities calls load activities on mockActivityRepostitory',
        () async {
      activitiesBloc.add(LoadActivities());
      await untilCalled(mockActivityRepository.load());
      verify(mockActivityRepository.load());
    });

    test('LoadActivities event returns ActivitiesLoaded state', () {
      final expected = [ActivitiesNotLoaded(), ActivitiesLoaded([])];
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[]));

      expectLater(
        activitiesBloc,
        emitsInOrder(expected),
      );
      activitiesBloc.add(LoadActivities());
    });

    test('LoadActivities event returns ActivitiesLoaded state with Activity',
        () {
      final exptectedActivity = Activity.createNew(
          title: 'title',
          startTime: 1,
          duration: 2,
          reminderBefore: [],
          alarmType: ALARM_SILENT_ONLY_ON_START,
          category: 0);
      final expectedStates = [
        ActivitiesNotLoaded(),
        ActivitiesLoaded([exptectedActivity])
      ];
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[exptectedActivity]));

      expectLater(
        activitiesBloc,
        emitsInOrder(expectedStates),
      );
      activitiesBloc.add(LoadActivities());
    });

    test('calls add activities on mockActivityRepostitory', () async {
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[]));
      final anActivity = FakeActivity.starts(anyTime);
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
      activitiesBloc.add(AddActivity(anActivity));
      await untilCalled(mockActivityRepository.save(any));
      await untilCalled(mockSyncBloc.add(ActivitySaved()));

      verify(mockActivityRepository.save([anActivity]));
      verify(mockSyncBloc.add(ActivitySaved()));
    });

    test('AddActivity calls add activities on mockActivityRepostitory',
        () async {
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[]));
      final anActivity = FakeActivity.starts(anyTime);
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
      activitiesBloc.add(AddActivity(anActivity));

      await untilCalled(mockActivityRepository.save(any));
      await untilCalled(mockSyncBloc.add(ActivitySaved()));
    });

    test('UpdateActivities calls save activities on mockActivityRepostitory',
        () async {
      final anActivity = FakeActivity.starts(anyTime);

      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[anActivity]));
      activitiesBloc.add(LoadActivities());

      final updatedActivity = anActivity.copyWith(title: 'new title');
      activitiesBloc.add(UpdateActivity(updatedActivity));

      await untilCalled(mockActivityRepository.save([updatedActivity]));
      await untilCalled(mockSyncBloc.add(ActivitySaved()));
    });

    test('DeleteActivities calls save activities on mockActivityRepostitory',
        () async {
      // Arrange
      final anActivity = FakeActivity.starts(anyTime);
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[anActivity]));
      activitiesBloc.add(LoadActivities());
      final deletedActivity = anActivity.copyWith(deleted: true);

      // Act
      activitiesBloc.add(DeleteActivity(anActivity));

      // Assert
      await untilCalled(mockActivityRepository.save([deletedActivity]));
      await untilCalled(mockSyncBloc.add(ActivitySaved()));
    });

    test('DeleteActivities does not yeild the deleted activity', () async {
      // Arrange
      final activity1 = FakeActivity.starts(anyTime);
      final activity2 = FakeActivity.starts(anyTime);
      final activity3 = FakeActivity.starts(anyTime);
      final activity4 = FakeActivity.starts(anyTime);
      final fullActivityList = [
        activity1,
        activity2,
        activity3,
        activity4,
      ];
      final activityListDeleted = [
        activity1,
        activity2,
        activity4,
      ].followedBy({});
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(fullActivityList));

      activitiesBloc.add(LoadActivities());

      // Act
      activitiesBloc.add(DeleteActivity(activity3));

      // Assert
      final expectedResponse = [
        ActivitiesNotLoaded(),
        ActivitiesLoaded(fullActivityList),
        ActivitiesLoaded(activityListDeleted),
      ];

      await expectLater(
        activitiesBloc,
        emitsInOrder(expectedResponse),
      );
      verify(mockSyncBloc.add(ActivitySaved()));
    });

    test('UpdateActivities state order', () async {
      // Arrange
      final anActivity = FakeActivity.starts(anyTime);
      final activityList = [anActivity];
      final updatedActivity = anActivity.copyWith(title: 'new title');
      final updatedActivityList = [updatedActivity];

      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activityList));
      when(mockActivityRepository.save(updatedActivityList))
          .thenAnswer((_) => Future.value(updatedActivityList));

      // Act
      activitiesBloc.add(LoadActivities());
      activitiesBloc.add(UpdateActivity(updatedActivity));

      // Assert
      final expectedResponse = [
        ActivitiesNotLoaded(),
        ActivitiesLoaded(activityList),
        ActivitiesLoaded(updatedActivityList.followedBy([])),
      ];

      await expectLater(
        activitiesBloc,
        emitsInOrder(expectedResponse),
      );
      verify(mockSyncBloc.add(ActivitySaved()));
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

      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activityList));

      // Act
      activitiesBloc.add(LoadActivities());
      activitiesBloc.add(
          DeleteRecurringActivity(recurrringActivity, ApplyTo.allDays, anyDay));

      // Assert
      await expectLater(
        activitiesBloc,
        emitsInOrder([
          ActivitiesNotLoaded(),
          ActivitiesLoaded(activityList),
          ActivitiesLoaded([anActivity].followedBy([])),
        ]),
      );
      // Assert calls save with deleted recurring
      verify(mockActivityRepository.save([
        recurrringActivity,
        recurrringActivity2
      ].map((a) => a.copyWith(deleted: true))));
      verify(mockSyncBloc.add(ActivitySaved()));
    });

    group('Only this day', () {
      test('for first day edits start time', () async {
        // Arrange
        final anActivity = FakeActivity.starts(anyTime);
        final inAWeek = anyDay.add(7.days()).millisecondsSinceEpoch;
        final ogRecurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final recurrringActivity =
            ogRecurrringActivity.copyWith(endTime: inAWeek - 1);
        final recurrringActivity2 = ogRecurrringActivity.copyWith(
          newId: true,
          startTime: inAWeek,
        );

        final activityList = [
          anActivity,
          recurrringActivity,
          recurrringActivity2
        ];

        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value(activityList));

        final expextedRecurring = recurrringActivity.copyWith(
            startTime: anyTime.nextDay().millisecondsSinceEpoch);

        final activityList2 = [
          anActivity,
          expextedRecurring,
          recurrringActivity2
        ];
        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(DeleteRecurringActivity(
            recurrringActivity, ApplyTo.onlyThisDay, anyDay));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded(activityList),
            ActivitiesLoaded(activityList2.followedBy({})),
          ]),
        );
        // Assert calls save with deleted recurring
        verify(mockActivityRepository.save([
          expextedRecurring,
        ]));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('for last day edits end time', () async {
        // Arrange
        final anActivity = FakeActivity.starts(anyTime);
        final ogRecurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final in6Days = inAWeek.previousDay();
        final recurrringActivity = ogRecurrringActivity.copyWith(
            endTime: inAWeek.onlyDays().millisecondsSinceEpoch - 1);
        final recurrringActivity2 = ogRecurrringActivity.copyWith(
          newId: true,
          title: 'other title',
          startTime: inAWeek.millisecondsSinceEpoch,
        );

        final activityList = [
          anActivity,
          recurrringActivity,
          recurrringActivity2
        ];

        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value(activityList));

        final expextedRecurring = recurrringActivity.copyWith(
            endTime: in6Days.millisecondsSinceEpoch - 1);

        final activityList2 = [
          anActivity,
          expextedRecurring,
          recurrringActivity2
        ];
        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(DeleteRecurringActivity(
            recurrringActivity, ApplyTo.onlyThisDay, in6Days));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded(activityList),
            ActivitiesLoaded(activityList2.followedBy({})),
          ]),
        );
        // Assert calls save with deleted recurring
        verify(mockActivityRepository.save([
          expextedRecurring,
        ]));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('for a mid day splits the activity up', () async {
        // Arrange
        final recurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final inAWeekDays = inAWeek.onlyDays();

        final activityList = [recurrringActivity];

        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value(activityList));

        final expextedRecurring1 = recurrringActivity.copyWith(
            endTime: inAWeekDays.millisecondsSinceEpoch - 1);
        final expextedRecurring2 = recurrringActivity.copyWith(
          newId: true,
          startTime: inAWeek.nextDay().millisecondsSinceEpoch,
        );

        final expectedActivityList = [
          expextedRecurring1,
          expextedRecurring2,
        ];

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(DeleteRecurringActivity(
            recurrringActivity, ApplyTo.onlyThisDay, inAWeek.onlyDays()));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded(activityList),
            MatchActivitiesWithoutId(expectedActivityList),
          ]),
        );
        // Assert calls save with deleted recurring
        verify(mockActivityRepository
            .save(argThat(MatchActivitiesWithoutId(expectedActivityList))));
        verify(mockSyncBloc.add(ActivitySaved()));
      });
    });

    group('This day and forward', () {
      test('for first day deletes all with seriesId', () async {
        // Arrange
        final anActivity = FakeActivity.starts(anyTime);
        final inAWeek = anyDay.add(7.days()).millisecondsSinceEpoch;
        final ogRecurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final recurrringActivity =
            ogRecurrringActivity.copyWith(endTime: inAWeek - 1);
        final recurrringActivity2 = ogRecurrringActivity.copyWith(
          newId: true,
          startTime: inAWeek,
        );

        final activityList = [
          anActivity,
          recurrringActivity,
          recurrringActivity2
        ];

        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value(activityList));

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(DeleteRecurringActivity(
            recurrringActivity, ApplyTo.thisDayAndForward, anyDay));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded(activityList),
            ActivitiesLoaded([anActivity].followedBy({})),
          ]),
        );
        // Assert calls save with deleted recurring
        verify(mockActivityRepository.save([
          recurrringActivity,
          recurrringActivity2
        ].map((a) => a.copyWith(deleted: true))));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('for a day modifies end time on activity', () async {
        // Arrange
        final inAWeek = anyDay.add(7.days());
        final recurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final recurrringActivityWithEndTime = recurrringActivity.copyWith(
            endTime: inAWeek.millisecondsSinceEpoch - 1);

        final activityList = [recurrringActivity];

        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value(activityList));

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(DeleteRecurringActivity(
            recurrringActivity, ApplyTo.thisDayAndForward, inAWeek));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded(activityList),
            ActivitiesLoaded([recurrringActivityWithEndTime].followedBy({})),
          ]),
        );
        // Assert calls save with deleted recurring
        verify(mockActivityRepository.save([recurrringActivityWithEndTime]));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('for a day modifies end time on activity and deletes future series',
          () async {
        // Arrange
        final inTwoWeeks = anyDay.add(14.days());
        final inAWeek = anyDay.add(7.days());

        final ogRecurrringActivity = FakeActivity.reocurrsFridays(anyTime);

        final recurrringActivity1 = ogRecurrringActivity.copyWith(
          endTime: inTwoWeeks.millisecondsSinceEpoch - 1,
        );
        final recurrringActivity2 = ogRecurrringActivity.copyWith(
          newId: true,
          startTime: inTwoWeeks
              .copyWith(hour: anyTime.hour, minute: anyTime.minute)
              .millisecondsSinceEpoch,
        );

        final activityList = [recurrringActivity1, recurrringActivity2];

        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value(activityList));

        final recurrringActivity1AfterDelete = recurrringActivity1.copyWith(
            endTime: inAWeek.millisecondsSinceEpoch - 1);
        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(DeleteRecurringActivity(
            recurrringActivity1, ApplyTo.thisDayAndForward, inAWeek));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded(activityList),
            ActivitiesLoaded([recurrringActivity1AfterDelete].followedBy({})),
          ]),
        );
        // Assert calls save with deleted recurring
        verify(mockActivityRepository.save([
          recurrringActivity2.copyWith(deleted: true),
          recurrringActivity1AfterDelete,
        ]));
        verify(mockSyncBloc.add(ActivitySaved()));
      });
    });
  });

  group('Update recurring activity', () {
    group('Only this day', () {
      test('on a recurring only spanning one day just updates that activity',
          () async {
        // Arrange
        final recurring = FakeActivity.reocurrsEveryDay(anyTime)
            .copyWith(endTime: anyDay.nextDay().millisecondsSinceEpoch - 1);
        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value([recurring]));
        final starttime = anyTime.subtract(1.hours()).millisecondsSinceEpoch;
        final updated = recurring.copyWith(
            title: 'new title',
            startTime: starttime,
            endTime: starttime + recurring.duration);

        final expected = updated.copyWith(recurrentData: 0, recurrentType: 0);
        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc
            .add(UpdateRecurringActivity(updated, ApplyTo.onlyThisDay, anyDay));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded([recurring]),
            ActivitiesLoaded([expected].followedBy([])),
          ]),
        );

        // Assert calls save
        verify(mockActivityRepository.save([expected]));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('on first day split activity in two and updates the activty ',
          () async {
        // Arrange
        final recurring = FakeActivity.reocurrsEveryDay(anyTime)
            .copyWith(endTime: anyDay.add(5.days()).millisecondsSinceEpoch - 1);
        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value([recurring]));

        final starttime =
            recurring.start.subtract(1.hours()).millisecondsSinceEpoch;
        final updated =
            recurring.copyWith(title: 'new title', startTime: starttime);

        final expcetedUpdatedActivity = updated.copyWith(
          newId: true,
          endTime: starttime + recurring.duration,
          recurrentData: 0,
          recurrentType: 0,
        );
        final updatedOldActivity = recurring.copyWith(
            startTime: recurring.start.nextDay().millisecondsSinceEpoch);

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc
            .add(UpdateRecurringActivity(updated, ApplyTo.onlyThisDay, anyDay));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded([recurring]),
            MatchActivitiesWithoutId(
                [expcetedUpdatedActivity, updatedOldActivity]),
          ]),
        );

        // Assert calls save
        verify(mockActivityRepository.save(argThat(MatchActivitiesWithoutId(
            [expcetedUpdatedActivity, updatedOldActivity]))));
        verify(mockSyncBloc.add(ActivitySaved()));
      });
      test('on last day split activity in two and updates the activty ',
          () async {
        // Arrange
        final startTime = DateTime(2020, 01, 01, 15, 20);
        final lastDay = DateTime(2020, 05, 05);
        final lastDayEndTime =
            DateTime(2020, 05, 06).millisecondsSinceEpoch - 1;
        final recurring = FakeActivity.reocurrsEveryDay(startTime)
            .copyWith(endTime: lastDayEndTime);
        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value([recurring]));

        final newStartTime = recurring
            .startClock(lastDay)
            .subtract(1.hours())
            .millisecondsSinceEpoch;
        final updated =
            recurring.copyWith(title: 'new title', startTime: newStartTime);

        final expectedUpdatedActivity = updated.copyWith(
          newId: true,
          endTime: newStartTime + recurring.duration,
          recurrentData: 0,
          recurrentType: 0,
        );
        final exptectedUpdatedOldActivity =
            recurring.copyWith(endTime: lastDay.millisecondsSinceEpoch - 1);

        final exptected = MatchActivitiesWithoutId(
            [exptectedUpdatedOldActivity, expectedUpdatedActivity]);

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(
            UpdateRecurringActivity(updated, ApplyTo.onlyThisDay, lastDay));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded([recurring]),
            exptected,
          ]),
        );

        // Assert calls save
        verify(mockActivityRepository.save(argThat(exptected)));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('on a day split activity in three and updates the activty ',
          () async {
        // Arrange
        final aDay = anyDay.add(5.days()).onlyDays();
        final recurring = FakeActivity.reocurrsEveryDay(anyTime);
        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value([recurring]));

        final updated = recurring.copyWith(
            title: 'new title',
            startTime: aDay
                .copyWith(hour: anyTime.hour - 1, minute: anyTime.millisecond)
                .millisecondsSinceEpoch);

        final expectedUpdatedActivity = updated.copyWith(
          newId: true,
          endTime: updated.startTime + updated.duration,
          recurrentType: 0,
          recurrentData: 0,
        );
        final preModDaySeries =
            recurring.copyWith(endTime: aDay.millisecondsSinceEpoch - 1);
        final postModDaySeries = recurring.copyWith(
            newId: true,
            startTime: aDay
                .nextDay()
                .copyWith(
                    hour: recurring.start.hour, minute: recurring.start.minute)
                .millisecondsSinceEpoch);

        final expected = MatchActivitiesWithoutId(
            [preModDaySeries, expectedUpdatedActivity, postModDaySeries]);

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc
            .add(UpdateRecurringActivity(updated, ApplyTo.onlyThisDay, aDay));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded([recurring]),
            expected,
          ]),
        );

        // Assert calls save
        verify(mockActivityRepository.save(argThat(expected)));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('fullday split', () async {
        // Arrange
        final aDay = DateTime(2020, 04, 01);
        final recurring = FakeActivity.reocurrsEveryDay(anyTime);
        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value([recurring]));

        final fullday = recurring.copyWith(
            title: 'new title',
            alarmType: NO_ALARM,
            reminderBefore: [],
            fullDay: true,
            duration: 1.days().inMilliseconds - 1,
            startTime: aDay.millisecondsSinceEpoch);

        final expectedUpdatedActivity = fullday.copyWith(
          newId: true,
          endTime: aDay.nextDay().millisecondsSinceEpoch - 1,
          recurrentType: 0,
          recurrentData: 0,
        );

        final preModDaySeries =
            recurring.copyWith(endTime: aDay.millisecondsSinceEpoch - 1);
        final postModDaySeries = recurring.copyWith(
            newId: true,
            startTime: aDay
                .nextDay()
                .copyWith(
                    hour: recurring.start.hour, minute: recurring.start.minute)
                .millisecondsSinceEpoch);

        final expected = MatchActivitiesWithoutId(
            [preModDaySeries, expectedUpdatedActivity, postModDaySeries]);

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc
            .add(UpdateRecurringActivity(fullday, ApplyTo.onlyThisDay, aDay));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded([recurring]),
            expected,
          ]),
        );

        // Assert calls save
        verify(mockActivityRepository.save(argThat(expected)));
        verify(mockSyncBloc.add(ActivitySaved()));
      });
    });

    group('This day and forward', () {
      test('on first day, just updates the activty ', () async {
        // Arrange
        final recurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final updatedRecurrringActivity =
            recurrringActivity.copyWith(title: 'new title');

        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value([recurrringActivity]));

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
            updatedRecurrringActivity, ApplyTo.thisDayAndForward, anyDay));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded([recurrringActivity]),
            ActivitiesLoaded([updatedRecurrringActivity].followedBy([])),
          ]),
        );

        // Assert calls save with deleted recurring
        verify(mockActivityRepository.save([updatedRecurrringActivity]));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('on second day splits the activity ', () async {
        // Arrange
        final recurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final aDay = anyDay.add(2.days()).onlyDays();
        final updatedRecurrringActivity = recurrringActivity.copyWith(
            title: 'new title',
            startTime:
                aDay.copyWith(hour: 4, minute: 4).millisecondsSinceEpoch);

        final beforeModifiedDay = recurrringActivity.copyWith(
          newId: true,
          endTime: aDay.millisecondsSinceEpoch - 1,
        );
        final onAndAfterModifiedDay = updatedRecurrringActivity.copyWith();

        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value([recurrringActivity]));

        final exptected = [beforeModifiedDay, onAndAfterModifiedDay];

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          updatedRecurrringActivity,
          ApplyTo.thisDayAndForward,
          aDay,
        ));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded([recurrringActivity]),
            MatchActivitiesWithoutId(exptected),
          ]),
        );
        verify(mockActivityRepository
            .save(argThat(MatchActivitiesWithoutId(exptected))));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('change on occourance backwards ', () async {
        // Arrange
        final recurrringActivity = FakeActivity.reocurrsEveryDay(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final inTwoWeek = anyTime.copyWith(day: anyTime.day + 14);

        final updatedRecurrringActivity = recurrringActivity.copyWith(
            title: 'new title', startTime: inAWeek.millisecondsSinceEpoch);

        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value([recurrringActivity]));

        final expectedPreModified = recurrringActivity.copyWith(
            newId: true,
            endTime: inAWeek.onlyDays().millisecondsSinceEpoch - 1);
        final exptectedList = [expectedPreModified, updatedRecurrringActivity];

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          updatedRecurrringActivity,
          ApplyTo.thisDayAndForward,
          inTwoWeek.onlyDays(),
        ));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded([recurrringActivity]),
            MatchActivitiesWithoutId(exptectedList),
          ]),
        );

        verify(mockActivityRepository
            .save(argThat(MatchActivitiesWithoutId(exptectedList))));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('change on occourance forward ', () async {
        // Arrange
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final inTwoWeeks = anyTime.copyWith(day: anyTime.day + 14);
        final inFourWeeks = anyTime.copyWith(day: anyTime.day + 4 * 7);

        final recurrringActivity = FakeActivity.reocurrsEveryDay(anyTime)
            .copyWith(endTime: inFourWeeks.millisecondsSinceEpoch);

        final updatedRecurrringActivity = recurrringActivity.copyWith(
            title: 'new title', startTime: inTwoWeeks.millisecondsSinceEpoch);

        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value([recurrringActivity]));

        final expectedPreModified = recurrringActivity.copyWith(
            newId: true,
            endTime: inTwoWeeks.onlyDays().millisecondsSinceEpoch - 1);
        final exptectedList = [expectedPreModified, updatedRecurrringActivity];

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          updatedRecurrringActivity,
          ApplyTo.thisDayAndForward,
          inAWeek.onlyDays(),
        ));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded([recurrringActivity]),
            MatchActivitiesWithoutId(exptectedList),
          ]),
        );

        verify(mockActivityRepository
            .save(argThat(MatchActivitiesWithoutId(exptectedList))));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('changes all future activities in series ', () async {
        // Arrange
        final inFiveDays = anyTime.copyWith(day: anyTime.day + 5);
        final inSevenDays = anyTime.copyWith(day: anyTime.day + 7);
        final inNineDays = anyTime.copyWith(day: anyTime.day + 8);
        final in12Days = anyTime.copyWith(day: anyTime.day + 12);

        final og = FakeActivity.reocurrsEveryDay(anyTime);
        final before = og.copyWith(
            endTime: inSevenDays.onlyDays().millisecondsSinceEpoch - 1,
            title: 'original');

        final after = og.copyWith(
            newId: true,
            startTime: inNineDays.millisecondsSinceEpoch,
            fullDay: true,
            title: 'now full day');

        final stray = og.copyWith(
            newId: true,
            startTime: in12Days.millisecondsSinceEpoch,
            duration: 10.minutes().inMilliseconds,
            endTime:
                in12Days.millisecondsSinceEpoch + 10.minutes().inMilliseconds,
            recurrentData: 0,
            recurrentType: 0,
            title: 'a stray');

        final stray2 = og.copyWith(
            newId: true,
            startTime: inFiveDays.millisecondsSinceEpoch,
            endTime: inFiveDays.add(66.minutes()).millisecondsSinceEpoch,
            duration: 66.minutes().inMilliseconds,
            title: 'a second stray');

        final currentActivities = [before, after, stray, stray2];
        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value(currentActivities));

        final newTitle = 'newTitle';
        final newTime = inFiveDays.add(2.hours());
        final newDuration = 30.minutes().inMilliseconds;

        final updatedRecurrringActivity = stray2.copyWith(
          title: newTitle,
          startTime: newTime.millisecondsSinceEpoch,
          duration: newDuration,
          removeAfter: true,
        );

        final beforePostMod = before.copyWith(
            endTime: inFiveDays.onlyDays().millisecondsSinceEpoch - 1);

        final beforeSplitPostMod = before.copyWith(
          newId: true,
          title: newTitle,
          startTime: newTime.millisecondsSinceEpoch,
          duration: newDuration,
          removeAfter: true,
        );

        final afterPostMod = after.copyWith(
          title: newTitle,
          startTime: after.start
              .copyWith(hour: newTime.hour, minute: newTime.minute)
              .millisecondsSinceEpoch,
          duration: newDuration,
          fullDay: false,
          removeAfter: true,
        );
        final strayPostMod = stray.copyWith(
          title: newTitle,
          startTime: stray.start
              .copyWith(hour: newTime.hour, minute: newTime.minute)
              .millisecondsSinceEpoch,
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
          updatedRecurrringActivity,
          ApplyTo.thisDayAndForward,
          inFiveDays.onlyDays(),
        ));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded(currentActivities),
            MatchActivitiesWithoutId(exptectedList),
          ]),
        );

        verify(mockActivityRepository
            .save(argThat(MatchActivitiesWithoutId(exptectedList))));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('dont edited activity before ', () async {
        final a1Start = DateTime(2020, 04, 01, 13, 00).millisecondsSinceEpoch;
        final a1End = DateTime(2020, 04, 05).millisecondsSinceEpoch - 1;
        final a2Start = DateTime(2020, 04, 06, 13, 00).millisecondsSinceEpoch;
        final a2End = DateTime(10000).millisecondsSinceEpoch;
        final a3Time = DateTime(2020, 04, 18, 13, 00).millisecondsSinceEpoch;

        // Arrange
        final a1 = Activity.createNew(
            title: 'asdf',
            startTime: a1Start,
            endTime: a1End,
            recurrentType: 1,
            recurrentData: 16383);
        final a2 = a1.copyWith(
            newId: true,
            title: 'asdf',
            startTime: a2Start,
            endTime: a2End,
            recurrentType: 1,
            recurrentData: 16383);
        final a3 = a2.copyWith(
          newId: true,
          title: 'Moved',
          startTime: a3Time,
          endTime: a3Time,
          recurrentData: 0,
          recurrentType: 0,
        );

        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value([a1, a2, a3]));

        final newTitle = 'updated';
        final newTime = DateTime(2020, 04, 08, 13, 00);
        final updatedA2 = a2.copyWith(
            title: 'updated', startTime: newTime.millisecondsSinceEpoch);

        final a2Part1 =
            a2.copyWith(endTime: newTime.onlyDays().millisecondsSinceEpoch - 1);

        final expectedA3 = a3.copyWith(title: newTitle);

        // Act
        activitiesBloc.add(LoadActivities());
        activitiesBloc.add(UpdateRecurringActivity(
          updatedA2,
          ApplyTo.thisDayAndForward,
          newTime.onlyDays(),
        ));

        // Assert
        await expectLater(
          activitiesBloc,
          emitsInOrder([
            ActivitiesNotLoaded(),
            ActivitiesLoaded([a1, a2, a3]),
            MatchActivitiesWithoutId([a1, a2Part1, updatedA2, expectedA3]),
          ]),
        );
        verify(mockActivityRepository.save(argThat(
            MatchActivitiesWithoutId([a2Part1, updatedA2, expectedA3]))));
        verify(mockSyncBloc.add(ActivitySaved()));
      });
    });
  });

  tearDown(() {
    activitiesBloc.close();
    mockPushBloc.close();
  });
}
