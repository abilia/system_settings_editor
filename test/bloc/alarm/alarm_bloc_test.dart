import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks.dart';

void main() {
  ClockBloc clockBloc;
  ActivitiesBloc activitiesBloc;
  AlarmBloc alarmBloc;
  final thisMinute = DateTime(2006, 06, 06, 06, 06).onlyMinutes();
  final nextMinute = thisMinute.add(Duration(minutes: 1));
  final inTwoMin = thisMinute.add(Duration(minutes: 2));
  final day = thisMinute.onlyDays();
  MockActivityRepository mockActivityRepository;
  StreamController<DateTime> mockedTicker;

  Future _tick() async {
    final nextMin = clockBloc?.state?.add(Duration(minutes: 1));
    if (nextMin != null) {
      mockedTicker?.add(nextMin);
      await clockBloc.firstWhere((d) => d == nextMin);
    }
  }

  setUp(() {
    mockedTicker = StreamController<DateTime>();
    clockBloc = ClockBloc(mockedTicker.stream, initialTime: thisMinute);
    mockActivityRepository = MockActivityRepository();
    activitiesBloc = ActivitiesBloc(
      activityRepository: mockActivityRepository,
      syncBloc: MockSyncBloc(),
      pushBloc: MockPushBloc(),
    );
    alarmBloc = AlarmBloc(clockBloc: clockBloc, activitiesBloc: activitiesBloc);
  });

  test('Load activities with current alarm shows alarm', () async {
    // Arrange
    final nowActivity = FakeActivity.starts(nextMinute);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([nowActivity]));
    // Act
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
    await _tick();
    // Assert
    await expectLater(
      alarmBloc,
      emits(AlarmState(StartAlarm(nowActivity, day))),
    );
  });

  test('Ticks before Load activities does nothing', () async {
    // Arrange
    final nowActivity = FakeActivity.starts(thisMinute);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([nowActivity]));
    // Act
    await _tick();
    await _tick();
    await _tick();
    await _tick();
    await _tick();
    // https://github.com/felangel/bloc/issues/1943
    // ignore: unawaited_futures
    alarmBloc.close();
    // Assert
    await expectLater(
      alarmBloc,
      neverEmits(AlarmState(StartAlarm(nowActivity, day))),
    );
  });

  test('Does not show if clock is not on start time', () async {
    // Arrange
    final soonActivity = FakeActivity.starts(thisMinute);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([soonActivity]));
    // Act
    await _tick();
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.any((s) => s is ActivitiesLoaded);
    // ignore: unawaited_futures
    alarmBloc.close();
    // Assert
    await expectLater(
      alarmBloc,
      neverEmits(AlarmState(StartAlarm(soonActivity, day))),
    );
  });

  test('Next minut alarm does nothing', () async {
    // Arrange
    final soonActivity = FakeActivity.starts(nextMinute);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([soonActivity]));
    // Act
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.any((s) => s is ActivitiesLoaded);
    // ignore: unawaited_futures
    alarmBloc.close();
    // Assert
    await expectLater(
      alarmBloc,
      neverEmits(AlarmState(StartAlarm(soonActivity, day))),
    );
  });

  test('Next minut alarm alarm next minute', () async {
    // Arrange
    final soonActivity = FakeActivity.starts(nextMinute);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([soonActivity]));
    // Act
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.any((s) => s is ActivitiesLoaded);
    await _tick();
    // Assert
    await expectLater(
      alarmBloc,
      emits(AlarmState(StartAlarm(soonActivity, day))),
    );
  });

  test('Two activities at the same time emits', () async {
    // Arrange
    final soonActivity = FakeActivity.starts(nextMinute);
    final soonActivity2 = FakeActivity.starts(nextMinute);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([soonActivity, soonActivity2]));
    // Act
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.any((s) => s is ActivitiesLoaded);
    // Assert
    final futureExpect = expectLater(
      alarmBloc,
      emitsInAnyOrder([
        AlarmState(StartAlarm(soonActivity, day)),
        AlarmState(StartAlarm(soonActivity2, day)),
      ]),
    );
    await _tick();
    await futureExpect;
  });

  test('two activities starts in order', () async {
    // Arrange
    final nowActivity = FakeActivity.starts(thisMinute);
    final nextMinActivity = FakeActivity.starts(nextMinute);
    final inTwoMinActivity = FakeActivity.starts(inTwoMin);
    when(mockActivityRepository.load()).thenAnswer(
        (_) => Future.value([inTwoMinActivity, nowActivity, nextMinActivity]));

    // Act
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.any((s) => s is ActivitiesLoaded);
    await _tick();

    // Assert
    await expectLater(
      alarmBloc,
      emits(AlarmState(StartAlarm(nextMinActivity, day))),
    );

    // Act
    await _tick();
    // Assert
    await expectLater(
      alarmBloc,
      emits(AlarmState(StartAlarm(inTwoMinActivity, day))),
    );
  });

  test('Activity with no alarm set does not trigger an alarm', () async {
    // Arrange
    final inOneMinuteWithoutAlarmActivity =
        FakeActivity.starts(thisMinute.add(1.minutes()))
            .copyWith(alarmType: NO_ALARM);
    final inTwoMinutesActivity =
        FakeActivity.starts(nextMinute.add(1.minutes()));
    when(mockActivityRepository.load()).thenAnswer((_) =>
        Future.value([inTwoMinutesActivity, inOneMinuteWithoutAlarmActivity]));
    // Act
    activitiesBloc.add(LoadActivities());
    await _tick();
    await _tick();

    // Assert
    await expectLater(
        alarmBloc, emits(AlarmState(StartAlarm(inTwoMinutesActivity, day))));
  });

  test('Recurring weekly alarms shows', () async {
    // Arrange
    final recursThursday = FakeActivity.reocurrsTuedays(nextMinute);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([recursThursday]));
    // Act
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.any((s) => s is ActivitiesLoaded);
    await _tick();
    // Assert
    await expectLater(
        alarmBloc, emits(AlarmState(StartAlarm(recursThursday, day))));
  });

  test('Recurring monthly alarms shows', () async {
    // Arrange
    final recursTheThisDayOfMonth = FakeActivity.reocurrsOnDay(
        nextMinute.day,
        nextMinute.subtract(Duration(days: 60)),
        nextMinute.add(Duration(days: 60)));
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([recursTheThisDayOfMonth]));
    // Act
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.any((s) => s is ActivitiesLoaded);
    await _tick();
    // Assert
    await expectLater(
        alarmBloc, emits(AlarmState(StartAlarm(recursTheThisDayOfMonth, day))));
  });

  test('Recurring yearly alarms shows', () async {
    // Arrange
    final recursTheThisDayOfYear = FakeActivity.reocurrsOnDate(nextMinute);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([recursTheThisDayOfYear]));
    // Act
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.any((s) => s is ActivitiesLoaded);
    await _tick();
    // Assert
    await expectLater(
        alarmBloc, emits(AlarmState(StartAlarm(recursTheThisDayOfYear, day))));
  });

  test('Alarm on EndTime shows', () async {
    // Arrange
    final activityEnding = FakeActivity.ends(nextMinute);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([activityEnding]));
    // Act
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.any((s) => s is ActivitiesLoaded);
    await _tick();
    // Assert
    await expectLater(
        alarmBloc,
        emits(
          AlarmState(EndAlarm(activityEnding, day)),
        ));
  });

  test(
      'Alarm on EndTime does not show when it has no end time (start time is same as end time)',
      () async {
    // Arrange
    final nextAlarm = FakeActivity.starts(nextMinute, duration: Duration.zero);
    final afterThatAlarm =
        FakeActivity.starts(inTwoMin, duration: Duration.zero);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([nextAlarm, afterThatAlarm]));
    // Act
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.any((s) => s is ActivitiesLoaded);
    await _tick();

    // Assert
    await expectLater(alarmBloc, emits(AlarmState(StartAlarm(nextAlarm, day))));

    // Act
    await _tick();
    await expectLater(
        alarmBloc, emits(AlarmState(StartAlarm(afterThatAlarm, day))));
  });

  test('Reminders shows', () async {
    // Arrange
    final reminderTime = Duration(hours: 1);
    final remind1HourBefore = FakeActivity.starts(nextMinute.add(reminderTime))
        .copyWith(reminderBefore: [reminderTime.inMilliseconds]);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([remind1HourBefore]));
    // Act
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.any((s) => s is ActivitiesLoaded);
    await _tick();
    // Assert
    await expectLater(
      alarmBloc,
      emits(
        AlarmState(
            ReminderBefore(remind1HourBefore, day, reminder: reminderTime)),
      ),
    );
  });

  tearDown(() {
    activitiesBloc.close();
    clockBloc.close();
    mockedTicker.close();
    alarmBloc.close();
  });
}
