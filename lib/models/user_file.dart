import 'package:meta/meta.dart';
import 'package:seagull/db/all.dart';

class UserFile extends DataModel {
  final String id, sha1, path, contentType;
  final int fileSize;
  final bool deleted;

  UserFile({
    @required this.id,
    @required this.sha1,
    @required this.path,
    @required this.contentType,
    @required this.fileSize,
    @required this.deleted,
  })  : assert(id != null),
        super(id);

  @override
  List<Object> get props => [id, sha1, path, contentType, fileSize, deleted];

  @override
  DbModel<DataModel> wrapWithDbModel({int revision = 0, int dirty = 0}) =>
      DbUserFile._(
        userFile: this,
        dirty: dirty,
        revision: revision,
      );
}

class DbUserFile extends DbModel<UserFile> {
  final UserFile userFile;

  const DbUserFile._({int dirty, int revision, this.userFile})
      : super(dirty: dirty, revision: revision, model: userFile);

  @override
  DbModel<UserFile> copyWith({int revision, int dirty}) {
    // TODO: implement copyWith
    return null;
  }

  @override
  // TODO: implement props
  List<Object> get props => [dirty, revision, userFile];

  @override
  Map<String, dynamic> toMapForDb() => {
        'id': userFile.id,
      };
}
