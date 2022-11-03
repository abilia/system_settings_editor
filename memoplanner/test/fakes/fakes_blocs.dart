import 'package:mocktail/mocktail.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';

import 'all.dart';

class FakePushCubit extends Fake implements PushCubit {
  @override
  Stream<RemoteMessage> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeSyncBloc extends Fake implements SyncBloc {
  @override
  Stream<SyncPerformed> get stream => const Stream.empty();
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
  late final ActivityRepository activityRepository;
  FakeActivitiesBloc({ActivityRepository? activityRepository}) {
    this.activityRepository = activityRepository ?? FakeActivityRepository();
  }
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

class FakeSessionCubit extends Fake implements SessionCubit {
  @override
  Stream<bool> get stream => const Stream.empty();

  @override
  bool get state => false;

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
