import 'package:mockito/mockito.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';

class FakeUserRepository extends Fake implements UserRepository {
  @override
  String get baseUrl => 'fake.url';
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
  @override
  Future setAlwaysUse24HourFormat(bool alwaysUse24HourFormat) async {}
}

class FakeTokenDb extends Fake implements TokenDb {}

class FakeUserDb extends Fake implements UserDb {}

class FakeUserFileDb extends Fake implements UserFileDb {
  @override
  Future<Iterable<UserFile>> getMissingFiles({int? limit}) => Future.value([]);
  @override
  Future<Iterable<UserFile>> getAllLoadedFiles() => Future.value([]);
  @override
  Future<int> getLastRevision() => Future.value(0);
  @override
  Future insert(Iterable<DbModel<UserFile>> dataModels) => Future.value();
}

class FakeSortableDb extends Fake implements SortableDb {
  @override
  Future<Iterable<Sortable<SortableData>>> getAllNonDeleted() =>
      Future.value([]);
}

class FakeGenericDb extends Fake implements GenericDb {
  @override
  Future<Iterable<Generic<GenericData>>> getAllNonDeletedMaxRevision() =>
      Future.value([]);
}

class FakeActivityDb extends Fake implements ActivityDb {
  @override
  Future<int> getLastRevision() => Future.value(0);
  @override
  Future<Iterable<Activity>> getAllNonDeleted() => Future.value([]);
}

class FakeDatabase extends Fake implements Database {
  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql,
          [List<Object?>? arguments]) =>
      Future.value([]);
  @override
  Batch batch() => FakeBatch();
}

class FakeBatch extends Fake implements Batch {
  @override
  Future<List<Object?>> commit(
          {bool? exclusive, bool? noResult, bool? continueOnError}) =>
      Future.value([]);
  @override
  void delete(String table, {String? where, List<Object?>? whereArgs}) {}
}

class FakeGenericRepository extends Fake implements GenericRepository {}

class FakeFileStorage extends Fake implements FileStorage {}

class FakeUserFileRepository extends Fake implements UserFileRepository {}

class FakeFirebasePushService extends Fake implements FirebasePushService {
  @override
  Future<String?> initPushToken() => Future.value('fakeToken');
}
