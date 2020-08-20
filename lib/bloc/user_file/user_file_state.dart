part of 'user_file_bloc.dart';

abstract class UserFileState extends Equatable {
  const UserFileState();
  @override
  List<Object> get props => [];

  UserFile getLoadedByIdOrPath(String fileId, String filePath);
}

class UserFilesLoaded extends UserFileState {
  final Iterable<UserFile> userFiles;

  const UserFilesLoaded(this.userFiles);

  @override
  List<Object> get props => [userFiles];

  @override
  String toString() => 'UserFilesLoaded { userFiles: $userFiles }';

  @override
  UserFile getLoadedByIdOrPath(String fileId, String filePath) {
    return userFiles.firstWhere(
        (f) => (f.id == fileId || f.path == filePath) && f.fileLoaded,
        orElse: () => null);
  }
}

class UserFilesNotLoaded extends UserFileState {
  @override
  UserFile getLoadedByIdOrPath(String fileId, String filePath) {
    return null;
  }
}
