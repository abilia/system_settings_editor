import 'dart:io';

import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/tts/tts_handler.dart';
import 'package:test/fake.dart';
import 'fake_client.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/storage/all.dart';

class FakeUserRepository extends Fake implements UserRepository {
  @override
  String get baseUrl => 'fake.url';
  @override
  Future<void> persistLoginInfo(LoginInfo token) => Future.value();
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
  String language = 'en';

  @override
  Future setLanguage(String language) async {}

  @override
  Future setAlwaysUse24HourFormat(bool alwaysUse24HourFormat) async {}
  @override
  bool get alwaysUse24HourFormat => true;
}

class FakeLoginDb extends Fake implements LoginDb {
  @override
  String? getToken() => Fakes.token;
}

class FakeUserDb extends Fake implements UserDb {}

class FakeLicenseDb extends Fake implements LicenseDb {
  @override
  Future persistLicenses(List<License> licenses) => Future.value();
  @override
  List<License> getLicenses() => [
        License(
          id: 123,
          key: 'licenseKey',
          product: memoplannerLicenseName,
          endTime: DateTime(3333),
        ),
      ];
}

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
}

class FakeSortableDb extends Fake implements SortableDb {
  @override
  Future<Iterable<Sortable<SortableData>>> getAllNonDeleted() => Future.value([
        Sortable.createNew(
          data: const ImageArchiveData(myPhotos: true),
          fixed: true,
        ),
        Sortable.createNew(
          data: const ImageArchiveData(upload: true),
          fixed: true,
        ),
      ]);

  @override
  Future<bool> insertAndAddDirty(Iterable<Sortable> data) => Future.value(true);

  @override
  Future<Iterable<DbModel<Sortable>>> getAllDirty() =>
      Future.value(<DbModel<Sortable>>[]);

  @override
  Future<int> getLastRevision() => Future.value(0);
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
}

class FakeDatabase extends Fake implements Database {
  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql,
          [List<Object?>? arguments]) =>
      Future.value([]);
  @override
  Batch batch() => FakeBatch();

  @override
  Future<List<Map<String, Object?>>> query(String table,
          {bool? distinct,
          List<String>? columns,
          String? where,
          List<Object?>? whereArgs,
          String? groupBy,
          String? having,
          String? orderBy,
          int? limit,
          int? offset}) =>
      Future.value([]);

  @override
  Future<int> insert(String table, Map<String, Object?> values,
          {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) =>
      Future.value(values.length);
}

class FakeBatch extends Fake implements Batch {
  @override
  Future<List<Object?>> commit(
          {bool? exclusive, bool? noResult, bool? continueOnError}) =>
      Future.value([]);
  @override
  void delete(String table, {String? where, List<Object?>? whereArgs}) {}
}

class FakeGenericRepository extends Fake implements GenericRepository {
  @override
  Future<bool> synchronize() => Future.value(true);
}

class FakeActivityRepository extends Fake implements ActivityRepository {
  @override
  Future<bool> synchronize() => Future.value(true);

  @override
  Future<Iterable<Activity>> allBetween(DateTime start, DateTime end) =>
      Future.value([]);
}

class FakeFileStorage extends Fake implements FileStorage {
  @override
  File getFile(String id) => FakeFile('$id.mp3');
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

class FakeDeviceDb extends Fake implements DeviceDb {
  @override
  Future<String> getClientId() async {
    return 'clientId';
  }

  @override
  String get serialId => 'serialId';

  @override
  bool get startGuideCompleted => true;
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