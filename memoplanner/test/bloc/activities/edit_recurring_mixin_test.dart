import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/activities/edit_recurring_mixin.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../fakes/all.dart';
import '../../test_helpers/matchers.dart';

class _TestObject with EditRecurringMixin {}

void main() {
  final anyTime = DateTime(2020, 03, 28, 15, 20);
  final anyDay = DateTime(2020, 03, 28);
  final editRecurringMixin = _TestObject();

  group('Delete recurring activity', () {
    group('Only this day', () {
      test('for first day edits start time', () async {
        // Arrange
        final anActivity = FakeActivity.starts(anyTime);
        final inAWeek = anyDay.add(7.days());
        final orgRecurringActivity = FakeActivity.reoccursFridays(anyTime);
        final recurringActivity = orgRecurringActivity
            .copyWithRecurringEnd(inAWeek.millisecondBefore());
        final recurringActivity2 = orgRecurringActivity.copyWith(
          newId: true,
          startTime: inAWeek,
        );

        final activityList = {
          anActivity,
          recurringActivity,
          recurringActivity2
        };

        final expectedRecurring =
            recurringActivity.copyWith(startTime: anyTime.nextDay());

        final expectedNewState = [
          anActivity,
          expectedRecurring,
          recurringActivity2
        ];
        // Act
        final result = editRecurringMixin.deleteOnlyThisDay(
            activity: recurringActivity, activities: activityList, day: anyDay);

        // Assert
        expect(result.save, [expectedRecurring]);
        expect(result.state, expectedNewState);
      });

      test('for last day edits end time', () async {
        // Arrange
        final anActivity = FakeActivity.starts(anyTime);
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

        final activitySet = {anActivity, recurringActivity, recurringActivity2};

        final expectedRecurring =
            recurringActivity.copyWithRecurringEnd(in6Days.millisecondBefore());

        final newActivities = [
          anActivity,
          expectedRecurring,
          recurringActivity2
        ];
        // Act
        final res = editRecurringMixin.deleteOnlyThisDay(
            activity: recurringActivity, activities: activitySet, day: in6Days);

        // Assert
        expect(res.save, [expectedRecurring]);
        expect(res.state, newActivities);
      });

      test('for a mid day splits the activity up', () async {
        // Arrange
        final recurringActivity = FakeActivity.reoccursFridays(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);
        final inAWeekDays = inAWeek.onlyDays();

        final activitySet = {recurringActivity};

        final expectedRecurring1 = recurringActivity
            .copyWithRecurringEnd(inAWeekDays.millisecondBefore());
        final expectedRecurring2 = recurringActivity.copyWith(
          newId: true,
          startTime: inAWeek.nextDay(),
        );

        final expectedActivityList = [
          expectedRecurring1,
          expectedRecurring2,
        ];

        // Act
        final res = editRecurringMixin.deleteOnlyThisDay(
          activity: recurringActivity,
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
        final orgRecurringActivity = FakeActivity.reoccursFridays(anyTime);
        final recurringActivity = orgRecurringActivity
            .copyWithRecurringEnd(inAWeek.millisecondBefore());
        final recurringActivity2 = orgRecurringActivity.copyWith(
          newId: true,
          startTime: inAWeek,
        );

        final activitySet = {anActivity, recurringActivity, recurringActivity2};

        // Act
        final res = editRecurringMixin.deleteThisDayAndForwardToState(
          activity: recurringActivity,
          activities: activitySet,
          day: anyDay,
        );

        // Assert
        expect(
            res.save,
            [recurringActivity, recurringActivity2]
                .map((a) => a.copyWith(deleted: true)));
        expect(res.state, [anActivity]);
      });

      test('for a day modifies end time on activity', () async {
        // Arrange
        final inAWeek = anyDay.add(7.days());
        final recurringActivity = FakeActivity.reoccursFridays(anyTime);
        final recurringActivityWithEndTime =
            recurringActivity.copyWithRecurringEnd(inAWeek.millisecondBefore());

        final activitySet = {recurringActivity};

        // Act
        final res = editRecurringMixin.deleteThisDayAndForwardToState(
          activity: recurringActivity,
          activities: activitySet,
          day: inAWeek,
        );

        // Assert
        expect(res.state, [recurringActivityWithEndTime]);
        expect(res.save, [recurringActivityWithEndTime]);
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

        final activitySet = {recurringActivity1, recurringActivity2};

        final recurringActivity1AfterDelete = recurringActivity1
            .copyWithRecurringEnd(inAWeek.millisecondBefore());
        // Act
        final res = editRecurringMixin.deleteThisDayAndForwardToState(
          activity: recurringActivity1,
          activities: activitySet,
          day: inAWeek,
        );

        // Assert
        expect(res.state, [recurringActivity1AfterDelete]);
        expect(res.save, [
          recurringActivity2.copyWith(deleted: true),
          recurringActivity1AfterDelete,
        ]);
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

        final startTime = anyTime.subtract(1.hours());
        final updated = recurring.copyWith(
          title: 'new title',
          startTime: startTime,
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

      test('on first day split activity in two and updates the activity',
          () async {
        // Arrange
        final recurring = FakeActivity.reoccursEveryDay(anyTime)
            .copyWithRecurringEnd(anyDay.add(5.days()).millisecondBefore());

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
        final res = editRecurringMixin.updateOnlyThisDay(
          activity: updated,
          activities: {recurring},
          day: anyDay,
        );

        // Assert
        expect(
            res.state,
            MatchActivitiesWithoutId(
                [expectedUpdatedActivity, updatedOldActivity]));
        expect(
            res.save,
            MatchActivitiesWithoutId(
                [expectedUpdatedActivity, updatedOldActivity]));
      });

      test('on last day split activity in two and updates the activity',
          () async {
        // Arrange
        final startTime = DateTime(2020, 01, 01, 15, 20);
        final lastDay = DateTime(2020, 05, 05);
        final lastDayEndTime = DateTime(2020, 05, 06).millisecondBefore();
        final recurring = FakeActivity.reoccursEveryDay(startTime)
            .copyWithRecurringEnd(lastDayEndTime);

        final newStartTime = recurring.startClock(lastDay).subtract(1.hours());
        final updated =
            recurring.copyWith(title: 'new title', startTime: newStartTime);

        final expectedUpdatedActivity = updated.copyWith(
          newId: true,
          recurs: Recurs.not,
        );
        final expectedUpdatedOldActivity =
            recurring.copyWithRecurringEnd(lastDay.millisecondBefore());

        // Act
        final res = editRecurringMixin.updateOnlyThisDay(
            activity: updated, activities: {recurring}, day: lastDay);

        // Assert
        final expected = MatchActivitiesWithoutId(
            [expectedUpdatedOldActivity, expectedUpdatedActivity]);

        expect(res.state, expected);
        expect(res.save, expected);
      });

      test('on a day split activity in three and updates the activity',
          () async {
        // Arrange
        final aDay = anyDay.add(5.days()).onlyDays();
        final recurring = FakeActivity.reoccursEveryDay(anyTime);

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

      test('full day split', () async {
        // Arrange
        final aDay = DateTime(2020, 04, 01);
        final recurring = FakeActivity.reoccursEveryDay(anyTime);

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
                  minute: recurring.startTime.minute,
                ));

        final expected = MatchActivitiesWithoutId(
            [preModDaySeries, expectedUpdatedActivity, postModDaySeries]);

        final res = editRecurringMixin.updateOnlyThisDay(
          activity: fullDay,
          activities: {recurring},
          day: aDay,
        );

        // Assert
        expect(res.state, expected);
        expect(res.state, expected);
      });
    });
    group('This day and forward', () {
      test('on first day, just updates the activity', () async {
        // Arrange
        final recurringActivity = FakeActivity.reoccursFridays(anyTime);
        final updatedRecurringActivity =
            recurringActivity.copyWith(title: 'new title');

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
          activity: updatedRecurringActivity,
          activities: {recurringActivity},
          day: anyDay,
        );

        // Assert
        expect(res.state, [updatedRecurringActivity]);
        expect(res.save, [updatedRecurringActivity]);
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

        final expected = [beforeModifiedDay, onAndAfterModifiedDay];

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
          activity: updatedRecurringActivity,
          activities: {recurringActivity},
          day: anyDay,
        );

        final matcher = MatchActivitiesWithoutId(expected);
        // Assert
        expect(res.state, matcher);
        expect(res.save, matcher);
      });

      test('change on occurrence backwards ', () async {
        // Arrange
        final recurringActivity = FakeActivity.reoccursEveryDay(anyTime);
        final inAWeek = anyTime.copyWith(day: anyTime.day + 7);

        final updatedRecurringActivity =
            recurringActivity.copyWith(title: 'new title', startTime: inAWeek);

        final expectedPreModified = recurringActivity.copyWithRecurringEnd(
          inAWeek.onlyDays().millisecondBefore(),
          newId: true,
        );
        final expectedList = [expectedPreModified, updatedRecurringActivity];

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
          activity: updatedRecurringActivity,
          activities: {recurringActivity},
          day: anyDay,
        );
        final matcher = MatchActivitiesWithoutId(expectedList);

        // Assert
        expect(res.state, matcher);
        expect(res.save, matcher);
      });

      test('change on occurrence forward ', () async {
        // Arrange
        final inTwoWeeks = anyTime.copyWith(day: anyTime.day + 14);
        final inFourWeeks = anyTime.copyWith(day: anyTime.day + 4 * 7);

        final recurringActivity = FakeActivity.reoccursEveryDay(anyTime)
            .copyWithRecurringEnd(inFourWeeks);

        final updatedRecurringActivity = recurringActivity.copyWith(
            title: 'new title', startTime: inTwoWeeks);

        final expectedPreModified = recurringActivity.copyWithRecurringEnd(
          inTwoWeeks.onlyDays().millisecondBefore(),
          newId: true,
        );
        final expectedList = [expectedPreModified, updatedRecurringActivity];

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
          activity: updatedRecurringActivity,
          activities: {recurringActivity},
          day: anyDay,
        );
        final matcher = MatchActivitiesWithoutId(expectedList);

        // Assert
        expect(res.state, matcher);
        expect(res.save, matcher);
      });

      test('change on occurrence past endTime ', () async {
        // Arrange
        final inFourWeeks = anyTime.copyWith(day: anyTime.day + 4 * 7);
        final inSixWeeks = anyTime.copyWith(day: anyTime.day + 6 * 7);

        final recurringActivity = FakeActivity.reoccursEveryDay(anyTime)
            .copyWithRecurringEnd(inFourWeeks);

        final updatedRecurringActivity = recurringActivity.copyWith(
            title: 'new title', startTime: inSixWeeks);

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
          activity: updatedRecurringActivity,
          activities: {recurringActivity},
          day: anyDay,
        );
        final matcher = [recurringActivity];

        // Assert
        expect(res.state, matcher);
        expect(res.save, []);
      });

      test('changes all future activities in series ', () async {
        // Arrange
        final in5Days = anyTime.copyWith(day: anyTime.day + 5);
        final in7Days = anyTime.copyWith(day: anyTime.day + 7);
        final in8Days = anyTime.copyWith(day: anyTime.day + 8);
        final in12Days = anyTime.copyWith(day: anyTime.day + 12);

        final org = FakeActivity.reoccursEveryDay(anyTime);
        final startsBeforeEndsAfter = org
            .copyWith(title: 'original')
            .copyWithRecurringEnd(in7Days.onlyDays().millisecondBefore());

        final startsAfter = org
            .copyWith(
              newId: true,
              startTime: in8Days,
              fullDay: true,
              title: 'now full day',
            )
            .copyWithRecurringEnd(Recurs.noEndDate);

        final strayAfterNoRecurrence = org.copyWith(
          newId: true,
          startTime: in12Days,
          duration: 10.minutes(),
          recurs: Recurs.not,
          title: 'a stray',
        );

        final strayWithSameStartAndEndDay = org
            .copyWith(
              newId: true,
              startTime: in5Days,
              duration: 66.minutes(),
              title: 'a second stray',
            )
            .copyWithRecurringEnd(in5Days);

        final currentActivities = {
          startsBeforeEndsAfter,
          startsAfter,
          strayAfterNoRecurrence,
          strayWithSameStartAndEndDay
        };

        const newTitle = 'newTitle';
        final newTime = in5Days.add(2.hours());
        final newDuration = 30.minutes();

        final updatedRecurringActivity = strayWithSameStartAndEndDay.copyWith(
          title: newTitle,
          startTime: newTime,
          duration: newDuration,
          removeAfter: true,
        );

        final beforePostMod = startsBeforeEndsAfter.copyWithRecurringEnd(
          in5Days.onlyDays().millisecondBefore(),
        );

        final startsBeforeEndsAfterSplitPostMod =
            startsBeforeEndsAfter.copyWith(
          newId: true,
          title: newTitle,
          startTime: newTime,
          duration: newDuration,
          removeAfter: true,
        );

        final startsAfterPostMod = startsAfter.copyWith(
          title: newTitle,
          startTime: startsAfter.startTime.copyWith(
            hour: newTime.hour,
            minute: newTime.minute,
          ),
          duration: newDuration,
          fullDay: false,
          removeAfter: true,
        );
        final strayAfterNoRecurrencePostMod = strayAfterNoRecurrence.copyWith(
          title: newTitle,
          startTime: strayAfterNoRecurrence.startTime.copyWith(
            hour: newTime.hour,
            minute: newTime.minute,
          ),
          duration: newDuration,
          removeAfter: true,
        );

        final expectedList = <Activity>[
          beforePostMod,
          updatedRecurringActivity,
          startsBeforeEndsAfterSplitPostMod,
          startsAfterPostMod,
          strayAfterNoRecurrencePostMod
        ];

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
          activity: updatedRecurringActivity,
          activities: currentActivities,
          day: anyDay,
        );
        final matcher = MatchActivitiesWithoutId(expectedList);

        // Assert
        expect(res.state, matcher);
        expect(res.save, matcher);
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
              Recurs.typeWeekly, 16383, a1End.millisecondsSinceEpoch),
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

        const newTitle = 'updated';
        final newTime = DateTime(2020, 04, 08, 13, 00);
        final updatedA2 = a2.copyWith(title: 'updated', startTime: newTime);

        final a2Part1 =
            a2.copyWithRecurringEnd(newTime.onlyDays().millisecondBefore());

        final expectedA3 = a3.copyWith(title: newTitle);

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
          activity: updatedA2,
          activities: {a1, a2, a3},
          day: anyDay,
        );

        // Assert
        expect(
            res.state,
            MatchActivitiesWithoutId([
              a1,
              a2Part1,
              updatedA2,
              expectedA3,
            ]));
        expect(
            res.save,
            MatchActivitiesWithoutId([
              a2Part1,
              updatedA2,
              expectedA3,
            ]));
      });

      test('Moving yearly forward', () async {
        final start = DateTime(2020, 11, 06, 12, 00);
        final dayToMove = DateTime(2021, 11, 06);
        final newStartTime = DateTime(2021, 11, 09, 12, 00);
        final original = Activity.createNew(
          title: 'asdf',
          startTime: start,
          recurs: const Recurs.raw(
            Recurs.typeYearly,
            1006,
            Recurs.noEnd,
          ),
        );
        final updated = original.copyWith(
            startTime: newStartTime,
            recurs: Recurs.yearly(
              newStartTime.onlyDays(),
            ));

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
          activity: updated,
          activities: {original},
          day: dayToMove,
        );

        // Assert
        expect(res.state.expand((e) => e.dayActivitiesForDay(dayToMove)), []);
        expect(
            res.state
                .expand((e) => e.dayActivitiesForDay(newStartTime.onlyDays()))
                .length,
            1);
      });

      test('Moving yearly backwards', () async {
        // Arrange
        final start = DateTime(2020, 11, 06, 12, 00);
        final dayToMove = DateTime(2021, 11, 06);
        final newStartTime = DateTime(2021, 11, 02, 12, 00);
        final original = Activity.createNew(
          title: 'asdf',
          startTime: start,
          recurs: const Recurs.raw(
            Recurs.typeYearly,
            1006,
            Recurs.noEnd,
          ),
        );
        final updated = original.copyWith(
          startTime: newStartTime,
          recurs: Recurs.yearly(newStartTime.onlyDays()),
        );

        // Act
        final res = editRecurringMixin.updateThisDayAndForward(
          activity: updated,
          activities: {original},
          day: dayToMove,
        );

        // Assert
        expect(res.state.expand((e) => e.dayActivitiesForDay(dayToMove)), []);
        expect(
            res.state
                .expand((e) => e.dayActivitiesForDay(newStartTime.onlyDays()))
                .length,
            1);
      });
    });

    test(
        'bug SGC-332 recurring with trailing day before is not '
        'affected by this day and forward', () {
      final a = Activity.createNew(
        title: 'asdf',
        startTime: DateTime(2020, 10, 02, 13, 14),
        recurs: Recurs.everyDay,
      );

      final aUpdated = a.copyWith(title: 'only this day');

      final expectedUpdate1 = aUpdated.copyWith(
        recurs: Recurs.not,
      );

      final expectedUpdate2 = a.copyWith(
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
            expectedUpdate1,
            expectedUpdate2,
          ],
        ),
      );
      expect(
        res1.save,
        MatchActivitiesWithoutId(
          [
            expectedUpdate1,
            expectedUpdate2,
          ],
        ),
      );

      // Arrange
      final recurringA = res1.state.firstWhere((a) => a.isRecurring);

      expect(recurringA, MatchActivityWithoutId(expectedUpdate2));

      final recurringAUpdated2 = recurringA.copyWith(title: 'brand new title');

      final res2 = editRecurringMixin.updateThisDayAndForward(
        activity: recurringAUpdated2,
        activities: res1.state.toSet(),
        day: anyDay,
      );

      // Assert
      expect(
        res2.state,
        MatchActivitiesWithoutId(
          [
            expectedUpdate1,
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

    test('bug SGC-332 recurring not with end time is not overlapping', () {
      final activity = Activity.createNew(
        title: 'old title',
        startTime: DateTime(2022, 12, 12, 12, 12),
        recurs: Recurs.everyDay,
      );

      final onlyThis = activity.copyWith(
        title: 'new title',
        recurs: const Recurs.raw(0, 0, Recurs.noEnd),
      );
      final recurring = activity.copyWith(
        startTime: activity.startTime.nextDay(),
        newId: true,
      );

      final recurringUpdated = recurring.copyWith(title: 'brand new title');

      final res2 = editRecurringMixin.updateThisDayAndForward(
        activity: recurringUpdated,
        activities: {onlyThis, recurring},
        day: anyDay,
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
