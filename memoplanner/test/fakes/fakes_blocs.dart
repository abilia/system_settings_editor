import 'package:flutter/material.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:mocktail/mocktail.dart';

import 'all.dart';

class FakeGenericCubit extends Fake implements GenericCubit {
  @override
  Stream<GenericState> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

class FakeActivitiesCubit extends Fake implements ActivitiesCubit {
  @override
  late final ActivityRepository activityRepository;

  FakeActivitiesCubit({ActivityRepository? activityRepository}) {
    this.activityRepository = activityRepository ?? FakeActivityRepository();
  }

  @override
  Stream<ActivitiesChanged> get stream => const Stream.empty();

  @override
  ActivitiesChanged get state => ActivitiesChanged();

  @override
  Future<void> addActivity(Activity activity) async {}

  @override
  Future<void> updateActivity(Activity activity) async {}

  @override
  Future<void> updateRecurringActivity(
      ActivityDay activityDay, ApplyTo applyTo) async {}

  @override
  Future<void> close() async {}
}

class FakeMemoplannerSettingsBloc extends Fake
    implements MemoplannerSettingsBloc {
  @override
  Stream<MemoplannerSettings> get stream => const Stream.empty();

  @override
  MemoplannerSettings get state =>
      MemoplannerSettingsLoaded(const MemoplannerSettings());

  @override
  Future<void> close() async {}
}

class FakeTimepillarCubit extends Fake implements TimepillarCubit {
  @override
  Stream<TimepillarState> get stream => const Stream.empty();

  @override
  TimepillarState get state => TimepillarState(
        interval: TimepillarInterval(
          start: DateTime(1066, 10, 14, 09, 00),
          end: DateTime(1066, 10, 14, 17, 54),
        ),
        events: const [],
        calendarType: DayCalendarType.oneTimepillar,
        occasion: Occasion.current,
        showNightCalendar: false,
        day: DateTime(1066, 10, 14),
      );

  @override
  Future<void> close() async {}
}

class FakeTimepillarMeasuresCubit extends Fake
    implements TimepillarMeasuresCubit {
  @override
  Stream<TimepillarMeasures> get stream => const Stream.empty();

  @override
  TimepillarMeasures get state => TimepillarMeasures(
        TimepillarInterval(
          start: DateTime(1066, 10, 14, 09, 00),
          end: DateTime(1066, 10, 14, 17, 54),
        ),
        1,
      );

  @override
  Future<void> close() async {}
}

class FakeDayPickerBloc extends Fake implements DayPickerBloc {
  @override
  Stream<DayPickerState> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

class FakeDayEventsCubit extends Fake implements DayEventsCubit {
  @override
  Stream<EventsState> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

class FakeAlarmCubit extends Fake implements AlarmCubit {
  @override
  Stream<NotificationAlarm?> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

class FakeCalendarViewBloc extends Fake implements CalendarViewCubit {
  @override
  Stream<CalendarViewState> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

class FakeEditActivityCubit extends Fake implements EditActivityCubit {
  @override
  Stream<EditActivityState> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

class FakeSpeechSettingsCubit extends Fake implements SpeechSettingsCubit {
  @override
  Stream<SpeechSettingsState> get stream => const Stream.empty();

  @override
  SpeechSettingsState get state =>
      const SpeechSettingsState(textToSpeech: true);

  @override
  Future<void> close() async {}
}

class FakeVoicesCubit extends Fake implements VoicesCubit {
  @override
  Stream<VoicesState> get stream => const Stream.empty();

  @override
  VoicesState get state => VoicesState(languageCode: 'en');

  @override
  Future<void> close() async {}
}

class FakeSessionsCubit extends Fake implements SessionsCubit {
  @override
  Stream<SessionsState> get stream => const Stream.empty();

  @override
  SessionsState get state => const SessionsState(false);

  @override
  Future<void> close() async {}
}

class FakeDayPartCubit extends Fake implements DayPartCubit {
  @override
  Stream<DayPart> get stream => const Stream.empty();

  @override
  DayPart get state => DayPart.day;

  @override
  Future<void> close() async {}
}

class FakeConnectivityCubit extends Fake implements ConnectivityCubit {
  @override
  Stream<ConnectivityState> get stream => const Stream.empty();

  @override
  ConnectivityState get state => const ConnectivityState.none();

  @override
  Future<void> close() async {}
}

class FakeFeatureToggleCubit extends Fake implements FeatureToggleCubit {
  @override
  FeatureToggleState get state => FeatureToggleState({});

  @override
  Stream<FeatureToggleState> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

class FakeNightMode extends Fake implements NightMode {
  @override
  bool get state => false;

  @override
  Stream<bool> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

class FakeScrollPositionCubit extends Fake implements ScrollPositionCubit {
  @override
  ScrollPositionState get state => ScrollPositionUnready();

  @override
  Stream<ScrollPositionState> get stream => const Stream.empty();

  @override
  Future<void> close() async {}

  @override
  void updateState({
    required ScrollController scrollController,
    required double nowOffset,
  }) {}

  @override
  Future<void> goToNow({
    Duration duration = Duration.zero,
    Curve curve = Curves.easeInOut,
  }) async {}

  @override
  void reset() {}
}
