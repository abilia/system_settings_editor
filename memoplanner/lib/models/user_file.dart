import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

class UserFile extends DataModel {
  static const imageEndings = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff'];
  final String sha1, md5, path;
  final String? contentType;
  final int fileSize;
  final bool fileLoaded;

  const UserFile({
    required super.id,
    required super.deleted,
    required this.sha1,
    required this.md5,
    required this.path,
    required this.fileSize,
    required this.fileLoaded,
    this.contentType,
  });

  UserFile setLoaded() => UserFile(
        id: id,
        sha1: sha1,
        md5: md5,
        path: path,
        fileSize: fileSize,
        deleted: deleted,
        fileLoaded: true,
      );

  @override
  List<Object?> get props =>
      [id, sha1, md5, path, contentType, fileSize, deleted, fileLoaded];

  @override
  String toString() => 'UserFile: { ${props.join(', ')} }';

  @override
  DbUserFile wrapWithDbModel({int revision = 0, int dirty = 0}) => DbUserFile._(
        userFile: this,
        dirty: dirty,
        revision: revision,
      );

  bool get isImage =>
      (contentType?.toLowerCase().startsWith('image') ?? false) ||
      imageEndings.contains(path.toLowerCase().split('.').last);
}

class DbUserFile extends DbModel<UserFile> {
  UserFile get userFile => model;

  const DbUserFile._({
    required int dirty,
    required int revision,
    required UserFile userFile,
  }) : super(dirty: dirty, revision: revision, model: userFile);

  static DbUserFile fromDbMap(Map<String, dynamic> dbRow) => DbUserFile._(
      userFile: UserFile(
        id: dbRow['id'],
        sha1: dbRow['sha1'],
        md5: dbRow['md5'],
        path: dbRow['path'] ?? '',
        contentType: dbRow['content_type'],
        fileSize: dbRow['file_size'],
        deleted: dbRow['deleted'] == 1,
        fileLoaded: dbRow['file_loaded'] == 1,
      ),
      revision: dbRow['revision'],
      dirty: dbRow['dirty']);

  static DbUserFile fromJson(Map<String, dynamic> json) => DbUserFile._(
        userFile: UserFile(
          id: json['id'],
          sha1: json['sha1Hex'],
          md5: json['md5Hex'],
          path: json['path'] ?? '',
          contentType: json['contentType'],
          fileSize: json['size'],
          deleted: json['deleted'] ?? false,
          fileLoaded: json['fileLoaded'] ?? false,
        ),
        revision: json['revision'],
        dirty: 0,
      );

  @override
  DbUserFile copyWith({
    int? revision,
    int? dirty,
  }) =>
      DbUserFile._(
        userFile: userFile,
        revision: revision ?? this.revision,
        dirty: dirty ?? this.dirty,
      );

  @override
  List<Object> get props => [dirty, revision, userFile];

  @override
  Map<String, dynamic> toMapForDb() => {
        'id': userFile.id,
        'sha1': userFile.sha1,
        'md5': userFile.md5,
        'path': userFile.path,
        'content_type': userFile.contentType,
        'file_size': userFile.fileSize,
        'deleted': userFile.deleted ? 1 : 0,
        'file_loaded': userFile.fileLoaded ? 1 : 0,
        'revision': revision,
        'dirty': dirty,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': userFile.id,
        'sha1Hex': userFile.sha1.nullOnEmpty(),
        'md5Hex': userFile.md5.nullOnEmpty(),
        'path': userFile.path.nullOnEmpty(),
        'contentType': userFile.contentType,
        'size': userFile.fileSize,
        'deleted': userFile.deleted,
        'fileLoaded': userFile.fileLoaded,
        'revision': revision,
      };
}
