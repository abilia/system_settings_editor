import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks/mock_bloc.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  late ClockBloc clockBloc;
  late DayPickerBloc dayPickerBloc;

  late MockMemoplannerSettingBloc mockMemoplannerSettingBloc;
  late StreamController<MemoplannerSettingsState> mockSettingStream;
  late MockActivitiesBloc mockActivitiesBloc;
  late StreamController<ActivitiesState> activityBlocStreamController;
  late MockTimerAlarmBloc mockTimerAlarmBloc;
  late StreamController<TimerAlarmState> timerCubitStreamController;

  final initialMinutes = DateTime(2666, 06, 06, 06, 06);
  final initialDay = initialMinutes.onlyDays();
  final nextDay = initialDay.nextDay();
  final previusDay = initialDay.previousDay();

  setUpAll(registerFallbackValues);

  setUp(() {
    mockActivitiesBloc = MockActivitiesBloc();
    when(() => mockActivitiesBloc.state).thenReturn(ActivitiesNotLoaded());
    activityBlocStreamController = StreamController<ActivitiesState>();
    when(() => mockActivitiesBloc.stream)
        .thenAnswer((realInvocation) => activityBlocStreamController.stream);

    mockTimerAlarmBloc = MockTimerAlarmBloc();
    when(() => mockTimerAlarmBloc.state).thenReturn(TimerAlarmState(
      timers: const [],
      queue: const [],
    ));
    timerCubitStreamController = StreamController<TimerAlarmState>();
    when(() => mockTimerAlarmBloc.stream)
        .thenAnswer((realInvocation) => timerCubitStreamController.stream);

    mockMemoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingBloc.state)
        .thenReturn(const MemoplannerSettingsNotLoaded());
    mockSettingStream = StreamController<MemoplannerSettingsState>();
    when(() => mockMemoplannerSettingBloc.stream)
        .thenAnswer((realInvocation) => mockSettingStream.stream);
    clockBloc = ClockBloc.fixed(initialMinutes);
    dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
  });

  tearDown(() {
    mockSettingStream.close();
    activityBlocStreamController.close();
    timerCubitStreamController.close();
  });

  group('occasion', () {
    blocTest<NightEventsCubit, EventsState>(
      'initial state morning before',
      build: () => NightEventsCubit(
        activitiesBloc: mockActivitiesBloc,
        timerAlarmBloc: mockTimerAlarmBloc,
        memoplannerSettingBloc: mockMemoplannerSettingBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      ),
      verify: (cubit) => expect(
        cubit.state,
        EventsLoaded(
          activities: const [],
          timers: const [],
          day: initialDay,
          occasion: Occasion.future,
        ),
      ),
    );

    blocTest<NightEventsCubit, EventsState>(
      'when change to previous day change state',
      build: () => NightEventsCubit(
        activitiesBloc: mockActivitiesBloc,
        timerAlarmBloc: mockTimerAlarmBloc,
        memoplannerSettingBloc: mockMemoplannerSettingBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      ),
      act: (cubit) => dayPickerBloc.add(PreviousDay()),
      expect: () => [
        EventsLoaded(
          activities: const [],
          timers: const [],
          day: previusDay,
          occasion: Occasion.past,
        ),
      ],
    );

    blocTest<NightEventsCubit, EventsState>(
      'when change to next day change state',
      build: () => NightEventsCubit(
        activitiesBloc: mockActivitiesBloc,
        timerAlarmBloc: mockTimerAlarmBloc,
        memoplannerSettingBloc: mockMemoplannerSettingBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      ),
      act: (cubit) => dayPickerBloc.add(NextDay()),
      expect: () => [
        EventsLoaded(
          activities: const [],
          timers: const [],
          day: nextDay,
          occasion: Occasion.future,
        ),
      ],
    );

    blocTest<NightEventsCubit, EventsState>(
      'when time change to next day change state',
      build: () => NightEventsCubit(
        activitiesBloc: mockActivitiesBloc,
        timerAlarmBloc: mockTimerAlarmBloc,
        memoplannerSettingBloc: mockMemoplannerSettingBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      ),
      act: (cubit) {
        final dayParts = mockMemoplannerSettingBloc.state.dayParts;
        clockBloc.setTime(initialDay.add(dayParts.night));
      },
      expect: () => [
        EventsLoaded(
          activities: const [],
          timers: const [],
          day: initialDay,
          occasion: Occasion.current,
        ),
      ],
    );

    blocTest<NightEventsCubit, EventsState>(
      'when time changes from 00:00 to 00:01',
      build: () => NightEventsCubit(
        activitiesBloc: mockActivitiesBloc,
        timerAlarmBloc: mockTimerAlarmBloc,
        memoplannerSettingBloc: mockMemoplannerSettingBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      ),
      act: (cubit) {
        clockBloc.setTime(initialDay.add(1.minutes()));
        dayPickerBloc.add(PreviousDay());
      },
      expect: () => [
        EventsLoaded(
          activities: const [],
          timers: const [],
          day: initialDay,
          occasion: Occasion.future,
        ),
        EventsLoaded(
          activities: const [],
          timers: const [],
          day: previusDay,
          occasion: Occasion.current,
        ),
      ],
    );

    group('dayParts', () {
      blocTest<NightEventsCubit, EventsState>(
        'change time interval changes occasion',
        build: () => NightEventsCubit(
          activitiesBloc: mockActivitiesBloc,
          timerAlarmBloc: mockTimerAlarmBloc,
          memoplannerSettingBloc: mockMemoplannerSettingBloc,
          clockBloc: clockBloc,
          dayPickerBloc: dayPickerBloc,
        ),
        act: (cubit) async {
          final dayParts = mockMemoplannerSettingBloc.state.dayParts;
          await clockBloc.setTime(initialDay.add(dayParts.night));
          mockSettingStream.add(MemoplannerSettingsLoaded(MemoplannerSettings(
              nightIntervalStart: DayParts.nightLimit.max)));
        },
        expect: () => [
          EventsLoaded(
            activities: const [],
            timers: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
          EventsLoaded(
            activities: const [],
            timers: const [],
            day: initialDay,
            occasion: Occasion.future,
          ),
          EventsLoaded(
            activities: const [],
            timers: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ],
      );
    });

    group('activities', () {
      blocTest<NightEventsCubit, EventsState>(
        'no activity starting off night',
        build: () => NightEventsCubit(
          activitiesBloc: mockActivitiesBloc,
          timerAlarmBloc: mockTimerAlarmBloc,
          memoplannerSettingBloc: mockMemoplannerSettingBloc,
          clockBloc: clockBloc,
          dayPickerBloc: dayPickerBloc,
        ),
        verify: (cubit) => expect(
          cubit.state,
          EventsLoaded(
            activities: const [],
            timers: const [],
            day: initialDay,
            occasion: Occasion.future,
          ),
        ),
      );

      late final activityStartAtNight = Activity.createNew(
          startTime:
              initialDay.add(mockMemoplannerSettingBloc.state.dayParts.night));
      blocTest<NightEventsCubit, EventsState>(
        'activity starting at night start',
        build: () => NightEventsCubit(
          activitiesBloc: mockActivitiesBloc,
          timerAlarmBloc: mockTimerAlarmBloc,
          memoplannerSettingBloc: mockMemoplannerSettingBloc,
          clockBloc: clockBloc,
          dayPickerBloc: dayPickerBloc,
        ),
        act: (bloc) {
          activityBlocStreamController
              .add(ActivitiesLoaded([activityStartAtNight]));
        },
        expect: () => [
          EventsLoaded(
            activities: [
              ActivityDay(
                activityStartAtNight,
                activityStartAtNight.startTime.onlyDays(),
              )
            ],
            timers: const [],
            day: initialDay,
            occasion: Occasion.future,
          ),
        ],
      );
      late final activityStartAtMorning = Activity.createNew(
          startTime: initialDay
              .nextDay()
              .add(mockMemoplannerSettingBloc.state.dayParts.morning)
              .subtract(1.minutes()));
      blocTest<NightEventsCubit, EventsState>(
        'activity starting at night end',
        build: () => NightEventsCubit(
          activitiesBloc: mockActivitiesBloc,
          timerAlarmBloc: mockTimerAlarmBloc,
          memoplannerSettingBloc: mockMemoplannerSettingBloc,
          clockBloc: clockBloc,
          dayPickerBloc: dayPickerBloc,
        ),
        act: (bloc) {
          activityBlocStreamController
              .add(ActivitiesLoaded([activityStartAtMorning]));
        },
        expect: () => [
          EventsLoaded(
            activities: [
              ActivityDay(
                activityStartAtMorning,
                activityStartAtMorning.startTime.onlyDays(),
              )
            ],
            timers: const [],
            day: initialDay,
            occasion: Occasion.future,
          ),
        ],
      );
    });
  });
  group('timers', () {
    late final timerStartingAtNight = TimerOccasion(
      AbiliaTimer.createNew(
        title: 'title',
        startTime:
            initialDay.add(mockMemoplannerSettingBloc.state.dayParts.night),
        duration: const Duration(minutes: 10),
      ),
      Occasion.current,
    );

    blocTest<NightEventsCubit, EventsState>(
      'timer starting at night start',
      build: () => NightEventsCubit(
        activitiesBloc: mockActivitiesBloc,
        timerAlarmBloc: mockTimerAlarmBloc,
        memoplannerSettingBloc: mockMemoplannerSettingBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      ),
      act: (cubit) => timerCubitStreamController.add(TimerAlarmState(
          timers: [timerStartingAtNight], queue: [timerStartingAtNight])),
      expect: () => [
        EventsLoaded(
          activities: const [],
          timers: [timerStartingAtNight],
          day: initialDay,
          occasion: Occasion.future,
        ),
      ],
    );
    late final timerStartingAtMorning = TimerOccasion(
      AbiliaTimer.createNew(
        title: 'title',
        startTime:
            initialDay.add(mockMemoplannerSettingBloc.state.dayParts.night),
        duration: const Duration(minutes: 10),
      ),
      Occasion.current,
    );

    blocTest<NightEventsCubit, EventsState>(
      'timer starting at night end',
      build: () => NightEventsCubit(
        activitiesBloc: mockActivitiesBloc,
        timerAlarmBloc: mockTimerAlarmBloc,
        memoplannerSettingBloc: mockMemoplannerSettingBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      ),
      act: (bloc) {
        timerCubitStreamController.add(TimerAlarmState(
            timers: [timerStartingAtMorning], queue: [timerStartingAtMorning]));
      },
      expect: () => [
        EventsLoaded(
          activities: const [],
          timers: [timerStartingAtMorning],
          day: initialDay,
          occasion: Occasion.future,
        ),
      ],
    );
  });
}
