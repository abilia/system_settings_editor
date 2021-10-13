import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull/bloc/activities/activities_bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../fakes/fakes_blocs.dart';
import '../../../mocks/mock_bloc.dart';

void main() {
  late MockActivitiesBloc mockActivitiesBloc;
  late ClockBloc clockBloc;
  final nowTime = DateTime(2000, 02, 22, 22, 30);
  final aTime = DateTime(2022, 02, 22, 22, 30);
  final aDay = DateTime(2022, 02, 22);

  setUpAll(() {
    registerFallbackValue(ActivitiesNotLoaded());
    registerFallbackValue(LoadActivities());
    tz.initializeTimeZones();
  });

  setUp(() {
    mockActivitiesBloc = MockActivitiesBloc();
    when(() => mockActivitiesBloc.state)
        .thenAnswer((_) => ActivitiesNotLoaded());

    clockBloc =
        ClockBloc(StreamController<DateTime>().stream, initialTime: nowTime);
  });

  test('Initial edit state is', () {
    // Arrange
    final activityWizardCubit = ActivityWizardCubit.edit(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityBloc: FakeEditActivityBloc(),
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: false),
      ),
    );

    expect(activityWizardCubit.state,
        ActivityWizardState(0, UnmodifiableListView([WizardStep.advance])));
  });

  test('Initial new with default settings', () {
    // Arrange
    final activityWizardCubit = ActivityWizardCubit.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityBloc: FakeEditActivityBloc(),
      clockBloc: clockBloc,
      settings: MemoplannerSettingsNotLoaded(),
    );

    expect(
      activityWizardCubit.state,
      ActivityWizardState(
        0,
        UnmodifiableListView(
          [
            WizardStep.basic,
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
      editActivityBloc: EditActivityBloc.newActivity(
          day: aDay, defaultAlarmTypeSetting: NO_ALARM),
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
        MemoplannerSettings(addActivityTypeAdvanced: false),
      ),
    );

    expect(
      activityWizardCubit.state,
      ActivityWizardState(
        0,
        UnmodifiableListView(
          [
            WizardStep.basic,
            WizardStep.date,
            WizardStep.title,
            WizardStep.image,
            WizardStep.available_for,
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
      editActivityBloc: FakeEditActivityBloc(),
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: false),
      ),
    );

    expect(
      activityWizardCubit.state,
      ActivityWizardState(
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
    final editActivityBloc = EditActivityBloc.newActivity(
      day: aDay,
      defaultAlarmTypeSetting: NO_ALARM,
    );

    final activityWizardCubit = ActivityWizardCubit.edit(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityBloc: editActivityBloc,
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: false),
      ),
    );

    // Act
    activityWizardCubit.next();

    // Assert
    expect(
      activityWizardCubit.state,
      ActivityWizardState(
          0,
          UnmodifiableListView([
            WizardStep.advance,
          ])).failSave({
        SaveError.NO_TITLE_OR_IMAGE,
        SaveError.NO_START_TIME,
      }),
    );
  });

  test(
      'Trying to save uncompleted activity yields failed save and does not try to save',
      () async {
    // Arrange
    final mockActivitiesBloc = MockActivitiesBloc();
    when(() => mockActivitiesBloc.state).thenReturn(ActivitiesNotLoaded());

    final editActivityBloc = EditActivityBloc.newActivity(
      day: aTime,
      defaultAlarmTypeSetting: NO_ALARM,
    );
    final activityWizardCubit = ActivityWizardCubit.newActivity(
      activitiesBloc: mockActivitiesBloc,
      editActivityBloc: editActivityBloc,
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
        MemoplannerSettings(advancedActivityTemplate: false),
      ),
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
    activityWizardCubit.next();
    expect(
      activityWizardCubit.state,
      ActivityWizardState(
        0,
        [WizardStep.advance],
        saveErrors: {
          SaveError.NO_TITLE_OR_IMAGE,
          SaveError.NO_START_TIME,
        },
        sucessfullSave: false,
      ),
    );

    // Act
    editActivityBloc.add(ReplaceActivity(activityWithTitle));
    await expectLater(
      editActivityBloc.stream,
      emits(
        UnstoredActivityState(activityWithTitle, timeInterval),
      ),
    );

    // Act
    activityWizardCubit.next();
    expect(
      activityWizardCubit.state,
      ActivityWizardState(
        0,
        [WizardStep.advance],
        saveErrors: {
          SaveError.NO_START_TIME,
        },
      ),
    );

    editActivityBloc.add(ChangeTimeInterval(startTime: newStartTime));
    await expectLater(
      editActivityBloc.stream,
      emits(
        UnstoredActivityState(activityWithTitle, newTimeInterval),
      ),
    );
    // Act
    activityWizardCubit.next();
    expect(
      activityWizardCubit.state,
      ActivityWizardState(
        0,
        [WizardStep.advance],
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

    final editActivityBloc = EditActivityBloc.edit(
      ActivityDay(activity, aDay),
    );
    final activityWizardCubit = ActivityWizardCubit.edit(
      activitiesBloc: mockActivitiesBloc,
      editActivityBloc: editActivityBloc,
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: false),
      ),
    );

    final timeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(activity.startTime),
      endTime: TimeOfDay.fromDateTime(activity.noneRecurringEnd),
      startDate: aTime,
    );

    final wizState = ActivityWizardState(0, [WizardStep.advance]);

    // Act
    editActivityBloc.add(ReplaceActivity(activityAsFullDay));
    // Assert
    await expectLater(
      editActivityBloc.stream,
      emits(StoredActivityState(activityAsFullDay, timeInterval, aDay)),
    );
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

    final editActivityBloc = EditActivityBloc.newActivity(
      day: aDate,
      defaultAlarmTypeSetting: NO_ALARM,
    );

    final wizCubit = ActivityWizardCubit.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityBloc: editActivityBloc,
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
          MemoplannerSettings(advancedActivityTemplate: false)),
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
    // Act
    wizCubit.next();
    // Assert
    expect(
      wizCubit.state,
      ActivityWizardState(
        0,
        [WizardStep.advance],
        sucessfullSave: true,
      ),
    );

    expect(
      editActivityBloc.stream,
      emits(
        StoredActivityState(
          expectedFinalActivity,
          expectedTimeInterval2,
          expectedFinalStartTime.onlyDays(),
        ),
      ),
    );
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
        endTime:
            TimeOfDay.fromDateTime(activity.startTime.add(expectedDuration)),
        startDate: aDay,
      );

      final editActivityBloc = EditActivityBloc.edit(
        ActivityDay(activity, aDay),
      );

      final wizCubit = ActivityWizardCubit.edit(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityBloc: editActivityBloc,
        clockBloc: clockBloc,
        settings: MemoplannerSettingsLoaded(
          MemoplannerSettings(activityTimeBeforeCurrent: true),
        ),
      );

      // Assert
      expect(
        editActivityBloc.state,
        StoredActivityState(activity, expectedTimeInterval, aDay),
      );

      // Act
      editActivityBloc.add(ChangeTimeInterval(endTime: newEndTime));

      // Assert
      await expectLater(
        editActivityBloc.stream,
        emits(
          StoredActivityState(activity, expectedNewTimeInterval, aDay),
        ),
      );

      wizCubit.next();

      expect(
        wizCubit.state,
        ActivityWizardState(
          0,
          [WizardStep.advance],
          sucessfullSave: true,
        ),
      );

      await expectLater(
        editActivityBloc.stream,
        emits(
          StoredActivityState(
              expetedNewActivity, expectedNewTimeInterval, aDay),
        ),
      );
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

    final editActivityBloc = EditActivityBloc.edit(
      ActivityDay(activity, aDay),
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesBloc: FakeActivitiesBloc(),
      clockBloc: clockBloc,
      editActivityBloc: editActivityBloc,
      settings: MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: true),
      ),
    );

    // Assert
    expect(editActivityBloc.state,
        StoredActivityState(activity, expectedTimeInterval, aDay));

    // Act
    editActivityBloc.add(ChangeTimeInterval(endTime: newEndTime));

    // Assert
    await expectLater(
      editActivityBloc.stream,
      emits(
        StoredActivityState(activity, expectedNewTimeInterval, aDay),
      ),
    );

    wizCubit.next();
    expect(
      wizCubit.state,
      ActivityWizardState(0, [WizardStep.advance], sucessfullSave: true),
    );

    // Assert
    await expectLater(
      editActivityBloc.stream,
      emits(
        StoredActivityState(expetedNewActivity, expectedNewTimeInterval, aDay),
      ),
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

    final editActivityBloc = EditActivityBloc.edit(
      ActivityDay(activity, aDay),
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityBloc: editActivityBloc,
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: true),
      ),
    );

    // Assert
    expect(editActivityBloc.state,
        StoredActivityState(activity, expectedTimeInterval, aDay));

    // Act
    editActivityBloc.add(ChangeTimeInterval(
        startTime: TimeOfDay.fromDateTime(activity.startTime), endTime: null));

    // Assert
    await expectLater(
      editActivityBloc.stream,
      emits(StoredActivityState(activity, expectedNewTimeInterval, aDay)),
    );

    // Act
    wizCubit.next();

    // Assert
    expect(
      wizCubit.state,
      ActivityWizardState(
        0,
        [WizardStep.advance],
        sucessfullSave: true,
      ),
    );

    await expectLater(
      editActivityBloc.stream,
      emits(StoredActivityState(
          expectedNewActivity, expectedNewTimeInterval, aDay)),
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
    final editActivityBloc = EditActivityBloc.edit(
      activityDay,
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesBloc: mockActivitiesBloc,
      editActivityBloc: editActivityBloc,
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: true),
      ),
    );

    // Act
    editActivityBloc.add(ChangeInfoItemType(Checklist));

    // Assert
    await expectLater(
      editActivityBloc.stream,
      emits(
        StoredActivityState(
          activityWithEmptyChecklist,
          timeInterval,
          aDay,
        ).copyWith(activityWithEmptyChecklist,
            infoItems: {NoteInfoItem: activity.infoItem}),
      ),
    );

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
        infoItem: Checklist(questions: [Question(id: 0, name: 'name')]));
    final expectedActivity = activity.copyWith(infoItem: InfoItem.none);
    final activityWithEmptyNote = activity.copyWith(infoItem: NoteInfoItem());
    final activityDay = ActivityDay(activity, aDay);
    final timeInterval = TimeInterval(
      startTime: TimeOfDay.fromDateTime(aTime),
      startDate: aTime,
    );
    final editActivityBloc = EditActivityBloc.edit(
      activityDay,
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesBloc: mockActivitiesBloc,
      editActivityBloc: editActivityBloc,
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: true),
      ),
    );

    // Act
    editActivityBloc.add(ChangeInfoItemType(NoteInfoItem));

    // Assert
    await expectLater(
      editActivityBloc.stream,
      emits(
        StoredActivityState(
          activityWithEmptyNote,
          timeInterval,
          aDay,
        ).copyWith(activityWithEmptyNote,
            infoItems: {Checklist: activity.infoItem}),
      ),
    );

    wizCubit.next();

    // Assert
    await untilCalled(() => mockActivitiesBloc.add(any()));
    expect(verify(() => mockActivitiesBloc.add(captureAny())).captured.single,
        UpdateActivity(expectedActivity));
  });

  test('Trying to save recurrance withtout data yeilds error', () async {
    // Arrange
    final editActivityBloc = EditActivityBloc.newActivity(
      day: aDay,
      defaultAlarmTypeSetting: NO_ALARM,
    );

    final wizCubit = ActivityWizardCubit.newActivity(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityBloc: editActivityBloc,
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
          MemoplannerSettings(advancedActivityTemplate: false)),
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
        ]));

    wizCubit.next();

    await expectLater(
      wizCubit.state,
      ActivityWizardState(
        0,
        [WizardStep.advance],
        saveErrors: {SaveError.NO_RECURRING_DAYS},
        sucessfullSave: false,
      ),
    );
  });

  group('warnings', () {
    group('before now', () {
      test('Trying to save before now yields warning', () async {
        // Arrange

        final editActivityBloc = EditActivityBloc.newActivity(
          day: aDay,
          defaultAlarmTypeSetting: NO_ALARM,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityBloc: editActivityBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.add(1.hours())),
          settings: MemoplannerSettingsLoaded(
              MemoplannerSettings(advancedActivityTemplate: false)),
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
            ]));

        wizCubit.next();
        expect(
          wizCubit.state,
          ActivityWizardState(
            0,
            [WizardStep.advance],
            saveErrors: {SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW},
            sucessfullSave: false,
          ),
        );

        wizCubit.next(warningConfirmed: true);
        expect(
          wizCubit.state,
          ActivityWizardState(
            0,
            [WizardStep.advance],
            sucessfullSave: true,
          ),
        );

        // Assert
        await expectLater(
          editActivityBloc.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeIntervall,
              aDay,
            ),
          ),
        );

        expect(
            verify(() => mockActivitiesBloc.add(captureAny())).captured.single,
            AddActivity(expectedActivity));
      });

      test('Trying to save full day before now yields warning', () async {
        // Arrange
        final time = aTime.add(1.days());

        final editActivityBloc = EditActivityBloc.newActivity(
          day: aDay,
          defaultAlarmTypeSetting: NO_ALARM,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityBloc: editActivityBloc,
          clockBloc:
              ClockBloc(StreamController<DateTime>().stream, initialTime: time),
          settings: MemoplannerSettingsLoaded(
              MemoplannerSettings(advancedActivityTemplate: false)),
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

        // Assert
        await expectLater(
          editActivityBloc.stream,
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

        wizCubit.next();
        expect(
          wizCubit.state,
          ActivityWizardState(
            0,
            [WizardStep.advance],
            saveErrors: {SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW},
            sucessfullSave: false,
          ),
        );
        wizCubit.next(warningConfirmed: true);
        expect(
          wizCubit.state,
          ActivityWizardState(
            0,
            [WizardStep.advance],
            sucessfullSave: true,
          ),
        );

        // Assert
        await expectLater(
          editActivityBloc.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeIntervall,
              saveTime,
            ),
          ),
        );
      });

      test('Trying to save new recurring before now yields warning', () async {
        // Arrange
        final editActivityBloc = EditActivityBloc.newActivity(
          day: aDay,
          defaultAlarmTypeSetting: NO_ALARM,
        );
        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityBloc: editActivityBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.add(1.hours())),
          settings: MemoplannerSettingsLoaded(
              MemoplannerSettings(advancedActivityTemplate: false)),
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
            ]));

        wizCubit.next();
        wizCubit.next(warningConfirmed: true);

        wizCubit.next();
        expect(
          wizCubit.state,
          ActivityWizardState(
            0,
            [WizardStep.advance],
            saveErrors: {SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW},
            sucessfullSave: null,
          ),
        );
        wizCubit.next(warningConfirmed: true);
        expect(
          wizCubit.state,
          ActivityWizardState(
            0,
            [WizardStep.advance],
            sucessfullSave: true,
          ),
        );

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emits(
              StoredActivityState(
                expectedActivity,
                timeIntervall,
                aDay,
              ),
            ));
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

        final editActivityBloc = EditActivityBloc.edit(
          ActivityDay(activity, aDay),
        );

        final wizCubit = ActivityWizardCubit.edit(
          activitiesBloc: FakeActivitiesBloc(),
          editActivityBloc: editActivityBloc,
          clockBloc:
              ClockBloc(Stream.empty(), initialTime: aTime.add(1.hours())),
          settings: MemoplannerSettingsLoaded(
            MemoplannerSettings(activityTimeBeforeCurrent: true),
          ),
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

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emits(
              StoredActivityState(
                activityWithNewTitle,
                expectedTimeIntervall,
                aDay,
              ),
            ));

        // Act
        wizCubit.next();

        // Assert
        expect(
          wizCubit.state,
          ActivityWizardState(
            0,
            [WizardStep.advance],
            saveErrors: {
              SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW,
              SaveError.STORED_RECURRING,
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
          ActivityWizardState(
            0,
            [WizardStep.advance],
            sucessfullSave: true,
          ),
        );

        await expectLater(
            editActivityBloc.stream,
            emits(StoredActivityState(
              expetedActivityToSave,
              expectedTimeIntervall,
              aDay,
            )));
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
        final editActivityBloc = EditActivityBloc.newActivity(
          day: aDay,
          defaultAlarmTypeSetting: NO_ALARM,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityBloc: editActivityBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.subtract(1.hours())),
          settings: MemoplannerSettingsLoaded(
              MemoplannerSettings(advancedActivityTemplate: false)),
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
            ]));

        wizCubit.next();
        expect(
          wizCubit.state,
          ActivityWizardState(
            0,
            [WizardStep.advance],
            saveErrors: {SaveError.UNCONFIRMED_ACTIVITY_CONFLICT},
            sucessfullSave: false,
          ),
        );

        wizCubit.next(warningConfirmed: true);
        expect(
          wizCubit.state,
          ActivityWizardState(
            0,
            [WizardStep.advance],
            sucessfullSave: true,
          ),
        );

        // Assert
        await expectLater(
          editActivityBloc.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeIntervall,
              aDay,
            ),
          ),
        );
      });

      test('Trying to save with conflict and before now yields warnings',
          () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(() => mockActivitiesBloc.state)
            .thenReturn(ActivitiesLoaded([stored]));
        final editActivityBloc = EditActivityBloc.newActivity(
          day: aDay,
          defaultAlarmTypeSetting: NO_ALARM,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityBloc: editActivityBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.add(1.hours())),
          settings: MemoplannerSettingsLoaded(
              MemoplannerSettings(advancedActivityTemplate: false)),
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

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emitsInOrder([
              UnstoredActivityState(originalActivity, timeIntervall),
              UnstoredActivityState(
                activity,
                timeIntervall,
              ),
            ]));

        wizCubit.next();
        expect(
          wizCubit.state,
          ActivityWizardState(
            0,
            [WizardStep.advance],
            saveErrors: {
              SaveError.UNCONFIRMED_ACTIVITY_CONFLICT,
              SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW,
            },
            sucessfullSave: false,
          ),
        );
        wizCubit.next(warningConfirmed: true);
        expect(
          wizCubit.state,
          ActivityWizardState(
            0,
            [WizardStep.advance],
            sucessfullSave: true,
          ),
        );

        await expectLater(
          editActivityBloc.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeIntervall,
              aDay,
            ),
          ),
        );
      });

      test('No self conflicts', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(() => mockActivitiesBloc.state)
            .thenReturn(ActivitiesLoaded([stored]));
        final editActivityBloc = EditActivityBloc.edit(
          ActivityDay(stored, aDay),
        );

        final wizCubit = ActivityWizardCubit.edit(
          activitiesBloc: mockActivitiesBloc,
          editActivityBloc: editActivityBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.subtract(1.hours())),
          settings: MemoplannerSettingsLoaded(
            MemoplannerSettings(activityTimeBeforeCurrent: false),
          ),
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

        // Assert
        await expectLater(
          editActivityBloc.stream,
          emits(
            StoredActivityState(
              titleChanged,
              timeIntervall,
              aDay,
            ),
          ),
        );

        wizCubit.next();

        expect(
          wizCubit.state,
          ActivityWizardState(0, [WizardStep.advance], sucessfullSave: true),
        );

        expect(
          editActivityBloc.state,
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

        final editActivityBloc = EditActivityBloc.newActivity(
          day: aDay,
          defaultAlarmTypeSetting: NO_ALARM,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityBloc: editActivityBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime),
          settings: MemoplannerSettingsLoaded(
              MemoplannerSettings(advancedActivityTemplate: false)),
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

        // Assert
        await expectLater(
            editActivityBloc.stream,
            emits(
              UnstoredActivityState(
                activity,
                timeIntervall,
              ),
            ));

        wizCubit.next();
        expect(
          wizCubit.state,
          ActivityWizardState(0, [WizardStep.advance], sucessfullSave: true),
        );
        await expectLater(
            editActivityBloc.stream,
            emits(StoredActivityState(
              expectedActivity,
              timeIntervall,
              aDay,
            )));
      });

      test('no conflict for recuring', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(() => mockActivitiesBloc.state)
            .thenReturn(ActivitiesLoaded([stored]));
        final editActivityBloc = EditActivityBloc.newActivity(
          day: aDay,
          defaultAlarmTypeSetting: NO_ALARM,
        );

        final wizCubit = ActivityWizardCubit.newActivity(
          activitiesBloc: mockActivitiesBloc,
          editActivityBloc: editActivityBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.subtract(1.hours())),
          settings: MemoplannerSettingsLoaded(
              MemoplannerSettings(advancedActivityTemplate: false)),
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

        // Assert
        await expectLater(
          editActivityBloc.stream,
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
        wizCubit.next();
        expect(
          wizCubit.state,
          ActivityWizardState(0, [WizardStep.advance], sucessfullSave: true),
        );

        await expectLater(
          editActivityBloc.stream,
          emits(
            StoredActivityState(
              expectedActivity,
              timeIntervall,
              aDay,
            ),
          ),
        );
      });

      test('No conflicts when edit but not time', () async {
        // Arrange
        final stored = Activity.createNew(title: 'stored', startTime: aTime);
        final stored2 = Activity.createNew(title: 'stored2', startTime: aTime);
        final mockActivitiesBloc = MockActivitiesBloc();
        when(() => mockActivitiesBloc.state)
            .thenReturn(ActivitiesLoaded([stored, stored2]));

        final editActivityBloc = EditActivityBloc.edit(
          ActivityDay(stored, aDay),
        );

        final wizCubit = ActivityWizardCubit.edit(
          activitiesBloc: mockActivitiesBloc,
          editActivityBloc: editActivityBloc,
          clockBloc: ClockBloc(StreamController<DateTime>().stream,
              initialTime: aTime.subtract(1.hours())),
          settings: MemoplannerSettingsLoaded(
            MemoplannerSettings(activityTimeBeforeCurrent: false),
          ),
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

        // Assert
        await expectLater(
          editActivityBloc.stream,
          emits(
            StoredActivityState(
              titleChanged,
              timeIntervall,
              aDay,
            ),
          ),
        );

        wizCubit.next();
        expect(
          wizCubit.state,
          ActivityWizardState(0, [WizardStep.advance], sucessfullSave: true),
        );

        expect(
          editActivityBloc.state,
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
    final editActivityBloc = EditActivityBloc.edit(
      ActivityDay(activity, aDay),
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesBloc: FakeActivitiesBloc(),
      editActivityBloc: editActivityBloc,
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: false),
      ),
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

    // Assert
    await expectLater(
      editActivityBloc.stream,
      emits(
        StoredActivityState(
          recurringActivity,
          expectedTimeIntervall,
          aDay,
        ),
      ),
    );
    wizCubit.next();
    expect(
      wizCubit.state,
      ActivityWizardState(0, [WizardStep.advance], sucessfullSave: true),
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
    when(() => mockActivitiesBloc.state)
        .thenReturn(ActivitiesLoaded([activity]));

    final editActivityBloc = EditActivityBloc.edit(
      ActivityDay(activity, aDay),
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesBloc: mockActivitiesBloc,
      editActivityBloc: editActivityBloc,
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: false),
      ),
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

    final editActivityBloc = EditActivityBloc.edit(
      ActivityDay(activity, aDay),
    );

    final wizCubit = ActivityWizardCubit.edit(
      activitiesBloc: mockActivitiesBloc,
      editActivityBloc: editActivityBloc,
      clockBloc: clockBloc,
      settings: MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: false),
      ),
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

    await expectLater(
        editActivityBloc.stream, emitsInOrder([anything, anything]));

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
      final editActivityBloc = EditActivityBloc.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: NO_ALARM,
      );

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityBloc: editActivityBloc,
        clockBloc: clockBloc,
        settings: MemoplannerSettingsLoaded(
          MemoplannerSettings(addActivityTypeAdvanced: false),
        ),
      );

      expect(
        wizCubit.state,
        ActivityWizardState(
          0,
          [
            WizardStep.basic,
            WizardStep.date,
            WizardStep.title,
            WizardStep.image,
            WizardStep.available_for,
            WizardStep.checkable,
            WizardStep.time,
            WizardStep.recurring,
          ],
        ),
      );
    });

    test('is correct state opposite settings', () async {
      // Arrange
      final editActivityBloc = EditActivityBloc.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: NO_ALARM,
      );

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityBloc: editActivityBloc,
        clockBloc: clockBloc,
        settings: MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizardDatePickerStep: false,
            wizardImageStep: false,
            wizardTitleStep: false,
            wizardTypeStep: true,
            wizardAvailabilityType: false,
            wizardCheckableStep: false,
            wizardRemoveAfterStep: true,
            wizardAlarmStep: true,
            wizardNotesStep: true,
            wizardRemindersStep: true,
            activityRecurringEditable: false,
          ),
        ),
      );

      expect(
        wizCubit.state,
        ActivityWizardState(
          0,
          [
            WizardStep.basic,
            WizardStep.type,
            WizardStep.delete_after,
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
      final editActivityBloc = EditActivityBloc.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: NO_ALARM,
      );

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityBloc: editActivityBloc,
        clockBloc: clockBloc,
        settings: MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizardTemplateStep: false,
            wizardDatePickerStep: false,
            wizardImageStep: false,
            wizardTitleStep: true,
            wizardTypeStep: false,
            wizardAvailabilityType: false,
            wizardCheckableStep: false,
            wizardRemoveAfterStep: false,
            wizardAlarmStep: false,
            wizardChecklistStep: false,
            wizardNotesStep: false,
            wizardRemindersStep: false,
            activityRecurringEditable: false,
          ),
        ),
      );

      expect(
        wizCubit.state,
        ActivityWizardState(
          0,
          [
            WizardStep.title,
            WizardStep.time,
          ],
        ),
      );
    });

    final allWizStepsSettings = MemoplannerSettings(
      addActivityTypeAdvanced: false,
      wizardTemplateStep: true,
      wizardDatePickerStep: true,
      wizardImageStep: true,
      wizardTitleStep: true,
      wizardTypeStep: true,
      wizardAvailabilityType: true,
      wizardCheckableStep: true,
      wizardRemoveAfterStep: true,
      wizardAlarmStep: true,
      wizardChecklistStep: true,
      wizardNotesStep: true,
      wizardRemindersStep: true,
      activityRecurringEditable: true,
    );

    const allWizStep = [
      WizardStep.basic,
      WizardStep.date,
      WizardStep.title,
      WizardStep.image,
      WizardStep.type,
      WizardStep.available_for,
      WizardStep.checkable,
      WizardStep.delete_after,
      WizardStep.time,
      WizardStep.alarm,
      WizardStep.connectedFunction,
      WizardStep.reminder,
      WizardStep.recurring,
    ];

    test('all steps on', () async {
      // Arrange
      final editActivityBloc = EditActivityBloc.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: NO_ALARM,
      );

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityBloc: editActivityBloc,
        clockBloc: clockBloc,
        settings: MemoplannerSettingsLoaded(allWizStepsSettings),
      );

      expect(
        wizCubit.state,
        ActivityWizardState(
          0,
          allWizStep,
        ),
      );
    });

    test('all steps, stepping through all', () async {
      // Arrange
      final editActivityBloc = EditActivityBloc.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: NO_ALARM,
      );
      final activity = editActivityBloc.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityBloc: editActivityBloc,
        clockBloc: clockBloc,
        settings: MemoplannerSettingsLoaded(allWizStepsSettings),
      );

      expect(
        wizCubit.state,
        ActivityWizardState(
          0,
          allWizStep,
        ),
      );
      wizCubit.next(); // basic
      wizCubit.next(); // date
      wizCubit.next(); // title
      wizCubit.next(); // image ---> error

      expect(
        wizCubit.state,
        ActivityWizardState(
          3,
          allWizStep,
          saveErrors: {SaveError.NO_TITLE_OR_IMAGE},
          sucessfullSave: false,
        ),
      );

      editActivityBloc.add(
        ReplaceActivity(activity.copyWith(title: 'one title please')),
      );
      await expectLater(editActivityBloc.stream, emits(anything));
      wizCubit.next(); // title
      wizCubit.next(); // type
      wizCubit.next(); // availible for
      wizCubit.next(); // checkable
      wizCubit.next(); // delete after
      wizCubit.next(); // time ---> error

      expect(
        wizCubit.state,
        ActivityWizardState(
          8,
          allWizStep,
          saveErrors: {SaveError.NO_START_TIME},
          sucessfullSave: false,
        ),
      );

      editActivityBloc
          .add(ChangeTimeInterval(startTime: TimeOfDay(hour: 4, minute: 4)));
      await expectLater(editActivityBloc.stream, emits(anything));
      wizCubit.next(); // time
      wizCubit.next(); // alarm,
      wizCubit.next(); // note,
      wizCubit.next(); // reminder,
      wizCubit.next(); // recurring,

      expect(
        wizCubit.state,
        ActivityWizardState(
          12,
          allWizStep,
          sucessfullSave: true,
        ),
      );
    });

    test('Can remove and add time step', () async {
      // Arrange
      final editActivityBloc = EditActivityBloc.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: NO_ALARM,
      );
      final activity = editActivityBloc.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityBloc: editActivityBloc,
        clockBloc: clockBloc,
        settings: MemoplannerSettingsLoaded(allWizStepsSettings),
      );

      expect(
        wizCubit.state,
        ActivityWizardState(0, allWizStep),
      );

      editActivityBloc.add(ReplaceActivity(activity.copyWith(fullDay: true)));

      editActivityBloc.add(ReplaceActivity(activity.copyWith(fullDay: false)));
      expectLater(
        wizCubit.stream,
        emitsInOrder([
          ActivityWizardState(0, [
            WizardStep.basic,
            WizardStep.date,
            WizardStep.title,
            WizardStep.image,
            WizardStep.type,
            WizardStep.available_for,
            WizardStep.checkable,
            WizardStep.delete_after,
            WizardStep.connectedFunction,
            WizardStep.recurring,
          ]),
          ActivityWizardState(0, allWizStep),
        ]),
      );
    });

    test('Changing recurring changes wizard steps', () async {
      // Arrange
      final editActivityBloc = EditActivityBloc.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: NO_ALARM,
      );
      final activity = editActivityBloc.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityBloc: editActivityBloc,
        clockBloc: clockBloc,
        settings: MemoplannerSettingsLoaded(allWizStepsSettings),
      );

      editActivityBloc.add(
          ReplaceActivity(activity.copyWith(recurs: Recurs.monthly(aDay.day))));
      editActivityBloc.add(ReplaceActivity(
          activity.copyWith(recurs: Recurs.weeklyOnDay(aDay.weekday))));
      editActivityBloc
          .add(ReplaceActivity(activity.copyWith(recurs: Recurs.not)));
      await expectLater(
        wizCubit.stream,
        emitsInOrder([
          ActivityWizardState(0, [...allWizStep, WizardStep.recursMonthly]),
          ActivityWizardState(0, [...allWizStep, WizardStep.recursWeekly]),
          ActivityWizardState(0, allWizStep),
        ]),
      );
    });

    test('Saving recuring weekly without any days yeilds warning', () async {
      // Arrange
      final editActivityBloc = EditActivityBloc.newActivity(
        day: aDay,
        defaultAlarmTypeSetting: NO_ALARM,
      );
      final activity = editActivityBloc.state.activity;

      final wizCubit = ActivityWizardCubit.newActivity(
        activitiesBloc: FakeActivitiesBloc(),
        editActivityBloc: editActivityBloc,
        clockBloc: clockBloc,
        settings: MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizardTemplateStep: false,
            wizardDatePickerStep: false,
            wizardImageStep: false,
            wizardTitleStep: false,
            wizardTypeStep: false,
            wizardAvailabilityType: false,
            wizardCheckableStep: false,
            wizardRemoveAfterStep: false,
            wizardAlarmStep: false,
            wizardChecklistStep: false,
            wizardNotesStep: false,
            wizardRemindersStep: false,
            activityRecurringEditable: true,
          ),
        ),
      );

      editActivityBloc
          .add(ChangeTimeInterval(startTime: TimeOfDay(hour: 22, minute: 22)));

      editActivityBloc.add(ReplaceActivity(
          activity.copyWith(title: 'titlte', recurs: Recurs.weeklyOnDays([]))));

      await expectLater(
        wizCubit.stream,
        emitsInOrder([
          ActivityWizardState(
            0,
            [WizardStep.time, WizardStep.recurring],
          ),
          ActivityWizardState(
            0,
            [WizardStep.time, WizardStep.recurring, WizardStep.recursWeekly],
          ),
        ]),
      );

      wizCubit.next();
      wizCubit.next();
      wizCubit.next();

      expect(
        wizCubit.state,
        ActivityWizardState(
          2,
          [WizardStep.time, WizardStep.recurring, WizardStep.recursWeekly],
          saveErrors: {SaveError.NO_RECURRING_DAYS},
          sucessfullSave: false,
        ),
      );
    });
  });
}
