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
    AddActivityBloc addActivityBloc =
        AddActivityBloc(activitiesBloc: mockActivitiesBloc, activity: activity);
    // Act // Assert
    expect(addActivityBloc.initialState.activity, activity);
  });
  test('Initial state with no title is not saveable', () {
    // Arrange
    final activity =
        Activity.createNew(title: '', startTime: aTime.millisecondsSinceEpoch);
    AddActivityBloc addActivityBloc =
        AddActivityBloc(activitiesBloc: mockActivitiesBloc, activity: activity);
    // Act // Assert
    expect(addActivityBloc.initialState.canSave, isFalse);
  });
  test('Changing activity changes activity', () async {
    // Arrange
    final activity =
        Activity.createNew(title: '', startTime: aTime.millisecondsSinceEpoch);
    final activityWithTitle = activity.copyWith(title: 'new title');

    AddActivityBloc addActivityBloc =
        AddActivityBloc(activitiesBloc: mockActivitiesBloc, activity: activity);
    // Act
    addActivityBloc.add(ChangeActivity(activityWithTitle));

    // Assert
    await expectLater(
      addActivityBloc,
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

    AddActivityBloc addActivityBloc =
        AddActivityBloc(activitiesBloc: mockActivitiesBloc, activity: activity);
    // Act
    addActivityBloc.add(SaveActivity());
    addActivityBloc.add(ChangeActivity(activityWithTitle));
    addActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      addActivityBloc,
      emitsInOrder([
        UnsavedActivityState(activity),
        UnsavedActivityState(activityWithTitle),
        SavedActivityState(activityWithTitle),
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

    AddActivityBloc addActivityBloc =
        AddActivityBloc(activitiesBloc: mockActivitiesBloc, activity: activity);
    // Act
    addActivityBloc.add(ChangeDate(newDate));

    // Assert
    await expectLater(
      addActivityBloc,
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

    AddActivityBloc addActivityBloc =
        AddActivityBloc(activitiesBloc: mockActivitiesBloc, activity: activity);

    // Act
    addActivityBloc.add(ChangeStartTime(newStartTime));

    // Assert
    await expectLater(
        addActivityBloc,
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

    AddActivityBloc addActivityBloc =
        AddActivityBloc(activitiesBloc: mockActivitiesBloc, activity: activity);

    // Act
    addActivityBloc.add(ChangeEndTime(newEndTime));

    // Assert
    await expectLater(
      addActivityBloc,
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

    AddActivityBloc addActivityBloc =
        AddActivityBloc(activitiesBloc: mockActivitiesBloc, activity: activity);

    // Act
    addActivityBloc.add(ChangeEndTime(newEndTime));

    // Assert
    await expectLater(
      addActivityBloc,
      emitsInOrder([
        UnsavedActivityState(activity),
        UnsavedActivityState(expetedNewActivity),
      ]),
    );
  });
}
