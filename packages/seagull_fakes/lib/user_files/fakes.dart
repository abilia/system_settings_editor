import 'package:file_storage/file_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository_base/repository_base.dart';
import 'package:user_files/user_files.dart';

class MockFileStorage extends Mock implements FileStorage {
  @override
  String get dir => '';
}

class MockUserFileRepository extends Mock implements UserFileRepository {}

class FakeUserFileBloc extends Fake implements UserFileBloc {
  @override
  Stream<UserFileState> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

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

class FakeUserFile {
  static UserFile createNew({
    String? contentType,
    bool? deleted,
    int? fileSize,
    String? id,
    String? md5,
    String? path,
    String? sha1,
  }) {
    return UserFile(
      contentType: contentType ?? 'contentType',
      deleted: deleted ?? false,
      fileSize: fileSize ?? 1,
      id: id ?? 'id',
      md5: md5 ?? 'md5',
      path: path ?? 'path',
      sha1: sha1 ?? 'sha1',
      fileLoaded: false,
    );
  }

  static const onePixelPng =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==';
}

class FakeUserFileRepository extends Fake implements UserFileRepository {}

class MockUserFileDb extends Mock implements UserFileDb {}
