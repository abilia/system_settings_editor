import 'dart:async';
import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks/mock_bloc.dart';

void main() {
  late ClockBloc clockBloc;
  late DayPickerBloc dayPickerBloc;

  late NightActivitiesCubit nightActivitiesCubit;
  late MockMemoplannerSettingBloc mockMemoplannerSettingBloc;
  late StreamController<MemoplannerSettingsState> mockSettingStream;
  late StreamController<ActivitiesState> activityBlocStreamController;

  late MockActivitiesBloc mockActivitiesBloc;

  final initialMinutes = DateTime(2666, 06, 06, 06, 06);
  final initialDay = initialMinutes.onlyDays();
  final nextDay = initialDay.nextDay();
  final previusDay = initialDay.previousDay();

  setUpAll(() {
    registerFallbackValue(ActivitiesNotLoaded());
    registerFallbackValue(LoadActivities());
    registerFallbackValue(MemoplannerSettingsNotLoaded());
    registerFallbackValue(UpdateMemoplannerSettings(MapView({})));
  });

  setUp(() {
    mockActivitiesBloc = MockActivitiesBloc();
    when(() => mockActivitiesBloc.state).thenReturn(ActivitiesNotLoaded());
    activityBlocStreamController = StreamController<ActivitiesState>();
    when(() => mockActivitiesBloc.stream)
        .thenAnswer((realInvocation) => activityBlocStreamController.stream);

    mockMemoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingBloc.state)
        .thenReturn(MemoplannerSettingsNotLoaded());
    mockSettingStream = StreamController<MemoplannerSettingsState>();
    when(() => mockMemoplannerSettingBloc.stream)
        .thenAnswer((realInvocation) => mockSettingStream.stream);
    clockBloc = ClockBloc(Stream.empty(), initialTime: initialMinutes);
    dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);

    nightActivitiesCubit = NightActivitiesCubit(
      clockBloc: clockBloc,
      dayPickerBloc: dayPickerBloc,
      activitiesBloc: mockActivitiesBloc,
      memoplannerSettingBloc: mockMemoplannerSettingBloc,
    );
  });

  group('occasion', () {
    test('initial state morning before', () {
      expect(
        nightActivitiesCubit.state,
        ActivitiesOccasionLoaded(
          activities: [],
          day: initialDay,
          occasion: Occasion.future,
        ),
      );
    });

    test('when change to previus day change state', () {
      dayPickerBloc.add(PreviousDay());
      expectLater(
        nightActivitiesCubit.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: [],
            day: previusDay,
            occasion: Occasion.past,
          ),
        ),
      );
    });

    test('when change to next day change state', () {
      dayPickerBloc.add(NextDay());
      expectLater(
        nightActivitiesCubit.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: [],
            day: nextDay,
            occasion: Occasion.future,
          ),
        ),
      );
    });

    test('when time change to next day change state', () {
      final dayParts = mockMemoplannerSettingBloc.state.dayParts;
      clockBloc.add(initialDay.add(dayParts.night));
      expectLater(
        nightActivitiesCubit.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: [],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );
    });

    test('when time is 00:00', () {
      clockBloc.add(initialDay.add(1.hours()));
      dayPickerBloc.add(PreviousDay());
      expectLater(
        nightActivitiesCubit.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: [],
            day: previusDay,
            occasion: Occasion.current,
          ),
        ),
      );
    });

    group('dayParts', () {
      test('change time interval changes occasion', () {
        final dayParts = mockMemoplannerSettingBloc.state.dayParts;

        clockBloc.add(initialDay.add(dayParts.night));
        mockSettingStream.add(MemoplannerSettingsLoaded(
            MemoplannerSettings(nightIntervalStart: DayParts.nightLimit.max)));

        expectLater(
          nightActivitiesCubit.stream,
          emits(
            ActivitiesOccasionLoaded(
              activities: [],
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
        nightActivitiesCubit.state,
        ActivitiesOccasionLoaded(
          activities: [],
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
        nightActivitiesCubit.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: [
              ActivityOccasion.forTest(activity, occasion: Occasion.future)
            ],
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
        nightActivitiesCubit.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: [
              ActivityOccasion.forTest(activity, occasion: Occasion.future)
            ],
            day: initialDay,
            occasion: Occasion.future,
          ),
        ),
      );
    });
  });
}
