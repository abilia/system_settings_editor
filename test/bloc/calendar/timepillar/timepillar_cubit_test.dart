import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks/mock_bloc.dart';

void main() {
  late ClockBloc clockBloc;
  late ActivitiesBloc activitiesBloc;
  late DayPickerBloc dayPickerBloc;
  late MemoplannerSettingBloc memoplannerSettingBloc;
  late TimerAlarmBloc timerAlarmBloc;
  late StreamController<DateTime> clockStream;
  final now = DateTime(2022, 05, 12, 13, 15);

  setUp(() {
    clockStream = StreamController();
    clockBloc = ClockBloc(clockStream.stream, initialTime: now);
    activitiesBloc = MockActivitiesBloc();
    dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
    memoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => memoplannerSettingBloc.state)
        .thenReturn(MemoplannerSettingsLoaded(
      MemoplannerSettings(
        calendar: const GeneralCalendarSettings(
          categories: CategoriesSettings(
            show: false,
          ),
        ),
        viewOptionsTimeView: DayCalendarType.oneTimepillar.index,
      ),
    ));

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
    setUp: () => when(() => activitiesBloc.state).thenReturn(ActivitiesLoaded([
      nowActivity,
      fullDayActivity,
    ])),
    build: () => TimepillarCubit(
      clockBloc: clockBloc,
      activitiesBloc: activitiesBloc,
      dayPickerBloc: dayPickerBloc,
      memoSettingsBloc: memoplannerSettingBloc,
      timerAlarmBloc: timerAlarmBloc,
    ),
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
    setUp: () => when(() => activitiesBloc.state).thenReturn(
      ActivitiesLoaded([removeAfter, removeAfterRecurring]),
    ),
    build: () => TimepillarCubit(
      clockBloc: clockBloc,
      activitiesBloc: activitiesBloc,
      dayPickerBloc: dayPickerBloc,
      memoSettingsBloc: memoplannerSettingBloc,
      timerAlarmBloc: timerAlarmBloc,
    ),
    act: (cubit) => cubit.previous(),
    expect: () => [
      TimepillarState(
        interval: TimepillarInterval(
          start: DateTime(2022, 05, 11),
          end: DateTime(2022, 05, 12),
          intervalPart: IntervalPart.dayAndNight,
        ),
        events: const <Event>[],
        calendarType: DayCalendarType.oneTimepillar,
        occasion: Occasion.past,
        showNightCalendar: true,
      ),
    ],
  );

  tearDown(() {
    clockStream.close();
  });
}
