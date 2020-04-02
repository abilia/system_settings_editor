import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/activities/activities_bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks.dart';

void main() {
  ActivitiesBloc mockActivitiesBloc = MockActivitiesBloc();
  DateTime aTime = DateTime(2022, 02, 22, 22, 30);
  test('Initial state is the given activity', () {
    // Arrange
    final activity =
        Activity.createNew(title: '', startTime: aTime.millisecondsSinceEpoch);
    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity);
    // Act // Assert
    expect(editActivityBloc.initialState.activity, activity);
  });
  test('Initial state with no title is not saveable', () {
    // Arrange
    final activity =
        Activity.createNew(title: '', startTime: aTime.millisecondsSinceEpoch);
    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity);
    // Act // Assert
    expect(editActivityBloc.initialState.canSave, isFalse);
  });
  test('Changing activity changes activity', () async {
    // Arrange
    final activity =
        Activity.createNew(title: '', startTime: aTime.millisecondsSinceEpoch);
    final activityWithTitle = activity.copyWith(title: 'new title');

    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity);
    // Act
    editActivityBloc.add(ChangeActivity(activityWithTitle));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnsavedActivityState(activity),
        UnsavedActivityState(activityWithTitle),
      ]),
    );
  });
  test('Trying to save yields nothing and does not try to save', () async {
    // Arrange
    final activity =
        Activity.createNew(title: '', startTime: aTime.millisecondsSinceEpoch);
    final activityWithTitle = activity.copyWith(title: 'new title');

    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity);
    // Act
    editActivityBloc.add(SaveActivity());
    editActivityBloc.add(ChangeActivity(activityWithTitle));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnsavedActivityState(activity),
        UnsavedActivityState(activityWithTitle),
        SavedActivityState(activityWithTitle),
      ]),
    );
  });

  test('Saving full day activity sets correct time and alarms', () async {
    // Arrange
    final activity = Activity.createNew(
      title: 'a title',
      fullDay: true,
      startTime: aTime.millisecondsSinceEpoch,
      endTime: aTime.add(5.hours()).millisecondsSinceEpoch,
      reminderBefore: [10.minutes().inMilliseconds, 1.hours().inMilliseconds],
      alarmType: ALARM_SOUND_AND_VIBRATION,
    );

    final activityExpectedToBeSaved = activity.copyWith(
      alarmType: NO_ALARM,
      startTime: activity.startDateTime.onlyDays().millisecondsSinceEpoch,
      endTime: activity.startDateTime
              .add(1.days())
              .onlyDays()
              .millisecondsSinceEpoch -
          1,
      duration: 1.days().inMilliseconds - 1,
      reminderBefore: [],
    );

    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity);
    // Act
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnsavedActivityState(activity),
        SavedActivityState(activityExpectedToBeSaved),
      ]),
    );
  });

  test('Changing date changes date but not time', () async {
    // Arrange
    final DateTime aDate = DateTime(2022, 02, 22, 22, 30);

    final activity =
        Activity.createNew(title: '', startTime: aDate.millisecondsSinceEpoch);
    final newDate = DateTime(2011, 11, 11, 11, 11, 11, 11, 11);
    final expetedNewDate = DateTime(2011, 11, 11, 22, 30);
    final expetedNewActivity = activity.copyWith(
        startTime: expetedNewDate.millisecondsSinceEpoch,
        endTime: expetedNewDate.millisecondsSinceEpoch);

    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity);
    // Act
    editActivityBloc.add(ChangeDate(newDate));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnsavedActivityState(activity),
        UnsavedActivityState(expetedNewActivity),
      ]),
    );
  });

  test('Changing start time changes start and end time but not duration',
      () async {
    // Arrange
    final DateTime aDate = DateTime(2022, 02, 22, 22, 30);

    final activity = Activity.createNew(
      title: '',
      startTime: aDate.millisecondsSinceEpoch,
      duration: 30.minutes().inMilliseconds,
    );
    final newStartTime = TimeOfDay(hour: 11, minute: 11);
    final expetedNewDate = DateTime(2022, 02, 22, 11, 11);

    final expetedNewActivity = activity.copyWith(
        startTime: expetedNewDate.millisecondsSinceEpoch,
        endTime: expetedNewDate.millisecondsSinceEpoch);

    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity);

    // Act
    editActivityBloc.add(ChangeStartTime(newStartTime));

    // Assert
    await expectLater(
        editActivityBloc,
        emitsInOrder([
          UnsavedActivityState(activity),
          UnsavedActivityState(expetedNewActivity),
        ]));
  });

  test('Changing end time changes duration but not start or end time',
      () async {
    // Arrange
    final DateTime aDate = DateTime(2001, 01, 01, 01, 01);

    final activity = Activity.createNew(
      title: '',
      startTime: aDate.millisecondsSinceEpoch,
      duration: 30.minutes().inMilliseconds,
    );
    final newEndTime = TimeOfDay(hour: 11, minute: 11);
    final expectedDuration = Duration(hours: 10, minutes: 10);

    final expetedNewActivity =
        activity.copyWith(duration: expectedDuration.inMilliseconds);

    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity);

    // Act
    editActivityBloc.add(ChangeEndTime(newEndTime));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnsavedActivityState(activity),
        UnsavedActivityState(expetedNewActivity),
      ]),
    );
  });

  test('Changing end time to before changes duration to more then 12 hours',
      () async {
    // Arrange
    final DateTime aDate = DateTime(2001, 01, 01, 20, 30);

    final activity = Activity.createNew(
      title: '',
      startTime: aDate.millisecondsSinceEpoch,
      duration: 30.minutes().inMilliseconds,
    );
    final newEndTime = TimeOfDay(hour: 20, minute: 00);

    final expectedDuration = Duration(hours: 23, minutes: 30);

    final expetedNewActivity =
        activity.copyWith(duration: expectedDuration.inMilliseconds);

    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity);

    // Act
    editActivityBloc.add(ChangeEndTime(newEndTime));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnsavedActivityState(activity),
        UnsavedActivityState(expetedNewActivity),
      ]),
    );
  });

  test('Add or remove reminders', () async {
    // Arrange
    final DateTime aDate = DateTime(2001, 01, 01, 20, 30);

    final activity = Activity.createNew(
      title: '',
      startTime: aDate.millisecondsSinceEpoch,
      duration: 30.minutes().inMilliseconds,
    );
    final min15Reminder = 15.minutes();
    final hour1Reminder = 1.hours();
    final with15MinReminder =
        activity.copyWith(reminderBefore: [min15Reminder.inMilliseconds]);
    final with15MinAnd1HourReminder = activity.copyWith(reminderBefore: [
      min15Reminder.inMilliseconds,
      hour1Reminder.inMilliseconds
    ]);

    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity);

    // Act
    editActivityBloc.add(AddOrRemoveReminder(min15Reminder));
    editActivityBloc.add(AddOrRemoveReminder(hour1Reminder));
    editActivityBloc.add(AddOrRemoveReminder(hour1Reminder));
    editActivityBloc.add(AddOrRemoveReminder(min15Reminder));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnsavedActivityState(activity),
        UnsavedActivityState(with15MinReminder),
        UnsavedActivityState(with15MinAnd1HourReminder),
        UnsavedActivityState(with15MinReminder),
        UnsavedActivityState(activity),
      ]),
    );
  });
}
