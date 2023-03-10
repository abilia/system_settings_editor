import 'dart:io';

import 'package:auth/auth.dart';
import 'package:calendar_repository/calendar_db.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/tts/tts_handler.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:test/fake.dart';
import '../test_helpers/default_sortables.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/storage/all.dart';

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
  bool get keepScreenOnWhileCharging => false;
  @override
  Future setKeepScreenOnWhileCharging(bool keepScreenOnWhileCharging) async {}
  @override
  bool get keepScreenOnWhileChargingSet => false;

  @override
  String language = 'en';

  @override
  Future setLanguage(String language) async {}

  @override
  Future setAlwaysUse24HourFormat(bool alwaysUse24HourFormat) async {}
  @override
  bool get alwaysUse24HourFormat => true;
}

class FakeUserDb extends Fake implements UserDb {}

class FakeCalendarDb extends Fake implements CalendarDb {}

class FakeUserFileDb extends Fake implements UserFileDb {
  @override
  Future<Iterable<UserFile>> getMissingFiles({int? limit}) => Future.value([]);
  @override
  Future<Iterable<UserFile>> getAllLoadedFiles() => Future.value([]);
  @override
  Future<Iterable<DbModel<UserFile>>> getAllDirty() => Future.value([]);
  @override
  Future<int> getLastRevision() => Future.value(0);
  @override
  Future insert(Iterable<DbModel<UserFile>> dataModels) => Future.value();
  @override
  Future<int> countAllDirty() => Future.value(0);
}

class FakeSortableDb extends Fake implements SortableDb {
  @override
  Future<Iterable<Sortable<SortableData>>> getAllNonDeleted() =>
      Future.value(defaultSortables);

  @override
  Future<bool> insertAndAddDirty(Iterable<Sortable> data) => Future.value(true);

  @override
  Future<Iterable<DbModel<Sortable>>> getAllDirty() =>
      Future.value(<DbModel<Sortable>>[]);

  @override
  Future<int> getLastRevision() => Future.value(0);

  @override
  Future<int> countAllDirty() => Future.value(0);
}

class FakeGenericDb extends Fake implements GenericDb {
  @override
  Future<Iterable<Generic<GenericData>>> getAllNonDeletedMaxRevision() =>
      Future.value([]);

  @override
  Future<bool> insertAndAddDirty(Iterable<Generic> data) => Future.value(true);

  @override
  Future<Iterable<DbModel<Generic<GenericData>>>> getAllDirty() =>
      Future.value(const Iterable.empty());
  @override
  Future<int> getLastRevision() => Future.value(0);

  @override
  Future<int> countAllDirty() => Future.value(0);
}

class FakeSessionsDb extends Fake implements SessionsDb {
  @override
  bool get hasMP4Session => false;

  @override
  Future<void> setHasMP4Session(bool session) async {}
}

class FakeActivityDb extends Fake implements ActivityDb {
  @override
  Future<int> getLastRevision() => Future.value(0);
  @override
  Future<Iterable<Activity>> getAllNonDeleted() => Future.value([]);
  @override
  Future<Iterable<Activity>> getAllAfter(DateTime time) => Future.value([]);
  @override
  Future<Iterable<Activity>> getAllBetween(DateTime start, DateTime end) =>
      Future.value([]);
  @override
  Future<Iterable<DbModel<Activity>>> getAllDirty() => Future.value([]);
  @override
  Future<int> countAllDirty() => Future.value(0);
}

class FakeGenericRepository extends Fake implements GenericRepository {
  @override
  Future<bool> synchronize() => Future.value(true);
}

class FakeActivityRepository extends Fake implements ActivityRepository {
  @override
  Future<bool> synchronize() => Future.value(true);

  @override
  Future<bool> save(Iterable<Activity> data) => Future.value(true);

  @override
  Future<Iterable<Activity>> allBetween(DateTime start, DateTime end) =>
      Future.value([]);
}

class FakeFileStorage extends Fake implements FileStorage {
  @override
  File getFile(String id) => FakeFile('$id.mp3');

  @override
  String get dir => '';
}

class FakeFile extends Fake implements File {
  FakeFile(this.path);
  @override
  final String path;
  @override
  Future<bool> exists() => Future.value(true);
}

class FakeUserFileRepository extends Fake implements UserFileRepository {}

class FakeSortableRepository extends Fake implements SortableRepository {}

class FakeFirebasePushService extends Fake implements FirebasePushService {
  @override
  Future<String?> initPushToken() => Future.value('fakeToken');
}

class FakeVoiceDb extends Fake implements VoiceDb {
  @override
  Future setVoice(String voice) async {}

  @override
  bool get textToSpeech => true;

  @override
  bool get speakEveryWord => false;

  @override
  String get voice => '';

  @override
  double get speechRate => 100;
}

class FakeTtsHandler extends Fake implements TtsInterface {
  @override
  Future<dynamic> speak(String text) async {}

  @override
  Future<dynamic> stop() async {}

  @override
  Future<dynamic> pause() async {}

  @override
  Future<dynamic> setVoice(Map<String, String> voice) async {}

  @override
  Future<dynamic> setSpeechRate(double speechRate) async {}

  @override
  Future<List<Object?>> get availableVoices => Future.value(List.empty());
}

class FakeLastSyncDb extends Fake implements LastSyncDb {
  int? fakeLastSync;

  @override
  Future<void> setSyncTime(DateTime syncTime) async {
    fakeLastSync = syncTime.millisecondsSinceEpoch;
  }

  @override
  DateTime? getLastSyncTime() => fakeLastSync.fromMillisecondsSinceEpoch();
}

class FakeMyAbiliaConnection extends Fake implements MyAbiliaConnection {
  @override
  Future<bool> hasConnection() async => true;
}
