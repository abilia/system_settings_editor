import 'package:collection/src/unmodifiable_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:mocktail/mocktail.dart';

import 'all.dart';

class FakeSyncBloc extends Fake implements SyncBloc {
  @override
  Stream<Synced> get stream => const Stream.empty();

  @override
  void add(SyncEvent event) {}

  @override
  Future<bool> hasDirty() => Future.value(false);

  @override
  Future<void> close() async {}
}

class FakeAuthenticationBloc extends Fake implements AuthenticationBloc {
  @override
  Stream<AuthenticationState> get stream => const Stream.empty();

  @override
  AuthenticationState get state => const Authenticated(user: Fakes.user);

  @override
  Future<void> close() async {}
}

class FakeSortableBloc extends Fake implements SortableBloc {
  @override
  Stream<SortableState> get stream => const Stream.empty();

  @override
  SortableState get state => SortablesNotLoaded();

  @override
  Future<void> close() async {}
}

class FakeGenericCubit extends Fake implements GenericCubit {
  @override
  Stream<GenericState> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

class FakeActivitiesBloc extends Fake implements ActivitiesBloc {
  @override
  late final ActivityRepository activityRepository;

  FakeActivitiesBloc({ActivityRepository? activityRepository}) {
    this.activityRepository = activityRepository ?? FakeActivityRepository();
  }

  @override
  Stream<ActivitiesChanged> get stream => const Stream.empty();

  @override
  ActivitiesChanged get state => ActivitiesChanged();

  @override
  void add(ActivitiesEvent event) {}

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

class FakeUserFileBloc extends Fake implements UserFileBloc {
  @override
  Stream<UserFileState> get stream => const Stream.empty();

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

class FakeLicenseCubit extends Fake implements LicenseCubit {
  @override
  bool get validLicense => true;

  @override
  ValidLicense get state => ValidLicense();

  @override
  Stream<LicenseState> get stream => const Stream.empty();

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

class FakeSupportPersonsCubit extends Fake implements SupportPersonsCubit {
  Set<SupportPerson>? supportPersons;

  FakeSupportPersonsCubit();

  FakeSupportPersonsCubit.withSupportPerson()
      : supportPersons = {
          const SupportPerson(
            id: 0,
            name: '',
            image: '',
          )
        };

  @override
  Stream<SupportPersonsState> get stream => const Stream.empty();

  @override
  SupportPersonsState get state => SupportPersonsState(
      UnmodifiableSetView<SupportPerson>(supportPersons ?? {}));

  @override
  Future<void> loadSupportPersons() async => Future.value();

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
  ScrollPositionState get state => Unready();

  @override
  Stream<ScrollPositionState> get stream => const Stream.empty();

  @override
  Future<void> close() async {}

  @override
  void updateState({
    required ScrollController scrollController,
    required double nowOffset,
    required double inViewMargin,
  }) {}

  @override
  Future<void> goToNow({
    Duration duration = Duration.zero,
    Curve curve = Curves.easeInOut,
  }) async {}

  @override
  void reset() {}
}
