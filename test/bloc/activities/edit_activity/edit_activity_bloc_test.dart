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
      startTime: aTime,
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
    expect(editActivityBloc.saveErrors(SaveActivity()), isNotEmpty);
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
    final timeInterval = TimeInterval(startDate: aTime);

    // Act
    editActivityBloc.add(ReplaceActivity(activityWithTitle));

    // Assert
    await expectLater(
      editActivityBloc,
      emits(UnstoredActivityState(activityWithTitle, timeInterval)),
    );
  });

  test(
      'Trying to save uncompleted activity yields failed save and does not try to save',
      () async {
    // Arrange

    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: mockActivitiesBloc,
      day: aTime,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );
    final activity = editActivityBloc.state.activity;
    final activityWithTitle = activity.copyWith(title: 'new title');
    final timeInterval = TimeInterval(startDate: aTime);
    final newStartTime = TimeOfDay(hour: 10, minute: 0);
    final newTime = aTime.copyWith(
      hour: newStartTime.hour,
      minute: newStartTime.minute,
    );
    final newTimeInterval = TimeInterval(
      startTime: newStartTime,
      startDate: aTime,
    );

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
        UnstoredActivityState(activity, timeInterval).failSave({
          SaveError.NO_TITLE_OR_IMAGE,
          SaveError.NO_START_TIME,
        }),
        UnstoredActivityState(activityWithTitle, timeInterval),
        UnstoredActivityState(activityWithTitle, timeInterval).failSave({
          SaveError.NO_START_TIME,
        }),
        UnstoredActivityState(activityWithTitle, newTimeInterval),
        StoredActivityState(expectedSaved, newTimeInterval, aTime.onlyDays())
            .saveSucess(),
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
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.noneRecurringEnd),
      startDate: aTime,
    );
    // Act
    editActivityBloc.add(ReplaceActivity(activityAsFullDay));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder([
        StoredActivityState(activityAsFullDay, timeInterval, aDay),
        StoredActivityState(activityExpectedToBeSaved, timeInterval,
                activityExpectedToBeSaved.startTime.onlyDays())
            .saveSucess(),
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
    final expectedTimeInterval = TimeInterval(startDate: expetedNewDate);

    // Act
    editActivityBloc.add(ChangeDate(newDate));

    // Assert
    await expectLater(
      editActivityBloc,
      emits(UnstoredActivityState(activity, expectedTimeInterval)),
    );
  });

  test('activity.startTime set correctly', () async {
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
    final newTime = TimeOfDay(hour: 1, minute: 1);
    final newActivity = activity.copyWith(title: 'newTile');
    final expectedTimeInterval1 = TimeInterval(
      startTime: newTime,
      startDate: aDate,
    );
    final expectedTimeInterval2 = TimeInterval(
      startTime: newTime,
      startDate: newDate,
    );
    final expectedFinalStartTime = DateTime(
      expectedTimeInterval2.startDate.year,
      expectedTimeInterval2.startDate.month,
      expectedTimeInterval2.startDate.day,
      expectedTimeInterval2.startTime.hour,
      expectedTimeInterval2.startTime.minute,
    );
    final expectedFinalActivity = newActivity.copyWith(
      startTime: expectedFinalStartTime,
    );

    // Act
    editActivityBloc.add(ChangeStartTime(TimeOfDay(hour: 1, minute: 1)));
    editActivityBloc.add(ChangeDate(newDate));
    editActivityBloc.add(ReplaceActivity(newActivity));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder(
        [
          UnstoredActivityState(activity, expectedTimeInterval1),
          UnstoredActivityState(activity, expectedTimeInterval2),
          UnstoredActivityState(newActivity, expectedTimeInterval2),
          StoredActivityState(
            expectedFinalActivity,
            expectedTimeInterval2,
            expectedFinalStartTime.onlyDays(),
          ).saveSucess(),
        ],
      ),
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
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.noneRecurringEnd),
      startDate: aDate,
    );

    final expetedNewActivity = activity.copyWith(startTime: expectedNewDate);
    final expectedNewTimeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(expectedNewDate),
      endTime: TimeOfDay.fromDateTime(expectedNewDate.add(activity.duration)),
      startDate: aDate,
    );

    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, day),
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    final orignalState =
        StoredActivityState(activity, expectedTimeInterval, day);
    // Assert
    expect(editActivityBloc.state, orignalState);

    // Act
    editActivityBloc.add(ChangeStartTime(newStartTime));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
        editActivityBloc,
        emitsInOrder([
          StoredActivityState(activity, expectedNewTimeInterval, day),
          StoredActivityState(expetedNewActivity, expectedNewTimeInterval, day)
              .saveSucess(),
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
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.noneRecurringEnd),
      startDate: aDate,
    );

    final expetedNewActivity = activity.copyWith(duration: expectedDuration);
    final expectedNewTimeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.startTime.add(expectedDuration)),
      startDate: aDay,
    );

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
      emitsInOrder(
        [
          StoredActivityState(activity, expectedNewTimeInterval, aDay),
          StoredActivityState(expetedNewActivity, expectedNewTimeInterval, aDay)
              .saveSucess(),
        ],
      ),
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
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.noneRecurringEnd),
      startDate: aDate,
    );

    final expetedNewActivity = activity.copyWith(duration: expectedDuration);
    final expectedNewTimeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.startTime.add(expectedDuration)),
      startDate: aDate,
    );

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
        StoredActivityState(expetedNewActivity, expectedNewTimeInterval, aDay)
            .saveSucess(),
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
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.startTime.add(30.minutes())),
      startDate: aDate,
    );

    final expectedNewActivity = activity.copyWith(duration: expectedDuration);
    final expectedNewTimeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      startDate: aDate,
    );

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
            .saveSucess(),
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
      startTime: TimeOfDay.fromDateTime(aDay.copyWith(hour: 8, minute: 0)),
      endTime: TimeOfDay.fromDateTime(aDay.copyWith(hour: 10, minute: 0)),
      startDate: aDay,
    );

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
          TimeInterval(
            endTime: TimeOfDay.fromDateTime(aDay.copyWith(hour: 10, minute: 0)),
            startDate: aDay,
          ),
        ),
        UnstoredActivityState(activity, expectedTimeInterval),
        UnstoredActivityState(activityWithTitle, expectedTimeInterval),
        StoredActivityState(expectedActivity, expectedTimeInterval, aDay)
            .saveSucess(),
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
      startTime: TimeOfDay(hour: 12, minute: 0),
      endTime: TimeOfDay(hour: 10, minute: 0),
      startDate: aDay,
    );

    // Act
    editActivityBloc.add(ChangeEndTime(TimeOfDay(hour: 10, minute: 0)));
    editActivityBloc.add(ChangeStartTime(TimeOfDay(hour: 12, minute: 0)));
    editActivityBloc.add(ReplaceActivity(activityWithTitle));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder(
        [
          UnstoredActivityState(
            activity,
            TimeInterval(
              endTime: TimeOfDay(hour: 10, minute: 0),
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
          StoredActivityState(
            expectedActivity,
            expectedTimeInterval,
            aDay,
          ).saveSucess(),
        ],
      ),
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
        UnstoredActivityState(
          activity,
          TimeInterval(
            startTime: startTime1,
            startDate: aDay,
          ),
        ),
        UnstoredActivityState(
          activity,
          TimeInterval(
            startTime: startTime1,
            endTime: endTime1,
            startDate: aDay,
          ),
        ),
        UnstoredActivityState(
          activity,
          TimeInterval(
            startTime: startTime2,
            endTime: endTime2,
            startDate: aDay,
          ),
        ),
        UnstoredActivityState(
          activity,
          TimeInterval(
            startTime: startTime3,
            endTime: endTime3,
            startDate: aDay,
          ),
        ),
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
    final timeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(aTime),
      startDate: aTime,
    );
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
    final timeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(aTime),
      startDate: aTime,
    );
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
    final timeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(aTime),
      startDate: aTime,
    );
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

  test('Trying to save recurrance withtout data yeilds error', () async {
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
    final time = TimeOfDay.fromDateTime(aTime);
    final expectedTimeIntervall = TimeInterval(
      startTime: time,
      startDate: aDay,
    );
    editActivityBloc.add(ChangeStartTime(time));
    editActivityBloc.add(ReplaceActivity(activity));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
        editActivityBloc,
        emitsInOrder([
          UnstoredActivityState(
            originalActivity,
            expectedTimeIntervall,
          ),
          UnstoredActivityState(
            activity,
            expectedTimeIntervall,
          ),
          UnstoredActivityState(
            activity,
            expectedTimeIntervall,
          ).failSave({SaveError.NO_RECURRING_DAYS}),
        ]));
  });

  test('BUG SGC-352 edit a none recurring activity to be recurring', () async {
    // Arrange
    final activity = Activity.createNew(title: 'SGC-352', startTime: aTime);
    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    final expectedTimeIntervall = TimeInterval(
      startDate: aDay,
      startTime: TimeOfDay.fromDateTime(aTime),
    );
    final recurringActivity = activity.copyWith(
      recurs: Recurs.weeklyOnDay(aTime.weekday),
    );

    // Act
    editActivityBloc.add(ReplaceActivity(recurringActivity));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc,
      emitsInOrder(
        [
          StoredActivityState(
            recurringActivity,
            expectedTimeIntervall,
            aDay,
          ),
          StoredActivityState(
            recurringActivity,
            expectedTimeIntervall,
            aDay,
          ).saveSucess(),
        ],
      ),
    );
  });

  test('bug SGC-332 - Editing recurring on this day should save this day',
      () async {
    // Arrange
    final activity = Activity.createNew(
      title: 'title',
      startTime: aTime.subtract(
        100.days(),
      ),
      recurs: Recurs.weeklyOnDays([1, 2, 3, 4, 5, 6, 7]),
    );

    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    final activityWithNewTitle = activity.copyWith(title: 'new title');
    final expetedActivityToSave =
        activityWithNewTitle.copyWith(startTime: activity.startClock(aDay));

    // Act
    editActivityBloc.add(ReplaceActivity(activityWithNewTitle));

    // Assert
    await expectLater(
        editActivityBloc,
        emitsInOrder([
          StoredActivityState(
            activityWithNewTitle,
            TimeInterval(
              startTime: TimeOfDay.fromDateTime(activity.startTime),
              startDate: aDay,
            ),
            aDay,
          ),
        ]));

    // Act
    editActivityBloc.add(SaveRecurringActivity(ApplyTo.onlyThisDay, aDay));

    // Assert - correct day is saved
    await untilCalled(mockActivitiesBloc.add(any));
    expect(
      verify(mockActivitiesBloc.add(captureAny)).captured.single,
      UpdateRecurringActivity(
        ActivityDay(expetedActivityToSave, aDay),
        ApplyTo.onlyThisDay,
      ),
    );
  });
}
