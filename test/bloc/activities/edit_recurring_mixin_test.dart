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
        final inAWeek = anyDay.add(7.days()).millisecondsSinceEpoch;
        final ogRecurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final recurrringActivity =
            ogRecurrringActivity.copyWith(endTime: inAWeek - 1);
        final recurrringActivity2 = ogRecurrringActivity.copyWith(
          newId: true,
          startTime: inAWeek,
        );

        final activityList = {
          anActivity,
          recurrringActivity,
          recurrringActivity2
        };

        final expextedRecurring = recurrringActivity.copyWith(
            startTime: anyTime.nextDay().millisecondsSinceEpoch);

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
        final recurrringActivity = ogRecurrringActivity.copyWith(
            endTime: inAWeek.onlyDays().millisecondsSinceEpoch - 1);
        final recurrringActivity2 = ogRecurrringActivity.copyWith(
          newId: true,
          title: 'other title',
          startTime: inAWeek.millisecondsSinceEpoch,
        );

        final activitySet = {
          anActivity,
          recurrringActivity,
          recurrringActivity2
        };

        final expextedRecurring = recurrringActivity.copyWith(
            endTime: in6Days.millisecondsSinceEpoch - 1);

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
        final inAWeek = anyDay.add(7.days()).millisecondsSinceEpoch;
        final ogRecurrringActivity = FakeActivity.reocurrsFridays(anyTime);
        final recurrringActivity =
            ogRecurrringActivity.copyWith(endTime: inAWeek - 1);
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
        final recurrringActivityWithEndTime = recurrringActivity.copyWith(
            endTime: inAWeek.millisecondsSinceEpoch - 1);

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

        final recurrringActivity1 = ogRecurrringActivity.copyWith(
          endTime: inTwoWeeks.millisecondsSinceEpoch - 1,
        );
        final recurrringActivity2 = ogRecurrringActivity.copyWith(
          newId: true,
          startTime: inTwoWeeks
              .copyWith(hour: anyTime.hour, minute: anyTime.minute)
              .millisecondsSinceEpoch,
        );

        final activitySet = {recurrringActivity1, recurrringActivity2};

        final recurrringActivity1AfterDelete = recurrringActivity1.copyWith(
            endTime: inAWeek.millisecondsSinceEpoch - 1);
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
            .copyWith(endTime: anyDay.nextDay().millisecondsSinceEpoch - 1);

        final starttime = anyTime.subtract(1.hours()).millisecondsSinceEpoch;
        final updated = recurring.copyWith(
            title: 'new title',
            startTime: starttime,
            endTime: starttime + recurring.duration);

        final expected = updated.copyWith(recurrentData: 0, recurrentType: 0);

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
    });

    test('on first day split activity in two and updates the activty ',
        () async {
      // Arrange
      final recurring = FakeActivity.reocurrsEveryDay(anyTime)
          .copyWith(endTime: anyDay.add(5.days()).millisecondsSinceEpoch - 1);

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
      final lastDayEndTime = DateTime(2020, 05, 06).millisecondsSinceEpoch - 1;
      final recurring = FakeActivity.reocurrsEveryDay(startTime)
          .copyWith(endTime: lastDayEndTime);

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

      // Act
      final res = editRecurringMixin.updateOnlyThisDay(
          activity: updated, activities: {recurring}, day: lastDay);

      // Assert
      final exptected = MatchActivitiesWithoutId(
          [exptectedUpdatedOldActivity, expectedUpdatedActivity]);

      expect(res.state, exptected);
      expect(res.save, exptected);
    });

    test('on a day split activity in three and updates the activty ', () async {
      // Arrange
      final aDay = anyDay.add(5.days()).onlyDays();
      final recurring = FakeActivity.reocurrsEveryDay(anyTime);

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
          title: 'new title',
          startTime: aDay.copyWith(hour: 4, minute: 4).millisecondsSinceEpoch);

      final beforeModifiedDay = recurrringActivity.copyWith(
        newId: true,
        endTime: aDay.millisecondsSinceEpoch - 1,
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

      final updatedRecurrringActivity = recurrringActivity.copyWith(
          title: 'new title', startTime: inAWeek.millisecondsSinceEpoch);

      final expectedPreModified = recurrringActivity.copyWith(
        newId: true,
        endTime: inAWeek.onlyDays().millisecondsSinceEpoch - 1,
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
          .copyWith(endTime: inFourWeeks.millisecondsSinceEpoch);

      final updatedRecurrringActivity = recurrringActivity.copyWith(
          title: 'new title', startTime: inTwoWeeks.millisecondsSinceEpoch);

      final expectedPreModified = recurrringActivity.copyWith(
          newId: true,
          endTime: inTwoWeeks.onlyDays().millisecondsSinceEpoch - 1);
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
          .copyWith(endTime: inFourWeeks.millisecondsSinceEpoch);

      final updatedRecurrringActivity = recurrringActivity.copyWith(
          title: 'new title', startTime: inSixWeeks.millisecondsSinceEpoch);

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

      final currentActivities = {before, after, stray, stray2};

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
      final res = editRecurringMixin.updateThisDayAndForward(
          activity: updatedRecurrringActivity, activities: currentActivities);
      final matcher = MatchActivitiesWithoutId(exptectedList);

      // Assert
      expect(res.state, matcher);
      expect(res.save, matcher);
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

      final newTitle = 'updated';
      final newTime = DateTime(2020, 04, 08, 13, 00);
      final updatedA2 = a2.copyWith(
          title: 'updated', startTime: newTime.millisecondsSinceEpoch);

      final a2Part1 =
          a2.copyWith(endTime: newTime.onlyDays().millisecondsSinceEpoch - 1);

      final expectedA3 = a3.copyWith(title: newTitle);

      // Act
      final res = editRecurringMixin.updateThisDayAndForward(
          activity: updatedA2, activities: {a1, a2, a3});

      // Assert
      expect(res.state,
          MatchActivitiesWithoutId([a1, a2Part1, updatedA2, expectedA3]));
      expect(
          res.save, MatchActivitiesWithoutId([a2Part1, updatedA2, expectedA3]));
    });
  });
}