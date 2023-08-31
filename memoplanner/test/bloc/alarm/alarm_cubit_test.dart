import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:rxdart/rxdart.dart';

import 'package:timezone/timezone.dart';

import '../../fakes/all.dart';
import '../../mocks/mocks.dart';

void main() {
  group('When time ticks', () {
    late ClockCubit clockCubit;
    late ActivitiesCubit activitiesCubit;
    late GenericCubit genericCubit;
    late MemoplannerSettingsBloc memoplannerSettingBloc;

    late MockActivityRepository mockActivityRepository;
    late MockGenericRepository mockGenericRepository;
    late StreamController<DateTime> mockedTicker;

    final thisMinute = DateTime(2006, 06, 06, 06, 06).onlyMinutes();
    final nextMinute = thisMinute.add(const Duration(minutes: 1));
    final inTwoMin = thisMinute.add(const Duration(minutes: 2));
    final day = thisMinute.onlyDays();

    Future<DateTime> tick() {
      final nextMin = clockCubit.state.add(const Duration(minutes: 1));
      mockedTicker.add(nextMin);
      return clockCubit.stream.firstWhere((d) => d == nextMin);
    }

    setUp(() {
      mockedTicker = StreamController<DateTime>();
      clockCubit = ClockCubit(mockedTicker.stream, initialTime: thisMinute);
      mockActivityRepository = MockActivityRepository();
      activitiesCubit = ActivitiesCubit(
        activityRepository: mockActivityRepository,
        syncBloc: FakeSyncBloc(),
      );
      mockGenericRepository = MockGenericRepository();
      when(() => mockGenericRepository.getAll())
          .thenAnswer((invocation) => Future.value([]));

      genericCubit = GenericCubit(
        genericRepository: mockGenericRepository,
        syncBloc: FakeSyncBloc(),
      );

      memoplannerSettingBloc = MemoplannerSettingsBloc(
        genericCubit: genericCubit,
      );
    });

    final nowActivity = FakeActivity.starts(thisMinute);
    final soonActivity = FakeActivity.starts(nextMinute);
    final soonActivity2 = FakeActivity.starts(nextMinute);
    final inTwoMinActivity = FakeActivity.starts(inTwoMin);

    blocTest(
      'Load activities with current alarm shows alarm',
      setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([soonActivity])),
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) {
        activitiesCubit.notifyChange();
        tick();
      },
      expect: () => [StartAlarm(ActivityDay(soonActivity, day))],
    );

    blocTest(
      'Ticks before Load activities does nothing',
      setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([soonActivity])),
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) async {
        await tick();
      },
      expect: () => [StartAlarm(ActivityDay(soonActivity, day))],
    );

    blocTest(
      'Does not show if clock is not on start time',
      setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([nowActivity])),
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) async {
        await tick();
      },
      expect: () => [],
    );

    blocTest(
      'Next minute alarm does nothing',
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) => activitiesCubit.notifyChange(),
      expect: () => [],
    );

    blocTest(
      'Next minute alarm alarm next minute',
      setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([soonActivity])),
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) {
        tick();
      },
      expect: () => [StartAlarm(ActivityDay(soonActivity, day))],
    );

    blocTest(
      'Two activities at the same time emits',
      setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([soonActivity, soonActivity2])),
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) {
        tick();
      },
      expect: () => [
        StartAlarm(ActivityDay(soonActivity, day)),
        StartAlarm(ActivityDay(soonActivity2, day)),
      ],
    );

    blocTest(
      'two activities starts in order',
      setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) =>
              Future.value([inTwoMinActivity, nowActivity, soonActivity])),
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) async {
        await tick();
        await tick();
      },
      expect: () => [
        StartAlarm(ActivityDay(soonActivity, day)),
        StartAlarm(ActivityDay(inTwoMinActivity, day)),
      ],
    );

    final inOneMinuteWithoutAlarmActivity =
        FakeActivity.starts(thisMinute.add(1.minutes()))
            .copyWith(alarmType: noAlarm);

    blocTest(
      'Activity with no alarm set does not trigger an alarm',
      setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value(
              [inTwoMinActivity, inOneMinuteWithoutAlarmActivity])),
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) async {
        await tick();
        tick();
      },
      expect: () => [StartAlarm(ActivityDay(inTwoMinActivity, day))],
    );

    final recursThursday = FakeActivity.reoccursTuesdays(nextMinute);
    blocTest(
      'Recurring weekly alarms shows',
      setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([recursThursday])),
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) {
        tick();
      },
      expect: () => [StartAlarm(ActivityDay(recursThursday, day))],
    );

    final recursTheThisDayOfMonth = FakeActivity.reoccursOnDay(
        nextMinute.day,
        nextMinute.subtract(const Duration(days: 60)),
        nextMinute.add(const Duration(days: 60)));
    blocTest(
      'Recurring monthly alarms shows',
      setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([recursTheThisDayOfMonth])),
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) async {
        await tick();
      },
      wait: const Duration(milliseconds: 3000),
      expect: () => [StartAlarm(ActivityDay(recursTheThisDayOfMonth, day))],
    );

    final recursTheThisDayOfYear = FakeActivity.reoccursOnDate(nextMinute);
    blocTest(
      'Recurring yearly alarms shows',
      setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([recursTheThisDayOfYear])),
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) async {
        await tick();
      },
      expect: () => [StartAlarm(ActivityDay(recursTheThisDayOfYear, day))],
    );

    final activityEnding = FakeActivity.ends(nextMinute);
    blocTest(
      'Alarm on EndTime shows',
      setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([activityEnding])),
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) async {
        await tick();
      },
      expect: () => [EndAlarm(ActivityDay(activityEnding, day))],
    );

    final nextAlarm = FakeActivity.starts(nextMinute, duration: Duration.zero);
    final afterThatAlarm =
        FakeActivity.starts(inTwoMin, duration: Duration.zero);
    blocTest(
      'Alarm on EndTime does not show when it has no end time (start time is same as end time)',
      setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([nextAlarm, afterThatAlarm])),
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) async {
        await tick();
        await tick();
      },
      expect: () => [
        StartAlarm(ActivityDay(nextAlarm, day)),
        StartAlarm(ActivityDay(afterThatAlarm, day)),
      ],
    );

    const reminderTime = Duration(hours: 1);
    final remind1HourBefore = FakeActivity.starts(nextMinute.add(reminderTime))
        .copyWith(reminderBefore: [reminderTime.inMilliseconds]);
    blocTest(
      'Reminders shows',
      setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([remind1HourBefore])),
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) async {
        tick();
      },
      expect: () => [
        ReminderBefore(
          ActivityDay(remind1HourBefore, day),
          reminder: reminderTime,
        ),
      ],
    );

    blocTest(
      'SGC-1710 Nothing when disable until is set',
      setUp: () {
        when(() => mockActivityRepository.allBetween(any(), any()))
            .thenAnswer((_) => Future.value([soonActivity]));
        when(() => mockGenericRepository.getAll()).thenAnswer(
          (invocation) => Future.value(
            [
              Generic.createNew<GenericSettingData>(
                data: GenericSettingData.fromData(
                  data: day.nextDay().millisecondsSinceEpoch,
                  identifier: AlarmSettings.alarmsDisabledUntilKey,
                ),
              ),
            ],
          ),
        );
      },
      build: () => AlarmCubit(
        clockCubit: clockCubit,
        activityRepository: mockActivityRepository,
        settingsBloc: memoplannerSettingBloc,
        selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) async {
        await genericCubit.loadGenerics();
        await memoplannerSettingBloc.stream.any((s) => true);
        await tick();
      },
      expect: () => [],
    );

    tearDown(() {
      activitiesCubit.close();
      clockCubit.close();
      mockedTicker.close();
    });
  });

  group('when notification arrives', () {
    final aTime = DateTime(1999, 12, 20, 20, 12);
    final aDay = aTime.onlyDays();
    late ReplaySubject<NotificationAlarm> notificationSelected;
    late AlarmCubit notificationBloc;
    const localTimezoneName = 'aTimeZone';
    final aTimer = TimerAlarm(AbiliaTimer.createNew(
      title: 'title',
      startTime: aTime.subtract(3.minutes()),
      duration: 3.minutes(),
    ));

    setUp(() {
      setLocalLocation(Location(localTimezoneName, [], [], []));
      notificationSelected = ReplaySubject<NotificationAlarm>();

      notificationBloc = AlarmCubit(
        activityRepository: MockActivityRepository(),
        clockCubit: ClockCubit.fixed(aTime),
        settingsBloc: FakeMemoplannerSettingsBloc(),
        selectedNotificationSubject: notificationSelected,
        timerAlarm: const Stream.empty(),
      );
    });

    tearDown(() {
      notificationSelected.close();
    });

    test('initial state', () {
      expect(notificationBloc.state, null);
    });

    test('Notification selected emits new alarm state', () async {
      // Arrange
      final nowActivity =
          FakeActivity.starts(aTime).copyWith(timezone: localTimezoneName);
      final payload = StartAlarm(ActivityDay(nowActivity, aDay));

      // Act
      notificationSelected.add(payload);

      // Assert
      await expectLater(notificationBloc.stream,
          emits(StartAlarm(ActivityDay(nowActivity, aDay))));
    });

    test('Notification selected emits new reminder state', () async {
      // Arrange
      final reminderTime = 5.minutes();
      final nowActivity = FakeActivity.starts(aTime).copyWith(
          timezone: localTimezoneName,
          reminderBefore: [reminderTime.inMilliseconds]);

      final payload = ReminderBefore(
        ActivityDay(nowActivity, aDay),
        reminder: reminderTime,
      );
      notificationSelected.add(payload);

      // Assert
      await expectLater(
        notificationBloc.stream,
        emits(ReminderBefore(
          ActivityDay(nowActivity, aDay),
          reminder: reminderTime,
        )),
      );
    });

    blocTest(
      'Timers are handled in the AlarmCubit',
      build: () => AlarmCubit(
        activityRepository: MockActivityRepository(),
        clockCubit: ClockCubit.fixed(aTime),
        settingsBloc: FakeMemoplannerSettingsBloc(),
        selectedNotificationSubject: notificationSelected,
        timerAlarm: const Stream.empty(),
      ),
      act: (cubit) => notificationSelected.add(aTimer),
      expect: () => [aTimer],
    );
  });
}
