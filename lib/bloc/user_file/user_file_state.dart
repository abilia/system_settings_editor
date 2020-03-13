part of 'user_file_bloc.dart';

abstract class UserFileState extends Equatable {
  const UserFileState();
  @override
  List<Object> get props => [];
}

class UserFilesLoaded extends UserFileState {
  final Iterable<UserFile> userFiles;

  const UserFilesLoaded(this.userFiles);

  @override
  List<Object> get props => [userFiles];

  @override
  String toString() => 'UserFilesLoaded { userFiles: $userFiles }';
}

class UserFilesNotLoaded extends UserFileState {}
