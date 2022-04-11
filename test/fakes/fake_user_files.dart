import 'package:seagull/models/all.dart';

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
