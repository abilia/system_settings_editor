import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  late MockActivitiesBloc mockActivitiesBloc;
  late MockActivityRepository mockActivityRepository;
  late ClockBloc clockBloc;
  final nowTime = DateTime(2000, 02, 22, 22, 30);
  final aTime = DateTime(2022, 02, 22, 22, 30);
  final aDay = DateTime(2022, 02, 22);
  const calendarId = 'Some calendar id';

  setUpAll(() {
    registerFallbackValues();
    tz.initializeTimeZones();
  });

  setUp(() {
    mockActivitiesBloc = MockActivitiesBloc();
    when(() => mockActivitiesBloc.state).thenAnswer((_) => ActivitiesChanged());
    mockActivityRepository = MockActivityRepository();
    when(() => mockActivityRepository.allBetween(any(), any()))
        .thenAnswer((_) => Future.value([]));
    when(() => mockActivitiesBloc.activityRepository)
        .thenReturn(mockActivityRepository);

    clockBloc = ClockBloc.fixed(nowTime);
  });

  test('Initial edit state is', () {
    // Arrange
    final activityWizardCubit = ActivityWizardCubit.edit(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: FakeEditActivityCubit(),
      clockBloc: clockBloc,
      allowPassedStartTime: false,
    );

    expect(activityWizardCubit.state,
        WizardState(0, UnmodifiableListView([WizardStep.advance])));
  });

  test('Initial new with default settings', () {
    // Arrange
    final activityWizardCubit = ActivityWizardCubit.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: FakeEditActivityCubit(),
      clockBloc: clockBloc,
      addActivitySettings: const AddActivitySettings(),
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
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: calendarId,
      ),
      clockBloc: clockBloc,
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
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: FakeEditActivityCubit(),
      clockBloc: clockBloc,
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
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
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
      activitiesBloc: mockActivitiesBloc,
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
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
        UnstoredActivityState(activityWithTitle, timeInterval),
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
        UnstoredActivityState(activityWithTitle, newTimeInterval),
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
    verify(() => mockActivitiesBloc.add(AddActivity(expectedSaved)));
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
      activitiesBloc: mockActivitiesBloc,
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
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
      emits(StoredActivityState(activityAsFullDay, timeInterval, aDay)),
    );

    // Act
    editActivityCubit.replaceActivity(activityAsFullDay);
    // Assert
    await expect1;
    // Act
    await activityWizardCubit.next();

    // Assert
    expect(activityWizardCubit.state, wizState.saveSuccess());
    verify(() =>
        mockActivitiesBloc.add(UpdateActivity(activityExpectedToBeSaved)));
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
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
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
          UnstoredActivityState(activity, expectedTimeInterval1),
          UnstoredActivityState(activity, expectedTimeInterval2),
          UnstoredActivityState(newActivity, expectedTimeInterval2),
        ],
      ),
    );
    // Act
    editActivityCubit.changeTimeInterval(
        startTime: const TimeOfDay(hour: 1, minute: 1));
    editActivityCubit.changeStartDate(newDate);
    editActivityCubit.replaceActivity(newActivity);

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
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        allowPassedStartTime: true,
      );

      // Assert
      expect(
        editActivityCubit.state,
        StoredActivityState(activity, expectedTimeInterval, aDay),
      );

      final expected1 = expectLater(
        editActivityCubit.stream,
        emits(
          StoredActivityState(activity, expectedNewTimeInterval, aDay),
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
              expectedNewActivity, expectedNewTimeInterval, aDay),
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
      activitiesBloc: FakeActivitiesBloc(),
      clockBloc: clockBloc,
      editActivityCubit: editActivityCubit,
      allowPassedStartTime: false,
    );

    // Assert
    expect(editActivityCubit.state,
        StoredActivityState(activity, expectedTimeInterval, aDay));

    final expected1 = expectLater(
      editActivityCubit.stream,
      emits(
        StoredActivityState(activity, expectedNewTimeInterval, aDay),
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
        StoredActivityState(expectedNewActivity, expectedNewTimeInterval, aDay),
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
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
      allowPassedStartTime: true,
    );

    // Assert
    expect(editActivityCubit.state,
        StoredActivityState(activity, expectedTimeInterval, aDay));

    final expected1 = expectLater(
      editActivityCubit.stream,
      emits(StoredActivityState(activity, expectedNewTimeInterval, aDay)),
    );

    // Act
    editActivityCubit.changeTimeInterval(
        startTime: TimeOfDay.fromDateTime(activity.startTime), endTime: null);

    // Assert
    await expected1;
    final expected2 = expectLater(
      editActivityCubit.stream,
      emits(StoredActivityState(
          expectedNewActivity, expectedNewTimeInterval, aDay)),
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

  test('Trying to save an empty checklist saves noInfoItem', () async {
    // Arrange
    final activity = Activity.createNew(
        title: 'null',
        startTime: aTime,
        infoItem: const NoteInfoItem('a note'));
    final activityWithEmptyChecklist = activity.copyWith(infoItem: Checklist());
    final expectedActivity = activity.copyWith(infoItem: InfoItem.none);
    final activityDay = ActivityDay(activity, aDay);
    final timeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(aTime),
      startDate: aTime,
    );
    final editActivityCubit = EditActivityCubit.edit(
      activityDay,
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesBloc: mockActivitiesBloc,
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
      allowPassedStartTime: true,
    );

    final expected1 = expectLater(
      editActivityCubit.stream,
      emits(
        StoredActivityState(
          activityWithEmptyChecklist,
          timeInterval,
          aDay,
        ).copyWith(activityWithEmptyChecklist,
            infoItems: {NoteInfoItem: activity.infoItem}),
      ),
    );
    // Act
    editActivityCubit.changeInfoItemType(Checklist);

    // Assert
    await expected1;

    wizCubit.next();

    // Assert
    await untilCalled(() => mockActivitiesBloc.add(any()));
    expect(verify(() => mockActivitiesBloc.add(captureAny())).captured.single,
        UpdateActivity(expectedActivity));
  });

  test('Trying to save an empty note saves noInfoItem', () async {
    // Arrange
    final activity = Activity.createNew(
        title: 'null',
        startTime: aTime,
        infoItem: Checklist(questions: const [Question(id: 0, name: 'name')]));
    final expectedActivity = activity.copyWith(infoItem: InfoItem.none);
    final activityWithEmptyNote =
        activity.copyWith(infoItem: const NoteInfoItem());
    final activityDay = ActivityDay(activity, aDay);
    final timeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(aTime),
      startDate: aTime,
    );
    final editActivityCubit = EditActivityCubit.edit(
      activityDay,
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesBloc: mockActivitiesBloc,
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
      allowPassedStartTime: true,
    );

    final expected1 = expectLater(
      editActivityCubit.stream,
      emits(
        StoredActivityState(
          activityWithEmptyNote,
          timeInterval,
          aDay,
        ).copyWith(activityWithEmptyNote,
            infoItems: {Checklist: activity.infoItem}),
      ),
    );
    // Act
    editActivityCubit.changeInfoItemType(NoteInfoItem);

    // Assert
    await expected1;

    wizCubit.next();

    // Assert
    await untilCalled(() => mockActivitiesBloc.add(any()));
    expect(verify(() => mockActivitiesBloc.add(captureAny())).captured.single,
        UpdateActivity(expectedActivity));
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
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
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
          ),
          UnstoredActivityState(
            activity,
            expectedTimeInterval,
          ),
        ]));
    editActivityCubit.changeTimeInterval(startTime: time);
    editActivityCubit.replaceActivity(activity);
    editActivityCubit.changeRecurrentEndDate(null);

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
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime.add(1.days())),
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
              ),
              UnstoredActivityState(
                activity,
                timeInterval,
              ),
            ]));
        editActivityCubit.changeStartDate(aDay);
        editActivityCubit.replaceActivity(activity);

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
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime.add(1.hours())),
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
              ),
              UnstoredActivityState(
                activity,
                timeInterval,
              ),
            ]));
        editActivityCubit.changeTimeInterval(startTime: time);
        editActivityCubit.replaceActivity(activity);

        // Assert
        await expected1;

        final expected2 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeInterval,
              aDay,
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
            verify(() => mockActivitiesBloc.add(captureAny())).captured.single,
            AddActivity(expectedActivity));
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
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(time),
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
              ),
              UnstoredActivityState(
                activity,
                timeInterval,
              ),
            ],
          ),
        );
        editActivityCubit.changeStartDate(saveTime);
        editActivityCubit.replaceActivity(activity);

        // Assert
        await expected1;
        final expected2 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeInterval,
              saveTime,
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

      test('Trying to save new recurring before now yields warning', () async {
        final clockBloc = ClockBloc.fixed(aTime.add(1.hours()));
        // Arrange
        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultsSettings:
              DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
          calendarId: calendarId,
        );
        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: clockBloc,
          addActivitySettings: const AddActivitySettings(
            editActivity: EditActivitySettings(template: false),
          ),
        );

        // Act
        final originalActivity = editActivityCubit.state.activity;
        final activity1 = originalActivity.copyWith(title: 'null');
        final activity2 = activity1.copyWith(
          recurs: Recurs.weeklyOnDay(clockBloc.state.weekday),
        );
        final activity3 = activity2.copyWith(recurs: Recurs.everyDay);
        final time = TimeOfDay.fromDateTime(aTime);
        final timeInterval = TimeInterval(
          startTime: time,
          endTime: null,
          startDate: aDay,
        );
        final recursTimeInterval = timeInterval.changeEndDate(Recurs.noEndDate);

        final expectedActivity = activity3.copyWith(startTime: aTime);

        final expected1 = expectLater(
            editActivityCubit.stream,
            emitsInOrder([
              UnstoredActivityState(
                originalActivity,
                timeInterval,
              ),
              UnstoredActivityState(
                activity1,
                timeInterval,
              ),
              UnstoredActivityState(
                activity2,
                timeInterval,
              ),
              UnstoredActivityState(
                activity3,
                timeInterval,
              ),
            ]));

        editActivityCubit.changeRecurrentEndDate(null);
        editActivityCubit.changeTimeInterval(startTime: time);
        editActivityCubit.replaceActivity(activity1);
        editActivityCubit.changeRecurrentType(RecurrentType.weekly);
        editActivityCubit.changeWeeklyRecurring(Recurs.everyDay);

        // Assert
        await expected1;

        final expected2 = expectLater(
            editActivityCubit.stream,
            emits(
              StoredActivityState(
                expectedActivity,
                recursTimeInterval,
                aDay,
              ),
            ));

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
          activitiesBloc: FakeActivitiesBloc(),
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime.add(1.hours())),
          allowPassedStartTime: true,
        );

        final expectedTimeInterval = TimeInterval(
          startTime: TimeOfDay.fromDateTime(aTime),
          startDate: aDay,
          endDate: Recurs.noEndDate,
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
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime.subtract(1.hours())),
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
              ),
              UnstoredActivityState(
                activity,
                timeInterval,
              ),
            ]));
        editActivityCubit.changeTimeInterval(startTime: time);
        editActivityCubit.replaceActivity(activity);

        // Assert
        await expected1;

        final expected2 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeInterval,
              aDay,
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
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime.add(1.hours())),
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
              UnstoredActivityState(originalActivity, timeInterval),
              UnstoredActivityState(
                activity,
                timeInterval,
              ),
            ]));

        editActivityCubit.changeTimeInterval(startTime: time);
        editActivityCubit.replaceActivity(activity);

        // Assert
        await expected1;
        final expected2 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeInterval,
              aDay,
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
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime.subtract(1.hours())),
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
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime),
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
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime.subtract(1.hours())),
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
        final secondTimeInterval =
            firstTimeInterval.changeEndDate(Recurs.noEndDate);
        editActivityCubit.changeTimeInterval(startTime: time);
        final expectedActivity = activity.copyWith(startTime: aTime);
        final expected1 = expectLater(
          editActivityCubit.stream,
          emitsInOrder(
            [
              UnstoredActivityState(
                activity,
                firstTimeInterval,
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
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime.subtract(1.hours())),
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
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
      allowPassedStartTime: false,
    );

    final expectedTimeInterval1 = TimeInterval(
      startDate: aDay,
      startTime: TimeOfDay.fromDateTime(aTime),
    );
    final expectedTimeInterval2 = expectedTimeInterval1.changeEndDate(null);
    final expectedTimeInterval3 =
        expectedTimeInterval1.changeEndDate(Recurs.noEndDate);
    final recurringActivity1 = activity.copyWith(
      recurs: Recurs.weeklyOnDay(aDay.weekday),
    );
    final recurringActivity2 = activity.copyWith(
      recurs: Recurs.weeklyOnDay(aTime.weekday, ends: Recurs.noEndDate),
    );

    final expected1 = expectLater(
      editActivityCubit.stream,
      emitsInOrder([
        StoredActivityState(
          recurringActivity1,
          expectedTimeInterval1,
          aDay,
        ),
        StoredActivityState(
          recurringActivity2,
          expectedTimeInterval2,
          aDay,
        ),
        StoredActivityState(
          recurringActivity2,
          expectedTimeInterval3,
          aDay,
        ),
      ]),
    );

    // Act
    editActivityCubit.changeRecurrentType(RecurrentType.weekly);
    editActivityCubit.changeRecurrentEndDate(null);
    editActivityCubit.changeRecurrentEndDate(Recurs.noEndDate);
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
      activitiesBloc: mockActivitiesBloc,
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
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
              endDate: Recurs.noEndDate,
            ),
            aDay,
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
    await untilCalled(() => mockActivitiesBloc.add(any()));
    expect(
      verify(() => mockActivitiesBloc.add(captureAny())).captured.single,
      UpdateRecurringActivity(
        ActivityDay(expectedActivityToSave, aDay),
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
    when(() => mockActivityRepository.allBetween(any(), any()))
        .thenAnswer((_) => Future.value([activity]));

    final editActivityCubit = EditActivityCubit.edit(
      ActivityDay(activity, aDay),
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesBloc: mockActivitiesBloc,
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
      allowPassedStartTime: false,
    );

    final nextDay = aTime.add(1.days());
    final expectedActivity = activity.copyWith(
      startTime: nextDay,
      recurs: Recurs.yearly(nextDay),
    );

    // Acts
    editActivityCubit.changeRecurrentType(RecurrentType.yearly);
    editActivityCubit.changeStartDate(nextDay);

    await wizCubit.next(
        saveRecurring: SaveRecurring(ApplyTo.onlyThisDay, aDay));

    await untilCalled(() => mockActivitiesBloc.add(any()));
    expect(
      verify(() => mockActivitiesBloc.add(captureAny())).captured.single,
      UpdateRecurringActivity(
        ActivityDay(expectedActivity, aDay),
        ApplyTo.onlyThisDay,
      ),
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
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
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
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
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
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
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
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
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
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
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
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        addActivitySettings: allWizStepsSettings,
      );

      expect(
        wizCubit.state,
        WizardState(0, allWizStep),
      );

      editActivityCubit.replaceActivity(activity.copyWith(fullDay: true));

      editActivityCubit.replaceActivity(activity.copyWith(fullDay: false));
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

    test('Changing recurring changes wizard steps', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: calendarId,
      );
      final activity = editActivityCubit.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        addActivitySettings: allWizStepsSettings,
      );

      editActivityCubit
          .replaceActivity(activity.copyWith(recurs: Recurs.monthly(aDay.day)));
      editActivityCubit.changeRecurrentEndDate(DateTime(2023));
      editActivityCubit.replaceActivity(
          activity.copyWith(recurs: Recurs.weeklyOnDay(aDay.weekday)));
      editActivityCubit.replaceActivity(activity.copyWith(recurs: Recurs.not));
      await expectLater(
        wizCubit.stream,
        emitsInOrder([
          WizardState(0, [
            ...List.from(allWizStep)
              ..insert(allWizStep.length - 1, WizardStep.recursMonthly)
          ]),
          WizardState(0, [
            ...List.from(allWizStep)
              ..insert(allWizStep.length - 1, WizardStep.endDate)
              ..insert(allWizStep.length - 1, WizardStep.recursMonthly)
          ]),
          WizardState(0, [
            ...List.from(allWizStep)
              ..insert(allWizStep.length - 1, WizardStep.endDate)
              ..insert(allWizStep.length - 1, WizardStep.recursWeekly)
          ]),
          WizardState(0, allWizStep),
        ]),
      );
    });

    test('Saving recurring weekly without any days yields warning', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: calendarId,
      );
      final activity = editActivityCubit.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        addActivitySettings: const AddActivitySettings(
          mode: AddActivityMode.stepByStep,
          general: GeneralAddActivitySettings(
            addRecurringActivity: true,
          ),
          stepByStep: StepByStepSettings(
            template: false,
            date: false,
            image: false,
            title: false,
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
      editActivityCubit.replaceActivity(activity.copyWith(title: 'title'));
      editActivityCubit.changeTimeInterval(
          startTime: const TimeOfDay(hour: 22, minute: 22));

      editActivityCubit.changeRecurrentType(RecurrentType.weekly);
      editActivityCubit.changeWeeklyRecurring(Recurs.weeklyOnDays(const []));
      editActivityCubit.changeRecurrentEndDate(DateTime(2023));

      await expectLater(
        wizCubit.stream,
        emitsInOrder([
          WizardState(
            0,
            const [
              WizardStep.time,
              WizardStep.category,
              WizardStep.recurring,
            ],
          ),
          WizardState(
            0,
            const [
              WizardStep.time,
              WizardStep.category,
              WizardStep.recurring,
              WizardStep.recursWeekly,
            ],
          ),
          WizardState(
            0,
            const [
              WizardStep.time,
              WizardStep.category,
              WizardStep.recurring,
              WizardStep.recursWeekly,
              WizardStep.endDate,
            ],
          ),
        ]),
      );

      await wizCubit.next();
      await wizCubit.next();
      await wizCubit.next();
      await wizCubit.next();

      expect(
        wizCubit.state,
        WizardState(
          3,
          const [
            WizardStep.time,
            WizardStep.category,
            WizardStep.recurring,
            WizardStep.recursWeekly,
            WizardStep.endDate,
          ],
          saveErrors: const {SaveError.noRecurringDays},
          successfulSave: false,
        ),
      );
    });

    test(
        'BUG SGC-1595 '
        'Saving recurring weekly without any days yields warning', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: '',
      );
      final activity = editActivityCubit.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        addActivitySettings: const AddActivitySettings(
          mode: AddActivityMode.stepByStep,
          general: GeneralAddActivitySettings(
            addRecurringActivity: true,
          ),
          stepByStep: StepByStepSettings(
            template: false,
            title: false,
            image: false,
            date: false,
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

      editActivityCubit.changeStartDate(nowTime.add(7.days()).onlyDays());
      editActivityCubit.changeTimeInterval(
        startTime: const TimeOfDay(hour: 12, minute: 34),
      );
      editActivityCubit.replaceActivity(
        activity.copyWith(
          title: '-_title_-',
          recurs: Recurs.weeklyOnDays(
            const [1, 2, 3, 4, 5, 6, 7],
            ends: nowTime.add(1.days()).onlyDays(),
          ),
        ),
      );
      editActivityCubit.changeRecurrentEndDate(
        nowTime.add(1.days()).onlyDays(),
      );

      await expectLater(
        wizCubit.stream,
        emitsInOrder([
          WizardState(
            0,
            const [
              WizardStep.time,
              WizardStep.category,
              WizardStep.recurring,
            ],
          ),
          WizardState(
            0,
            const [
              WizardStep.time,
              WizardStep.category,
              WizardStep.recurring,
              WizardStep.recursWeekly,
              WizardStep.endDate,
            ],
          ),
        ]),
      );

      await wizCubit.next();
      await wizCubit.next();
      await wizCubit.next();
      await wizCubit.next();
      await wizCubit.next();

      expect(
        wizCubit.state,
        WizardState(
          4,
          const [
            WizardStep.time,
            WizardStep.category,
            WizardStep.recurring,
            WizardStep.recursWeekly,
            WizardStep.endDate,
          ],
          saveErrors: const {SaveError.endDateBeforeStart},
          successfulSave: false,
        ),
      );
    });
  });
}
