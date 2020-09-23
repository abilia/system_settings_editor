import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/activities/activities_bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../matchers.dart';
import '../../../mocks.dart';

void main() {
  ActivitiesBloc mockActivitiesBloc;
  MemoplannerSettingBloc mockMemoplannerSettingsBloc;
  ClockBloc clockBloc;
  final aTime = DateTime(2022, 02, 22, 22, 30);
  final aDay = DateTime(2022, 02, 22);

  setUp(() {
    mockActivitiesBloc = MockActivitiesBloc();
    mockMemoplannerSettingsBloc = MockMemoplannerSettingsBloc();
    clockBloc = ClockBloc(StreamController<DateTime>().stream);
    when(mockMemoplannerSettingsBloc.state)
        .thenReturn(MemoplannerSettingsLoaded(MemoplannerSettings()));
  });

  test('Initial state is the given activity', () {
    // Arrange
    final activity = Activity.createNew(title: '', startTime: aTime);
    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );
    // Act // Assert
    expect(editActivityBloc.state, isA<StoredActivityState>());
    expect(editActivityBloc.state.activity, activity);
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
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: aTime,
    );
    // Act // Assert
    expect(editActivityBloc.state.activity, MatchActivityWithoutId(activity));
  });

  test('Initial state with no title is not saveable', () {
    // Arrange
    final activity = Activity.createNew(title: '', startTime: aTime);
    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );
    // Act // Assert
    expect(editActivityBloc.canSave.isEmpty, isFalse);
  });

  test('Changing activity changes activity', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: aTime,
    );
    final activity = editActivityBloc.state.activity;
    final activityWithTitle = activity.copyWith(title: 'new title');
    final timeInterval = TimeInterval(null, null);

    // Act
    editActivityBloc.add(ReplaceActivity(activityWithTitle));

    // Assert
    await expectLater(
      editActivityBloc,
      emits(UnstoredActivityState(activityWithTitle, timeInterval)),
    );
  });

  test('Trying to save yields failed save and does not try to save', () async {
    // Arrange

    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      day: aTime,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );
    final activity = editActivityBloc.state.activity;
    final activityWithTitle = activity.copyWith(title: 'new title');
    final timeInterval = TimeInterval(null, null);
    final newStartTime = TimeOfDay(hour: 10, minute: 0);
    final newTime = aTime.copyWith(
      hour: newStartTime.hour,
      minute: newStartTime.minute,
    );
    final newTimeInterval = TimeInterval(newStartTime, null);

    final expectedSaved = activityWithTitle.copyWith(startTime: newTime);
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
        UnstoredActivityState(activity, timeInterval, null, true),
        UnstoredActivityState(activityWithTitle, timeInterval, null, true),
        UnstoredActivityState(activityWithTitle, newTimeInterval, null, true),
        StoredActivityState(expectedSaved, newTimeInterval, aTime.onlyDays()),
      ]),
    );
    verify(mockActivitiesBloc.add(AddActivity(expectedSaved)));
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
      reminderBefore: [],
    );

    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );
    final timeInterval = TimeInterval(
        TimeOfDay.fromDateTime(activity.startTime),
        TimeOfDay.fromDateTime(activity.noneRecurringEnd));
    // Act
    editActivityBloc.add(ReplaceActivity(activityAsFullDay));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        StoredActivityState(activityAsFullDay, timeInterval, aDay),
        StoredActivityState(activityExpectedToBeSaved, timeInterval,
            activityExpectedToBeSaved.startTime.onlyDays()),
      ]),
    );
  });

  test('Changing date changes date but not time in timeinterval', () async {
    // Arrange
    final aDate = DateTime(2022, 02, 22, 22, 00);

    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      day: aDate,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );
    final activity = editActivityBloc.state.activity;
    final newDate = DateTime(2011, 11, 11, 11, 11);
    final expetedNewDate = DateTime(2011, 11, 11, 11, 11);
    final expetedNewActivity = activity.copyWith(startTime: expetedNewDate);
    final expectedTimeInterval = TimeInterval(null, null);

    // Act
    editActivityBloc.add(ChangeDate(newDate));

    // Assert
    await expectLater(
      editActivityBloc,
      emits(UnstoredActivityState(expetedNewActivity, expectedTimeInterval)),
    );
  });

  test('Changing start time changes start time but not duration', () async {
    // Arrange
    final aDate = DateTime(2022, 02, 22, 22, 30);
    final day = DateTime(2022, 02, 22);

    final activity = Activity.createNew(
      title: 'test',
      startTime: aDate,
      duration: 30.minutes(),
    );
    final newStartTime = TimeOfDay(hour: 11, minute: 00);
    final expectedNewDate = DateTime(2022, 02, 22, 11, 00);
    final expectedTimeInterval = TimeInterval(
        TimeOfDay.fromDateTime(activity.startTime),
        TimeOfDay.fromDateTime(activity.noneRecurringEnd));

    final expetedNewActivity = activity.copyWith(startTime: expectedNewDate);
    final expectedNewTimeInterval = TimeInterval(
        TimeOfDay.fromDateTime(expectedNewDate),
        TimeOfDay.fromDateTime(expectedNewDate.add(activity.duration)));

    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, day),
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    // Assert
    expect(editActivityBloc.state,
        StoredActivityState(activity, expectedTimeInterval, day));

    // Act
    editActivityBloc.add(ChangeStartTime(newStartTime));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
        editActivityBloc,
        emitsInOrder([
          StoredActivityState(activity, expectedNewTimeInterval, day),
          StoredActivityState(expetedNewActivity, expectedNewTimeInterval, day),
        ]));
  });

  test('Changing end time changes duration but not start or end time',
      () async {
    // Arrange
    final aDate = DateTime(2001, 01, 01, 01, 01);
    final aDay = DateTime(2001, 01, 01);

    final activity = Activity.createNew(
      title: 'test',
      startTime: aDate,
      duration: 30.minutes(),
    );
    final newEndTime = TimeOfDay(hour: 11, minute: 11);
    final expectedDuration = Duration(hours: 10, minutes: 10);
    final expectedTimeInterval = TimeInterval(
        TimeOfDay.fromDateTime(activity.startTime),
        TimeOfDay.fromDateTime(activity.noneRecurringEnd));

    final expetedNewActivity = activity.copyWith(duration: expectedDuration);
    final expectedNewTimeInterval = TimeInterval(
        TimeOfDay.fromDateTime(activity.startTime),
        TimeOfDay.fromDateTime(activity.startTime.add(expectedDuration)));

    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    // Assert
    expect(editActivityBloc.state,
        StoredActivityState(activity, expectedTimeInterval, aDay));

    // Act
    editActivityBloc.add(ChangeEndTime(newEndTime));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        StoredActivityState(activity, expectedNewTimeInterval, aDay),
        StoredActivityState(expetedNewActivity, expectedNewTimeInterval, aDay),
      ]),
    );
  });

  test('Changing end time to before changes duration to more than 12 hours',
      () async {
    // Arrange
    final aDate = DateTime(2001, 01, 01, 20, 30);
    final aDay = DateTime(2001, 01, 01);

    final activity = Activity.createNew(
      title: 'test',
      startTime: aDate,
      duration: 30.minutes(),
    );
    final newEndTime = TimeOfDay(hour: 20, minute: 00);

    final expectedDuration = Duration(hours: 23, minutes: 30);
    final expectedTimeInterval = TimeInterval(
        TimeOfDay.fromDateTime(activity.startTime),
        TimeOfDay.fromDateTime(activity.noneRecurringEnd));

    final expetedNewActivity = activity.copyWith(duration: expectedDuration);
    final expectedNewTimeInterval = TimeInterval(
        TimeOfDay.fromDateTime(activity.startTime),
        TimeOfDay.fromDateTime(activity.startTime.add(expectedDuration)));

    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    // Assert
    expect(editActivityBloc.state,
        StoredActivityState(activity, expectedTimeInterval, aDay));

    // Act
    editActivityBloc.add(ChangeEndTime(newEndTime));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        StoredActivityState(activity, expectedNewTimeInterval, aDay),
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
    final timeInterval = TimeInterval(
        TimeOfDay.fromDateTime(activity.startTime),
        TimeOfDay.fromDateTime(activity.noneRecurringEnd));
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
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
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
        StoredActivityState(with15MinReminder, timeInterval, aDay),
        StoredActivityState(with15MinAnd1HourReminder, timeInterval, aDay),
        StoredActivityState(with15MinReminder, timeInterval, aDay),
        StoredActivityState(activity, timeInterval, aDay),
      ]),
    );
  });

  test('set empty end time sets duration to 0 and end time to empty', () async {
    // Arrange
    final aDate = DateTime(2001, 01, 01, 01, 01);
    final aDay = DateTime(2001, 01, 01);

    final activity = Activity.createNew(
      title: 'test',
      startTime: aDate,
      duration: 30.minutes(),
    );
    final expectedDuration = Duration.zero;
    final expectedTimeInterval = TimeInterval(
        TimeOfDay.fromDateTime(activity.startTime),
        TimeOfDay.fromDateTime(activity.startTime.add(30.minutes())));

    final expectedNewActivity = activity.copyWith(duration: expectedDuration);
    final expectedNewTimeInterval =
        TimeInterval(TimeOfDay.fromDateTime(activity.startTime), null);

    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    // Assert
    expect(editActivityBloc.state,
        StoredActivityState(activity, expectedTimeInterval, aDay));

    // Act
    editActivityBloc.add(ChangeEndTime(null));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        StoredActivityState(activity, expectedNewTimeInterval, aDay),
        StoredActivityState(expectedNewActivity, expectedNewTimeInterval, aDay)
      ]),
    );
  });

  test('first set end time and then start time should give correct duration',
      () async {
    // Arrange
    final aDay = DateTime(2001, 01, 01);

    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      day: aDay,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );
    final activity = editActivityBloc.state.activity;
    final activityWithTitle = activity.copyWith(title: 'title');

    final expectedActivity = activityWithTitle.copyWith(
        startTime: aDay.copyWith(hour: 8, minute: 0), duration: 2.hours());
    final expectedTimeInterval = TimeInterval(
        TimeOfDay.fromDateTime(aDay.copyWith(hour: 8, minute: 0)),
        TimeOfDay.fromDateTime(aDay.copyWith(hour: 10, minute: 0)));

    // Act
    editActivityBloc.add(ChangeEndTime(TimeOfDay(hour: 10, minute: 0)));
    editActivityBloc.add(ChangeStartTime(TimeOfDay(hour: 8, minute: 0)));
    editActivityBloc.add(ReplaceActivity(activityWithTitle));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnstoredActivityState(
            activity,
            TimeInterval(null,
                TimeOfDay.fromDateTime(aDay.copyWith(hour: 10, minute: 0)))),
        UnstoredActivityState(activity, expectedTimeInterval),
        UnstoredActivityState(activityWithTitle, expectedTimeInterval),
        StoredActivityState(expectedActivity, expectedTimeInterval, aDay)
      ]),
    );
  });

  test('Setting start time after end time', () async {
    // Arrange
    final aDay = DateTime(2001, 01, 01);

    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      day: aDay,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );
    final activity = editActivityBloc.state.activity;
    final activityWithTitle = activity.copyWith(title: 'title');

    final expectedActivity = activityWithTitle.copyWith(
        startTime: aDay.copyWith(hour: 12, minute: 0), duration: 22.hours());
    final expectedTimeInterval = TimeInterval(
        TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 10, minute: 0));

    // Act
    editActivityBloc.add(ChangeEndTime(TimeOfDay(hour: 10, minute: 0)));
    editActivityBloc.add(ChangeStartTime(TimeOfDay(hour: 12, minute: 0)));
    editActivityBloc.add(ReplaceActivity(activityWithTitle));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnstoredActivityState(
          activity,
          TimeInterval(null, TimeOfDay(hour: 10, minute: 0)),
        ),
        UnstoredActivityState(
          activity,
          expectedTimeInterval,
        ),
        UnstoredActivityState(
          activityWithTitle,
          expectedTimeInterval,
        ),
        StoredActivityState(
          expectedActivity,
          expectedTimeInterval,
          aDay,
        )
      ]),
    );
  });

  test('Changing start time changes end time equally', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: aDay,
    );

    final activity = editActivityBloc.state.activity;

    final startTime1 = TimeOfDay(hour: 10, minute: 0);
    final endTime1 = TimeOfDay(hour: 11, minute: 0);

    final endTime2 = TimeOfDay(hour: 16, minute: 15);
    final startTime2 = TimeOfDay(hour: 15, minute: 15);

    final startTime3 = TimeOfDay(hour: 23, minute: 30);
    final endTime3 = TimeOfDay(hour: 0, minute: 30);

    // Act
    editActivityBloc.add(ChangeStartTime(startTime1));
    editActivityBloc.add(ChangeEndTime(endTime1));
    editActivityBloc.add(ChangeStartTime(startTime2));
    editActivityBloc.add(ChangeStartTime(startTime3));

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        UnstoredActivityState(activity, TimeInterval(startTime1, null)),
        UnstoredActivityState(activity, TimeInterval(startTime1, endTime1)),
        UnstoredActivityState(activity, TimeInterval(startTime2, endTime2)),
        UnstoredActivityState(activity, TimeInterval(startTime3, endTime3)),
      ]),
    );
  });

  test('Changing InfoItem', () async {
    // Arrange
    final note = NoteInfoItem('anote');
    final withNote =
        Activity.createNew(title: 'null', startTime: aTime, infoItem: note);
    final withChecklist = withNote.copyWith(infoItem: Checklist());
    final withNoInfoItem = withNote.copyWith(infoItem: NoInfoItem());
    final activityDay = ActivityDay(withNote, aDay);
    final timeInterval = TimeInterval(TimeOfDay.fromDateTime(aTime), null);
    final editActivityBloc = EditActivityBloc(
      activityDay,
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    // Act
    editActivityBloc.add(ChangeInfoItemType(Checklist));
    editActivityBloc.add(ChangeInfoItemType(NoteInfoItem));
    editActivityBloc.add(ChangeInfoItemType(NoInfoItem));

    // Assert
    await expectLater(
      editActivityBloc,
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
  });

  test('Trying to save an empty checklist saves noInfoItem', () async {
    // Arrange
    final activity = Activity.createNew(
        title: 'null', startTime: aTime, infoItem: NoteInfoItem('anote'));
    final activityWithEmptyChecklist = activity.copyWith(infoItem: Checklist());
    final expectedActivity = activity.copyWith(infoItem: InfoItem.none);
    final activityDay = ActivityDay(activity, aDay);
    final timeInterval = TimeInterval(TimeOfDay.fromDateTime(aTime), null);
    final editActivityBloc = EditActivityBloc(
      activityDay,
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    // Act
    editActivityBloc.add(ChangeInfoItemType(Checklist));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emits(
        StoredActivityState(
          activityWithEmptyChecklist,
          timeInterval,
          aDay,
        ).copyWith(activityWithEmptyChecklist,
            infoItems: {NoteInfoItem: activity.infoItem}),
      ),
    );

    await untilCalled(mockActivitiesBloc.add(any));
    expect(verify(mockActivitiesBloc.add(captureAny)).captured.single,
        UpdateActivity(expectedActivity));
  });

  test('Trying to save an empty note saves noInfoItem', () async {
    // Arrange

    final activity = Activity.createNew(
        title: 'null',
        startTime: aTime,
        infoItem: Checklist(questions: [Question(id: 0, name: 'name')]));
    final expectedActivity = activity.copyWith(infoItem: InfoItem.none);
    final activityWithEmptyNote = activity.copyWith(infoItem: NoteInfoItem());
    final activityDay = ActivityDay(activity, aDay);
    final timeInterval = TimeInterval(TimeOfDay.fromDateTime(aTime), null);
    final editActivityBloc = EditActivityBloc(
      activityDay,
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    // Act
    editActivityBloc.add(ChangeInfoItemType(NoteInfoItem));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emits(
        StoredActivityState(
          activityWithEmptyNote,
          timeInterval,
          aDay,
        ).copyWith(activityWithEmptyNote,
            infoItems: {Checklist: activity.infoItem}),
      ),
    );

    await untilCalled(mockActivitiesBloc.add(any));
    expect(verify(mockActivitiesBloc.add(captureAny)).captured.single,
        UpdateActivity(expectedActivity));
  });

  test('Trying to save recurrance withtout data saves no recurrence', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: aDay,
    );

    // Act
    final originalActivity = editActivityBloc.state.activity;
    final activity = originalActivity.copyWith(
      title: 'null',
      recurs: Recurs.monthlyOnDays([]),
    );
    final expectedActivity = activity.copyWith(
      recurs: Recurs.not,
      startTime: aTime,
    );
    final time = TimeOfDay.fromDateTime(aTime);
    editActivityBloc.add(ChangeStartTime(time));
    editActivityBloc.add(ReplaceActivity(activity));

    // Assert
    await expectLater(
        editActivityBloc,
        emitsInOrder([
          UnstoredActivityState(originalActivity, TimeInterval(time, null)),
          UnstoredActivityState(activity, TimeInterval(time, null)),
        ]));

    editActivityBloc.add(SaveActivity());

    await untilCalled(mockActivitiesBloc.add(any));

    expect(verify(mockActivitiesBloc.add(captureAny)).captured.single,
        AddActivity(expectedActivity));
  });
}
