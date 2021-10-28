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

  setUp(() {
    tz.initializeTimeZones();
  });

  test('Initial state is the given activity', () {
    // Arrange
    final activity = Activity.createNew(title: '', startTime: aTime);
    final editActivityBloc = EditActivityBloc.edit(
      ActivityDay(activity, aDay),
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
      day: aTime,
      defaultAlarmTypeSetting: alarmSoundAndVibration,
    );
    // Act // Assert
    expect(editActivityBloc.state.activity, MatchActivityWithoutId(activity));
  });

  test('Initial state with basic activity starting at 00:00 has no start time',
      () async {
    // Arrange
    final basicActivity = BasicActivityDataItem.createNew(
      title: 'basic title',
      startTime: Duration.zero,
    );
    // Act
    final editActivityBloc = EditActivityBloc.newActivity(
      day: aDay,
      defaultAlarmTypeSetting: alarmSilent,
    );

    editActivityBloc.add(AddBasiActivity(basicActivity));
    // Assert
    await expectLater(
      editActivityBloc.stream,
      emits(isA<UnstoredActivityState>()),
    );
    expect(
      editActivityBloc.state.activity,
      MatchActivityWithoutId(
        basicActivity.toActivity(
          timezone: 'UTC',
          day: aDay,
        ),
      ),
    );

    expect(editActivityBloc.state.timeInterval.startTime, isNull);
    expect(editActivityBloc.state.timeInterval, TimeInterval(startDate: aDay));
  });

  test('Initial state with basic activity starting at 00:01 has start time',
      () async {
    // Arrange
    final basicActivity = BasicActivityDataItem.createNew(
      title: 'basic title',
      startTime: const Duration(minutes: 1),
    );
    // Act
    final editActivityBloc = EditActivityBloc.newActivity(
      day: aDay,
      defaultAlarmTypeSetting: noAlarm,
    );

    editActivityBloc.add(AddBasiActivity(basicActivity));
    // Assert
    await expectLater(
      editActivityBloc.stream,
      emits(isA<UnstoredActivityState>()),
    );
    expect(
      editActivityBloc.state.activity,
      MatchActivityWithoutId(
        basicActivity.toActivity(
          timezone: 'UTC',
          day: aDay,
        ),
      ),
    );
    final expected = TimeInterval(
      startDate: aDay,
      startTime: const TimeOfDay(hour: 0, minute: 1),
    );
    final actual = editActivityBloc.state.timeInterval;
    expect(actual, expected);
  });

  test(
      'Initial state with basic activity starting at 00:00, '
      'end time 00:01 has start time and time', () async {
    // Arrange
    final basicActivity = BasicActivityDataItem.createNew(
      title: 'basic title',
      startTime: Duration.zero,
      duration: const Duration(minutes: 1),
    );
    // Act
    final editActivityBloc = EditActivityBloc.newActivity(
      day: aDay,
      defaultAlarmTypeSetting: noAlarm,
    );

    editActivityBloc.add(AddBasiActivity(basicActivity));
    // Assert
    await expectLater(
      editActivityBloc.stream,
      emits(isA<UnstoredActivityState>()),
    );
    expect(
      editActivityBloc.state.activity,
      MatchActivityWithoutId(
        basicActivity.toActivity(
          timezone: 'UTC',
          day: aDay,
        ),
      ),
    );
    final expected = TimeInterval(
      startDate: aDay,
      startTime: const TimeOfDay(hour: 0, minute: 0),
      endTime: const TimeOfDay(hour: 0, minute: 1),
    );
    final actual = editActivityBloc.state.timeInterval;
    expect(actual, expected);
  });

  test(
      'Initial state with basic activity starting at 00:00 but with duration has start time',
      () async {
    // Arrange
    final basicActivity = BasicActivityDataItem.createNew(
      title: 'basic title',
      startTime: Duration.zero,
      duration: const Duration(minutes: 30),
    );
    // Act
    final editActivityBloc = EditActivityBloc.newActivity(
      defaultAlarmTypeSetting: noAlarm,
      day: aDay,
    );
    editActivityBloc.add(AddBasiActivity(basicActivity));
    // Assert
    await expectLater(
      editActivityBloc.stream,
      emits(isA<UnstoredActivityState>()),
    );
    expect(
      editActivityBloc.state.activity,
      MatchActivityWithoutId(
        basicActivity.toActivity(
          timezone: 'UTC',
          day: aDay,
        ),
      ),
    );
    final expected = TimeInterval(
      startDate: aDay,
      startTime: const TimeOfDay(hour: 0, minute: 0),
      endTime: const TimeOfDay(hour: 0, minute: 30),
    );
    final actual = editActivityBloc.state.timeInterval;
    expect(actual, expected);
  });

  test('Replace activity in bloc changes activity in state', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      day: aTime,
      defaultAlarmTypeSetting: noAlarm,
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

  test('Changing date changes date but not time in timeinterval', () async {
    // Arrange
    final aDate = DateTime(2022, 02, 22, 22, 00);

    final editActivityBloc = EditActivityBloc.newActivity(
      day: aDate,
      defaultAlarmTypeSetting: noAlarm,
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
      day: aDate,
      defaultAlarmTypeSetting: noAlarm,
    );

    final activity = editActivityBloc.state.activity;

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

    // Act
    editActivityBloc.add(
        const ChangeTimeInterval(startTime: TimeOfDay(hour: 1, minute: 1)));
    editActivityBloc.add(ChangeDate(newDate));
    editActivityBloc.add(ReplaceActivity(newActivity));

    // Assert
    await expectLater(
      editActivityBloc.stream,
      emitsInOrder(
        [
          UnstoredActivityState(activity, expectedTimeInterval1),
          UnstoredActivityState(activity, expectedTimeInterval2),
          UnstoredActivityState(newActivity, expectedTimeInterval2),
        ],
      ),
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

    final editActivityBloc = EditActivityBloc.edit(
      ActivityDay(activity, aDay),
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

  test('Setting start time after end time', () async {
    // Arrange
    final aDay = DateTime(2001, 01, 01);

    final editActivityBloc = EditActivityBloc.newActivity(
      day: aDay,
      defaultAlarmTypeSetting: noAlarm,
    );

    final wizCubit = ActivityWizardCubit.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityBloc: editActivityBloc,
      clockBloc: ClockBloc(const Stream.empty(), initialTime: nowTime),
      settings: const MemoplannerSettingsLoaded(
          MemoplannerSettings(advancedActivityTemplate: false)),
    );
    final activity = editActivityBloc.state.activity;
    final activityWithTitle = activity.copyWith(title: 'title');

    final expectedActivity = activityWithTitle.copyWith(
        startTime: aDay.copyWith(hour: 12, minute: 0), duration: 22.hours());
    final expectedTimeInterval = TimeInterval(
      startTime: const TimeOfDay(hour: 12, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      startDate: aDay,
    );

    // Act
    editActivityBloc
        .add(const ChangeTimeInterval(endTime: TimeOfDay(hour: 10, minute: 0)));
    editActivityBloc.add(const ChangeTimeInterval(
        startTime: TimeOfDay(hour: 12, minute: 0),
        endTime: TimeOfDay(hour: 10, minute: 0)));
    editActivityBloc.add(ReplaceActivity(activityWithTitle));

    // Assert
    await expectLater(
      editActivityBloc.stream,
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

    wizCubit.next();
    expect(
      wizCubit.state,
      ActivityWizardState(0, const [WizardStep.advance], sucessfullSave: true),
    );
    // Assert
    await expectLater(
      editActivityBloc.stream,
      emits(
        StoredActivityState(
          expectedActivity,
          expectedTimeInterval,
          aDay,
        ),
      ),
    );
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
    final editActivityBloc = EditActivityBloc.edit(
      activityDay,
    );

    // Act
    editActivityBloc.add(const ChangeInfoItemType(Checklist));
    editActivityBloc.add(const ChangeInfoItemType(NoteInfoItem));
    editActivityBloc.add(const ChangeInfoItemType(NoInfoItem));

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

  test('Changing start date to after recuring end changes recuring end',
      () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      day: aDay,
      defaultAlarmTypeSetting: noAlarm,
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
