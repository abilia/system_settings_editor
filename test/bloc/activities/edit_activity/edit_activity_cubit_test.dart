import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../fakes/all.dart';
import '../../../test_helpers/matchers.dart';

void main() {
  final nowTime = DateTime(2000, 02, 22, 22, 30);
  final aTime = DateTime(2022, 02, 22, 22, 30);
  final aDay = DateTime(2022, 02, 22);
  const calendarId = 'Some-calendar-id';

  setUp(() {
    tz.initializeTimeZones();
  });

  test('Initial state is the given activity', () {
    // Arrange
    final activity = Activity.createNew(title: '', startTime: aTime);
    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(activity, aDay),
    );
    // Act // Assert
    expect(editActivityCubit.state, isA<StoredActivityState>());
    expect(editActivityCubit.state.activity, activity);
  });

  test('Initial state is a new activity', () {
    // Arrange
    final activity = Activity.createNew(
      title: '',
      calendarId: calendarId,
      startTime: aTime,
      timezone: tz.local.name,
    );
    final editActivityCubit = EditActivityCubit.newActivity(
      day: aTime,
      defaultAlarmTypeSetting: alarmSoundAndVibration,
      calendarId: calendarId,
    );
    // Act // Assert
    expect(editActivityCubit.state.activity, MatchActivityWithoutId(activity));
  });

  test('Replace activity in bloc changes activity in state', () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.newActivity(
      day: aTime,
      defaultAlarmTypeSetting: noAlarm,
      calendarId: calendarId,
    );
    final activity = editActivityCubit.state.activity;
    final activityWithTitle = activity.copyWith(title: 'new title');
    final timeInterval = TimeInterval(startDate: aTime);

    final expect = expectLater(
      editActivityCubit.stream,
      emits(UnstoredActivityState(activityWithTitle, timeInterval)),
    );

    // Act
    editActivityCubit.replaceActivity(activityWithTitle);

    // Assert
    await expect;
  });

  test('Changing date changes date but not time in timeinterval', () async {
    // Arrange
    final aDate = DateTime(2022, 02, 22, 22, 00);

    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDate,
      defaultAlarmTypeSetting: noAlarm,
      calendarId: calendarId,
    );
    final activity = editActivityCubit.state.activity;
    final newDate = DateTime(2011, 11, 11, 11, 11);
    final expetedNewDate = DateTime(2011, 11, 11, 11, 11);
    final expectedTimeInterval = TimeInterval(startDate: expetedNewDate);

    final expect = expectLater(
      editActivityCubit.stream,
      emits(UnstoredActivityState(activity, expectedTimeInterval)),
    );

    // Act
    editActivityCubit.changeDate(newDate);

    // Assert
    await expect;
  });

  test('activity.startTime set correctly', () async {
    // Arrange
    final aDate = DateTime(2022, 02, 22, 22, 00);

    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDate,
      defaultAlarmTypeSetting: noAlarm,
      calendarId: calendarId,
    );

    final activity = editActivityCubit.state.activity;

    final newDate = DateTime(2011, 11, 11, 11, 11);
    const newTime = TimeOfDay(hour: 1, minute: 1);
    final newActivity = activity.copyWith(title: 'newTile');
    final expectedTimeInterval1 = TimeInterval(
      startTime: newTime,
      endTime: newTime,
      startDate: aDate,
    );
    final expectedTimeInterval2 = TimeInterval(
      startTime: newTime,
      endTime: newTime,
      startDate: newDate,
    );

    final expected = expectLater(
      editActivityCubit.stream,
      emitsInOrder(
        [
          UnstoredActivityState(activity, expectedTimeInterval1),
          UnstoredActivityState(activity, expectedTimeInterval2),
          UnstoredActivityState(newActivity, expectedTimeInterval2),
        ],
      ),
    );
    // Act
    editActivityCubit.changeTimeInterval(
        startTime: const TimeOfDay(hour: 1, minute: 1));
    editActivityCubit.changeDate(newDate);
    editActivityCubit.replaceActivity(newActivity);

    // Assert
    await expected;
  });

  test('Add or remove reminders', () async {
    // Arrange
    final aDate = DateTime(2001, 01, 01, 20, 30);
    final aDay = DateTime(2001, 01, 01);

    final activity = Activity.createNew(
      title: '',
      startTime: aDate,
      duration: 30.minutes(),
    );
    final timeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.noneRecurringEnd),
      startDate: aDate,
    );
    final min15Reminder = 15.minutes();
    final hour1Reminder = 1.hours();
    final with15MinReminder =
        activity.copyWith(reminderBefore: [min15Reminder.inMilliseconds]);
    final with15MinAnd1HourReminder = activity.copyWith(reminderBefore: [
      min15Reminder.inMilliseconds,
      hour1Reminder.inMilliseconds
    ]);

    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(activity, aDay),
    );

    final expected = expectLater(
      editActivityCubit.stream,
      emitsInOrder([
        StoredActivityState(with15MinReminder, timeInterval, aDay),
        StoredActivityState(with15MinAnd1HourReminder, timeInterval, aDay),
        StoredActivityState(with15MinReminder, timeInterval, aDay),
        StoredActivityState(activity, timeInterval, aDay),
      ]),
    );

    // Act
    editActivityCubit.addOrRemoveReminder(min15Reminder);
    editActivityCubit.addOrRemoveReminder(hour1Reminder);
    editActivityCubit.addOrRemoveReminder(hour1Reminder);
    editActivityCubit.addOrRemoveReminder(min15Reminder);

    // Assert
    await expected;
  });

  test('Setting start time after end time', () async {
    // Arrange
    final aDay = DateTime(2001, 01, 01);

    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDay,
      defaultAlarmTypeSetting: noAlarm,
      calendarId: calendarId,
    );

    final wizCubit = ActivityWizardCubit.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: editActivityCubit,
      clockBloc: ClockBloc.fixed(nowTime),
      settings: const MemoplannerSettingsLoaded(
        MemoplannerSettings(
          editActivity: EditActivitySettings(template: false),
        ),
      ),
    );
    final activity = editActivityCubit.state.activity;
    final activityWithTitle = activity.copyWith(title: 'title');

    final expectedActivity = activityWithTitle.copyWith(
        startTime: aDay.copyWith(hour: 12, minute: 0), duration: 22.hours());
    final expectedTimeInterval = TimeInterval(
      startTime: const TimeOfDay(hour: 12, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      startDate: aDay,
    );

    final expect1 = expectLater(
      editActivityCubit.stream,
      emitsInOrder(
        [
          UnstoredActivityState(
            activity,
            TimeInterval(
              endTime: const TimeOfDay(hour: 10, minute: 0),
              startDate: aDay,
            ),
          ),
          UnstoredActivityState(
            activity,
            expectedTimeInterval,
          ),
          UnstoredActivityState(
            activityWithTitle,
            expectedTimeInterval,
          ),
        ],
      ),
    );

    // Act
    editActivityCubit.changeTimeInterval(
        endTime: const TimeOfDay(hour: 10, minute: 0));
    editActivityCubit.changeTimeInterval(
        startTime: const TimeOfDay(hour: 12, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0));
    editActivityCubit.replaceActivity(activityWithTitle);

    // Assert
    await expect1;

    // Arrange
    final expect2 = expectLater(
      editActivityCubit.stream,
      emits(
        StoredActivityState(
          expectedActivity,
          expectedTimeInterval,
          aDay,
        ),
      ),
    );
    // Act
    wizCubit.next();
    // Assert
    expect(
      wizCubit.state,
      ActivityWizardState(0, const [WizardStep.advance], sucessfullSave: true),
    );
    // Assert
    await expect2;
  });

  test('Changing InfoItem', () async {
    // Arrange
    const note = NoteInfoItem('anote');
    final withNote =
        Activity.createNew(title: 'null', startTime: aTime, infoItem: note);
    final withChecklist = withNote.copyWith(infoItem: Checklist());
    final withNoInfoItem = withNote.copyWith(infoItem: const NoInfoItem());
    final activityDay = ActivityDay(withNote, aDay);
    final timeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(aTime),
      startDate: aTime,
    );
    final editActivityCubit = EditActivityCubit.edit(
      activityDay,
    );

    final expect = expectLater(
      editActivityCubit.stream,
      emitsInOrder([
        StoredActivityState(
          withChecklist,
          timeInterval,
          aDay,
        ).copyWith(
          withChecklist,
          infoItems: {
            NoteInfoItem: note,
          },
        ),
        StoredActivityState(
          withNote,
          timeInterval,
          aDay,
        ).copyWith(
          withNote,
          infoItems: {
            NoteInfoItem: note,
            Checklist: Checklist(),
          },
        ),
        StoredActivityState(
          withNoInfoItem,
          timeInterval,
          aDay,
        ).copyWith(withNoInfoItem, infoItems: {
          NoteInfoItem: note,
          Checklist: Checklist(),
        }),
      ]),
    );

    // Act
    editActivityCubit.changeInfoItemType(Checklist);
    editActivityCubit.changeInfoItemType(NoteInfoItem);
    editActivityCubit.changeInfoItemType(NoInfoItem);

    // Assert
    await expect;
  });

  test('Changing start date to after recuring end changes recuring end',
      () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDay,
      defaultAlarmTypeSetting: noAlarm,
      calendarId: calendarId,
    );

    final in30Days = aTime.add(30.days());
    final in60Days = aTime.add(60.days());
    final activity = editActivityCubit.state.activity;
    final timeInterval = editActivityCubit.state.timeInterval;
    final recurringActivity = activity.copyWith(
      recurs: Recurs.weeklyOnDay(2, ends: in30Days),
    );

    final expectedActivity =
        activity.copyWith(recurs: Recurs.weeklyOnDay(2, ends: in60Days));
    final expectedInterval = timeInterval.copyWith(startDate: in60Days);

    final expect = expectLater(
      editActivityCubit.stream,
      emitsInOrder(
        [
          UnstoredActivityState(
            recurringActivity,
            timeInterval,
          ),
          UnstoredActivityState(
            expectedActivity,
            expectedInterval,
          ),
        ],
      ),
    );

    editActivityCubit.replaceActivity(recurringActivity);
    editActivityCubit.changeDate(in60Days);

    await expect;
  });
}
