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
  DateTime aTime = DateTime(2022, 02, 22, 22, 30);
  DateTime aDay = DateTime(2022, 02, 22);

  test('Initial state is the given activity', () {
    // Arrange
    final activity = Activity.createNew(title: '', startTime: aTime);
    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity, day: aDay);
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
    EditActivityBloc editActivityBloc =
        EditActivityBloc(activitiesBloc: mockActivitiesBloc, now: aTime);
    // Act // Assert
    expect(editActivityBloc.initialState.activity,
        MatchActivityWithoutId(activity));
  });

  test('Initial state with no title is not saveable', () {
    // Arrange
    final activity =
        Activity.createNew(title: '', startTime: aTime);
    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity, day: aDay);
    // Act // Assert
    expect(editActivityBloc.initialState.canSave, isFalse);
  });

  test('Changing activity changes activity', () async {
    // Arrange
    EditActivityBloc editActivityBloc =
        EditActivityBloc(activitiesBloc: mockActivitiesBloc, now: aTime);
    final activity = editActivityBloc.initialState.activity;
    final activityWithTitle = activity.copyWith(title: 'new title');

    // Act
    editActivityBloc.add(ChangeActivity(activityWithTitle));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnstoredActivityState(activity),
        UnstoredActivityState(activityWithTitle),
      ]),
    );
  });

  test('Trying to save yields nothing and does not try to save', () async {
    // Arrange

    EditActivityBloc editActivityBloc =
        EditActivityBloc(activitiesBloc: mockActivitiesBloc, now: aTime);
    final activity = editActivityBloc.initialState.activity;
    final activityWithTitle = activity.copyWith(title: 'new title');
    // Act
    editActivityBloc.add(SaveActivity());
    editActivityBloc.add(ChangeActivity(activityWithTitle));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnstoredActivityState(activity),
        UnstoredActivityState(activityWithTitle),
        StoredActivityState(activityWithTitle, aTime.onlyDays()),
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
      startTime: activity.start.onlyDays(),
      duration: 1.days() - 1.milliseconds(),
      reminderBefore: [],
    );

    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity, day: aDay);
    // Act
    editActivityBloc.add(ChangeActivity(activityAsFullDay));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        StoredActivityState(activity, aDay),
        StoredActivityState(activityAsFullDay, aDay),
        StoredActivityState(activityExpectedToBeSaved,
            activityExpectedToBeSaved.start.onlyDays()),
      ]),
    );
  });

  test('Changing date changes date but not time', () async {
    // Arrange
    final DateTime aDate = DateTime(2022, 02, 22, 22, 00);

    EditActivityBloc editActivityBloc =
        EditActivityBloc(activitiesBloc: mockActivitiesBloc, now: aDate);
    final activity = editActivityBloc.initialState.activity;
    final newDate = DateTime(2011, 11, 11, 11, 11, 11, 11, 11);
    final expetedNewDate = DateTime(2011, 11, 11, 22, 30);
    final expetedNewActivity =
        activity.copyWith(startTime: expetedNewDate);

    // Act
    editActivityBloc.add(ChangeDate(newDate));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnstoredActivityState(activity),
        UnstoredActivityState(expetedNewActivity),
      ]),
    );
  });

  test('Changing start time changes start time but not duration', () async {
    // Arrange
    final DateTime aDate = DateTime(2022, 02, 22, 22, 30);
    final DateTime day = DateTime(2022, 02, 22);

    final activity = Activity.createNew(
      title: '',
      startTime: aDate,
      duration: 30.minutes(),
    );
    final newStartTime = TimeOfDay(hour: 11, minute: 11);
    final expetedNewDate = DateTime(2022, 02, 22, 11, 11);

    final expetedNewActivity =
        activity.copyWith(startTime: expetedNewDate);

    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity, day: day);

    // Act
    editActivityBloc.add(ChangeStartTime(newStartTime));

    // Assert
    await expectLater(
        editActivityBloc,
        emitsInOrder([
          StoredActivityState(activity, day),
          StoredActivityState(expetedNewActivity, day),
        ]));
  });

  test('Changing end time changes duration but not start or end time',
      () async {
    // Arrange
    final DateTime aDate = DateTime(2001, 01, 01, 01, 01);
    final DateTime aDay = DateTime(2001, 01, 01);

    final activity = Activity.createNew(
      title: '',
      startTime: aDate,
      duration: 30.minutes(),
    );
    final newEndTime = TimeOfDay(hour: 11, minute: 11);
    final expectedDuration = Duration(hours: 10, minutes: 10);

    final expetedNewActivity =
        activity.copyWith(duration: expectedDuration);

    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity, day: aDay);

    // Act
    editActivityBloc.add(ChangeEndTime(newEndTime));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        StoredActivityState(activity, aDay),
        StoredActivityState(expetedNewActivity, aDay),
      ]),
    );
  });

  test('Changing end time to before changes duration to more then 12 hours',
      () async {
    // Arrange
    final DateTime aDate = DateTime(2001, 01, 01, 20, 30);
    final DateTime aDay = DateTime(2001, 01, 01);

    final activity = Activity.createNew(
      title: '',
      startTime: aDate,
      duration: 30.minutes(),
    );
    final newEndTime = TimeOfDay(hour: 20, minute: 00);

    final expectedDuration = Duration(hours: 23, minutes: 30);

    final expetedNewActivity =
        activity.copyWith(duration: expectedDuration);

    EditActivityBloc editActivityBloc = EditActivityBloc(
        activitiesBloc: mockActivitiesBloc, activity: activity, day: aDay);

    // Act
    editActivityBloc.add(ChangeEndTime(newEndTime));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        StoredActivityState(activity, aDay),
        StoredActivityState(expetedNewActivity, aDay),
      ]),
    );
  });

  test('Add or remove reminders', () async {
    // Arrange
    final DateTime aDate = DateTime(2001, 01, 01, 20, 30);
    final DateTime aDay = DateTime(2001, 01, 01);

    final activity = Activity.createNew(
      title: '',
      startTime: aDate,
      duration: 30.minutes(),
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
        activitiesBloc: mockActivitiesBloc, activity: activity, day: aDay);

    // Act
    editActivityBloc.add(AddOrRemoveReminder(min15Reminder));
    editActivityBloc.add(AddOrRemoveReminder(hour1Reminder));
    editActivityBloc.add(AddOrRemoveReminder(hour1Reminder));
    editActivityBloc.add(AddOrRemoveReminder(min15Reminder));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        StoredActivityState(activity, aDay),
        StoredActivityState(with15MinReminder, aDay),
        StoredActivityState(with15MinAnd1HourReminder, aDay),
        StoredActivityState(with15MinReminder, aDay),
        StoredActivityState(activity, aDay),
      ]),
    );
  });
}
