import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/activities/edit_recurring_mixin.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../matchers.dart';

class _TestObject with EditRecurringMixin {}

void main() {
  final anyTime = DateTime(2020, 03, 28, 15, 20);
  final anyDay = DateTime(2020, 03, 28);
  EditRecurringMixin editRecurringMixin = _TestObject();

  group('Delete recurring activity', () {
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

        final activityList = {
          anActivity,
          recurrringActivity,
          recurrringActivity2
        };

        final expextedRecurring =
            recurrringActivity.copyWith(startTime: anyTime.nextDay());

        final exptectedNewState = [
          anActivity,
          expextedRecurring,
          recurrringActivity2
        ];
        // Act
        final result = editRecurringMixin.deleteOnlyThisDay(
            activity: recurrringActivity,
            activities: activityList,
            day: anyDay);

        // Assert
        expect(result.save, [expextedRecurring]);
        expect(result.state, exptectedNewState);
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

        final activitySet = {
          anActivity,
          recurrringActivity,
          recurrringActivity2
        };

        final expextedRecurring = recurrringActivity
            .copyWithRecurringEnd(in6Days.millisecondBefore());

        final newActivities = [
          anActivity,
          expextedRecurring,
          recurrringActivity2
        ];
        // Act
        final res = editRecurringMixin.deleteOnlyThisDay(
            activity: recurrringActivity,
            activities: activitySet,
            day: in6Days);

        // Assert
        expect(res.save, [expextedRecurring]);
        expect(res.state, newActivities);
      });

      test('for a mid day splits the activity up', () async {
        // Arrange
        final recurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final inAWeekDays = inAWeek.onlyDays();

        final activitySet = {recurrringActivity};

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
        final res = editRecurringMixin.deleteOnlyThisDay(
          activity: recurrringActivity,
          activities: activitySet,
          day: inAWeek.onlyDays(),
        );

        // Assert
        expect(res.state, MatchActivitiesWithoutId(expectedActivityList));
        expect(res.save, MatchActivitiesWithoutId(expectedActivityList));
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

        final activitySet = {
          anActivity,
          recurrringActivity,
          recurrringActivity2
        };

        // Act
        final res = editRecurringMixin.deleteThisDayAndForwardToState(
          activity: recurrringActivity,
          activities: activitySet,
          day: anyDay,
        );

        // Assert
        expect(
            res.save,
            [recurrringActivity, recurrringActivity2]
                .map((a) => a.copyWith(deleted: true)));
        expect(res.state, [anActivity]);
      });

      test('for a day modifies end time on activity', () async {
        // Arrange
        final inAWeek = anyDay.add(7.days());
        final recurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final recurrringActivityWithEndTime = recurrringActivity
            .copyWithRecurringEnd(inAWeek.millisecondBefore());

        final activitySet = {recurrringActivity};

        // Act
        final res = editRecurringMixin.deleteThisDayAndForwardToState(
          activity: recurrringActivity,
          activities: activitySet,
          day: inAWeek,
        );

        // Assert
        expect(res.state, [recurrringActivityWithEndTime]);
        expect(res.save, [recurrringActivityWithEndTime]);
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

        final activitySet = {recurrringActivity1, recurrringActivity2};

        final recurrringActivity1AfterDelete = recurrringActivity1
            .copyWithRecurringEnd(inAWeek.millisecondBefore());
        // Act
        final res = editRecurringMixin.deleteThisDayAndForwardToState(
          activity: recurrringActivity1,
          activities: activitySet,
          day: inAWeek,
        );

        // Assert
        expect(res.state, [recurrringActivity1AfterDelete]);
        expect(res.save, [
          recurrringActivity2.copyWith(deleted: true),
          recurrringActivity1AfterDelete,
        ]);
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

        final starttime = anyTime.subtract(1.hours());
        final updated = recurring.copyWith(
          title: 'new title',
          startTime: starttime,
        );

        final expected = updated.copyWith(recurs: Recurs.not);

        // Act
        final res = editRecurringMixin.updateOnlyThisDay(
          activity: updated,
          activities: {recurring},
          day: anyDay,
        );

        // Assert
        expect(res.state, [expected]);
        expect(res.save, [expected]);
      });

      test('on first day split activity in two and updates the activty ',
          () async {
        // Arrange
        final recurring = FakeActivity.reocurrsEveryDay(anyTime)
            .copyWithRecurringEnd(anyDay.add(5.days()).millisecondBefore());

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
        final res = editRecurringMixin.updateOnlyThisDay(
          activity: updated,
          activities: {recurring},
          day: anyDay,
        );

        // Assert
        expect(
            res.state,
            MatchActivitiesWithoutId(
                [expcetedUpdatedActivity, updatedOldActivity]));
        expect(
            res.save,
            MatchActivitiesWithoutId(
                [expcetedUpdatedActivity, updatedOldActivity]));
      });

      test('on last day split activity in two and updates the activty ',
          () async {
        // Arrange
        final startTime = DateTime(2020, 01, 01, 15, 20);
        final lastDay = DateTime(2020, 05, 05);
        final lastDayEndTime = DateTime(2020, 05, 06).millisecondBefore();
        final recurring = FakeActivity.reocurrsEveryDay(startTime)
            .copyWithRecurringEnd(lastDayEndTime);

        final newStartTime = recurring.startClock(lastDay).subtract(1.hours());
        final updated =
            recurring.copyWith(title: 'new title', startTime: newStartTime);

        final expectedUpdatedActivity = updated.copyWith(
          newId: true,
          recurs: Recurs.not,
        );
        final exptectedUpdatedOldActivity =
            recurring.copyWithRecurringEnd(lastDay.millisecondBefore());

        // Act
        final res = editRecurringMixin.updateOnlyThisDay(
            activity: updated, activities: {recurring}, day: lastDay);

        // Assert
        final exptected = MatchActivitiesWithoutId(
            [exptectedUpdatedOldActivity, expectedUpdatedActivity]);

        expect(res.state, exptected);
        expect(res.save, exptected);
      });

      test('on a day split activity in three and updates the activty ',
          () async {
        // Arrange
        final aDay = anyDay.add(5.days()).onlyDays();
        final recurring = FakeActivity.reocurrsEveryDay(anyTime);

        final updated = recurring.copyWith(
            title: 'new title',
            startTime: aDay.copyWith(
                hour: anyTime.hour - 1, minute: anyTime.millisecond));

        final expectedUpdatedActivity = updated.copyWith(
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

        // Act
        final res = editRecurringMixin.updateOnlyThisDay(
            activity: updated, activities: {recurring}, day: aDay);

        // Assert
        final expected = MatchActivitiesWithoutId(
            [preModDaySeries, expectedUpdatedActivity, postModDaySeries]);
        expect(res.state, expected);
        expect(res.state, expected);
      });

      test('fullday split', () async {
        // Arrange
        final aDay = DateTime(2020, 04, 01);
        final recurring = FakeActivity.reocurrsEveryDay(anyTime);
        // when(mockActivityRepository.load())
        //     .thenAnswer((_) => Future.value([recurring]));

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
                  minute: recurring.startTime.minute,
                ));

        final expected = MatchActivitiesWithoutId(
            [preModDaySeries, expectedUpdatedActivity, postModDaySeries]);

        final res = editRecurringMixin.updateOnlyThisDay(
          activity: fullday,
          activities: {recurring},
          day: aDay,
        );

        // Assert
        expect(res.state, expected);
        expect(res.state, expected);
      });
    });
    group('This day and forward', () {
      test('on first day, just updates the activty ', () async {
        // Arrange
        final recurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final updatedRecurrringActivity =
            recurrringActivity.copyWith(title: 'new title');

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
            activity: updatedRecurrringActivity,
            activities: {recurrringActivity});

        // Assert
        expect(res.state, [updatedRecurrringActivity]);
        expect(res.save, [updatedRecurrringActivity]);
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

        final exptected = [beforeModifiedDay, onAndAfterModifiedDay];

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
          activity: updatedRecurrringActivity,
          activities: {recurrringActivity},
        );

        final matcher = MatchActivitiesWithoutId(exptected);
        // Assert
        expect(res.state, matcher);
        expect(res.save, matcher);
      });

      test('change on occourance backwards ', () async {
        // Arrange
        final recurrringActivity = FakeActivity.reocurrsEveryDay(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);

        final updatedRecurrringActivity =
            recurrringActivity.copyWith(title: 'new title', startTime: inAWeek);

        final expectedPreModified = recurrringActivity.copyWithRecurringEnd(
          inAWeek.onlyDays().millisecondBefore(),
          newId: true,
        );
        final exptectedList = [expectedPreModified, updatedRecurrringActivity];

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
            activity: updatedRecurrringActivity,
            activities: {recurrringActivity});
        final matcher = MatchActivitiesWithoutId(exptectedList);

        // Assert
        expect(res.state, matcher);
        expect(res.save, matcher);
      });

      test('change on occourance forward ', () async {
        // Arrange
        final inTwoWeeks = anyTime.copyWith(day: anyTime.day + 14);
        final inFourWeeks = anyTime.copyWith(day: anyTime.day + 4 * 7);

        final recurrringActivity = FakeActivity.reocurrsEveryDay(anyTime)
            .copyWithRecurringEnd(inFourWeeks);

        final updatedRecurrringActivity = recurrringActivity.copyWith(
            title: 'new title', startTime: inTwoWeeks);

        final expectedPreModified = recurrringActivity.copyWithRecurringEnd(
          inTwoWeeks.onlyDays().millisecondBefore(),
          newId: true,
        );
        final exptectedList = [expectedPreModified, updatedRecurrringActivity];

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
          activity: updatedRecurrringActivity,
          activities: {recurrringActivity},
        );
        final matcher = MatchActivitiesWithoutId(exptectedList);

        // Assert
        expect(res.state, matcher);
        expect(res.save, matcher);
      });

      test('change on occourance past endTime ', () async {
        // Arrange
        final inFourWeeks = anyTime.copyWith(day: anyTime.day + 4 * 7);
        final inSixWeeks = anyTime.copyWith(day: anyTime.day + 6 * 7);

        final recurrringActivity = FakeActivity.reocurrsEveryDay(anyTime)
            .copyWithRecurringEnd(inFourWeeks);

        final updatedRecurrringActivity = recurrringActivity.copyWith(
            title: 'new title', startTime: inSixWeeks);

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
          activity: updatedRecurrringActivity,
          activities: {recurrringActivity},
        );
        final matcher = [recurrringActivity];

        // Assert
        expect(res.state, matcher);
        expect(res.save, []);
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
          title: 'now full day',
        );

        final stray = og
            .copyWith(
              newId: true,
              startTime: in12Days,
              duration: 10.minutes(),
              recurs: Recurs.not,
              title: 'a stray',
            )
            .copyWithRecurringEnd(in12Days.add(10.minutes()));

        final stray2 = og
            .copyWith(
              newId: true,
              startTime: inFiveDays,
              duration: 66.minutes(),
              title: 'a second stray',
            )
            .copyWithRecurringEnd(inFiveDays.add(66.minutes()));

        final currentActivities = {before, after, stray, stray2};

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
          startTime: after.startTime.copyWith(
            hour: newTime.hour,
            minute: newTime.minute,
          ),
          duration: newDuration,
          fullDay: false,
          removeAfter: true,
        );
        final strayPostMod = stray.copyWith(
          title: newTitle,
          startTime: stray.startTime.copyWith(
            hour: newTime.hour,
            minute: newTime.minute,
          ),
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
        final res = editRecurringMixin.updateThisDayAndForward(
            activity: updatedRecurrringActivity, activities: currentActivities);
        final matcher = MatchActivitiesWithoutId(exptectedList);

        // Assert
        expect(res.state, matcher);
        expect(res.save, matcher);
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
              Recurs.TYPE_WEEKLY, 16383, a1End.millisecondsSinceEpoch),
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
          recurs: Recurs.not.changeEnd(a3Time),
        );

        final newTitle = 'updated';
        final newTime = DateTime(2020, 04, 08, 13, 00);
        final updatedA2 = a2.copyWith(title: 'updated', startTime: newTime);

        final a2Part1 =
            a2.copyWithRecurringEnd(newTime.onlyDays().millisecondBefore());

        final expectedA3 = a3.copyWith(title: newTitle);

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
            activity: updatedA2, activities: {a1, a2, a3});

        // Assert
        expect(res.state,
            MatchActivitiesWithoutId([a1, a2Part1, updatedA2, expectedA3]));
        expect(res.save,
            MatchActivitiesWithoutId([a2Part1, updatedA2, expectedA3]));
      });
    });

    test(
        'bug SGC-332 recurring with traling day before is not affected by this day and forward',
        () {
      final a = Activity.createNew(
        title: 'asdf',
        startTime: DateTime(2020, 10, 02, 13, 14),
        recurs: Recurs.everyDay,
      );

      final aUpdated = a.copyWith(title: 'only this day');

      final expetedUpdate1 = aUpdated.copyWith(
        recurs: Recurs.not,
      );

      final expetedUpdate2 = a.copyWith(
        startTime: a.startTime.nextDay(),
      );

      // Act
      final res1 = editRecurringMixin.updateOnlyThisDay(
        activity: aUpdated,
        activities: {a},
        day: a.startTime.onlyDays(),
      );

      // Assert
      expect(
        res1.state,
        MatchActivitiesWithoutId(
          [
            expetedUpdate1,
            expetedUpdate2,
          ],
        ),
      );
      expect(
        res1.save,
        MatchActivitiesWithoutId(
          [
            expetedUpdate1,
            expetedUpdate2,
          ],
        ),
      );

      // Arrange
      final recurringA = res1.state.firstWhere((a) => a.isRecurring);

      expect(recurringA, MatchActivityWithoutId(expetedUpdate2));

      final recurringAUpdated2 = recurringA.copyWith(title: 'brand new title');

      final res2 = editRecurringMixin.updateThisDayAndForward(
        activity: recurringAUpdated2,
        activities: res1.state.toSet(),
      );

      // Assert
      expect(
        res2.state,
        MatchActivitiesWithoutId(
          [
            expetedUpdate1,
            recurringAUpdated2,
          ],
        ),
      );
      expect(
        res2.save,
        MatchActivitiesWithoutId(
          [
            recurringAUpdated2,
          ],
        ),
      );
    });

    test('bug SGC-332 recurring not with endtime is not overlapping', () {
      final activity = Activity.createNew(
        title: 'old title',
        startTime: DateTime(2022, 12, 12, 12, 12),
        recurs: Recurs.everyDay,
      );

      final onlyThis = activity.copyWith(
        title: 'new title',
        recurs: Recurs.raw(0, 0, Recurs.NO_END),
      );
      final recurring = activity.copyWith(
        startTime: activity.startTime.nextDay(),
        newId: true,
      );

      final recurringUpdated = recurring.copyWith(title: 'brand new title');

      final res2 = editRecurringMixin.updateThisDayAndForward(
        activity: recurringUpdated,
        activities: {onlyThis, recurring},
      );

      // Assert
      expect(
        res2.state,
        MatchActivitiesWithoutId(
          [
            onlyThis,
            recurringUpdated,
          ],
        ),
      );
      expect(
        res2.save,
        MatchActivitiesWithoutId(
          [
            recurringUpdated,
          ],
        ),
      );
    });
  });
}
