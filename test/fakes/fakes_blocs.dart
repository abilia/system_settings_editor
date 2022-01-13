import 'package:mocktail/mocktail.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import 'fake_db_and_repository.dart';

class FakePushBloc extends Fake implements PushBloc {
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
  AuthenticationState get state =>
      Authenticated(token: '', userId: 1, userRepository: FakeUserRepository());
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

class FakeGenericBloc extends Fake implements GenericBloc {
  @override
  Stream<GenericState> get stream => const Stream.empty();
  @override
  void add(GenericEvent event) {}
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

class FaketimepillarCubit extends Fake implements TimepillarCubit {
  @override
  Stream<TimepillarState> get stream => const Stream.empty();

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
  Stream<SettingsState> get stream => const Stream.empty();
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
  Stream<DayEventsState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeAlarmCubit extends Fake implements AlarmCubit {
  @override
  Stream<NotificationAlarm?> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeNotificationBloc extends Fake implements NotificationCubit {
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

class FakeLicenseBloc extends Fake implements LicenseBloc {
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
