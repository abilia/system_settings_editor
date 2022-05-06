import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../fakes/fakes_blocs.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  late MockActivitiesBloc mockActivitiesBloc;
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
    when(() => mockActivitiesBloc.state)
        .thenAnswer((_) => ActivitiesNotLoaded());

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
      settings: const MemoplannerSettingsNotLoaded(),
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
        defaultAlarmTypeSetting: noAlarm,
        calendarId: calendarId,
      ),
      clockBloc: clockBloc,
      settings: const MemoplannerSettingsLoaded(
        MemoplannerSettings(addActivityTypeAdvanced: false),
      ),
    );

    expect(
      activityWizardCubit.state,
      WizardState(
        0,
        UnmodifiableListView(
          [
            WizardStep.date,
            WizardStep.title,
            WizardStep.image,
            WizardStep.availableFor,
            WizardStep.checkable,
            WizardStep.time,
            WizardStep.recurring,
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

  test('Initial state with no title and no image is not saveable', () {
    // Arrange
    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDay,
      defaultAlarmTypeSetting: noAlarm,
      calendarId: calendarId,
    );

    final activityWizardCubit = ActivityWizardCubit.edit(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
      allowPassedStartTime: false,
    );

    // Act
    activityWizardCubit.next();

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
    final mockActivitiesBloc = MockActivitiesBloc();
    when(() => mockActivitiesBloc.state).thenReturn(ActivitiesNotLoaded());

    final editActivityCubit = EditActivityCubit.newActivity(
      day: aTime,
      defaultAlarmTypeSetting: noAlarm,
      calendarId: calendarId,
    );
    final activityWizardCubit = ActivityWizardCubit.newActivity(
      activitiesBloc: mockActivitiesBloc,
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
      settings: const MemoplannerSettingsLoaded(
        MemoplannerSettings(
          editActivity: EditActivitySettings(template: false),
        ),
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
      endTime: newStartTime,
      startDate: aTime,
    );

    final expectedSaved = activityWithTitle.copyWith(startTime: newTime);

    // Act
    activityWizardCubit.next();
    expect(
      activityWizardCubit.state,
      WizardState(
        0,
        const [WizardStep.advance],
        saveErrors: const {
          SaveError.noTitleOrImage,
          SaveError.noStartTime,
        },
        sucessfullSave: false,
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
    activityWizardCubit.next();
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
    activityWizardCubit.next();
    expect(
      activityWizardCubit.state,
      WizardState(
        0,
        const [WizardStep.advance],
        sucessfullSave: true,
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
    activityWizardCubit.next();

    // Assert
    expect(activityWizardCubit.state, wizState.saveSucess());
    verify(() =>
        mockActivitiesBloc.add(UpdateActivity(activityExpectedToBeSaved)));
  });

  test('activity.startTime set correctly', () async {
    // Arrange
    final aDate = DateTime(2022, 02, 22, 22, 00);

    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDate,
      defaultAlarmTypeSetting: noAlarm,
      calendarId: calendarId,
    );

    final wizCubit = ActivityWizardCubit.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
      settings: const MemoplannerSettingsLoaded(
        MemoplannerSettings(
          editActivity: EditActivitySettings(template: false),
        ),
      ),
    );

    final activity = editActivityCubit.state.activity;

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
    editActivityCubit.changeDate(newDate);
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
    wizCubit.next();
    // Assert
    expect(
      wizCubit.state,
      WizardState(
        0,
        const [WizardStep.advance],
        sucessfullSave: true,
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

      final expetedNewActivity = activity.copyWith(duration: expectedDuration);
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
      editActivityCubit.changeTimeInterval(endTime: newEndTime);

      // Assert
      await expected1;

      final expected2 = expectLater(
        editActivityCubit.stream,
        emits(
          StoredActivityState(
              expetedNewActivity, expectedNewTimeInterval, aDay),
        ),
      );
      wizCubit.next();

      expect(
        wizCubit.state,
        WizardState(
          0,
          const [WizardStep.advance],
          sucessfullSave: true,
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

    final expetedNewActivity = activity.copyWith(duration: expectedDuration);
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
    editActivityCubit.changeTimeInterval(endTime: newEndTime);

    // Assert
    await expected1;

    final expected2 = expectLater(
      editActivityCubit.stream,
      emits(
        StoredActivityState(expetedNewActivity, expectedNewTimeInterval, aDay),
      ),
    );

    wizCubit.next();
    expect(
      wizCubit.state,
      WizardState(0, const [WizardStep.advance], sucessfullSave: true),
    );

    // Assert
    await expected2;
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

    final expectedTimeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.startTime.add(30.minutes())),
      startDate: aDate,
    );

    final expectedNewActivity = activity.copyWith(duration: Duration.zero);
    final expectedNewTimeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.startTime),
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
    wizCubit.next();

    // Assert
    expect(
      wizCubit.state,
      WizardState(
        0,
        const [WizardStep.advance],
        sucessfullSave: true,
      ),
    );

    await expected2;
  });

  test('Trying to save an empty checklist saves noInfoItem', () async {
    // Arrange
    final activity = Activity.createNew(
        title: 'null', startTime: aTime, infoItem: const NoteInfoItem('anote'));
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

  test('Trying to save recurrance withtout data yeilds error', () async {
    // Arrange
    final editActivityCubit = EditActivityCubit.newActivity(
      day: aDay,
      defaultAlarmTypeSetting: noAlarm,
      calendarId: calendarId,
    );

    final wizCubit = ActivityWizardCubit.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
      settings: const MemoplannerSettingsLoaded(
        MemoplannerSettings(
          editActivity: EditActivitySettings(template: false),
        ),
      ),
    );

    // Act
    final originalActivity = editActivityCubit.state.activity;
    final activity = originalActivity.copyWith(
      title: 'null',
      recurs: Recurs.monthlyOnDays(const []),
    );
    final time = TimeOfDay.fromDateTime(aTime);
    final expectedTimeIntervall = TimeInterval(
      startTime: time,
      endTime: time,
      startDate: aDay,
    );

    final expected1 = expectLater(
        editActivityCubit.stream,
        emitsInOrder([
          UnstoredActivityState(
            originalActivity,
            expectedTimeIntervall,
          ),
          UnstoredActivityState(
            activity,
            expectedTimeIntervall,
          ),
        ]));
    editActivityCubit.changeTimeInterval(startTime: time);
    editActivityCubit.replaceActivity(activity);

    // Assert
    await expected1;

    wizCubit.next();

    expect(
      wizCubit.state,
      WizardState(
        0,
        const [WizardStep.advance],
        saveErrors: const {SaveError.noRecurringDays},
        sucessfullSave: false,
      ),
    );
  });

  group('warnings', () {
    group('before now', () {
      test('Trying to save before now yields warning', () async {
        // Arrange

        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultAlarmTypeSetting: noAlarm,
          calendarId: calendarId,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime.add(1.hours())),
          settings: const MemoplannerSettingsLoaded(
            MemoplannerSettings(
              editActivity: EditActivitySettings(template: false),
            ),
          ),
        );

        // Act

        final originalActivity = editActivityCubit.state.activity;
        final activity = originalActivity.copyWith(title: 'null');
        final time = TimeOfDay.fromDateTime(aTime);
        final timeIntervall = TimeInterval(
          startTime: time,
          endTime: time,
          startDate: aDay,
        );
        final expectedActivity = activity.copyWith(startTime: aTime);
        final expected1 = expectLater(
            editActivityCubit.stream,
            emitsInOrder([
              UnstoredActivityState(
                originalActivity,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity,
                timeIntervall,
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
              timeIntervall,
              aDay,
            ),
          ),
        );
        wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            saveErrors: const {SaveError.unconfirmedStartTimeBeforeNow},
            sucessfullSave: false,
          ),
        );

        wizCubit.next(warningConfirmed: true);

        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            sucessfullSave: true,
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
          defaultAlarmTypeSetting: noAlarm,
          calendarId: calendarId,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(time),
          settings: const MemoplannerSettingsLoaded(
            MemoplannerSettings(
              editActivity: EditActivitySettings(template: false),
            ),
          ),
        );

        // Act

        final originalActivity = editActivityCubit.state.activity;
        final activity =
            originalActivity.copyWith(title: 'null', fullDay: true);

        final saveTime = aDay.previousDay();
        final timeIntervall = TimeInterval(
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
                timeIntervall,
              ),
              UnstoredActivityState(
                activity,
                timeIntervall,
              ),
            ],
          ),
        );
        editActivityCubit.changeDate(saveTime);
        editActivityCubit.replaceActivity(activity);

        // Assert
        await expected1;
        final expected2 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeIntervall,
              saveTime,
            ),
          ),
        );

        wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            saveErrors: const {SaveError.unconfirmedStartTimeBeforeNow},
            sucessfullSave: false,
          ),
        );
        wizCubit.next(warningConfirmed: true);
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            sucessfullSave: true,
          ),
        );

        // Assert
        await expected2;
      });

      test('Trying to save new recurring before now yields warning', () async {
        // Arrange
        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultAlarmTypeSetting: noAlarm,
          calendarId: calendarId,
        );
        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime.add(1.hours())),
          settings: const MemoplannerSettingsLoaded(
            MemoplannerSettings(
              editActivity: EditActivitySettings(template: false),
            ),
          ),
        );

        // Act
        final originalActivity = editActivityCubit.state.activity;
        final activity1 = originalActivity.copyWith(title: 'null');
        final activity2 = activity1.copyWith(recurs: Recurs.everyDay);
        final time = TimeOfDay.fromDateTime(aTime);
        final timeIntervall = TimeInterval(
          startTime: time,
          endTime: time,
          startDate: aDay,
        );

        final expectedActivity = activity2.copyWith(startTime: aTime);

        final expected1 = expectLater(
            editActivityCubit.stream,
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
            ]));

        editActivityCubit.changeTimeInterval(startTime: time);
        editActivityCubit.replaceActivity(activity1);
        editActivityCubit.replaceActivity(activity2);

        // Assert
        await expected1;

        final expected2 = expectLater(
            editActivityCubit.stream,
            emits(
              StoredActivityState(
                expectedActivity,
                timeIntervall,
                aDay,
              ),
            ));

        wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            saveErrors: const {SaveError.unconfirmedStartTimeBeforeNow},
            sucessfullSave: false,
          ),
        );
        wizCubit.next(warningConfirmed: true);
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            sucessfullSave: true,
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

        final expectedTimeIntervall = TimeInterval(
          startTime: TimeOfDay.fromDateTime(aTime),
          startDate: aDay,
        );

        final activityWithNewTitle = activity.copyWith(title: 'new title');

        final expetedActivityToSave =
            activityWithNewTitle.copyWith(startTime: activity.startClock(aDay));

        final expected1 = expectLater(
            editActivityCubit.stream,
            emits(
              StoredActivityState(
                activityWithNewTitle,
                expectedTimeIntervall,
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
              expetedActivityToSave,
              expectedTimeIntervall,
              aDay,
            )));

        // Act
        wizCubit.next();

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
            sucessfullSave: false,
          ),
        );

        // Act
        wizCubit.next(
            warningConfirmed: true,
            saveRecurring: SaveRecurring(ApplyTo.onlyThisDay, aDay));
        // Assert
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            sucessfullSave: true,
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
        final mockActivitiesBloc = MockActivitiesBloc();
        when(() => mockActivitiesBloc.state)
            .thenReturn(ActivitiesLoaded([stored]));
        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultAlarmTypeSetting: noAlarm,
          calendarId: calendarId,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime.subtract(1.hours())),
          settings: const MemoplannerSettingsLoaded(
            MemoplannerSettings(
              editActivity: EditActivitySettings(template: false),
            ),
          ),
        );

        // Act
        final originalActivity = editActivityCubit.state.activity;
        final activity = originalActivity.copyWith(title: 'null');
        final time = TimeOfDay.fromDateTime(aTime);
        final timeIntervall = TimeInterval(
          startTime: time,
          endTime: time,
          startDate: aDay,
        );
        final expectedActivity = activity.copyWith(startTime: aTime);
        final expected1 = expectLater(
            editActivityCubit.stream,
            emitsInOrder([
              UnstoredActivityState(
                originalActivity,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity,
                timeIntervall,
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
              timeIntervall,
              aDay,
            ),
          ),
        );

        wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            saveErrors: const {SaveError.unconfirmedActivityConflict},
            sucessfullSave: false,
          ),
        );

        wizCubit.next(warningConfirmed: true);
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            sucessfullSave: true,
          ),
        );

        // Assert
        await expected2;
      });

      test('Trying to save with conflict and before now yields warnings',
          () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(() => mockActivitiesBloc.state)
            .thenReturn(ActivitiesLoaded([stored]));
        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultAlarmTypeSetting: noAlarm,
          calendarId: calendarId,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime.add(1.hours())),
          settings: const MemoplannerSettingsLoaded(
            MemoplannerSettings(
              editActivity: EditActivitySettings(template: false),
            ),
          ),
        );

        // Act
        final originalActivity = editActivityCubit.state.activity;
        final activity = originalActivity.copyWith(title: 'null');
        final time = TimeOfDay.fromDateTime(aTime);
        final timeIntervall = TimeInterval(
          startTime: time,
          endTime: time,
          startDate: aDay,
        );
        final expectedActivity = activity.copyWith(startTime: aTime);

        final expected1 = expectLater(
            editActivityCubit.stream,
            emitsInOrder([
              UnstoredActivityState(originalActivity, timeIntervall),
              UnstoredActivityState(
                activity,
                timeIntervall,
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
              timeIntervall,
              aDay,
            ),
          ),
        );

        wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            saveErrors: const {
              SaveError.unconfirmedActivityConflict,
              SaveError.unconfirmedStartTimeBeforeNow,
            },
            sucessfullSave: false,
          ),
        );
        wizCubit.next(warningConfirmed: true);
        expect(
          wizCubit.state,
          WizardState(
            0,
            const [WizardStep.advance],
            sucessfullSave: true,
          ),
        );

        await expected2;
      });

      test('No self conflicts', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(() => mockActivitiesBloc.state)
            .thenReturn(ActivitiesLoaded([stored]));
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
        final timeIntervall = TimeInterval(
          startTime: time,
          startDate: aDay,
        );
        final expectedActivity = titleChanged.copyWith(startTime: aTime);

        final expected1 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              titleChanged,
              timeIntervall,
              aDay,
            ),
          ),
        );
        editActivityCubit.replaceActivity(titleChanged);

        // Assert
        await expected1;

        wizCubit.next();

        expect(
          wizCubit.state,
          WizardState(0, const [WizardStep.advance], sucessfullSave: true),
        );

        expect(
          editActivityCubit.state,
          StoredActivityState(
            expectedActivity,
            timeIntervall,
            aDay,
          ),
        );
      });

      test('no conflict for fullday', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(() => mockActivitiesBloc.state)
            .thenReturn(ActivitiesLoaded([stored]));

        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultAlarmTypeSetting: noAlarm,
          calendarId: calendarId,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime),
          settings: const MemoplannerSettingsLoaded(
            MemoplannerSettings(
              editActivity: EditActivitySettings(template: false),
            ),
          ),
        );

        // Act
        final originalActivity = editActivityCubit.state.activity;
        final activity = originalActivity.copyWith(
          title: 'null',
          fullDay: true,
          alarmType: noAlarm,
        );
        final timeIntervall = TimeInterval(
          startDate: aDay,
        );
        final expectedActivity = activity.copyWith(startTime: aDay);

        final expected1 = expectLater(
            editActivityCubit.stream,
            emits(
              UnstoredActivityState(
                activity,
                timeIntervall,
              ),
            ));
        editActivityCubit.replaceActivity(activity);

        // Assert
        await expected1;
        final expected2 = expectLater(
            editActivityCubit.stream,
            emits(StoredActivityState(
              expectedActivity,
              timeIntervall,
              aDay,
            )));

        wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(0, const [WizardStep.advance], sucessfullSave: true),
        );
        await expected2;
      });

      test('no conflict for recuring', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(() => mockActivitiesBloc.state)
            .thenReturn(ActivitiesLoaded([stored]));
        final editActivityCubit = EditActivityCubit.newActivity(
          day: aDay,
          defaultAlarmTypeSetting: noAlarm,
          calendarId: calendarId,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityCubit: editActivityCubit,
          clockBloc: ClockBloc.fixed(aTime.subtract(1.hours())),
          settings: const MemoplannerSettingsLoaded(
            MemoplannerSettings(
              editActivity: EditActivitySettings(template: false),
            ),
          ),
        );

        // Act
        final originalActivity = editActivityCubit.state.activity;
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
        final expected1 = expectLater(
          editActivityCubit.stream,
          emitsInOrder(
            [
              UnstoredActivityState(
                originalActivity,
                timeIntervall,
              ),
              UnstoredActivityState(
                activity,
                timeIntervall,
              ),
            ],
          ),
        );
        editActivityCubit.changeTimeInterval(startTime: time);
        editActivityCubit.replaceActivity(activity);

        // Assert
        await expected1;
        final expected2 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeIntervall,
              aDay,
            ),
          ),
        );
        wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(0, const [WizardStep.advance], sucessfullSave: true),
        );

        await expected2;
      });

      test('No conflicts when edit but not time', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final stored2 = Activity.createNew(title: 'stored2', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(() => mockActivitiesBloc.state)
            .thenReturn(ActivitiesLoaded([stored, stored2]));

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
        final timeIntervall = TimeInterval(
          startTime: time,
          startDate: aDay,
        );
        final expectedActivity = titleChanged.copyWith(startTime: aTime);

        final expected1 = expectLater(
          editActivityCubit.stream,
          emits(
            StoredActivityState(
              titleChanged,
              timeIntervall,
              aDay,
            ),
          ),
        );
        editActivityCubit.replaceActivity(titleChanged);

        // Assert
        await expected1;

        wizCubit.next();
        expect(
          wizCubit.state,
          WizardState(0, const [WizardStep.advance], sucessfullSave: true),
        );

        expect(
          editActivityCubit.state,
          StoredActivityState(
            expectedActivity,
            timeIntervall,
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

    final expectedTimeIntervall = TimeInterval(
      startDate: aDay,
      startTime: TimeOfDay.fromDateTime(aTime),
    );
    final recurringActivity = activity.copyWith(
      recurs: Recurs.weeklyOnDay(aTime.weekday),
    );

    final expected1 = expectLater(
      editActivityCubit.stream,
      emits(
        StoredActivityState(
          recurringActivity,
          expectedTimeIntervall,
          aDay,
        ),
      ),
    );

    // Act
    editActivityCubit.replaceActivity(recurringActivity);

    // Assert
    await expected1;

    wizCubit.next();
    expect(
      wizCubit.state,
      WizardState(0, const [WizardStep.advance], sucessfullSave: true),
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
    final mockActivitiesBloc = MockActivitiesBloc();
    when(() => mockActivitiesBloc.state)
        .thenReturn(ActivitiesLoaded([activity]));

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
    final expetedActivityToSave =
        activityWithNewTitle.copyWith(startTime: activity.startClock(aDay));
    final expected1 = expectLater(
        editActivityCubit.stream,
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
    editActivityCubit.replaceActivity(activityWithNewTitle);

    // Assert
    await expected1;

    // Act
    wizCubit.next(saveRecurring: SaveRecurring(ApplyTo.onlyThisDay, aDay));

    // Assert - correct day is saved
    await untilCalled(() => mockActivitiesBloc.add(any()));
    expect(
      verify(() => mockActivitiesBloc.add(captureAny())).captured.single,
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
    when(() => mockActivitiesBloc.state)
        .thenReturn(ActivitiesLoaded([activity]));

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
    editActivityCubit.replaceActivity(
        activity.copyWith(recurs: Recurs.yearly(activity.startTime)));
    editActivityCubit.changeDate(nextDay);

    wizCubit.next(saveRecurring: SaveRecurring(ApplyTo.onlyThisDay, aDay));

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
        defaultAlarmTypeSetting: noAlarm,
        calendarId: calendarId,
      );

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        settings: const MemoplannerSettingsLoaded(
          MemoplannerSettings(addActivityTypeAdvanced: false),
        ),
      );

      expect(
        wizCubit.state,
        WizardState(
          0,
          const [
            WizardStep.date,
            WizardStep.title,
            WizardStep.image,
            WizardStep.availableFor,
            WizardStep.checkable,
            WizardStep.time,
            WizardStep.recurring,
          ],
        ),
      );
    });

    test('is correct state opposite settings', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: noAlarm,
        calendarId: calendarId,
      );

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        settings: const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            stepByStep: StepByStepSettings(
              datePicker: false,
              image: false,
              title: false,
              type: true,
              availability: false,
              checkable: false,
              removeAfter: true,
              alarm: true,
              notes: true,
              reminders: true,
            ),
            addActivity: AddActivitySettings(addRecurringActivity: false),
          ),
        ),
      );

      expect(
        wizCubit.state,
        WizardState(
          0,
          const [
            WizardStep.type,
            WizardStep.deleteAfter,
            WizardStep.time,
            WizardStep.alarm,
            WizardStep.connectedFunction,
            WizardStep.reminder,
          ],
        ),
      );
    });

    test('all except title steps off', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: noAlarm,
        calendarId: calendarId,
      );

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        settings: const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            stepByStep: StepByStepSettings(
              template: false,
              datePicker: false,
              image: false,
              title: true,
              type: false,
              availability: false,
              checkable: false,
              removeAfter: false,
              alarm: false,
              checklist: false,
              notes: false,
              reminders: false,
            ),
            addActivity: AddActivitySettings(addRecurringActivity: false),
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
          ],
        ),
      );
    });

    const allWizStepsSettings = MemoplannerSettings(
      addActivityTypeAdvanced: false,
      stepByStep: StepByStepSettings(
        template: true,
        datePicker: true,
        image: true,
        title: true,
        type: true,
        availability: true,
        checkable: true,
        removeAfter: true,
        alarm: true,
        checklist: true,
        notes: true,
        reminders: true,
      ),
      addActivity: AddActivitySettings(addRecurringActivity: true),
    );

    const allWizStep = [
      WizardStep.date,
      WizardStep.title,
      WizardStep.image,
      WizardStep.type,
      WizardStep.availableFor,
      WizardStep.checkable,
      WizardStep.deleteAfter,
      WizardStep.time,
      WizardStep.alarm,
      WizardStep.connectedFunction,
      WizardStep.reminder,
      WizardStep.recurring,
    ];

    test('all steps on', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: noAlarm,
        calendarId: calendarId,
      );

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        settings: const MemoplannerSettingsLoaded(allWizStepsSettings),
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
        defaultAlarmTypeSetting: noAlarm,
        calendarId: calendarId,
      );
      final activity = editActivityCubit.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        settings: const MemoplannerSettingsLoaded(allWizStepsSettings),
      );

      expect(
        wizCubit.state,
        WizardState(
          0,
          allWizStep,
        ),
      );
      wizCubit.next(); // date
      wizCubit.next(); // title
      wizCubit.next(); // image ---> error

      expect(
        wizCubit.state,
        WizardState(
          2,
          allWizStep,
          saveErrors: const {SaveError.noTitleOrImage},
          sucessfullSave: false,
        ),
      );

      editActivityCubit.replaceActivity(
        activity.copyWith(title: 'one title please'),
      );

      wizCubit.next(); // title
      wizCubit.next(); // type
      wizCubit.next(); // availible for
      wizCubit.next(); // checkable
      wizCubit.next(); // delete after
      wizCubit.next(); // time ---> error

      expect(
        wizCubit.state,
        WizardState(
          7,
          allWizStep,
          saveErrors: const {SaveError.noStartTime},
          sucessfullSave: false,
        ),
      );

      editActivityCubit.changeTimeInterval(
          startTime: const TimeOfDay(hour: 4, minute: 4));

      wizCubit.next(); // time
      wizCubit.next(); // alarm,
      wizCubit.next(); // note,
      wizCubit.next(); // reminder,
      wizCubit.next(); // recurring,

      expect(
        wizCubit.state,
        WizardState(
          11,
          allWizStep,
          sucessfullSave: true,
        ),
      );
    });

    test('Can remove and add time step', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: noAlarm,
        calendarId: calendarId,
      );
      final activity = editActivityCubit.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        settings: const MemoplannerSettingsLoaded(allWizStepsSettings),
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
            WizardStep.date,
            WizardStep.title,
            WizardStep.image,
            WizardStep.type,
            WizardStep.availableFor,
            WizardStep.checkable,
            WizardStep.deleteAfter,
            WizardStep.connectedFunction,
            WizardStep.recurring,
          ]),
          WizardState(0, allWizStep),
        ]),
      );
    });

    test('Changing recurring changes wizard steps', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: noAlarm,
        calendarId: calendarId,
      );
      final activity = editActivityCubit.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        settings: const MemoplannerSettingsLoaded(allWizStepsSettings),
      );

      editActivityCubit
          .replaceActivity(activity.copyWith(recurs: Recurs.monthly(aDay.day)));
      editActivityCubit.replaceActivity(
          activity.copyWith(recurs: Recurs.weeklyOnDay(aDay.weekday)));
      editActivityCubit.replaceActivity(activity.copyWith(recurs: Recurs.not));
      await expectLater(
        wizCubit.stream,
        emitsInOrder([
          WizardState(0, const [...allWizStep, WizardStep.recursMonthly]),
          WizardState(0, const [...allWizStep, WizardStep.recursWeekly]),
          WizardState(0, allWizStep),
        ]),
      );
    });

    test('Saving recuring weekly without any days yeilds warning', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: noAlarm,
        calendarId: calendarId,
      );
      final activity = editActivityCubit.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        settings: const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            stepByStep: StepByStepSettings(
              template: false,
              datePicker: false,
              image: false,
              title: false,
              type: false,
              availability: false,
              checkable: false,
              removeAfter: false,
              alarm: false,
              checklist: false,
              notes: false,
              reminders: false,
            ),
            addActivity: AddActivitySettings(addRecurringActivity: true),
          ),
        ),
      );

      editActivityCubit.changeTimeInterval(
          startTime: const TimeOfDay(hour: 22, minute: 22));

      editActivityCubit.replaceActivity(activity.copyWith(
          title: 'titlte', recurs: Recurs.weeklyOnDays(const [])));

      await expectLater(
        wizCubit.stream,
        emitsInOrder([
          WizardState(
            0,
            const [WizardStep.time, WizardStep.recurring],
          ),
          WizardState(
            0,
            const [
              WizardStep.time,
              WizardStep.recurring,
              WizardStep.recursWeekly
            ],
          ),
        ]),
      );

      wizCubit.next();
      wizCubit.next();
      wizCubit.next();

      expect(
        wizCubit.state,
        WizardState(
          2,
          const [
            WizardStep.time,
            WizardStep.recurring,
            WizardStep.recursWeekly
          ],
          saveErrors: const {SaveError.noRecurringDays},
          sucessfullSave: false,
        ),
      );
    });

    test(
        'BUG SGC-1595 '
        'Saving recuring weekly without any days yeilds warning', () async {
      // Arrange
      final editActivityCubit = EditActivityCubit.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: noAlarm,
        calendarId: '',
      );
      final activity = editActivityCubit.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        settings: const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            stepByStep: StepByStepSettings(
              template: false,
              title: false,
              image: false,
              datePicker: false,
              type: false,
              availability: false,
              checkable: false,
              removeAfter: false,
              alarm: false,
              checklist: false,
              notes: false,
              reminders: false,
            ),
            addActivity: AddActivitySettings(addRecurringActivity: true),
          ),
        ),
      );

      editActivityCubit.changeDate(nowTime.add(7.days()).onlyDays());
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

      await expectLater(
        wizCubit.stream,
        emitsInOrder([
          WizardState(
            0,
            const [
              WizardStep.time,
              WizardStep.recurring,
            ],
          ),
          WizardState(
            0,
            const [
              WizardStep.time,
              WizardStep.recurring,
              WizardStep.recursWeekly,
              WizardStep.endDate,
            ],
          ),
        ]),
      );

      wizCubit.next();
      wizCubit.next();
      wizCubit.next();
      wizCubit.next();

      expect(
        wizCubit.state,
        WizardState(
          3,
          const [
            WizardStep.time,
            WizardStep.recurring,
            WizardStep.recursWeekly,
            WizardStep.endDate,
          ],
          saveErrors: const {SaveError.endDateBeforeStart},
          sucessfullSave: false,
        ),
      );
    });
  });
}
