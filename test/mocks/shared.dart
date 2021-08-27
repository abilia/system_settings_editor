import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';

@GenerateMocks([
  ActivityRepository,
  UserRepository,
  SortableRepository,
  UserFileRepository,
  FirebasePushService,
  FileStorage,
  FlutterLocalNotificationsPlugin,
  ActivitiesBloc,
  SyncBloc,
  PushBloc,
  GenericBloc,
  MemoplannerSettingBloc,
  ScrollController,
  MultipartRequestBuilder,
  MultipartRequest,
  // ScrollPosition,
  Database,
  BaseClient,
  SettingsDb,
  ActivityDb,
  UserFileDb,
  UserDb,
  TokenDb,
  LicenseDb,
  Notification,
])
class Notification {
  Future mockCancelAll() => Future.value();
}

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

class FakeUserRepository extends Fake implements UserRepository {
  @override
  String get baseUrl => 'fake.url';
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

class FakeSettingsDb extends Fake implements SettingsDb {
  @override
  bool get leftCategoryExpanded => true;
  @override
  bool get rightCategoryExpanded => true;
  @override
  Future setLeftCategoryExpanded(bool expanded) async {}
  @override
  Future setRightCategoryExpanded(bool expanded) async {}
  @override
  bool get textToSpeech => true;
}

class FakeUserFileDb extends Fake implements UserFileDb {
  @override
  Future<Iterable<UserFile>> getMissingFiles({int? limit}) => Future.value([]);
  @override
  Future<Iterable<UserFile>> getAllLoadedFiles() => Future.value([]);
}

class FakeDatabase extends Fake implements Database {
  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql,
          [List<Object?>? arguments]) =>
      Future.value([]);
}

class FakeSortableBloc extends Fake implements SortableBloc {
  @override
  Stream<SortableState> get stream => Stream.empty();
  @override
  SortableState get state => SortablesNotLoaded();
  @override
  Future<void> close() async {}
}

class FakeGenericRepository extends Fake implements GenericRepository {}

class FakeFileStorage extends Fake implements FileStorage {}

class FakeUserFileRepository extends Fake implements UserFileRepository {}

class FakeSettingsBloc extends Fake implements SettingsBloc {}

class FakeUserFileBloc extends Fake implements UserFileBloc {}

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
