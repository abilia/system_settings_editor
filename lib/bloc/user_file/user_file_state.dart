part of 'user_file_bloc.dart';

abstract class UserFileState extends Equatable {
  const UserFileState(this.userFiles);
  @override
  List<Object> get props => [userFiles];

  final Iterable<UserFile> userFiles;

  UserFile getLoadedByIdOrPath(String fileId, String filePath) =>
      userFiles.firstWhere(
          (f) => (f.id == fileId || f.path == filePath) && f.fileLoaded,
          orElse: () => null);
}

class UserFilesLoaded extends UserFileState {
  const UserFilesLoaded(Iterable<UserFile> userFiles) : super(userFiles);

  @override
  String toString() => 'UserFlesLoaded { userFiles: $userFiles }';
}

class UserFilesNotLoaded extends UserFileState {
  const UserFilesNotLoaded() : super(const <UserFile>[]);
  @override
  String toString() => 'UserFilesNotLoaded ';
  @override
  UserFile getLoadedByIdOrPath(String fileId, String filePath) => null;
}
