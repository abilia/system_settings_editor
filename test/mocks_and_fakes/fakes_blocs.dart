import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import 'fake_db_and_repository.dart';

class FakePushBloc extends Fake implements PushBloc {
  @override
  Stream<PushState> get stream => Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeSyncBloc extends Fake implements SyncBloc {
  @override
  Stream<SyncState> get stream => Stream.empty();
  @override
  void add(SyncEvent event) {}
  @override
  Future<void> close() async {}
}

class FakeAuthenticationBloc extends Fake implements AuthenticationBloc {
  @override
  Stream<AuthenticationState> get stream => Stream.empty();
  @override
  AuthenticationState get state =>
      Authenticated(token: '', userId: 1, userRepository: FakeUserRepository());
  @override
  Future<void> close() async {}
}

class FakeSortableBloc extends Fake implements SortableBloc {
  @override
  Stream<SortableState> get stream => Stream.empty();
  @override
  SortableState get state => SortablesNotLoaded();
  @override
  Future<void> close() async {}
}

class FakeGenericBloc extends Fake implements GenericBloc {
  @override
  Stream<GenericState> get stream => Stream.empty();
  @override
  void add(GenericEvent event) {}
  @override
  Future<void> close() async {}
}

class FakeActivitiesBloc extends Fake implements ActivitiesBloc {
  @override
  Stream<ActivitiesState> get stream => Stream.empty();
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
  Stream<MemoplannerSettingsState> get stream => Stream.empty();
  @override
  MemoplannerSettingsState get state =>
      MemoplannerSettingsLoaded(MemoplannerSettings());
  @override
  Future<void> close() async {}
}

class FakeTimepillarBloc extends Fake implements TimepillarBloc {
  @override
  Stream<TimepillarState> get stream => Stream.empty();
  @override
  TimepillarState get state => TimepillarState(
        TimepillarInterval(
          start: DateTime.now(),
          end: DateTime.now(),
        ),
        1,
      );
  @override
  Future<void> close() async {}
}

class FakeSettingsBloc extends Fake implements SettingsBloc {
  @override
  Stream<SettingsState> get stream => Stream.empty();
}

class FakeUserFileBloc extends Fake implements UserFileBloc {
  @override
  Stream<UserFileState> get stream => Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeDayPickerBloc extends Fake implements DayPickerBloc {
  @override
  Stream<DayPickerState> get stream => Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeDayActivitiesBloc extends Fake implements DayActivitiesBloc {
  @override
  Stream<DayActivitiesState> get stream => Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeActivitiesOccasionBloc extends Fake
    implements ActivitiesOccasionBloc {
  @override
  Stream<ActivitiesOccasionState> get stream => Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeAlarmBloc extends Fake implements AlarmBloc {
  @override
  Stream<AlarmStateBase> get stream => Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeNotificationBloc extends Fake implements NotificationBloc {
  @override
  Stream<AlarmStateBase> get stream => Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeCalendarViewBloc extends Fake implements CalendarViewBloc {
  @override
  Stream<CalendarViewState> get stream => Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeLicenseBloc extends Fake implements LicenseBloc {
  @override
  Stream<LicenseState> get stream => Stream.empty();
  @override
  Future<void> close() async {}
}
