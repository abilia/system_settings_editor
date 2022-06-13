import 'package:mocktail/mocktail.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class FakePushCubit extends Fake implements PushCubit {
  @override
  Stream<PushState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeSyncBloc extends Fake implements SyncBloc {
  @override
  Stream<dynamic> get stream => const Stream.empty();
  @override
  void add(SyncEvent event) {}
  @override
  Future<void> close() async {}
}

class FakeAuthenticationBloc extends Fake implements AuthenticationBloc {
  @override
  Stream<AuthenticationState> get stream => const Stream.empty();
  @override
  AuthenticationState get state => const Authenticated(userId: 1);
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
  Stream<ActivitiesState> get stream => const Stream.empty();
  @override
  ActivitiesState get state => ActivitiesNotLoaded();
  @override
  void add(ActivitiesEvent event) {}
  @override
  Future<void> close() async {}
}

class FakeMemoplannerSettingsBloc extends Fake
    implements MemoplannerSettingBloc {
  @override
  Stream<MemoplannerSettingsState> get stream => const Stream.empty();
  @override
  MemoplannerSettingsState get state =>
      const MemoplannerSettingsLoaded(MemoplannerSettings());
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

class FakeSettingsCubit extends Fake implements SettingsCubit {
  @override
  Stream<SettingsState> get stream => const Stream.empty();
  @override
  SettingsState get state => const SettingsState(textToSpeech: false);
  @override
  Future<void> close() async {}
}

class FakeUserFileCubit extends Fake implements UserFileCubit {
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
  Stream<ActivityAlarm?> get stream => const Stream.empty();
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
  SpeechSettingsState get state => const SpeechSettingsState();

  @override
  Future<void> close() async {}
}

class FakeVoicesCubit extends Fake implements VoicesCubit {
  @override
  Stream<VoicesState> get stream => const Stream.empty();

  @override
  VoicesState get state => const VoicesState();

  @override
  Future<void> close() async {}
}
