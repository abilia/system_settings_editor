import 'dart:async';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/activities/activities_bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks/shared.dart';
import '../../../mocks/shared.mocks.dart';
import '../../../test_helpers/matchers.dart';

void main() {
  // late FakeActivitiesBloc mockActivitiesBloc;
  late MemoplannerSettingBloc mockMemoplannerSettingsBloc;
  late ClockBloc clockBloc;
  final nowTime = DateTime(2000, 02, 22, 22, 30);
  final aTime = DateTime(2022, 02, 22, 22, 30);
  final aDay = DateTime(2022, 02, 22);

  setUp(() {
    tz.initializeTimeZones();

    mockMemoplannerSettingsBloc = FakeMemoplannerSettingsBloc();
    clockBloc =
        ClockBloc(StreamController<DateTime>().stream, initialTime: nowTime);
  });

  test('Initial state is the given activity', () {
    // Arrange
    final activity = Activity.createNew(title: '', startTime: aTime);
    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: FakeActivitiesBloc(),
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
      timezone: tz.local.name,
    );
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: aTime,
    );
    // Act // Assert
    expect(editActivityBloc.state.activity, MatchActivityWithoutId(activity));
  });

  test('Initial state with basic activity starting at 00:00 has no start time',
      () {
    // Arrange
    final basicActivity = BasicActivityDataItem.createNew(
      title: 'basic title',
      startTime: Duration.zero,
    );
    // Act
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: aDay,
      basicActivityData: basicActivity,
    );
    // Assert
    expect(
      editActivityBloc.state.activity,
      MatchActivityWithoutId(
        basicActivity.toActivity(
          timezone: 'UTC',
          day: aDay,
        ),
      ),
    );
    expect(editActivityBloc.state.timeInterval, TimeInterval(startDate: aDay));
  });

  test('Initial state with basic activity starting at 00:01 has start time',
      () {
    // Arrange
    final basicActivity = BasicActivityDataItem.createNew(
      title: 'basic title',
      startTime: Duration(hours: 4, minutes: 4),
      duration: Duration(hours: 4, minutes: 4),
    );
    // Act
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: aDay,
      basicActivityData: basicActivity,
    );
    // Assert
    expect(
        editActivityBloc.state.activity,
        MatchActivityWithoutId(
          basicActivity.toActivity(
            timezone: 'UTC',
            day: aDay,
          ),
        ));
    final expected = TimeInterval(
      startDate: aDay,
      startTime: TimeOfDay(hour: 4, minute: 4),
      endTime: TimeOfDay(hour: 8, minute: 8),
    );
    final actual = editActivityBloc.state.timeInterval;
    expect(actual, expected);
  });

  test(
      'Initial state with basic activity starting at 00:00 but with duration has start time',
      () {
    // Arrange
    final basicActivity = BasicActivityDataItem.createNew(
      title: 'basic title',
      startTime: Duration.zero,
      duration: Duration(minutes: 30),
    );
    // Act
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: aDay,
      basicActivityData: basicActivity,
    );
    // Assert
    expect(
        editActivityBloc.state.activity,
        MatchActivityWithoutId(
          basicActivity.toActivity(
            timezone: 'UTC',
            day: aDay,
          ),
        ));
    final expected = TimeInterval(
      startDate: aDay,
      startTime: TimeOfDay(hour: 0, minute: 0),
      endTime: TimeOfDay(hour: 0, minute: 30),
    );
    final actual = editActivityBloc.state.timeInterval;
    expect(actual, expected);
  });

  test('Initial state with no title is not saveable', () {
    // Arrange
    final activity = Activity.createNew(title: '', startTime: aTime);
    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: FakeActivitiesBloc(),
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );
    // Act // Assert
    expect(editActivityBloc.saveErrors(SaveActivity()), isNotEmpty);
  });

  test('Changing activity changes activity', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
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
      editActivityBloc.stream,
      emits(UnstoredActivityState(activityWithTitle, timeInterval)),
    );
  });

  test(
      'Trying to save uncompleted activity yields failed save and does not try to save',
      () async {
    // Arrange
    final mockActivitiesBloc = MockActivitiesBloc();
    when(mockActivitiesBloc.state).thenReturn(ActivitiesNotLoaded());

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
      endTime: newStartTime,
      startDate: aTime,
    );

    final expectedSaved = activityWithTitle.copyWith(startTime: newTime);
    // Act
    editActivityBloc.add(SaveActivity());
    editActivityBloc.add(ReplaceActivity(activityWithTitle));
    editActivityBloc.add(SaveActivity());
    editActivityBloc.add(ChangeTimeInterval(startTime: newStartTime));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc.stream,
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
      activitiesBloc: FakeActivitiesBloc(),
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
      editActivityBloc.stream,
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
      activitiesBloc: FakeActivitiesBloc(),
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
      editActivityBloc.stream,
      emits(UnstoredActivityState(activity, expectedTimeInterval)),
    );
  });

  test('activity.startTime set correctly', () async {
    // Arrange
    final aDate = DateTime(2022, 02, 22, 22, 00);

    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
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
      endTime: newTime,
      startDate: aDate,
    );
    final expectedTimeInterval2 = TimeInterval(
      startTime: newTime,
      endTime: newTime,
      startDate: newDate,
    );
    final expectedFinalStartTime = DateTime(
      expectedTimeInterval2.startDate.year,
      expectedTimeInterval2.startDate.month,
      expectedTimeInterval2.startDate.day,
      expectedTimeInterval2.startTime!.hour,
      expectedTimeInterval2.startTime!.minute,
    );
    final expectedFinalActivity = newActivity.copyWith(
      startTime: expectedFinalStartTime,
    );

    // Act
    editActivityBloc
        .add(ChangeTimeInterval(startTime: TimeOfDay(hour: 1, minute: 1)));
    editActivityBloc.add(ChangeDate(newDate));
    editActivityBloc.add(ReplaceActivity(newActivity));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc.stream,
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
      activitiesBloc: FakeActivitiesBloc(),
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    // Assert
    expect(editActivityBloc.state,
        StoredActivityState(activity, expectedTimeInterval, aDay));

    // Act
    editActivityBloc.add(ChangeTimeInterval(endTime: newEndTime));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc.stream,
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
      activitiesBloc: FakeActivitiesBloc(),
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    // Assert
    expect(editActivityBloc.state,
        StoredActivityState(activity, expectedTimeInterval, aDay));

    // Act
    editActivityBloc.add(ChangeTimeInterval(endTime: newEndTime));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc.stream,
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
      activitiesBloc: FakeActivitiesBloc(),
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
      editActivityBloc.stream,
      emitsInOrder([
        StoredActivityState(with15MinReminder, timeInterval, aDay),
        StoredActivityState(with15MinAnd1HourReminder, timeInterval, aDay),
        StoredActivityState(with15MinReminder, timeInterval, aDay),
        StoredActivityState(activity, timeInterval, aDay),
      ]),
    );
  });

  test(
      'set empty end time sets duration to 0 and end time to same as start time',
      () async {
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
      endTime: TimeOfDay.fromDateTime(activity.startTime),
      startDate: aDate,
    );

    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: FakeActivitiesBloc(),
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    // Assert
    expect(editActivityBloc.state,
        StoredActivityState(activity, expectedTimeInterval, aDay));

    // Act
    editActivityBloc.add(ChangeTimeInterval(
        startTime: TimeOfDay.fromDateTime(activity.startTime), endTime: null));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc.stream,
      emitsInOrder([
        StoredActivityState(activity, expectedNewTimeInterval, aDay),
        StoredActivityState(expectedNewActivity, expectedNewTimeInterval, aDay)
            .saveSucess(),
      ]),
    );
  });

  test('Setting start time after end time', () async {
    // Arrange
    final aDay = DateTime(2001, 01, 01);

    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
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
    editActivityBloc
        .add(ChangeTimeInterval(endTime: TimeOfDay(hour: 10, minute: 0)));
    editActivityBloc.add(ChangeTimeInterval(
        startTime: TimeOfDay(hour: 12, minute: 0),
        endTime: TimeOfDay(hour: 10, minute: 0)));
    editActivityBloc.add(ReplaceActivity(activityWithTitle));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
      editActivityBloc.stream,
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
      activitiesBloc: FakeActivitiesBloc(),
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    // Act
    editActivityBloc.add(ChangeInfoItemType(Checklist));
    editActivityBloc.add(ChangeInfoItemType(NoteInfoItem));
    editActivityBloc.add(ChangeInfoItemType(NoInfoItem));

    // Assert
    await expectLater(
      editActivityBloc.stream,
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

  // test('Trying to save an empty checklist saves noInfoItem', () async {
  //   // Arrange
  //   final activity = Activity.createNew(
  //       title: 'null', startTime: aTime, infoItem: NoteInfoItem('anote'));
  //   final activityWithEmptyChecklist = activity.copyWith(infoItem: Checklist());
  //   final expectedActivity = activity.copyWith(infoItem: InfoItem.none);
  //   final activityDay = ActivityDay(activity, aDay);
  //   final timeInterval = TimeInterval(
  //     startTime: TimeOfDay.fromDateTime(aTime),
  //     startDate: aTime,
  //   );
  //   final editActivityBloc = EditActivityBloc(
  //     activityDay,
  //     activitiesBloc: mockActivitiesBloc,
  //     memoplannerSettingBloc: mockMemoplannerSettingsBloc,
  //     clockBloc: clockBloc,
  //   );

  //   // Act
  //   editActivityBloc.add(ChangeInfoItemType(Checklist));
  //   editActivityBloc.add(SaveActivity());

  //   // Assert
  //   await expectLater(
  //     editActivityBloc.stream,
  //     emits(
  //       StoredActivityState(
  //         activityWithEmptyChecklist,
  //         timeInterval,
  //         aDay,
  //       ).copyWith(activityWithEmptyChecklist,
  //           infoItems: {NoteInfoItem: activity.infoItem}),
  //     ),
  //   );

  //   await untilCalled(mockActivitiesBloc.add(any));
  //   expect(verify(mockActivitiesBloc.add(captureAny)).captured.single,
  //       UpdateActivity(expectedActivity));
  // });

  // test('Trying to save an empty note saves noInfoItem', () async {
  //   // Arrange

  //   final activity = Activity.createNew(
  //       title: 'null',
  //       startTime: aTime,
  //       infoItem: Checklist(questions: [Question(id: 0, name: 'name')]));
  //   final expectedActivity = activity.copyWith(infoItem: InfoItem.none);
  //   final activityWithEmptyNote = activity.copyWith(infoItem: NoteInfoItem());
  //   final activityDay = ActivityDay(activity, aDay);
  //   final timeInterval = TimeInterval(
  //     startTime: TimeOfDay.fromDateTime(aTime),
  //     startDate: aTime,
  //   );
  //   final editActivityBloc = EditActivityBloc(
  //     activityDay,
  //     activitiesBloc: mockActivitiesBloc,
  //     memoplannerSettingBloc: mockMemoplannerSettingsBloc,
  //     clockBloc: clockBloc,
  //   );

  //   // Act
  //   editActivityBloc.add(ChangeInfoItemType(NoteInfoItem));
  //   editActivityBloc.add(SaveActivity());

  //   // Assert
  //   await expectLater(
  //     editActivityBloc.stream,
  //     emits(
  //       StoredActivityState(
  //         activityWithEmptyNote,
  //         timeInterval,
  //         aDay,
  //       ).copyWith(activityWithEmptyNote,
  //           infoItems: {Checklist: activity.infoItem}),
  //     ),
  //   );

  //   await untilCalled(mockActivitiesBloc.add(any));
  //   expect(verify(mockActivitiesBloc.add(captureAny)).captured.single,
  //       UpdateActivity(expectedActivity));
  // });

  test('Trying to save recurrance withtout data yeilds error', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
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
      endTime: time,
      startDate: aDay,
    );
    editActivityBloc.add(ChangeTimeInterval(startTime: time));
    editActivityBloc.add(ReplaceActivity(activity));
    editActivityBloc.add(SaveActivity());

    // Assert
    await expectLater(
        editActivityBloc.stream,
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

  group('warnings', () {
    group('before now', () {
      test('Trying to save before now yields warning', () async {
        // Arrange
        final editActivityBloc = EditActivityBloc.newActivity(
          activitiesBloc: FakeActivitiesBloc(),
          memoplannerSettingBloc: mockMemoplannerSettingsBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.add(1.hours())),
          day: aDay,
        );

        // Act

        final originalActivity = editActivityBloc.state.activity;
        final activity = originalActivity.copyWith(title: 'null');
        final time = TimeOfDay.fromDateTime(aTime);
        final timeIntervall = TimeInterval(
          startTime: time,
          endTime: time,
          startDate: aDay,
        );
        final expectedActivity = activity.copyWith(startTime: aTime);
        editActivityBloc.add(ChangeTimeInterval(startTime: time));
        editActivityBloc.add(ReplaceActivity(activity));
        editActivityBloc.add(SaveActivity());
        editActivityBloc.add(SaveActivity(warningConfirmed: true));

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emitsInOrder([
              UnstoredActivityState(
                originalActivity,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity,
                timeIntervall,
              ).failSave({SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW}),
              StoredActivityState(
                expectedActivity,
                timeIntervall,
                aDay,
              ).saveSucess()
            ]));
      });

      test('Trying to save full day before now yields warning', () async {
        // Arrange
        final time = aTime.add(1.days());
        final editActivityBloc = EditActivityBloc.newActivity(
          activitiesBloc: FakeActivitiesBloc(),
          memoplannerSettingBloc: mockMemoplannerSettingsBloc,
          clockBloc:
              ClockBloc(StreamController<DateTime>().stream, initialTime: time),
          day: aDay,
        );

        // Act

        final originalActivity = editActivityBloc.state.activity;
        final activity =
            originalActivity.copyWith(title: 'null', fullDay: true);

        final saveTime = aDay.previousDay();
        final timeIntervall = TimeInterval(
          startDate: saveTime,
        );

        final expectedActivity =
            activity.copyWith(startTime: saveTime, alarmType: NO_ALARM);
        editActivityBloc.add(ChangeDate(saveTime));
        editActivityBloc.add(ReplaceActivity(activity));
        editActivityBloc.add(SaveActivity());
        editActivityBloc.add(SaveActivity(warningConfirmed: true));

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emitsInOrder([
              UnstoredActivityState(
                originalActivity,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity,
                timeIntervall,
              ).failSave({SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW}),
              StoredActivityState(
                expectedActivity,
                timeIntervall,
                saveTime,
              ).saveSucess()
            ]));
      });

      test('Trying to save new recurring before now yields warning', () async {
        // Arrange
        final editActivityBloc = EditActivityBloc.newActivity(
          activitiesBloc: FakeActivitiesBloc(),
          memoplannerSettingBloc: mockMemoplannerSettingsBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.add(1.hours())),
          day: aDay,
        );

        // Act
        final originalActivity = editActivityBloc.state.activity;
        final activity1 = originalActivity.copyWith(title: 'null');
        final activity2 = activity1.copyWith(recurs: Recurs.everyDay);
        final time = TimeOfDay.fromDateTime(aTime);
        final timeIntervall = TimeInterval(
          startTime: time,
          endTime: time,
          startDate: aDay,
        );

        final expectedActivity = activity2.copyWith(startTime: aTime);

        editActivityBloc.add(ChangeTimeInterval(startTime: time));
        editActivityBloc.add(ReplaceActivity(activity1));
        editActivityBloc.add(ReplaceActivity(activity2));
        editActivityBloc.add(SaveActivity());
        editActivityBloc.add(SaveActivity(warningConfirmed: true));

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emitsInOrder([
              UnstoredActivityState(
                originalActivity,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity1,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity2,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity2,
                timeIntervall,
              ).failSave({SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW}),
              StoredActivityState(
                expectedActivity,
                timeIntervall,
                aDay,
              ).saveSucess()
            ]));
      });

      test('Trying to edit recurring THIS DAY ONLY before now yields warning',
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
          activitiesBloc: FakeActivitiesBloc(),
          memoplannerSettingBloc: mockMemoplannerSettingsBloc,
          clockBloc:
              ClockBloc(Stream.empty(), initialTime: aTime.add(1.hours())),
        );

        final expectedTimeIntervall = TimeInterval(
          startTime: TimeOfDay.fromDateTime(aTime),
          startDate: aDay,
        );

        final activityWithNewTitle = activity.copyWith(title: 'new title');

        final expetedActivityToSave =
            activityWithNewTitle.copyWith(startTime: activity.startClock(aDay));

        // Act
        editActivityBloc.add(ReplaceActivity(activityWithNewTitle));
        editActivityBloc.add(SaveActivity());
        editActivityBloc.add(SaveRecurringActivity(ApplyTo.onlyThisDay, aDay));

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emitsInOrder([
              StoredActivityState(
                activityWithNewTitle,
                expectedTimeIntervall,
                aDay,
              ),
              StoredActivityState(
                activityWithNewTitle,
                expectedTimeIntervall,
                aDay,
              ).failSave({
                SaveError.STORED_RECURRING,
                SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW,
              }),
              StoredActivityState(
                expetedActivityToSave,
                expectedTimeIntervall,
                aDay,
              ).saveSucess()
            ]));
      });
    });
    group('conflict', () {
      // base case, just a conflict
      test('Trying to save with conflict yields warning', () async {
        // Arrange

        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(mockActivitiesBloc.state).thenReturn(ActivitiesLoaded([stored]));
        final editActivityBloc = EditActivityBloc.newActivity(
          activitiesBloc: mockActivitiesBloc,
          memoplannerSettingBloc: mockMemoplannerSettingsBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.subtract(1.hours())),
          day: aDay,
        );

        // Act

        final originalActivity = editActivityBloc.state.activity;
        final activity = originalActivity.copyWith(title: 'null');
        final time = TimeOfDay.fromDateTime(aTime);
        final timeIntervall = TimeInterval(
          startTime: time,
          endTime: time,
          startDate: aDay,
        );
        final expectedActivity = activity.copyWith(startTime: aTime);
        editActivityBloc.add(ChangeTimeInterval(startTime: time));
        editActivityBloc.add(ReplaceActivity(activity));
        editActivityBloc.add(SaveActivity());
        editActivityBloc.add(SaveActivity(warningConfirmed: true));

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emitsInOrder([
              UnstoredActivityState(
                originalActivity,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity,
                timeIntervall,
              ).failSave({SaveError.UNCONFIRMED_ACTIVITY_CONFLICT}),
              StoredActivityState(
                expectedActivity,
                timeIntervall,
                aDay,
              ).saveSucess()
            ]));
      });

      test('Trying to save with conflict and before no yields warnings',
          () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(mockActivitiesBloc.state).thenReturn(ActivitiesLoaded([stored]));
        final editActivityBloc = EditActivityBloc.newActivity(
          activitiesBloc: mockActivitiesBloc,
          memoplannerSettingBloc: mockMemoplannerSettingsBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.add(1.hours())),
          day: aDay,
        );

        // Act

        final originalActivity = editActivityBloc.state.activity;
        final activity = originalActivity.copyWith(title: 'null');
        final time = TimeOfDay.fromDateTime(aTime);
        final timeIntervall = TimeInterval(
          startTime: time,
          endTime: time,
          startDate: aDay,
        );
        final expectedActivity = activity.copyWith(startTime: aTime);
        editActivityBloc.add(ChangeTimeInterval(startTime: time));
        editActivityBloc.add(ReplaceActivity(activity));
        editActivityBloc.add(SaveActivity());
        editActivityBloc.add(SaveActivity(warningConfirmed: true));

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emitsInOrder([
              UnstoredActivityState(originalActivity, timeIntervall),
              UnstoredActivityState(
                activity,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity,
                timeIntervall,
              ).failSave({
                SaveError.UNCONFIRMED_ACTIVITY_CONFLICT,
                SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW,
              }),
              StoredActivityState(
                expectedActivity,
                timeIntervall,
                aDay,
              ).saveSucess()
            ]));
      });

      test('No self conflicts', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(mockActivitiesBloc.state).thenReturn(ActivitiesLoaded([stored]));
        final editActivityBloc = EditActivityBloc(
          ActivityDay(stored, aDay),
          activitiesBloc: mockActivitiesBloc,
          memoplannerSettingBloc: mockMemoplannerSettingsBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.subtract(1.hours())),
        );

        // Act
        final titleChanged = stored.copyWith(title: 'null');
        final time = TimeOfDay.fromDateTime(aTime);
        final timeIntervall = TimeInterval(
          startTime: time,
          startDate: aDay,
        );
        final expectedActivity = titleChanged.copyWith(startTime: aTime);
        editActivityBloc.add(ReplaceActivity(titleChanged));
        editActivityBloc.add(SaveActivity());

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emitsInOrder([
              StoredActivityState(
                titleChanged,
                timeIntervall,
                aDay,
              ),
              StoredActivityState(
                expectedActivity,
                timeIntervall,
                aDay,
              ).saveSucess()
            ]));
      });

      test('no conflict for fullday', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(mockActivitiesBloc.state).thenReturn(ActivitiesLoaded([stored]));
        final editActivityBloc = EditActivityBloc.newActivity(
          activitiesBloc: mockActivitiesBloc,
          memoplannerSettingBloc: mockMemoplannerSettingsBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime),
          day: aDay,
        );

        // Act
        final originalActivity = editActivityBloc.state.activity;
        final activity = originalActivity.copyWith(
          title: 'null',
          fullDay: true,
          alarmType: NO_ALARM,
        );
        final timeIntervall = TimeInterval(
          startDate: aDay,
        );
        final expectedActivity = activity.copyWith(startTime: aDay);
        editActivityBloc.add(ReplaceActivity(activity));
        editActivityBloc.add(SaveActivity());

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emitsInOrder([
              UnstoredActivityState(
                activity,
                timeIntervall,
              ),
              StoredActivityState(
                expectedActivity,
                timeIntervall,
                aDay,
              ).saveSucess()
            ]));
      });

      test('no conflict for recuring', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(mockActivitiesBloc.state).thenReturn(ActivitiesLoaded([stored]));
        final editActivityBloc = EditActivityBloc.newActivity(
          activitiesBloc: mockActivitiesBloc,
          memoplannerSettingBloc: mockMemoplannerSettingsBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.subtract(1.hours())),
          day: aDay,
        );

        // Act
        final originalActivity = editActivityBloc.state.activity;
        final activity = originalActivity.copyWith(
          title: 'null',
          recurs: Recurs.everyDay,
        );
        final time = TimeOfDay.fromDateTime(aTime);
        final timeIntervall = TimeInterval(
          startTime: time,
          endTime: time,
          startDate: aDay,
        );
        final expectedActivity = activity.copyWith(startTime: aTime);
        editActivityBloc.add(ChangeTimeInterval(startTime: time));
        editActivityBloc.add(ReplaceActivity(activity));
        editActivityBloc.add(SaveActivity());

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emitsInOrder([
              UnstoredActivityState(
                originalActivity,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity,
                timeIntervall,
              ),
              StoredActivityState(
                expectedActivity,
                timeIntervall,
                aDay,
              ).saveSucess()
            ]));
      });

      test('No conflicts when edit but not time', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final stored2 = Activity.createNew(title: 'stored2', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(mockActivitiesBloc.state)
            .thenReturn(ActivitiesLoaded([stored, stored2]));

        final editActivityBloc = EditActivityBloc(
          ActivityDay(stored, aDay),
          activitiesBloc: mockActivitiesBloc,
          memoplannerSettingBloc: mockMemoplannerSettingsBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.subtract(1.hours())),
        );

        // Act
        final titleChanged = stored.copyWith(title: 'null');
        final time = TimeOfDay.fromDateTime(aTime);
        final timeIntervall = TimeInterval(
          startTime: time,
          startDate: aDay,
        );
        final expectedActivity = titleChanged.copyWith(startTime: aTime);
        editActivityBloc.add(ReplaceActivity(titleChanged));
        editActivityBloc.add(SaveActivity());

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emitsInOrder([
              StoredActivityState(
                titleChanged,
                timeIntervall,
                aDay,
              ),
              StoredActivityState(
                expectedActivity,
                timeIntervall,
                aDay,
              ).saveSucess()
            ]));
      });
    });
  });

  test('BUG SGC-352 edit a none recurring activity to be recurring', () async {
    // Arrange
    final activity = Activity.createNew(title: 'SGC-352', startTime: aTime);
    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: FakeActivitiesBloc(),
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
      editActivityBloc.stream,
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
    final mockActivitiesBloc = MockActivitiesBloc();
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
        editActivityBloc.stream,
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

  test('Changing date on recurring yearly should update recurring data',
      () async {
    // Arrange
    final activity = Activity.createNew(
      title: 'title',
      startTime: aTime,
    );
    final mockActivitiesBloc = MockActivitiesBloc();
    final editActivityBloc = EditActivityBloc(
      ActivityDay(activity, aDay),
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
    );

    final nextDay = aTime.add(1.days());
    final expectedActivity = activity.copyWith(
      startTime: nextDay,
      recurs: Recurs.yearly(nextDay),
    );

    // Act
    editActivityBloc.add(ReplaceActivity(
        activity.copyWith(recurs: Recurs.yearly(activity.startTime))));
    editActivityBloc.add(ChangeDate(nextDay));
    editActivityBloc.add(SaveRecurringActivity(ApplyTo.onlyThisDay, aDay));

    await untilCalled(mockActivitiesBloc.add(any));
    expect(
      verify(mockActivitiesBloc.add(captureAny)).captured.single,
      UpdateRecurringActivity(
        ActivityDay(expectedActivity, aDay),
        ApplyTo.onlyThisDay,
      ),
    );
  });

  test('Changing start date to after recuring end changes recuring end',
      () async {
    // Arrange

    final editActivityBloc = EditActivityBloc.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
      memoplannerSettingBloc: mockMemoplannerSettingsBloc,
      clockBloc: clockBloc,
      day: aDay,
    );

    final in30Days = aTime.add(30.days());
    final in60Days = aTime.add(60.days());
    final activity = editActivityBloc.state.activity;
    final timeInterval = editActivityBloc.state.timeInterval;
    final recurringActivity = activity.copyWith(
      recurs: Recurs.weeklyOnDay(2, ends: in30Days),
    );

    final expectedActivity =
        activity.copyWith(recurs: Recurs.weeklyOnDay(2, ends: in60Days));
    final expectedInterval = timeInterval.copyWith(startDate: in60Days);

    editActivityBloc.add(ReplaceActivity(recurringActivity));
    editActivityBloc.add(ChangeDate(in60Days));

    await expectLater(
      editActivityBloc.stream,
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
  });
}
