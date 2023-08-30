import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';

void main() {
  late ClockCubit clockCubit;
  late ActivityRepository mockActivityRepository;
  late ActivitiesCubit activitiesCubit;
  late DayPickerBloc dayPickerBloc;
  late DayCalendarViewCubit dayCalendarViewCubit;
  late MemoplannerSettingsBloc memoplannerSettingBloc;
  late TimerAlarmBloc timerAlarmBloc;
  late StreamController<DateTime> clockStream;
  final now = DateTime(2022, 05, 12, 13, 15);

  setUp(() async {
    clockStream = StreamController();
    clockCubit = ClockCubit(clockStream.stream, initialTime: now);
    activitiesCubit = MockActivitiesCubit();
    mockActivityRepository = MockActivityRepository();
    when(() => activitiesCubit.activityRepository)
        .thenReturn(mockActivityRepository);
    dayPickerBloc = DayPickerBloc(clockCubit: clockCubit);
    dayCalendarViewCubit = DayCalendarViewCubit(
      DayCalendarViewDb(await FakeSharedPreferences.getInstance()),
      FakeGenericCubit(),
    );
    memoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => memoplannerSettingBloc.state).thenReturn(
      MemoplannerSettingsLoaded(
        const MemoplannerSettings(
          calendar: GeneralCalendarSettings(
            categories: CategoriesSettings(
              show: false,
            ),
          ),
        ),
      ),
    );

    timerAlarmBloc = MockTimerAlarmBloc();
    when(() => timerAlarmBloc.state).thenReturn(TimerAlarmState(
      timers: const [],
      queue: const [],
    ));
  });

  final nowActivity = Activity.createNew(startTime: now),
      fullDayActivity = Activity.createNew(
        startTime: now.onlyDays(),
        fullDay: true,
      );

  blocTest<TimepillarCubit, TimepillarState>(
    'No full day in timepillar state',
    setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
        .thenAnswer((_) => Future.value([nowActivity, fullDayActivity])),
    build: () => TimepillarCubit(
        clockCubit: clockCubit,
        activitiesCubit: activitiesCubit,
        dayPickerBloc: dayPickerBloc,
        memoSettingsBloc: memoplannerSettingBloc,
        dayCalendarViewCubit: dayCalendarViewCubit,
        timerAlarmBloc: timerAlarmBloc,
        dayPartCubit: FakeDayPartCubit())
      ..initialize(),
    verify: (cubit) => expect(
      cubit.state,
      TimepillarState(
        interval: TimepillarInterval(
          start: DateTime(2022, 05, 12, 06),
          end: DateTime(2022, 05, 12, 23),
          intervalPart: IntervalPart.day,
        ),
        events: <Event>[ActivityDay(nowActivity, now.onlyDays())],
        calendarType: DayCalendarType.oneTimepillar,
        occasion: Occasion.current,
        showNightCalendar: true,
        day: DateTime(2022, 05, 12),
      ),
    ),
  );

  final removeAfterRecurring = Activity.createNew(
        title: 'remove after recurring',
        startTime: now.subtract(100.days()),
        recurs: Recurs.everyDay,
        removeAfter: true,
      ),
      removeAfter = Activity.createNew(
        title: 'remove after',
        startTime: now.subtract(1.days()),
        removeAfter: true,
      );

  blocTest<TimepillarCubit, TimepillarState>(
    'remove activities that has remove after',
    setUp: () => when(() => mockActivityRepository.allBetween(any(), any()))
        .thenAnswer((_) => Future.value([removeAfter, removeAfterRecurring])),
    build: () => TimepillarCubit(
      clockCubit: clockCubit,
      activitiesCubit: activitiesCubit,
      dayPickerBloc: dayPickerBloc,
      memoSettingsBloc: memoplannerSettingBloc,
      dayCalendarViewCubit: dayCalendarViewCubit,
      timerAlarmBloc: timerAlarmBloc,
      dayPartCubit: FakeDayPartCubit(),
    )..initialize(),
    act: (cubit) => cubit.previous(),
    expect: () => [
      TimepillarState(
        interval: TimepillarInterval(
          start: DateTime(2022, 05, 12, 6),
          end: DateTime(2022, 05, 12, 23),
          intervalPart: IntervalPart.day,
        ),
        events: <Event>[
          ActivityDay(removeAfterRecurring, DateTime(2022, 05, 12))
        ],
        calendarType: DayCalendarType.oneTimepillar,
        occasion: Occasion.current,
        showNightCalendar: true,
        day: DateTime(2022, 05, 12),
      ),
      TimepillarState(
        interval: TimepillarInterval(
          start: DateTime(2022, 05, 11),
          end: DateTime(2022, 05, 12),
          intervalPart: IntervalPart.dayAndNight,
        ),
        events: const <Event>[],
        calendarType: DayCalendarType.oneTimepillar,
        occasion: Occasion.past,
        day: DateTime(2022, 05, 11),
        showNightCalendar: true,
      ),
    ],
  );

  tearDown(() {
    clockStream.close();
  });
}
