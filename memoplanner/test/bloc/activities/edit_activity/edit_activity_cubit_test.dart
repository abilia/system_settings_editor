import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../fakes/all.dart';

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
      defaultsSettings: DefaultsAddActivitySettings(
          alarm: Alarm.fromInt(alarmSoundAndVibration)),
      calendarId: calendarId,
    );
    // Act // Assert
    expect(editActivityCubit.state.activity, MatchActivityWithoutId(activity));
  });

  test('Replace activity in bloc changes activity in state', () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.newActivity(
      day: aTime,
      defaultsSettings:
          DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
      calendarId: calendarId,
    );
    final activity = editActivityCubit.state.activity;
    final activityWithTitle = activity.copyWith(title: 'new title');
    final timeInterval = TimeInterval(startDate: aTime);

    final expect = expectLater(
      editActivityCubit.stream,
      emits(UnstoredActivityState(
        activityWithTitle,
        timeInterval,
        RecurrentType.none,
      )),
    );

    // Act
    editActivityCubit.replaceActivity(activityWithTitle);

    // Assert
    await expect;
  });

  test('Changing date changes date but not time in time interval', () async {
    // Arrange
    final aDate = DateTime(2022, 02, 22, 22, 00);

    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDate,
      defaultsSettings:
          DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
      calendarId: calendarId,
    );
    final activity = editActivityCubit.state.activity;
    final newDate = DateTime(2011, 11, 11, 11, 11);
    final expectedNewDate = DateTime(2011, 11, 11, 11, 11);
    final expectedTimeInterval = TimeInterval(startDate: expectedNewDate);

    final expect = expectLater(
      editActivityCubit.stream,
      emits(UnstoredActivityState(
        activity,
        expectedTimeInterval,
        RecurrentType.none,
      )),
    );

    // Act
    editActivityCubit.changeStartDate(newDate);

    // Assert
    await expect;
  });

  test('activity.startTime set correctly', () async {
    // Arrange
    final aDate = DateTime(2022, 02, 22, 22, 00);

    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDate,
      defaultsSettings:
          DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
      calendarId: calendarId,
    );

    final activity = editActivityCubit.state.activity;

    final newDate = DateTime(2011, 11, 11, 11, 11);
    const newTime = TimeOfDay(hour: 1, minute: 1);
    final newActivity = activity.copyWith(title: 'newTile');
    final expectedTimeInterval1 = TimeInterval(
      startTime: newTime,
      endTime: null,
      startDate: aDate,
    );
    final expectedTimeInterval2 = TimeInterval(
      startTime: newTime,
      endTime: null,
      startDate: newDate,
    );

    final expected = expectLater(
      editActivityCubit.stream,
      emitsInOrder(
        [
          UnstoredActivityState(
            activity,
            expectedTimeInterval1,
            RecurrentType.none,
          ),
          UnstoredActivityState(
            activity,
            expectedTimeInterval2,
            RecurrentType.none,
          ),
          UnstoredActivityState(
            newActivity,
            expectedTimeInterval2,
            RecurrentType.none,
          ),
        ],
      ),
    );
    // Act
    editActivityCubit
      ..changeTimeInterval(startTime: const TimeOfDay(hour: 1, minute: 1))
      ..changeStartDate(newDate)
      ..replaceActivity(newActivity);

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
        StoredActivityState(
          with15MinReminder,
          timeInterval,
          aDay,
          RecurrentType.none,
        ),
        StoredActivityState(
          with15MinAnd1HourReminder,
          timeInterval,
          aDay,
          RecurrentType.none,
        ),
        StoredActivityState(
          with15MinReminder,
          timeInterval,
          aDay,
          RecurrentType.none,
        ),
        StoredActivityState(
          activity,
          timeInterval,
          aDay,
          RecurrentType.none,
        ),
      ]),
    );

    // Act
    editActivityCubit
      ..addOrRemoveReminder(min15Reminder)
      ..addOrRemoveReminder(hour1Reminder)
      ..addOrRemoveReminder(hour1Reminder)
      ..addOrRemoveReminder(min15Reminder);

    // Assert
    await expected;
  });

  test('Setting start time after end time', () async {
    // Arrange
    final aDay = DateTime(2001, 01, 01);

    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDay,
      defaultsSettings:
          DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
      calendarId: calendarId,
    );

    final wizCubit = ActivityWizardCubit.newActivity(
      supportPersonsCubit: FakeSupportPersonsCubit(),
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: editActivityCubit,
      clockBloc: ClockBloc.fixed(nowTime),
      addActivitySettings: const AddActivitySettings(
        editActivity: EditActivitySettings(template: false),
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
            RecurrentType.none,
          ),
          UnstoredActivityState(
            activity,
            expectedTimeInterval,
            RecurrentType.none,
          ),
          UnstoredActivityState(
            activityWithTitle,
            expectedTimeInterval,
            RecurrentType.none,
          ),
        ],
      ),
    );

    // Act
    editActivityCubit
      ..changeTimeInterval(endTime: const TimeOfDay(hour: 10, minute: 0))
      ..changeTimeInterval(
          startTime: const TimeOfDay(hour: 12, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0))
      ..replaceActivity(activityWithTitle);

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
          RecurrentType.none,
        ),
      ),
    );
    // Act
    await wizCubit.next();
    // Assert
    expect(
      wizCubit.state,
      WizardState(0, const [WizardStep.advance], successfulSave: true),
    );
    // Assert
    await expect2;
  });

  test('Changing start date to after recurring end changes recurring end',
      () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDay,
      defaultsSettings:
          DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
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
            RecurrentType.none,
          ),
          UnstoredActivityState(
            recurringActivity,
            timeInterval.copyWithEndDate(recurringActivity.recurs.end),
            RecurrentType.none,
          ),
          UnstoredActivityState(
            expectedActivity,
            expectedInterval.copyWithEndDate(expectedActivity.recurs.end),
            RecurrentType.none,
          ),
        ],
      ),
    );

    editActivityCubit
      ..replaceActivity(recurringActivity)
      ..changeRecurrentEndDate(recurringActivity.recurs.end)
      ..changeStartDate(in60Days);

    await expect;
  });

  test(
      'Setting new recurrence without end date sets the end time to unspecified end',
      () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDay,
      defaultsSettings:
          DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
      calendarId: calendarId,
    );

    final activity = editActivityCubit.state.activity;

    final timeInterval = editActivityCubit.state.timeInterval;

    final expectedActivity = activity.copyWith(
      recurs: Recurs.weeklyOnDay(
        aDay.weekday,
      ),
    );

    final expect = expectLater(
      editActivityCubit.stream,
      emits(
        UnstoredActivityState(
          expectedActivity,
          timeInterval,
          RecurrentType.weekly,
        ),
      ),
    );

    editActivityCubit.changeRecurrentType(RecurrentType.weekly);

    await expect;
  });

  test('Setting new recurrence with end date sets the end time to end date',
      () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDay,
      defaultsSettings:
          DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
      calendarId: calendarId,
    );

    final endDate = aDay.addDays(30);

    final activity = editActivityCubit.state.activity;

    final expectedTimeInterval1 = editActivityCubit.state.timeInterval;
    final expectedTimeInterval2 =
        expectedTimeInterval1.copyWithEndDate(endDate);
    final monthly = Recurs.monthly(aDay.day);
    final expectedActivity1 = activity.copyWith(recurs: monthly);
    final expectedActivity2 = activity.copyWith(
      recurs: monthly.changeEnd(endDate),
    );

    final expect = expectLater(
      editActivityCubit.stream,
      emitsInOrder([
        UnstoredActivityState(
          expectedActivity1,
          expectedTimeInterval1,
          RecurrentType.monthly,
        ),
        UnstoredActivityState(
          expectedActivity2,
          expectedTimeInterval2,
          RecurrentType.monthly,
        ),
      ]),
    );

    editActivityCubit
      ..changeRecurrentType(RecurrentType.monthly)
      ..changeRecurrentEndDate(endDate);
    await expect;
  });

  test('Load recurrence by switching back to original recurrence type',
      () async {
    // Arrange
    final recurs = Recurs.monthlyOnDays(
      {aDay.day, aDay.addDays(1).day, aDay.addDays(2).day},
    );

    final originalActivity =
        Activity.createNew(title: 'a title', startTime: aDay, recurs: recurs);

    final editActivityCubit =
        EditActivityCubit.edit(ActivityDay(originalActivity, aDay));

    final timeInterval = editActivityCubit.state.timeInterval;
    final weekly = Recurs.weeklyOnDay(aDay.addDays(10).weekday);
    final expectedActivity1 = originalActivity.copyWith(
      recurs: Recurs.weeklyOnDay(aDay.weekday),
    );
    final expectedActivity2 = originalActivity.copyWith(
      recurs: weekly,
    );

    final expect = expectLater(
      editActivityCubit.stream,
      emitsInOrder(
        [
          StoredActivityState(
            expectedActivity1,
            timeInterval,
            aDay,
            RecurrentType.weekly,
          ),
          StoredActivityState(
            expectedActivity2,
            timeInterval,
            aDay,
            RecurrentType.weekly,
          ),
          StoredActivityState(
            originalActivity,
            timeInterval,
            aDay,
            RecurrentType.monthly,
          )
        ],
      ),
    );

    editActivityCubit
      ..changeRecurrentType(RecurrentType.weekly)
      ..changeWeeklyRecurring(weekly)
      ..changeRecurrentType(RecurrentType.monthly);

    await expect;
  });
}
