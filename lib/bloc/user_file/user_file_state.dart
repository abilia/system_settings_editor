part of 'user_file_bloc.dart';

abstract class UserFileState extends Equatable {
  const UserFileState(this.userFiles, this._tempFiles);
  @override
  List<Object> get props => [userFiles, _tempFiles];

  final Iterable<UserFile> userFiles;

  final Map<String, File> _tempFiles;

  File getLoadedByIdOrPath(
    String fileId,
    String filePath,
    FileStorage fileStorage, {
    @required ImageSize imageSize,
  }) {
    final userFile = userFiles.firstWhere(
        (f) => (f.id == fileId || f.path == filePath) && f.fileLoaded,
        orElse: () => null);
    return userFile != null
        ? imageSize == ImageSize.THUMB
            ? fileStorage.getImageThumb(ImageThumb(id: userFile.id))
            : fileStorage.getFile(userFile.id)
        : _tempFiles[fileId];
  }

  UserFileState addTempFile(String id, File file);
  UserFileState add(UserFile userFile);
}

class UserFilesLoaded extends UserFileState {
  const UserFilesLoaded(Iterable<UserFile> userFiles,
      [Map<String, File> tempFiles])
      : super(userFiles, tempFiles ?? const {});

  @override
  String toString() =>
      'UserFlesLoaded { userFiles: $userFiles, tempFiles: $_tempFiles }';

  @override
  UserFileState addTempFile(String id, File file) =>
      UserFilesLoaded(userFiles, Map.from(_tempFiles)..[id] = file);

  @override
  UserFileState add(UserFile userFile) => UserFilesLoaded(
        [...userFiles, userFile],
        Map.from(_tempFiles)..remove(userFile.id),
      );
}

class UserFilesNotLoaded extends UserFileState {
  const UserFilesNotLoaded([Map<String, File> tempFiles])
      : super(const <UserFile>[], tempFiles ?? const {});
  @override
  String toString() => 'UserFilesNotLoaded { tempFiles: $_tempFiles } ';

  @override
  UserFilesNotLoaded addTempFile(String id, File file) =>
      UserFilesNotLoaded(Map.from(_tempFiles)..[id] = file);

  @override
  UserFileState add(_) => this;
}
