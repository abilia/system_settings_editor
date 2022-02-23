import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../fakes/fakes_blocs.dart';
import '../../mocks/mocks.dart';

void main() {
  group('When time ticks', () {
    late ClockBloc clockBloc;
    late ActivitiesBloc activitiesBloc;
    late AlarmCubit alarmCubit;
    late MockActivityRepository mockActivityRepository;
    late StreamController<DateTime> mockedTicker;

    final thisMinute = DateTime(2006, 06, 06, 06, 06).onlyMinutes();
    final nextMinute = thisMinute.add(const Duration(minutes: 1));
    final inTwoMin = thisMinute.add(const Duration(minutes: 2));
    final day = thisMinute.onlyDays();

    Future _tick() {
      final nextMin = clockBloc.state.add(const Duration(minutes: 1));
      mockedTicker.add(nextMin);
      return clockBloc.stream.firstWhere((d) => d == nextMin);
    }

    setUp(() {
      mockedTicker = StreamController<DateTime>();
      clockBloc = ClockBloc(mockedTicker.stream, initialTime: thisMinute);
      mockActivityRepository = MockActivityRepository();
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: FakeSyncBloc(),
        pushCubit: FakePushCubit(),
      );
      alarmCubit = AlarmCubit(
        clockBloc: clockBloc,
        activitiesBloc: activitiesBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
      );
    });

    test('Load activities with current alarm shows alarm', () async {
      // Arrange
      final nowActivity = FakeActivity.starts(nextMinute);
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([nowActivity]));
      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.firstWhere((s) => s is ActivitiesLoaded);
      _tick();
      // Assert
      await expectLater(
        alarmCubit.stream,
        emits(StartAlarm(nowActivity, day)),
      );
    });

    test('Ticks before Load activities does nothing', () async {
      // Arrange
      final nowActivity = FakeActivity.starts(thisMinute);
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([nowActivity]));
      // Act
      await _tick();
      await _tick();
      await _tick();
      await _tick();
      await _tick();

      await alarmCubit.close();
      // Assert
      await expectLater(
        alarmCubit.stream,
        neverEmits(StartAlarm(nowActivity, day)),
      );
    });

    test('Does not show if clock is not on start time', () async {
      // Arrange
      final soonActivity = FakeActivity.starts(thisMinute);
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([soonActivity]));
      // Act
      await _tick();
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);

      await alarmCubit.close();
      // Assert
      await expectLater(
        alarmCubit.stream,
        neverEmits(StartAlarm(soonActivity, day)),
      );
    });

    test('Next minut alarm does nothing', () async {
      // Arrange
      final soonActivity = FakeActivity.starts(nextMinute);
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([soonActivity]));
      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      await alarmCubit.close();
      // Assert
      await expectLater(
        alarmCubit.stream,
        neverEmits(StartAlarm(soonActivity, day)),
      );
    });

    test('Next minut alarm alarm next minute', () async {
      // Arrange
      final soonActivity = FakeActivity.starts(nextMinute);
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([soonActivity]));
      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      _tick();
      // Assert
      await expectLater(
        alarmCubit.stream,
        emits(StartAlarm(soonActivity, day)),
      );
    });

    test('Two activities at the same time emits', () async {
      // Arrange
      final soonActivity = FakeActivity.starts(nextMinute);
      final soonActivity2 = FakeActivity.starts(nextMinute);
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([soonActivity, soonActivity2]));
      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      // Assert
      final futureExpect = expectLater(
        alarmCubit.stream,
        emitsInAnyOrder([
          StartAlarm(soonActivity, day),
          StartAlarm(soonActivity2, day),
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
      when(() => mockActivityRepository.load()).thenAnswer((_) =>
          Future.value([inTwoMinActivity, nowActivity, nextMinActivity]));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      _tick();

      // Assert
      await expectLater(
        alarmCubit.stream,
        emits(StartAlarm(nextMinActivity, day)),
      );

      // Act
      _tick();
      // Assert
      await expectLater(
        alarmCubit.stream,
        emits(StartAlarm(inTwoMinActivity, day)),
      );
    });

    test('Activity with no alarm set does not trigger an alarm', () async {
      // Arrange
      final inOneMinuteWithoutAlarmActivity =
          FakeActivity.starts(thisMinute.add(1.minutes()))
              .copyWith(alarmType: noAlarm);
      final inTwoMinutesActivity =
          FakeActivity.starts(nextMinute.add(1.minutes()));
      when(() => mockActivityRepository.load()).thenAnswer((_) => Future.value(
          [inTwoMinutesActivity, inOneMinuteWithoutAlarmActivity]));
      // Act
      activitiesBloc.add(LoadActivities());
      await _tick();
      _tick();

      // Assert
      await expectLater(
          alarmCubit.stream, emits(StartAlarm(inTwoMinutesActivity, day)));
    });

    test('Recurring weekly alarms shows', () async {
      // Arrange
      final recursThursday = FakeActivity.reocurrsTuedays(nextMinute);
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([recursThursday]));
      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      _tick();
      // Assert
      await expectLater(
          alarmCubit.stream, emits(StartAlarm(recursThursday, day)));
    });

    test('Recurring monthly alarms shows', () async {
      // Arrange
      final recursTheThisDayOfMonth = FakeActivity.reocurrsOnDay(
          nextMinute.day,
          nextMinute.subtract(const Duration(days: 60)),
          nextMinute.add(const Duration(days: 60)));
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([recursTheThisDayOfMonth]));
      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      _tick();
      // Assert
      await expectLater(
          alarmCubit.stream, emits(StartAlarm(recursTheThisDayOfMonth, day)));
    });

    test('Recurring yearly alarms shows', () async {
      // Arrange
      final recursTheThisDayOfYear = FakeActivity.reocurrsOnDate(nextMinute);
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([recursTheThisDayOfYear]));
      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      _tick();
      // Assert
      await expectLater(
          alarmCubit.stream, emits(StartAlarm(recursTheThisDayOfYear, day)));
    });

    test('Alarm on EndTime shows', () async {
      // Arrange
      final activityEnding = FakeActivity.ends(nextMinute);
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([activityEnding]));
      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      _tick();
      // Assert
      await expectLater(
        alarmCubit.stream,
        emits(EndAlarm(activityEnding, day)),
      );
    });

    test(
        'Alarm on EndTime does not show when it has no end time (start time is same as end time)',
        () async {
      // Arrange
      final nextAlarm =
          FakeActivity.starts(nextMinute, duration: Duration.zero);
      final afterThatAlarm =
          FakeActivity.starts(inTwoMin, duration: Duration.zero);
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([nextAlarm, afterThatAlarm]));
      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      _tick();

      // Assert
      await expectLater(alarmCubit.stream, emits(StartAlarm(nextAlarm, day)));

      // Act
      _tick();
      await expectLater(
          alarmCubit.stream, emits(StartAlarm(afterThatAlarm, day)));
    });

    test('Reminders shows', () async {
      // Arrange
      const reminderTime = Duration(hours: 1);
      final remind1HourBefore =
          FakeActivity.starts(nextMinute.add(reminderTime))
              .copyWith(reminderBefore: [reminderTime.inMilliseconds]);
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([remind1HourBefore]));
      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      _tick();
      // Assert
      await expectLater(
        alarmCubit.stream,
        emits(
          ReminderBefore(remind1HourBefore, day, reminder: reminderTime),
        ),
      );
    });

    tearDown(() {
      activitiesBloc.close();
      clockBloc.close();
      mockedTicker.close();
      alarmCubit.close();
    });
  });

  group('when notification arrives', () {
    final aTime = DateTime(1999, 12, 20, 20, 12);
    final aDay = aTime.onlyDays();
    late ReplaySubject<ActivityAlarm> notificationSelected;
    late AlarmCubit notificationBloc;
    const localTimezoneName = 'aTimeZone';

    setUp(() {
      setLocalLocation(Location(localTimezoneName, [], [], []));
      notificationSelected = ReplaySubject<ActivityAlarm>();

      notificationBloc = AlarmCubit(
        activitiesBloc: ActivitiesBloc(
          activityRepository: MockActivityRepository(),
          syncBloc: FakeSyncBloc(),
          pushCubit: FakePushCubit(),
        ),
        clockBloc: ClockBloc.fixed(aTime),
        selectedNotificationSubject: notificationSelected,
      );
    });

    test('initial state', () {
      expect(notificationBloc.state, null);
    });

    test('Notification selected emits new alarm state', () async {
      // Arrange
      final nowActivity =
          FakeActivity.starts(aTime).copyWith(timezone: localTimezoneName);
      final payload = StartAlarm(nowActivity, aDay);

      // Act
      notificationSelected.add(payload);

      // Assert
      await expectLater(
          notificationBloc.stream, emits(StartAlarm(nowActivity, aDay)));
    });

    test('Notification selected emits new reminder state', () async {
      // Arrange
      final reminderTime = 5.minutes();
      final nowActivity = FakeActivity.starts(aTime).copyWith(
          timezone: localTimezoneName,
          reminderBefore: [reminderTime.inMilliseconds]);

      final payload = ReminderBefore(
        nowActivity,
        aDay,
        reminder: reminderTime,
      );
      notificationSelected.add(payload);

      // Assert
      await expectLater(
        notificationBloc.stream,
        emits(ReminderBefore(
          nowActivity,
          aDay,
          reminder: reminderTime,
        )),
      );
    });
  });
}
