import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks/mock_bloc.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  late ClockBloc clockBloc;
  late DayPickerBloc dayPickerBloc;

  late NightEventsCubit nightEventsCubit;
  late MockMemoplannerSettingBloc mockMemoplannerSettingBloc;
  late StreamController<MemoplannerSettingsState> mockSettingStream;
  late StreamController<ActivitiesState> activityBlocStreamController;

  late MockActivitiesBloc mockActivitiesBloc;

  final initialMinutes = DateTime(2666, 06, 06, 06, 06);
  final initialDay = initialMinutes.onlyDays();
  final nextDay = initialDay.nextDay();
  final previusDay = initialDay.previousDay();

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockActivitiesBloc = MockActivitiesBloc();
    when(() => mockActivitiesBloc.state).thenReturn(ActivitiesNotLoaded());
    activityBlocStreamController = StreamController<ActivitiesState>();
    when(() => mockActivitiesBloc.stream)
        .thenAnswer((realInvocation) => activityBlocStreamController.stream);

    mockMemoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingBloc.state)
        .thenReturn(const MemoplannerSettingsNotLoaded());
    mockSettingStream = StreamController<MemoplannerSettingsState>();
    when(() => mockMemoplannerSettingBloc.stream)
        .thenAnswer((realInvocation) => mockSettingStream.stream);
    clockBloc = ClockBloc.fixed(initialMinutes);
    dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);

    nightEventsCubit = NightEventsCubit(
      clockBloc: clockBloc,
      dayPickerBloc: dayPickerBloc,
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingBloc,
    );
  });

  group('occasion', () {
    test('initial state morning before', () {
      expect(
        nightEventsCubit.state,
        EventsLoaded(
          activities: const [],
          timers: const [],
          day: initialDay,
          occasion: Occasion.future,
        ),
      );
    });

    test('when change to previus day change state', () {
      dayPickerBloc.add(PreviousDay());
      expectLater(
        nightEventsCubit.stream,
        emits(
          EventsLoaded(
            activities: const [],
            timers: const [],
            day: previusDay,
            occasion: Occasion.past,
          ),
        ),
      );
    });

    test('when change to next day change state', () {
      dayPickerBloc.add(NextDay());
      expectLater(
        nightEventsCubit.stream,
        emits(
          EventsLoaded(
            activities: const [],
            timers: const [],
            day: nextDay,
            occasion: Occasion.future,
          ),
        ),
      );
    });

    test('when time change to next day change state', () {
      final dayParts = mockMemoplannerSettingBloc.state.dayParts;
      clockBloc.setTime(initialDay.add(dayParts.night));
      expectLater(
        nightEventsCubit.stream,
        emits(
          EventsLoaded(
            activities: const [],
            timers: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );
    });

    test('when time changes from 00:00 to 00:01', () async {
      clockBloc.setTime(initialDay.add(1.minutes()));
      await expectLater(
        nightEventsCubit.stream,
        emits(
          EventsLoaded(
            activities: const [],
            timers: const [],
            day: initialDay,
            occasion: Occasion.future,
          ),
        ),
      );
      dayPickerBloc.add(PreviousDay());
      await expectLater(
        nightEventsCubit.stream,
        emits(
          EventsLoaded(
            activities: const [],
            timers: const [],
            day: previusDay,
            occasion: Occasion.current,
          ),
        ),
      );
    });

    group('dayParts', () {
      test('change time interval changes occasion', () async {
        final dayParts = mockMemoplannerSettingBloc.state.dayParts;

        await clockBloc.setTime(initialDay.add(dayParts.night));
        mockSettingStream.add(MemoplannerSettingsLoaded(
            MemoplannerSettings(nightIntervalStart: DayParts.nightLimit.max)));

        await expectLater(
          nightEventsCubit.stream,
          emits(
            EventsLoaded(
              activities: const [],
              timers: const [],
              day: initialDay,
              occasion: Occasion.future,
            ),
          ),
        );
      });
    });
  });

  group('activities', () {
    test('no activity starting off night', () {
      expect(
        nightEventsCubit.state,
        EventsLoaded(
          activities: const [],
          timers: const [],
          day: initialDay,
          occasion: Occasion.future,
        ),
      );
    });

    test('activity starting at night start', () {
      final dayParts = mockMemoplannerSettingBloc.state.dayParts;
      final activity =
          Activity.createNew(startTime: initialDay.add(dayParts.night));
      activityBlocStreamController.add(ActivitiesLoaded([activity]));

      expectLater(
        nightEventsCubit.stream,
        emits(
          EventsLoaded(
            activities: [
              ActivityDay(
                activity,
                activity.startTime.onlyDays(),
              )
            ],
            timers: const [],
            day: initialDay,
            occasion: Occasion.future,
          ),
        ),
      );
    });

    test('activity starting at night end', () {
      final dayParts = mockMemoplannerSettingBloc.state.dayParts;
      final activity = Activity.createNew(
          startTime:
              initialDay.nextDay().add(dayParts.morning).subtract(1.minutes()));
      activityBlocStreamController.add(ActivitiesLoaded([activity]));

      expectLater(
        nightEventsCubit.stream,
        emits(
          EventsLoaded(
            activities: [
              ActivityDay(
                activity,
                activity.startTime.onlyDays(),
              )
            ],
            timers: const [],
            day: initialDay,
            occasion: Occasion.future,
          ),
        ),
      );
    });
  });
}
