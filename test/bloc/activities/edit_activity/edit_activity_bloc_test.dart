import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/activities/activities_bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../matchers.dart';
import '../../../mocks.dart';

void main() {
  ActivitiesBloc mockActivitiesBloc = MockActivitiesBloc();
  final aTime = DateTime(2022, 02, 22, 22, 30);
  final aDay = DateTime(2022, 02, 22);

  test('Initial state is the given activity', () {
    // Arrange
    final activity = Activity.createNew(title: '', startTime: aTime);
    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
    );
    // Act // Assert
    expect(editActivityBloc.initialState, isA<StoredActivityState>());
    expect(editActivityBloc.initialState.activity, activity);
  });

  test('Initial state is a new activity', () {
    // Arrange
    final activity = Activity.createNew(
      title: '',
      startTime: aTime.nextHalfHour(),
      timezone: aTime.timeZoneName,
    );
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      day: aTime,
    );
    // Act // Assert
    expect(editActivityBloc.initialState.activity,
        MatchActivityWithoutId(activity));
  });

  test('Initial state with no title is not saveable', () {
    // Arrange
    final activity = Activity.createNew(title: '', startTime: aTime);
    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
    );
    // Act // Assert
    expect(editActivityBloc.initialState.canSave, isFalse);
  });

  test('Changing activity changes activity', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      day: aTime,
    );
    final activity = editActivityBloc.initialState.activity;
    final activityWithTitle = activity.copyWith(title: 'new title');
    final timeInterval = TimeInterval(null, null);

    // Act
    editActivityBloc.add(ReplaceActivity(activityWithTitle));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnstoredActivityState(activity, timeInterval),
        UnstoredActivityState(activityWithTitle, timeInterval),
      ]),
    );
  });

  test('Trying to save yields nothing and does not try to save', () async {
    // Arrange

    final editActivityBloc = EditActivityBloc.newActivity(
        activitiesBloc: mockActivitiesBloc, day: aTime);
    final activity = editActivityBloc.initialState.activity;
    final activityWithTitle = activity.copyWith(title: 'new title');
    final timeInterval = TimeInterval(null, null);
    final newStartTime = TimeOfDay(hour: 10, minute: 0);
    final newTime = aTime.copyWith(
      hour: newStartTime.hour,
      minute: newStartTime.minute,
    );
    final newTimeInterval = TimeInterval(newTime, null);
    // Act
    editActivityBloc.add(SaveActivity());
    editActivityBloc.add(ReplaceActivity(activityWithTitle));
    editActivityBloc.add(SaveActivity());
    editActivityBloc.add(ChangeStartTime(newStartTime));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnstoredActivityState(activity, timeInterval),
        UnstoredActivityState(activityWithTitle, timeInterval),
        UnstoredActivityState(
            activityWithTitle.copyWith(startTime: newTime), newTimeInterval),
        StoredActivityState(activityWithTitle.copyWith(startTime: newTime),
            newTimeInterval, aTime.onlyDays()),
      ]),
    );
  });

  test('Saving full day activity sets correct time and alarms', () async {
    // Arrange
    final activity = Activity.createNew(
      title: 'a title',
      startTime: aTime,
      duration: 5.hours(),
      reminderBefore: [10.minutes().inMilliseconds, 1.hours().inMilliseconds],
      alarmType: ALARM_SOUND_AND_VIBRATION,
    );

    final activityAsFullDay = activity.copyWith(
      fullDay: true,
    );

    final activityExpectedToBeSaved = activityAsFullDay.copyWith(
      alarmType: NO_ALARM,
      startTime: activity.startTime.onlyDays(),
      duration: 1.days() - 1.milliseconds(),
      reminderBefore: [],
    );

    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
    );
    final timeInterval = TimeInterval(activity.startTime, activity.endTime);
    // Act
    editActivityBloc.add(ReplaceActivity(activityAsFullDay));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        StoredActivityState(activity, timeInterval, aDay),
        StoredActivityState(activityAsFullDay, timeInterval, aDay),
        StoredActivityState(activityExpectedToBeSaved, timeInterval,
            activityExpectedToBeSaved.startTime.onlyDays()),
      ]),
    );
  });

  test('Changing date changes date but not time', () async {
    // Arrange
    final aDate = DateTime(2022, 02, 22, 22, 00);

    final editActivityBloc = EditActivityBloc.newActivity(
        activitiesBloc: mockActivitiesBloc, day: aDate);
    final activity = editActivityBloc.initialState.activity;
    final newDate = DateTime(2011, 11, 11, 11, 11, 11, 11, 11);
    final expetedNewDate = DateTime(2011, 11, 11, 22, 30);
    final expetedNewActivity = activity.copyWith(startTime: expetedNewDate);
    final expectedTimeInterval = TimeInterval(null, null);

    // Act
    editActivityBloc.add(ChangeDate(newDate));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnstoredActivityState(activity, expectedTimeInterval),
        UnstoredActivityState(expetedNewActivity, expectedTimeInterval),
      ]),
    );
  });

  test('Changing start time changes start time but not duration', () async {
    // Arrange
    final aDate = DateTime(2022, 02, 22, 22, 30);
    final day = DateTime(2022, 02, 22);

    final activity = Activity.createNew(
      title: '',
      startTime: aDate,
      duration: 30.minutes(),
    );
    final newStartTime = TimeOfDay(hour: 11, minute: 11);
    final expectedNewDate = DateTime(2022, 02, 22, 11, 11);
    final expectedTimeInterval =
        TimeInterval(activity.startTime, activity.endTime);

    final expetedNewActivity = activity.copyWith(startTime: expectedNewDate);
    final expectedNewTimeInterval =
        TimeInterval(expectedNewDate, expectedNewDate.add(activity.duration));

    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, day),
      activitiesBloc: mockActivitiesBloc,
    );

    // Act
    editActivityBloc.add(ChangeStartTime(newStartTime));

    // Assert
    await expectLater(
        editActivityBloc,
        emitsInOrder([
          StoredActivityState(activity, expectedTimeInterval, day),
          StoredActivityState(expetedNewActivity, expectedNewTimeInterval, day),
        ]));
  });

  test('Changing end time changes duration but not start or end time',
      () async {
    // Arrange
    final aDate = DateTime(2001, 01, 01, 01, 01);
    final aDay = DateTime(2001, 01, 01);

    final activity = Activity.createNew(
      title: '',
      startTime: aDate,
      duration: 30.minutes(),
    );
    final newEndTime = TimeOfDay(hour: 11, minute: 11);
    final expectedDuration = Duration(hours: 10, minutes: 10);
    final expectedTimeInterval =
        TimeInterval(activity.startTime, activity.endTime);

    final expetedNewActivity = activity.copyWith(duration: expectedDuration);
    final expectedNewTimeInterval = TimeInterval(
        activity.startTime, activity.startTime.add(expectedDuration));

    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
    );

    // Act
    editActivityBloc.add(ChangeEndTime(newEndTime));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        StoredActivityState(activity, expectedTimeInterval, aDay),
        StoredActivityState(expetedNewActivity, expectedNewTimeInterval, aDay),
      ]),
    );
  });

  test('Changing end time to before changes duration to more then 12 hours',
      () async {
    // Arrange
    final aDate = DateTime(2001, 01, 01, 20, 30);
    final aDay = DateTime(2001, 01, 01);

    final activity = Activity.createNew(
      title: '',
      startTime: aDate,
      duration: 30.minutes(),
    );
    final newEndTime = TimeOfDay(hour: 20, minute: 00);

    final expectedDuration = Duration(hours: 23, minutes: 30);
    final expectedTimeInterval =
        TimeInterval(activity.startTime, activity.endTime);

    final expetedNewActivity = activity.copyWith(duration: expectedDuration);
    final expectedNewTimeInterval = TimeInterval(
        activity.startTime, activity.startTime.add(expectedDuration));

    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
    );

    // Act
    editActivityBloc.add(ChangeEndTime(newEndTime));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        StoredActivityState(activity, expectedTimeInterval, aDay),
        StoredActivityState(expetedNewActivity, expectedNewTimeInterval, aDay),
      ]),
    );
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
    final timeInterval = TimeInterval(activity.startTime, activity.endTime);
    final min15Reminder = 15.minutes();
    final hour1Reminder = 1.hours();
    final with15MinReminder =
        activity.copyWith(reminderBefore: [min15Reminder.inMilliseconds]);
    final with15MinAnd1HourReminder = activity.copyWith(reminderBefore: [
      min15Reminder.inMilliseconds,
      hour1Reminder.inMilliseconds
    ]);

    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
    );

    // Act
    editActivityBloc.add(AddOrRemoveReminder(min15Reminder));
    editActivityBloc.add(AddOrRemoveReminder(hour1Reminder));
    editActivityBloc.add(AddOrRemoveReminder(hour1Reminder));
    editActivityBloc.add(AddOrRemoveReminder(min15Reminder));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        StoredActivityState(activity, timeInterval, aDay),
        StoredActivityState(with15MinReminder, timeInterval, aDay),
        StoredActivityState(with15MinAnd1HourReminder, timeInterval, aDay),
        StoredActivityState(with15MinReminder, timeInterval, aDay),
        StoredActivityState(activity, timeInterval, aDay),
      ]),
    );
  });
}
