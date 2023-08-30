import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  late MockActivitiesCubit mockActivitiesCubit;
  late MockActivityRepository mockActivityRepository;
  late ClockCubit clockCubit;
  final nowTime = DateTime(2000, 02, 22, 22, 30);
  final aTime = DateTime(2022, 02, 22, 22, 30);
  final aDay = DateTime(2022, 02, 22);
  const calendarId = 'Some calendar id';

  setUpAll(() {
    registerFallbackValues();
    tz.initializeTimeZones();
  });

  setUp(() {
    mockActivitiesCubit = MockActivitiesCubit();
    when(() => mockActivitiesCubit.state)
        .thenAnswer((_) => ActivitiesChanged());
    mockActivityRepository = MockActivityRepository();
    when(() => mockActivityRepository.allBetween(any(), any()))
        .thenAnswer((_) => Future.value([]));
    when(() => mockActivitiesCubit.activityRepository)
        .thenReturn(mockActivityRepository);
    when(() => mockActivitiesCubit.addActivity(any()))
        .thenAnswer((_) => Future.value());
    when(() => mockActivitiesCubit.updateRecurringActivity(any(), any()))
        .thenAnswer((_) => Future.value());

    clockCubit = ClockCubit.fixed(nowTime);
  });

  test('Initial edit state is', () {
    // Arrange
    final activityWizardCubit = ActivityWizardCubit.edit(
      activitiesCubit: FakeActivitiesCubit(),
      editActivityCubit: FakeEditActivityCubit(),
      clockCubit: clockCubit,
      allowPassedStartTime: false,
    );

    expect(activityWizardCubit.state,
        WizardState(0, UnmodifiableListView([WizardStep.advance])));
  });

  test('Initial new with default settings', () {
    // Arrange
    final activityWizardCubit = ActivityWizardCubit.newActivity(
      activitiesCubit: FakeActivitiesCubit(),
      editActivityCubit: FakeEditActivityCubit(),
      clockCubit: clockCubit,
      addActivitySettings: const AddActivitySettings(),
      supportPersonsCubit: FakeSupportPersonsCubit(),
    );

    expect(
      activityWizardCubit.state,
      WizardState(
        0,
        UnmodifiableListView(
          [
            WizardStep.advance,
          ],
        ),
      ),
    );
  });

  test('Initial new with wizard steps', () {
    // Arrange
    final activityWizardCubit = ActivityWizardCubit.newActivity(
      supportPersonsCubit: FakeSupportPersonsCubit.withSupportPerson(),
      activitiesCubit: FakeActivitiesCubit(),
      editActivityCubit: EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: calendarId,
      ),
      clockCubit: clockCubit,
      addActivitySettings:
          const AddActivitySettings(mode: AddActivityMode.stepByStep),
    );

    expect(
      activityWizardCubit.state,
      WizardState(
        0,
        UnmodifiableListView(
          [
            WizardStep.title,
            WizardStep.image,
            WizardStep.date,
            WizardStep.fullDay,
            WizardStep.time,
            WizardStep.category,
            WizardStep.checkable,
            WizardStep.deleteAfter,
            WizardStep.availableFor,
            WizardStep.alarm,
            WizardStep.reminder,
            WizardStep.recurring,
            WizardStep.connectedFunction
          ],
        ),
      ),
    );
  });

  test('Initial edit', () {
    // Arrange
    final activityWizardCubit = ActivityWizardCubit.edit(
      activitiesCubit: FakeActivitiesCubit(),
      editActivityCubit: FakeEditActivityCubit(),
      clockCubit: clockCubit,
      allowPassedStartTime: false,
    );

    expect(
      activityWizardCubit.state,
      WizardState(
        0,
        UnmodifiableListView(
          [
            WizardStep.advance,
          ],
        ),
      ),
    );
  });

  test('Initial state with no title and no image is not savable', () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDay,
      defaultsSettings:
          DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
      calendarId: calendarId,
    );

    final activityWizardCubit = ActivityWizardCubit.edit(
      activitiesCubit: FakeActivitiesCubit(),
      editActivityCubit: editActivityCubit,
      clockCubit: clockCubit,
      allowPassedStartTime: false,
    );

    // Act
    await activityWizardCubit.next();

    // Assert
    expect(
      activityWizardCubit.state,
      WizardState(
          0,
          UnmodifiableListView([
            WizardStep.advance,
          ])).failSave({
        SaveError.noTitleOrImage,
        SaveError.noStartTime,
      }),
    );
  });

  test(
      'Trying to save uncompleted activity yields failed save and does not try to save',
      () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.newActivity(
      day: aTime,
      defaultsSettings:
          DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
      calendarId: calendarId,
    );
    final activityWizardCubit = ActivityWizardCubit.newActivity(
      supportPersonsCubit: FakeSupportPersonsCubit(),
      activitiesCubit: mockActivitiesCubit,
      editActivityCubit: editActivityCubit,
      clockCubit: clockCubit,
      addActivitySettings: const AddActivitySettings(
        editActivity: EditActivitySettings(template: false),
      ),
    );

    final activity = editActivityCubit.state.activity;
    final activityWithTitle = activity.copyWith(title: 'new title');
    final timeInterval = TimeInterval(startDate: aTime);
    const newStartTime = TimeOfDay(hour: 10, minute: 0);
    final newTime = aTime.copyWith(
      hour: newStartTime.hour,
      minute: newStartTime.minute,
    );
    final newTimeInterval = TimeInterval(
      startTime: newStartTime,
      endTime: null,
      startDate: aTime,
    );

    final expectedSaved = activityWithTitle.copyWith(startTime: newTime);

    // Act
    await activityWizardCubit.next();
    expect(
      activityWizardCubit.state,
      WizardState(
        0,
        const [WizardStep.advance],
        saveErrors: const {
          SaveError.noTitleOrImage,
          SaveError.noStartTime,
        },
        successfulSave: false,
      ),
    );

    final expect1 = expectLater(
      editActivityCubit.stream,
      emits(
        UnstoredActivityState(
          activityWithTitle,
          timeInterval,
          RecurrentType.none,
        ),
      ),
    );
    // Act
    editActivityCubit.replaceActivity(activityWithTitle);
    await expect1;

    // Act
    await activityWizardCubit.next();
    expect(
      activityWizardCubit.state,
      WizardState(
        0,
        const [WizardStep.advance],
        saveErrors: const {
          SaveError.noStartTime,
        },
      ),
    );

    final expect2 = expectLater(
      editActivityCubit.stream,
      emits(
        UnstoredActivityState(
          activityWithTitle,
          newTimeInterval,
          RecurrentType.none,
        ),
      ),
    );
    editActivityCubit.changeTimeInterval(startTime: newStartTime);
    await expect2;

    // Act
    await activityWizardCubit.next();
    expect(
      activityWizardCubit.state,
      WizardState(
        0,
        const [WizardStep.advance],
        successfulSave: true,
      ),
    );
    verify(() => mockActivitiesCubit.addActivity(expectedSaved));
  });

  test('Saving full day activity sets correct time and alarms', () async {
    // Arrange
    final activity = Activity.createNew(
      title: 'a title',
      startTime: aTime,
      duration: 5.hours(),
      reminderBefore: [10.minutes().inMilliseconds, 1.hours().inMilliseconds],
      alarmType: alarmSoundAndVibration,
    );

    final activityAsFullDay = activity.copyWith(
      fullDay: true,
    );

    final activityExpectedToBeSaved = activityAsFullDay.copyWith(
      alarmType: noAlarm,
      startTime: activity.startTime.onlyDays(),
      reminderBefore: [],
    );

    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(activity, aDay),
    );
    final activityWizardCubit = ActivityWizardCubit.edit(
      activitiesCubit: mockActivitiesCubit,
      editActivityCubit: editActivityCubit,
      clockCubit: clockCubit,
      allowPassedStartTime: false,
    );

    final timeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.noneRecurringEnd),
      startDate: aTime,
    );

    final wizState = WizardState(0, const [WizardStep.advance]);

    final expect1 = expectLater(
      editActivityCubit.stream,
      emits(StoredActivityState(
        activityAsFullDay,
        timeInterval,
        aDay,
        RecurrentType.none,
      )),
    );

    // Act
    editActivityCubit.replaceActivity(activityAsFullDay);
    // Assert
    await expect1;
    // Act
    await activityWizardCubit.next();

    // Assert
    expect(activityWizardCubit.state, wizState.saveSuccess());
    verify(() => mockActivitiesCubit.addActivity(activityExpectedToBeSaved));
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

    final wizCubit = ActivityWizardCubit.newActivity(
      supportPersonsCubit: FakeSupportPersonsCubit(),
      activitiesCubit: FakeActivitiesCubit(),
      editActivityCubit: editActivityCubit,
      clockCubit: clockCubit,
      addActivitySettings: const AddActivitySettings(
        editActivity: EditActivitySettings(template: false),
      ),
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

    final expected1 = expectLater(
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
      ..changeTimeInterval(
        startTime: const TimeOfDay(hour: 1, minute: 1),
      )
      ..changeStartDate(newDate)
      ..replaceActivity(newActivity);

    // Assert
    await expected1;
    // Arrange
    final expected2 = expectLater(
      editActivityCubit.stream,
      emits(
        StoredActivityState(
          expectedFinalActivity,
          expectedTimeInterval2,
          expectedFinalStartTime.onlyDays(),
          RecurrentType.none,
        ),
      ),
    );
    // Act
    await wizCubit.next();
    // Assert
    expect(
      wizCubit.state,
      WizardState(
        0,
        const [WizardStep.advance],
        successfulSave: true,
      ),
    );

    await expected2;
  });

  test(
    'Changing end time changes duration but not start or end time',
    () async {
      // Arrange
      final aDate = DateTime(2001, 01, 01, 01, 01);
      final aDay = DateTime(2001, 01, 01);

      final activity = Activity.createNew(
        title: 'test',
        startTime: aDate,
        duration: 30.minutes(),
      );
      const newEndTime = TimeOfDay(hour: 11, minute: 11);
      const expectedDuration = Duration(hours: 10, minutes: 10);
      final expectedTimeInterval = TimeInterval(
        startTime: TimeOfDay.fromDateTime(activity.startTime),
        endTime: TimeOfDay.fromDateTime(activity.noneRecurringEnd),
        startDate: aDate,
      );

      final expectedNewActivity = activity.copyWith(duration: expectedDuration);
      final expectedNewTimeInterval = TimeInterval(
        startTime: TimeOfDay.fromDateTime(activity.startTime),
        endTime:
            TimeOfDay.fromDateTime(activity.startTime.add(expectedDuration)),
        startDate: aDay,
      );

      final editActivityCubit = EditActivityCubit.edit(
        ActivityDay(activity, aDay),
      );

      final wizCubit = ActivityWizardCubit.edit(
        activitiesCubit: FakeActivitiesCubit(),
        editActivityCubit: editActivityCubit,
        clockCubit: clockCubit,
        allowPassedStartTime: true,
      );

      // Assert
      expect(
        editActivityCubit.state,
        StoredActivityState(
          activity,
          expectedTimeInterval,
          aDay,
          RecurrentType.none,
        ),
      );

      final expected1 = expectLater(
        editActivityCubit.stream,
        emits(
          StoredActivityState(
            activity,
            expectedNewTimeInterval,
            aDay,
            RecurrentType.none,
          ),
        ),
      );
      // Act
      editActivityCubit.changeTimeInterval(
          startTime: editActivityCubit.state.timeInterval.startTime,
          endTime: newEndTime);

      // Assert
      await expected1;

      final expected2 = expectLater(
        editActivityCubit.stream,
        emits(
          StoredActivityState(
            expectedNewActivity,
            expectedNewTimeInterval,
            aDay,
            RecurrentType.none,
          ),
        ),
      );
      await wizCubit.next();

      expect(
        wizCubit.state,
        WizardState(
          0,
          const [WizardStep.advance],
          successfulSave: true,
        ),
      );

      await expected2;
    },
  );

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
    const newEndTime = TimeOfDay(hour: 20, minute: 00);

    const expectedDuration = Duration(hours: 23, minutes: 30);
    final expectedTimeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.noneRecurringEnd),
      startDate: aDate,
    );

    final expectedNewActivity = activity.copyWith(duration: expectedDuration);
    final expectedNewTimeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.startTime.add(expectedDuration)),
      startDate: aDate,
    );

    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(activity, aDay),
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesCubit: FakeActivitiesCubit(),
      clockCubit: clockCubit,
      editActivityCubit: editActivityCubit,
      allowPassedStartTime: false,
    );

    // Assert
    expect(
        editActivityCubit.state,
        StoredActivityState(
          activity,
          expectedTimeInterval,
          aDay,
          RecurrentType.none,
        ));

    final expected1 = expectLater(
      editActivityCubit.stream,
      emits(
        StoredActivityState(
          activity,
          expectedNewTimeInterval,
          aDay,
          RecurrentType.none,
        ),
      ),
    );

    // Act
    editActivityCubit.changeTimeInterval(
        startTime: editActivityCubit.state.timeInterval.startTime,
        endTime: newEndTime);

    // Assert
    await expected1;

    final expected2 = expectLater(
      editActivityCubit.stream,
      emits(
        StoredActivityState(
          expectedNewActivity,
          expectedNewTimeInterval,
          aDay,
          RecurrentType.none,
        ),
      ),
    );

    await wizCubit.next();
    expect(
      wizCubit.state,
      WizardState(0, const [WizardStep.advance], successfulSave: true),
    );

    // Assert
    await expected2;
  });

  test('set empty end time sets duration to 0 and end time to null', () async {
    // Arrange
    final aDate = DateTime(2001, 01, 01, 01, 01);
    final aDay = DateTime(2001, 01, 01);

    final activity = Activity.createNew(
      title: 'test',
      startTime: aDate,
      duration: 30.minutes(),
    );

    final expectedTimeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.startTime.add(30.minutes())),
      startDate: aDate,
    );

    final expectedNewActivity = activity.copyWith(duration: Duration.zero);
    final expectedNewTimeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: null,
      startDate: aDate,
    );

    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(activity, aDay),
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesCubit: FakeActivitiesCubit(),
      editActivityCubit: editActivityCubit,
      clockCubit: clockCubit,
      allowPassedStartTime: true,
    );

    // Assert
    expect(
        editActivityCubit.state,
        StoredActivityState(
          activity,
          expectedTimeInterval,
          aDay,
          RecurrentType.none,
        ));

    final expected1 = expectLater(
      editActivityCubit.stream,
      emits(StoredActivityState(
        activity,
        expectedNewTimeInterval,
        aDay,
        RecurrentType.none,
      )),
    );

    // Act
    editActivityCubit.changeTimeInterval(
        startTime: TimeOfDay.fromDateTime(activity.startTime), endTime: null);

    // Assert
    await expected1;
    final expected2 = expectLater(
      editActivityCubit.stream,
      emits(StoredActivityState(
        expectedNewActivity,
        expectedNewTimeInterval,
        aDay,
        RecurrentType.none,
      )),
    );

    // Act
    await wizCubit.next();

    // Assert
    expect(
      wizCubit.state,
      WizardState(
        0,
        const [WizardStep.advance],
        successfulSave: true,
      ),
    );

    await expected2;
  });

  test('Trying to save recurrence without data yields error', () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDay,
      defaultsSettings:
          DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
      calendarId: calendarId,
    );

    final wizCubit = ActivityWizardCubit.newActivity(
      supportPersonsCubit: FakeSupportPersonsCubit(),
      activitiesCubit: FakeActivitiesCubit(),
      editActivityCubit: editActivityCubit,
      clockCubit: clockCubit,
      addActivitySettings: const AddActivitySettings(
        editActivity: EditActivitySettings(template: false),
      ),
    );

    // Act
    final originalActivity = editActivityCubit.state.activity;
    final activity = originalActivity.copyWith(
      title: 'null',
      recurs: Recurs.monthlyOnDays(const []),
    );
    final time = TimeOfDay.fromDateTime(aTime);
    final expectedTimeInterval = TimeInterval(
      startTime: time,
      endTime: null,
      startDate: aDay,
    );

    final expected1 = expectLater(
        editActivityCubit.stream,
        emitsInOrder([
          UnstoredActivityState(
            originalActivity,
            expectedTimeInterval,
            RecurrentType.none,
          ),
          UnstoredActivityState(
            activity,
            expectedTimeInterval,
            RecurrentType.none,
          ),
        ]));
    editActivityCubit
      ..changeTimeInterval(startTime: time)
      ..replaceActivity(activity)
      ..changeRecurrentEndDate(null);

    // Assert
    await expected1;

    await wizCubit.next();

    expect(
      wizCubit.state,
      WizardState(
        0,
        const [WizardStep.advance],
        saveErrors: const {
          SaveError.noRecurringDays,
          SaveError.noRecurringEndDate
        },
        successfulSave: false,
      ),
    );
  });

  group('warnings', () {
    group('before now', () {
      test('Trying to set start date before today yields error in step-by-step',
          () async {
        // Arrange
        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultsSettings:
              DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
          calendarId: calendarId,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          supportPersonsCubit: FakeSupportPersonsCubit(),
          activitiesCubit: mockActivitiesCubit,
          editActivityCubit: editActivityCubit,
          clockCubit: ClockCubit.fixed(aTime.add(1.days())),
          addActivitySettings: const AddActivitySettings(
              mode: AddActivityMode.stepByStep,
              editActivity: EditActivitySettings(template: false),
              general: GeneralAddActivitySettings(allowPassedStartTime: false),
              stepByStep: StepByStepSettings(
                template: false,
                image: false,
                checkable: false,
                alarm: false,
                availability: false,
                notes: false,
                reminders: false,
                checklist: false,
                fullDay: false,
                removeAfter: false,
              )),
        );

        // Act
        final originalActivity = editActivityCubit.state.activity;
        final activity = originalActivity.copyWith(title: 'title');
        final timeInterval = TimeInterval(startDate: aDay);
        final expected1 = expectLater(
            editActivityCubit.stream,
            emitsInOrder([
              UnstoredActivityState(
                originalActivity,
                timeInterval,
                RecurrentType.none,
              ),
              UnstoredActivityState(
                activity,
                timeInterval,
                RecurrentType.none,
              ),
            ]));
        editActivityCubit
          ..changeStartDate(aDay)
          ..replaceActivity(activity);

        // Assert
        await expected1;

        await wizCubit.next();
        await wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(
            1,
            const [
              WizardStep.title,
              WizardStep.date,
              WizardStep.time,
              WizardStep.category,
              WizardStep.recurring,
            ],
            saveErrors: const {SaveError.startTimeBeforeNow},
            successfulSave: false,
          ),
        );
      });

      test('Trying to save before now yields warning', () async {
        // Arrange

        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultsSettings:
              DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
          calendarId: calendarId,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          supportPersonsCubit: FakeSupportPersonsCubit(),
          activitiesCubit: mockActivitiesCubit,
          editActivityCubit: editActivityCubit,
          clockCubit: ClockCubit.fixed(aTime.add(1.hours())),
          addActivitySettings: const AddActivitySettings(
            editActivity: EditActivitySettings(template: false),
          ),
        );

        // Act

        final originalActivity = editActivityCubit.state.activity;
        final activity = originalActivity.copyWith(title: 'null');
        final time = TimeOfDay.fromDateTime(aTime);
        final timeInterval = TimeInterval(
          startTime: time,
          endTime: null,
          startDate: aDay,
        );
        final expectedActivity = activity.copyWith(startTime: aTime);
        final expected1 = expectLater(
            editActivityCubit.stream,
            emitsInOrder([
              UnstoredActivityState(
                originalActivity,
                timeInterval,
                RecurrentType.none,
              ),
              UnstoredActivityState(
                activity,
                timeInterval,
                RecurrentType.none,
              ),
            ]));
        editActivityCubit
          ..changeTimeInterval(startTime: time)
          ..replaceActivity(activity);

        // Assert
        await expected1;

        final expected2 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeInterval,
              aDay,
              RecurrentType.none,
            ),
          ),
        );
        await wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            saveErrors: const {SaveError.unconfirmedStartTimeBeforeNow},
            successfulSave: false,
          ),
        );

        await wizCubit.next(warningConfirmed: true);

        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            successfulSave: true,
          ),
        );

        // Assert
        await expected2;

        expect(
            verify(() => mockActivitiesCubit.addActivity(captureAny()))
                .captured
                .single,
            expectedActivity);
      });

      test('Trying to save full day before now yields warning', () async {
        // Arrange
        final time = aTime.add(1.days());

        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultsSettings:
              DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
          calendarId: calendarId,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          supportPersonsCubit: FakeSupportPersonsCubit(),
          activitiesCubit: mockActivitiesCubit,
          editActivityCubit: editActivityCubit,
          clockCubit: ClockCubit.fixed(time),
          addActivitySettings: const AddActivitySettings(
            editActivity: EditActivitySettings(template: false),
          ),
        );

        // Act

        final originalActivity = editActivityCubit.state.activity;
        final activity =
            originalActivity.copyWith(title: 'null', fullDay: true);

        final saveTime = aDay.previousDay();
        final timeInterval = TimeInterval(
          startDate: saveTime,
        );

        final expectedActivity =
            activity.copyWith(startTime: saveTime, alarmType: noAlarm);

        final expected1 = expectLater(
          editActivityCubit.stream,
          emitsInOrder(
            [
              UnstoredActivityState(
                originalActivity,
                timeInterval,
                RecurrentType.none,
              ),
              UnstoredActivityState(
                activity,
                timeInterval,
                RecurrentType.none,
              ),
            ],
          ),
        );
        editActivityCubit
          ..changeStartDate(saveTime)
          ..replaceActivity(activity);

        // Assert
        await expected1;
        final expected2 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeInterval,
              saveTime,
              RecurrentType.none,
            ),
          ),
        );

        await wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            saveErrors: const {SaveError.unconfirmedStartTimeBeforeNow},
            successfulSave: false,
          ),
        );
        await wizCubit.next(warningConfirmed: true);
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            successfulSave: true,
          ),
        );

        // Assert
        await expected2;
      });

      test('Trying to save recurring with errors yields warnings', () async {
        final clockCubit = ClockCubit.fixed(aTime.add(1.hours()));
        // Arrange
        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultsSettings:
              DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
          calendarId: calendarId,
        );
        final wizCubit = ActivityWizardCubit.newActivity(
          supportPersonsCubit: FakeSupportPersonsCubit(),
          activitiesCubit: mockActivitiesCubit,
          editActivityCubit: editActivityCubit,
          clockCubit: clockCubit,
          addActivitySettings: const AddActivitySettings(
            editActivity: EditActivitySettings(template: false),
          ),
        );
        final recursWeeklyEveryDay =
            Recurs.weeklyOnDays(List.generate(7, (d) => d + 1));

        // Act
        final originalActivity = editActivityCubit.state.activity;
        final activity1 = originalActivity.copyWith(title: 'null');
        final activity2 = activity1.copyWith(
          recurs: Recurs.weeklyOnDay(clockCubit.state.weekday),
        );
        final activity3 = activity2.copyWith(recurs: recursWeeklyEveryDay);
        final time = TimeOfDay.fromDateTime(aTime);
        final timeInterval = TimeInterval(
          startTime: time,
          endTime: null,
          startDate: aDay,
        );
        final recursTimeInterval = timeInterval.copyWithEndDate(noEndDate);

        final expectedActivity = activity3.copyWith(startTime: aTime);

        final expected1 = expectLater(
            editActivityCubit.stream,
            emitsInOrder([
              UnstoredActivityState(
                originalActivity,
                timeInterval,
                RecurrentType.none,
              ),
              UnstoredActivityState(
                activity1,
                timeInterval,
                RecurrentType.none,
              ),
              UnstoredActivityState(
                activity2,
                timeInterval,
                RecurrentType.weekly,
              ),
              UnstoredActivityState(
                activity3,
                timeInterval,
                RecurrentType.weekly,
              ),
            ]));

        editActivityCubit
          ..changeRecurrentEndDate(null)
          ..changeTimeInterval(startTime: time)
          ..replaceActivity(activity1)
          ..changeRecurrentType(RecurrentType.weekly)
          ..changeWeeklyRecurring(recursWeeklyEveryDay);

        // Assert
        await expected1;

        final expected2 = expectLater(
            editActivityCubit.stream,
            emits(
              StoredActivityState(
                expectedActivity,
                recursTimeInterval,
                aDay,
                RecurrentType.weekly,
              ),
            ));

        await wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            successfulSave: true,
          ),
        );

        // Assert
        await expected2;
      });

      test('Trying to edit recurring THIS DAY ONLY before now yields warning',
          () async {
        // Arrange
        final activity = Activity.createNew(
          title: 'title',
          startTime: aTime.subtract(
            100.days(),
          ),
          recurs: Recurs.weeklyOnDays(const [1, 2, 3, 4, 5, 6, 7]),
        );

        final editActivityCubit = EditActivityCubit.edit(
          ActivityDay(activity, aDay),
        );

        final wizCubit = ActivityWizardCubit.edit(
          activitiesCubit: FakeActivitiesCubit(),
          editActivityCubit: editActivityCubit,
          clockCubit: ClockCubit.fixed(aTime.add(1.hours())),
          allowPassedStartTime: true,
        );

        final expectedTimeInterval = TimeInterval(
          startTime: TimeOfDay.fromDateTime(aTime),
          startDate: aDay,
          endDate: noEndDate,
        );

        final activityWithNewTitle = activity.copyWith(title: 'new title');

        final expectedActivityToSave =
            activityWithNewTitle.copyWith(startTime: activity.startClock(aDay));

        final expected1 = expectLater(
            editActivityCubit.stream,
            emits(
              StoredActivityState(
                activityWithNewTitle,
                expectedTimeInterval,
                aDay,
                RecurrentType.daily,
              ),
            ));

        // Act
        editActivityCubit.replaceActivity(activityWithNewTitle);

        // Assert
        await expected1;

        final expected2 = expectLater(
            editActivityCubit.stream,
            emits(StoredActivityState(
              expectedActivityToSave,
              expectedTimeInterval,
              aDay,
              RecurrentType.daily,
            )));

        // Act
        await wizCubit.next();

        // Assert
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            saveErrors: const {
              SaveError.unconfirmedStartTimeBeforeNow,
              SaveError.storedRecurring,
            },
            successfulSave: false,
          ),
        );

        // Act
        await wizCubit.next(
            warningConfirmed: true,
            saveRecurring: SaveRecurring(ApplyTo.onlyThisDay, aDay));
        // Assert
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            successfulSave: true,
          ),
        );

        await expected2;
      });
    });
    group('conflict', () {
      // base case, just a conflict
      test('Trying to save with conflict yields warning', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        when(() => mockActivityRepository.allBetween(any(), any()))
            .thenAnswer((_) => Future.value([stored]));
        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultsSettings:
              DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
          calendarId: calendarId,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          supportPersonsCubit: FakeSupportPersonsCubit(),
          activitiesCubit: mockActivitiesCubit,
          editActivityCubit: editActivityCubit,
          clockCubit: ClockCubit.fixed(aTime.subtract(1.hours())),
          addActivitySettings: const AddActivitySettings(
            editActivity: EditActivitySettings(template: false),
          ),
        );

        // Act
        final originalActivity = editActivityCubit.state.activity;
        final activity = originalActivity.copyWith(title: 'null');
        final time = TimeOfDay.fromDateTime(aTime);
        final timeInterval = TimeInterval(
          startTime: time,
          endTime: null,
          startDate: aDay,
        );
        final expectedActivity = activity.copyWith(startTime: aTime);
        final expected1 = expectLater(
            editActivityCubit.stream,
            emitsInOrder([
              UnstoredActivityState(
                originalActivity,
                timeInterval,
                RecurrentType.none,
              ),
              UnstoredActivityState(
                activity,
                timeInterval,
                RecurrentType.none,
              ),
            ]));
        editActivityCubit
          ..changeTimeInterval(startTime: time)
          ..replaceActivity(activity);

        // Assert
        await expected1;

        final expected2 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeInterval,
              aDay,
              RecurrentType.none,
            ),
          ),
        );

        await wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            saveErrors: const {SaveError.unconfirmedActivityConflict},
            successfulSave: false,
          ),
        );

        await wizCubit.next(warningConfirmed: true);
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            successfulSave: true,
          ),
        );

        // Assert
        await expected2;
      });

      test('Trying to save with conflict and before now yields warnings',
          () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        when(() => mockActivityRepository.allBetween(any(), any()))
            .thenAnswer((_) => Future.value([stored]));
        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultsSettings:
              DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
          calendarId: calendarId,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          supportPersonsCubit: FakeSupportPersonsCubit(),
          activitiesCubit: mockActivitiesCubit,
          editActivityCubit: editActivityCubit,
          clockCubit: ClockCubit.fixed(aTime.add(1.hours())),
          addActivitySettings: const AddActivitySettings(
            editActivity: EditActivitySettings(template: false),
          ),
        );

        // Act
        final originalActivity = editActivityCubit.state.activity;
        final activity = originalActivity.copyWith(title: 'null');
        final time = TimeOfDay.fromDateTime(aTime);
        final timeInterval = TimeInterval(
          startTime: time,
          endTime: null,
          startDate: aDay,
        );
        final expectedActivity = activity.copyWith(startTime: aTime);

        final expected1 = expectLater(
            editActivityCubit.stream,
            emitsInOrder([
              UnstoredActivityState(
                originalActivity,
                timeInterval,
                RecurrentType.none,
              ),
              UnstoredActivityState(
                activity,
                timeInterval,
                RecurrentType.none,
              ),
            ]));

        editActivityCubit
          ..changeTimeInterval(startTime: time)
          ..replaceActivity(activity);

        // Assert
        await expected1;
        final expected2 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeInterval,
              aDay,
              RecurrentType.none,
            ),
          ),
        );

        await wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            saveErrors: const {
              SaveError.unconfirmedActivityConflict,
              SaveError.unconfirmedStartTimeBeforeNow,
            },
            successfulSave: false,
          ),
        );
        await wizCubit.next(warningConfirmed: true);
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            successfulSave: true,
          ),
        );

        await expected2;
      });

      test('No self conflicts', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        when(() => mockActivityRepository.allBetween(any(), any()))
            .thenAnswer((_) => Future.value([stored]));
        final editActivityCubit = EditActivityCubit.edit(
          ActivityDay(stored, aDay),
        );

        final wizCubit = ActivityWizardCubit.edit(
          activitiesCubit: mockActivitiesCubit,
          editActivityCubit: editActivityCubit,
          clockCubit: ClockCubit.fixed(aTime.subtract(1.hours())),
          allowPassedStartTime: false,
        );

        // Act
        final titleChanged = stored.copyWith(title: 'null');
        final time = TimeOfDay.fromDateTime(aTime);
        final timeInterval = TimeInterval(
          startTime: time,
          startDate: aDay,
        );
        final expectedActivity = titleChanged.copyWith(startTime: aTime);

        final expected1 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              titleChanged,
              timeInterval,
              aDay,
              RecurrentType.none,
            ),
          ),
        );
        editActivityCubit.replaceActivity(titleChanged);

        // Assert
        await expected1;

        await wizCubit.next();

        expect(
          wizCubit.state,
          WizardState(0, const [WizardStep.advance], successfulSave: true),
        );

        expect(
          editActivityCubit.state,
          StoredActivityState(
            expectedActivity,
            timeInterval,
            aDay,
            RecurrentType.none,
          ),
        );
      });

      test('no conflict for full day', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        when(() => mockActivityRepository.allBetween(any(), any()))
            .thenAnswer((_) => Future.value([stored]));

        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultsSettings:
              DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
          calendarId: calendarId,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          supportPersonsCubit: FakeSupportPersonsCubit(),
          activitiesCubit: mockActivitiesCubit,
          editActivityCubit: editActivityCubit,
          clockCubit: ClockCubit.fixed(aTime),
          addActivitySettings: const AddActivitySettings(
            editActivity: EditActivitySettings(template: false),
          ),
        );

        // Act
        final originalActivity = editActivityCubit.state.activity;
        final activity = originalActivity.copyWith(
          title: 'null',
          fullDay: true,
          alarmType: noAlarm,
        );
        final timeInterval = TimeInterval(
          startDate: aDay,
        );
        final expectedActivity = activity.copyWith(startTime: aDay);

        final expected1 = expectLater(
            editActivityCubit.stream,
            emits(
              UnstoredActivityState(
                activity,
                timeInterval,
                RecurrentType.none,
              ),
            ));
        editActivityCubit.replaceActivity(activity);

        // Assert
        await expected1;
        final expected2 = expectLater(
            editActivityCubit.stream,
            emits(StoredActivityState(
              expectedActivity,
              timeInterval,
              aDay,
              RecurrentType.none,
            )));

        await wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(0, const [WizardStep.advance], successfulSave: true),
        );
        await expected2;
      });

      test('no conflict for recurring', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        when(() => mockActivityRepository.allBetween(any(), any()))
            .thenAnswer((_) => Future.value([stored]));
        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultsSettings:
              DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
          calendarId: calendarId,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          supportPersonsCubit: FakeSupportPersonsCubit(),
          activitiesCubit: mockActivitiesCubit,
          editActivityCubit: editActivityCubit,
          clockCubit: ClockCubit.fixed(aTime.subtract(1.hours())),
          addActivitySettings: const AddActivitySettings(
            editActivity: EditActivitySettings(template: false),
          ),
        );

        // Act
        final originalActivity = editActivityCubit.state.activity;
        final activity = originalActivity.copyWith(
          title: 'null',
          recurs: Recurs.everyDay,
        );
        final time = TimeOfDay.fromDateTime(aTime);
        final firstTimeInterval = TimeInterval(
          startTime: time,
          endTime: null,
          startDate: aDay,
          endDate: null,
        );
        final secondTimeInterval = firstTimeInterval.copyWithEndDate(noEndDate);
        editActivityCubit.changeTimeInterval(startTime: time);
        final expectedActivity = activity.copyWith(startTime: aTime);
        final expected1 = expectLater(
          editActivityCubit.stream,
          emitsInOrder(
            [
              UnstoredActivityState(
                activity,
                firstTimeInterval,
                RecurrentType.none,
              ),
            ],
          ),
        );

        editActivityCubit.replaceActivity(activity);

        // Assert
        await expected1;
        final expected2 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              secondTimeInterval,
              aDay,
              RecurrentType.none,
            ),
          ),
        );
        await wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(0, const [WizardStep.advance], successfulSave: true),
        );

        await expected2;
      });

      test('No conflicts when edit but not time', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final stored2 = Activity.createNew(title: 'stored2', startTime: aTime);
        when(() => mockActivityRepository.allBetween(any(), any()))
            .thenAnswer((_) => Future.value([stored, stored2]));

        final editActivityCubit = EditActivityCubit.edit(
          ActivityDay(stored, aDay),
        );

        final wizCubit = ActivityWizardCubit.edit(
          activitiesCubit: mockActivitiesCubit,
          editActivityCubit: editActivityCubit,
          clockCubit: ClockCubit.fixed(aTime.subtract(1.hours())),
          allowPassedStartTime: false,
        );

        // Act
        final titleChanged = stored.copyWith(title: 'null');
        final time = TimeOfDay.fromDateTime(aTime);
        final timeInterval = TimeInterval(
          startTime: time,
          startDate: aDay,
        );
        final expectedActivity = titleChanged.copyWith(startTime: aTime);

        final expected1 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              titleChanged,
              timeInterval,
              aDay,
              RecurrentType.none,
            ),
          ),
        );
        editActivityCubit.replaceActivity(titleChanged);

        // Assert
        await expected1;

        await wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(0, const [WizardStep.advance], successfulSave: true),
        );

        expect(
          editActivityCubit.state,
          StoredActivityState(
            expectedActivity,
            timeInterval,
            aDay,
            RecurrentType.none,
          ),
        );
      });
    });
  });

  test('BUG SGC-352 edit a none recurring activity to be recurring', () async {
    // Arrange
    final activity = Activity.createNew(title: 'SGC-352', startTime: aTime);
    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(activity, aDay),
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesCubit: FakeActivitiesCubit(),
      editActivityCubit: editActivityCubit,
      clockCubit: clockCubit,
      allowPassedStartTime: false,
    );

    final expectedTimeInterval1 = TimeInterval(
      startDate: aDay,
      startTime: TimeOfDay.fromDateTime(aTime),
    );
    final expectedTimeInterval2 = expectedTimeInterval1.copyWithEndDate(null);
    final expectedTimeInterval3 =
        expectedTimeInterval1.copyWithEndDate(noEndDate);
    final recurringActivity1 = activity.copyWith(
      recurs: Recurs.weeklyOnDay(aDay.weekday),
    );
    final recurringActivity2 = activity.copyWith(
      recurs: Recurs.weeklyOnDay(aTime.weekday, ends: noEndDate),
    );

    final expected1 = expectLater(
      editActivityCubit.stream,
      emitsInOrder([
        StoredActivityState(
          recurringActivity1,
          expectedTimeInterval1,
          aDay,
          RecurrentType.weekly,
        ),
        StoredActivityState(
          recurringActivity2,
          expectedTimeInterval2,
          aDay,
          RecurrentType.weekly,
        ),
        StoredActivityState(
          recurringActivity2,
          expectedTimeInterval3,
          aDay,
          RecurrentType.weekly,
        ),
      ]),
    );

    // Act
    editActivityCubit
      ..changeRecurrentType(RecurrentType.weekly)
      ..changeRecurrentEndDate(null)
      ..changeRecurrentEndDate(noEndDate);
    // Assert
    await expected1;

    await wizCubit.next();
    expect(
      wizCubit.state,
      WizardState(0, const [WizardStep.advance], successfulSave: true),
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
      recurs: Recurs.weeklyOnDays(const [1, 2, 3, 4, 5, 6, 7]),
    );
    when(() => mockActivityRepository.allBetween(any(), any()))
        .thenAnswer((_) => Future.value([activity]));

    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(activity, aDay),
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesCubit: mockActivitiesCubit,
      editActivityCubit: editActivityCubit,
      clockCubit: clockCubit,
      allowPassedStartTime: false,
    );

    final activityWithNewTitle = activity.copyWith(title: 'new title');
    final expectedActivityToSave =
        activityWithNewTitle.copyWith(startTime: activity.startClock(aDay));
    final expected1 = expectLater(
        editActivityCubit.stream,
        emitsInOrder([
          StoredActivityState(
            activityWithNewTitle,
            TimeInterval(
              startTime: TimeOfDay.fromDateTime(activity.startTime),
              startDate: aDay,
              endDate: noEndDate,
            ),
            aDay,
            RecurrentType.daily,
          ),
        ]));
    // Act
    editActivityCubit.replaceActivity(activityWithNewTitle);

    // Assert
    await expected1;

    // Act
    await wizCubit.next(
        saveRecurring: SaveRecurring(ApplyTo.onlyThisDay, aDay));

    // Assert - correct day is saved
    await untilCalled(
        () => mockActivitiesCubit.updateRecurringActivity(any(), any()));
    expect(
      verify(() => mockActivitiesCubit.updateRecurringActivity(
          captureAny(), captureAny())).captured,
      [
        ActivityDay(expectedActivityToSave, aDay),
        ApplyTo.onlyThisDay,
      ],
    );
  });

  test('Changing date on recurring yearly should update recurring data',
      () async {
    // Arrange
    final activity = Activity.createNew(
      title: 'title',
      startTime: aTime,
    );
    when(() => mockActivityRepository.allBetween(any(), any()))
        .thenAnswer((_) => Future.value([activity]));

    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(activity, aDay),
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesCubit: mockActivitiesCubit,
      editActivityCubit: editActivityCubit,
      clockCubit: clockCubit,
      allowPassedStartTime: false,
    );

    final nextDay = aTime.add(1.days());
    final expectedActivity = activity.copyWith(
      startTime: nextDay,
      recurs: Recurs.yearly(nextDay),
    );

    // Acts
    editActivityCubit
      ..changeRecurrentType(RecurrentType.yearly)
      ..changeStartDate(nextDay);

    await wizCubit.next(
        saveRecurring: SaveRecurring(ApplyTo.onlyThisDay, aDay));

    await untilCalled(
        () => mockActivitiesCubit.updateRecurringActivity(any(), any()));
    expect(
      verify(() => mockActivitiesCubit.updateRecurringActivity(
          captureAny(), captureAny())).captured,
      [
        ActivityDay(expectedActivity, aDay),
        ApplyTo.onlyThisDay,
      ],
    );
  });

  group('Wizard steps', () {
    test('is correct state default settings', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: calendarId,
      );

      final wizCubit = ActivityWizardCubit.newActivity(
        supportPersonsCubit: FakeSupportPersonsCubit.withSupportPerson(),
        activitiesCubit: FakeActivitiesCubit(),
        editActivityCubit: editActivityCubit,
        clockCubit: clockCubit,
        addActivitySettings:
            const AddActivitySettings(mode: AddActivityMode.stepByStep),
      );

      expect(
        wizCubit.state,
        WizardState(
          0,
          const [
            WizardStep.title,
            WizardStep.image,
            WizardStep.date,
            WizardStep.fullDay,
            WizardStep.time,
            WizardStep.category,
            WizardStep.checkable,
            WizardStep.deleteAfter,
            WizardStep.availableFor,
            WizardStep.alarm,
            WizardStep.reminder,
            WizardStep.recurring,
            WizardStep.connectedFunction
          ],
        ),
      );
    });

    test('is correct state opposite settings', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: calendarId,
      );

      final wizCubit = ActivityWizardCubit.newActivity(
        supportPersonsCubit: FakeSupportPersonsCubit(),
        activitiesCubit: FakeActivitiesCubit(),
        editActivityCubit: editActivityCubit,
        clockCubit: clockCubit,
        addActivitySettings: const AddActivitySettings(
          mode: AddActivityMode.stepByStep,
          general: GeneralAddActivitySettings(addRecurringActivity: false),
          stepByStep: StepByStepSettings(
            date: false,
            image: false,
            title: false,
            fullDay: false,
            availability: false,
            checkable: false,
            removeAfter: true,
            alarm: true,
            notes: true,
            reminders: true,
          ),
        ),
      );

      expect(
        wizCubit.state,
        WizardState(
          0,
          const [
            WizardStep.time,
            WizardStep.category,
            WizardStep.deleteAfter,
            WizardStep.alarm,
            WizardStep.reminder,
            WizardStep.connectedFunction,
          ],
        ),
      );
    });

    test('all except title steps off', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: calendarId,
      );

      final wizCubit = ActivityWizardCubit.newActivity(
        supportPersonsCubit: FakeSupportPersonsCubit(),
        activitiesCubit: FakeActivitiesCubit(),
        editActivityCubit: editActivityCubit,
        clockCubit: clockCubit,
        addActivitySettings: const AddActivitySettings(
          mode: AddActivityMode.stepByStep,
          general: GeneralAddActivitySettings(
            addRecurringActivity: false,
          ),
          stepByStep: StepByStepSettings(
            template: false,
            date: false,
            image: false,
            title: true,
            fullDay: false,
            availability: false,
            checkable: false,
            removeAfter: false,
            alarm: false,
            checklist: false,
            notes: false,
            reminders: false,
          ),
        ),
      );

      expect(
        wizCubit.state,
        WizardState(
          0,
          const [
            WizardStep.title,
            WizardStep.time,
            WizardStep.category,
          ],
        ),
      );
    });

    test(
        'When availability option is true but has no support persons, do not show availability wiz',
        () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: calendarId,
      );

      final wizCubit = ActivityWizardCubit.newActivity(
        supportPersonsCubit: FakeSupportPersonsCubit(),
        activitiesCubit: FakeActivitiesCubit(),
        editActivityCubit: editActivityCubit,
        clockCubit: clockCubit,
        addActivitySettings: const AddActivitySettings(
          mode: AddActivityMode.stepByStep,
          general: GeneralAddActivitySettings(
            addRecurringActivity: false,
          ),
          stepByStep: StepByStepSettings(
            template: false,
            date: false,
            image: false,
            title: true,
            fullDay: false,
            availability: true,
            checkable: false,
            removeAfter: false,
            alarm: false,
            checklist: false,
            notes: false,
            reminders: false,
          ),
        ),
      );

      expect(
        wizCubit.state,
        WizardState(
          0,
          const [
            WizardStep.title,
            WizardStep.time,
            WizardStep.category,
          ],
        ),
      );
    });

    const allWizStepsSettings = AddActivitySettings(
      mode: AddActivityMode.stepByStep,
      general: GeneralAddActivitySettings(
        addRecurringActivity: true,
      ),
      stepByStep: StepByStepSettings(
        template: true,
        date: true,
        image: true,
        title: true,
        fullDay: true,
        availability: true,
        checkable: true,
        removeAfter: true,
        alarm: true,
        checklist: true,
        notes: true,
        reminders: true,
      ),
    );

    const allWizStep = [
      WizardStep.title,
      WizardStep.image,
      WizardStep.date,
      WizardStep.fullDay,
      WizardStep.time,
      WizardStep.category,
      WizardStep.checkable,
      WizardStep.deleteAfter,
      WizardStep.availableFor,
      WizardStep.alarm,
      WizardStep.reminder,
      WizardStep.recurring,
      WizardStep.connectedFunction,
    ];

    test('all steps on', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: calendarId,
      );

      final wizCubit = ActivityWizardCubit.newActivity(
        supportPersonsCubit: FakeSupportPersonsCubit.withSupportPerson(),
        activitiesCubit: FakeActivitiesCubit(),
        editActivityCubit: editActivityCubit,
        clockCubit: clockCubit,
        addActivitySettings: allWizStepsSettings,
      );

      expect(
        wizCubit.state,
        WizardState(
          0,
          allWizStep,
        ),
      );
    });

    test('all steps, stepping through all', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: calendarId,
      );
      final activity = editActivityCubit.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        supportPersonsCubit: FakeSupportPersonsCubit.withSupportPerson(),
        activitiesCubit: FakeActivitiesCubit(),
        editActivityCubit: editActivityCubit,
        clockCubit: clockCubit,
        addActivitySettings: allWizStepsSettings,
      );

      expect(
        wizCubit.state,
        WizardState(
          0,
          allWizStep,
        ),
      );
      await wizCubit.next(); // title
      await wizCubit.next(); // image ---> error

      expect(
        wizCubit.state,
        WizardState(
          1,
          allWizStep,
          saveErrors: const {SaveError.noTitleOrImage},
          successfulSave: false,
        ),
      );

      editActivityCubit.replaceActivity(
        activity.copyWith(title: 'one title please'),
      );

      await wizCubit.next(); // image
      await wizCubit.next(); // date
      await wizCubit.next(); // full day
      await wizCubit.next(); // time ---> error

      expect(
        wizCubit.state,
        WizardState(
          4,
          allWizStep,
          saveErrors: const {SaveError.noStartTime},
          successfulSave: false,
        ),
      );

      editActivityCubit.changeTimeInterval(
          startTime: const TimeOfDay(hour: 4, minute: 4));

      await wizCubit.next(); // time
      await wizCubit.next(); // category
      await wizCubit.next(); // alarm,
      await wizCubit.next(); // checkable,
      await wizCubit.next(); // deleteAfter,
      await wizCubit.next(); // reminder,
      await wizCubit.next(); // recurring,
      await wizCubit.next(); // checklist,
      await wizCubit.next(); // connectedFunction,

      expect(
        wizCubit.state,
        WizardState(
          12,
          allWizStep,
          successfulSave: true,
        ),
      );
    });

    test('Can remove and add time step', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: calendarId,
      );
      final activity = editActivityCubit.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        supportPersonsCubit: FakeSupportPersonsCubit.withSupportPerson(),
        activitiesCubit: FakeActivitiesCubit(),
        editActivityCubit: editActivityCubit,
        clockCubit: clockCubit,
        addActivitySettings: allWizStepsSettings,
      );

      expect(
        wizCubit.state,
        WizardState(0, allWizStep),
      );

      editActivityCubit
        ..replaceActivity(activity.copyWith(fullDay: true))
        ..replaceActivity(activity.copyWith(fullDay: false));
      expectLater(
        wizCubit.stream,
        emitsInOrder([
          WizardState(0, const [
            WizardStep.title,
            WizardStep.image,
            WizardStep.date,
            WizardStep.fullDay,
            WizardStep.checkable,
            WizardStep.deleteAfter,
            WizardStep.availableFor,
            WizardStep.recurring,
            WizardStep.connectedFunction,
          ]),
          WizardState(0, allWizStep),
        ]),
      );
    });
  });
}
