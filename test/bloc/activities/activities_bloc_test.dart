import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sync/sync_bloc.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks/shared.mocks.dart';
import '../../test_helpers/matchers.dart';

void main() {
  final anyTime = DateTime(2020, 03, 28, 15, 20);
  final anyDay = DateTime(2020, 03, 28);

  late ActivitiesBloc activitiesBloc;
  late MockActivityRepository mockActivityRepository;
  late PushBloc mockPushBloc;
  late SyncBloc mockSyncBloc;
  setUp(() {
    mockActivityRepository = MockActivityRepository();
    mockPushBloc = MockPushBloc();
    mockSyncBloc = MockSyncBloc();
    when(mockPushBloc.stream).thenAnswer((_) => Stream.empty());
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value(<Activity>[]));
    when(mockActivityRepository.save(any))
        .thenAnswer((_) => Future.value(true));

    activitiesBloc = ActivitiesBloc(
      activityRepository: mockActivityRepository,
      pushBloc: mockPushBloc,
      syncBloc: mockSyncBloc,
    );
  });

  group('ActivitiesBloc', () {
    test('initial state is ActivitiesNotLoaded', () {
      expect(activitiesBloc.state, ActivitiesNotLoaded());
    });

    test('load activities calls load activities on mockActivityRepostitory',
        () async {
      activitiesBloc.add(LoadActivities());
      await untilCalled(mockActivityRepository.load());
      verify(mockActivityRepository.load());
    });

    test('LoadActivities event returns ActivitiesLoaded state', () async {
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[]));

      activitiesBloc.add(LoadActivities());
      await expectLater(
        activitiesBloc.stream,
        emits(ActivitiesLoaded([])),
      );
    });

    test('LoadActivities event returns ActivitiesLoaded state with Activity',
        () {
      final exptectedActivity = Activity.createNew(
        title: 'title',
        startTime: DateTime(1900),
        duration: 2.milliseconds(),
        alarmType: ALARM_SILENT_ONLY_ON_START,
      );

      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[exptectedActivity]));

      activitiesBloc.add(LoadActivities());
      expectLater(
        activitiesBloc.stream,
        emits(ActivitiesLoaded([exptectedActivity])),
      );
    });

    test('calls add activities on mockActivityRepostitory', () async {
      final anActivity = FakeActivity.starts(anyTime);
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.firstWhere((s) => s is ActivitiesLoaded);
      activitiesBloc.add(AddActivity(anActivity));
      await untilCalled(mockActivityRepository.save(any));
      await untilCalled(mockSyncBloc.add(ActivitySaved()));

      verify(mockActivityRepository.save([anActivity]));
      verify(mockSyncBloc.add(ActivitySaved()));
    });

    test('AddActivity calls add activities on mockActivityRepostitory',
        () async {
      final anActivity = FakeActivity.starts(anyTime);
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.firstWhere((s) => s is ActivitiesLoaded);
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
      await expectLater(
        activitiesBloc.stream,
        emitsInOrder([
          ActivitiesLoaded(fullActivityList),
          ActivitiesLoaded(activityListDeleted),
        ]),
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
          .thenAnswer((_) => Future.value(true));

      // Act
      activitiesBloc.add(LoadActivities());
      activitiesBloc.add(UpdateActivity(updatedActivity));

      // Assert
      await expectLater(
        activitiesBloc.stream,
        emitsInOrder([
          ActivitiesLoaded(activityList),
          ActivitiesLoaded(updatedActivityList.followedBy([])),
        ]),
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

        when(mockActivityRepository.load())
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

        when(mockActivityRepository.load())
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
        verify(mockActivityRepository
            .save(argThat(MatchActivitiesWithoutId(expectedActivityList))));
        verify(mockSyncBloc.add(ActivitySaved()));
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

        when(mockActivityRepository.load())
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
        final recurrringActivityWithEndTime = recurrringActivity
            .copyWithRecurringEnd(inAWeek.millisecondBefore());

        final activityList = [recurrringActivity];

        when(mockActivityRepository.load())
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
        verify(mockActivityRepository.save([recurrringActivityWithEndTime]));
        verify(mockSyncBloc.add(ActivitySaved()));
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

        when(mockActivityRepository.load())
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
            .copyWithRecurringEnd(anyDay.nextDay().millisecondBefore());
        when(mockActivityRepository.load())
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
        verify(mockActivityRepository.save([expected]));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('on first day split activity in two and updates the activty ',
          () async {
        // Arrange
        final recurring = FakeActivity.reocurrsEveryDay(anyTime)
            .copyWithRecurringEnd(anyDay.add(5.days()).millisecondBefore());
        when(mockActivityRepository.load())
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
        verify(mockActivityRepository.save(argThat(MatchActivitiesWithoutId(
            [expcetedUpdatedActivity, updatedOldActivity]))));
        verify(mockSyncBloc.add(ActivitySaved()));
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
            [
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

        when(mockActivityRepository.load())
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
        verify(mockActivityRepository.save(argThat(exptected)));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test(
          'on a day split in middle activity in three and updates the activty ',
          () async {
        // Arrange
        final updatedDay = anyDay.add(5.days()).onlyDays();
        final recurring = Activity.createNew(
          title: 'title',
          startTime: anyTime,
          recurs: Recurs.raw(
            Recurs.TYPE_WEEKLY,
            Recurs.allDaysOfWeek,
            Recurs.NO_END,
          ),
        );

        when(mockActivityRepository.load())
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
        verify(mockActivityRepository.save([updatedRecurrringActivity]));
        verify(mockSyncBloc.add(ActivitySaved()));
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

        when(mockActivityRepository.load())
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
        verify(mockActivityRepository
            .save(argThat(MatchActivitiesWithoutId(exptected))));
        verify(mockSyncBloc.add(ActivitySaved()));
      });

      test('change on occourance backwards ', () async {
        // Arrange
        final recurrringActivity = FakeActivity.reocurrsEveryDay(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final inTwoWeek = anyTime.copyWith(day: anyTime.day + 14);

        final updatedRecurrringActivity =
            recurrringActivity.copyWith(title: 'new title', startTime: inAWeek);

        when(mockActivityRepository.load())
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
            .copyWithRecurringEnd(inFourWeeks);

        final updatedRecurrringActivity = recurrringActivity.copyWith(
            title: 'new title', startTime: inTwoWeeks);

        when(mockActivityRepository.load())
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
        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value(currentActivities));

        final newTitle = 'newTitle';
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

        verify(mockActivityRepository
            .save(argThat(MatchActivitiesWithoutId(exptectedList))));
        verify(mockSyncBloc.add(ActivitySaved()));
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
            Recurs.TYPE_WEEKLY,
            16383,
            a1End.millisecondsSinceEpoch,
          ),
        );
        final a2 = a1.copyWith(
          newId: true,
          title: 'asdf',
          startTime: a2Start,
          recurs: Recurs.raw(
            Recurs.TYPE_WEEKLY,
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
        when(mockActivityRepository.load())
            .thenAnswer((_) => Future.value([a1, a2, a3]));

        final newTitle = 'updated';
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
