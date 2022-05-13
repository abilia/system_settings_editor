import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks/mock_bloc.dart';

void main() {
  late TimepillarCubit timepillarCubit;
  late ClockBloc clockBloc;
  late ActivitiesBloc activitiesBloc;
  late DayPickerBloc dayPickerBloc;
  late MemoplannerSettingBloc memoplannerSettingBloc;
  late TimerAlarmBloc timerAlarmBloc;
  late StreamController<DateTime> clockStream;
  final now = DateTime(2022, 05, 12, 13, 15);
  final nowActivity = Activity.createNew(startTime: now);
  final fullDayActivity =
      Activity.createNew(startTime: now.onlyDays(), fullDay: true);

  setUp(() {
    clockStream = StreamController();
    clockBloc = ClockBloc(clockStream.stream, initialTime: now);
    activitiesBloc = MockActivitiesBloc();
    dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
    memoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => memoplannerSettingBloc.state)
        .thenReturn(MemoplannerSettingsLoaded(
      MemoplannerSettings(
        calendarActivityTypeShowTypes: false,
        viewOptionsTimeView: DayCalendarType.oneTimepillar.index,
      ),
    ));

    timerAlarmBloc = MockTimerAlarmBloc();
    when(() => timerAlarmBloc.state).thenReturn(TimerAlarmState(
      timers: const [],
      queue: const [],
    ));
  });

  test('No full day in timepillar state', () {
    when(() => activitiesBloc.state).thenReturn(ActivitiesLoaded([
      nowActivity,
      fullDayActivity,
    ]));

    timepillarCubit = TimepillarCubit(
      clockBloc: clockBloc,
      activitiesBloc: activitiesBloc,
      dayPickerBloc: dayPickerBloc,
      memoSettingsBloc: memoplannerSettingBloc,
      timerAlarmBloc: timerAlarmBloc,
    );

    expect(
      timepillarCubit.state,
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
    );
  });

  tearDown(() {
    clockStream.close();
  });
}
